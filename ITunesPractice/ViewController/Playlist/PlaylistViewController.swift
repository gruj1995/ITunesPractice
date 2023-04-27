//
//  PlayListViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/12.
//

import Combine
import SnapKit
import UIKit

// MARK: - PlaylistViewController

/**
  - 沒網路時，網路音樂文字變灰色且不可選擇，本地音樂維持白字可選擇
  - tableView 滑動到待播清單時：
        上滑隱藏播放器; 下滑顯示播放器
    其他時候
        上滑顯示播放器; 下滑隱藏播放器
  - tableView header 切換時有小震動
  - cell 拖曳排序功能
 */

class PlaylistViewController: UIViewController {
    // MARK: Lifecycle

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Internal

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(TrackCell.self, forCellReuseIdentifier: TrackCell.reuseIdentifier)
        tableView.register(PlayListHeaderView.self, forHeaderFooterViewReuseIdentifier: PlayListHeaderView.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
//        // 是否允許拖動操作(要放在以下兩者前)
//        tableView.dragInteractionEnabled = true
//        // 拖放事件
//        tableView.dragDelegate = self
//        tableView.dropDelegate = self
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    // MARK: Private

    private let viewModel: PlaylistViewModel = .init()
    private let playerContainerViewHeight = Constants.screenHeight * 0.35
    private let cellHeight: CGFloat = 60

    private var cancellables: Set<AnyCancellable> = .init()
    private var lastVelocityYSign = 0
    private var lastContentOffset: CGFloat = 0
    private var playerContainerViewBottom: Constraint?
    private var animator: UIViewPropertyAnimator!

    private lazy var playerContainerView: UIView = .init()

    private lazy var coverImageView: UIImageView = .coverImageView()
    private lazy var coverImageContainerView: UIView = {
        let view = UIView.emptyView()
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 7
        return view
    }()

    private var currentTrackView: CurrentTrackView = CurrentTrackView()

    // 音樂播放器頁
    private lazy var playerVC: PlaylistPlayerViewController = {
        let vc = UIStoryboard(name: "PlayListPlayer", bundle: nil).instantiateViewController(withIdentifier: PlaylistPlayerViewController.storyboardIdentifier) as! PlaylistPlayerViewController
        return vc
    }()

    private lazy var gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        // 顏色起始點與終點
//        gradient.locations = [0.3, 0.7, 1]
        view.layer.insertSublayer(gradient, at: 0)
        return gradient
    }()

    private var isPlayerHidden: Bool = false {
        didSet {
            let inset = isPlayerHidden ? playerHiddenInset : 0
            playerContainerViewBottom?.update(inset: inset)
        }
    }

    private var playerHiddenInset: CGFloat {
        // 加號後的值是 playerContainerView 隱藏時上方要露出的高度
        -playerContainerViewHeight + 5
    }

    // MARK: Setup

    private func setupUI() {
        setupLayout()
    }

    private func setupLayout() {
        let topViewHeight = 62
        view.addSubview(currentTrackView)
        currentTrackView.snp.makeConstraints { make in
            // 與頂部的距離和 fpc.surfaceView.grabberHandlePadding 有關
            make.top.equalToSuperview().offset(50)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(topViewHeight)
        }

        coverImageContainerView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(coverImageContainerView)
        coverImageContainerView.snp.makeConstraints { make in
            // 與頂部的距離和 fpc.surfaceView.grabberHandlePadding 有關
            make.top.equalToSuperview().offset(50)
            make.leading.equalToSuperview().inset(20)
            make.height.width.equalTo(topViewHeight)
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(currentTrackView.snp.bottom)
            make.bottom.leading.trailing.equalToSuperview()
        }

        view.addSubview(playerContainerView)
        playerContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(playerContainerViewHeight)
            playerContainerViewBottom = make.bottom.equalToSuperview().constraint
        }

        addChild(playerVC)
        playerContainerView.addSubview(playerVC.view)
        playerVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        playerVC.didMove(toParent: self)
    }

    private func bindViewModel() {
        viewModel.currentTrackIndexPublisher
            .receive(on: RunLoop.main)
            .removeDuplicates() // 為什麼會觸發多次？
            .sink { [weak self] _ in
                guard let self else { return }
                self.viewModel.changeImage()
                self.updateCurrentTrackView()
                self.updateTableView()
            }.store(in: &cancellables)

        viewModel.colorsPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .removeDuplicates() // 為什麼會觸發多次？
            .sink { [weak self] _ in
                self?.updateGradientLayers()
            }.store(in: &cancellables)

        UserDefaults.$playlist
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .combineLatest(UserDefaults.$playedTracks)
            .sink { [weak self] _ in
                self?.updateCurrentTrackView()
                self?.updateTableView()
            }.store(in: &cancellables)

        NetworkMonitor.shared.$isConnected
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.updateTableView()
            }.store(in: &cancellables)
    }

    // MARK: Update

    private func updateCurrentTrackView() {
        let track = viewModel.currentTrack

        // 更新左側圖片
        let url = track?.getArtworkImageWithSize(size: .square800)
        coverImageView.loadCoverImage(with: url)
        let showDefaultImage = coverImageView.image == DefaultTrack.coverImage
        coverImageView.backgroundColor = showDefaultImage ? UIColor.appColor(.gray3) : .clear
        coverImageContainerView.layer.shadowColor = showDefaultImage ? UIColor.clear.cgColor : UIColor.black.cgColor

        // 更新歌曲資訊
        let trackName = track?.trackName ?? DefaultTrack.trackName
        let menu = ContextMenuManager.shared.createTrackMenu(track, canEditPlayList: false)
        currentTrackView.configure(trackName: trackName, artistName: track?.artistName, menu: menu)
    }

    private func updateTableView() {
        // 在 viewDidLoad 時使用 Combine 綁定資料，可能會導致 UITableView 在還未加入視圖階層的情況下被 layoutIfNeeded 呼叫，從而觸發出現警告的問題，所以這邊加上判斷避免此狀況發生。
        guard tableView.isVisible else { return }
        // 要放在 tableView.reloadData() 前
        tableView.tableFooterView = nil
        tableView.reloadData()
        hideCellsIfTouchingHeader()
    }

    private func updateGradientLayers() {
        let cgColors = viewModel.colors.map { $0.cgColor }
        // 更新主要漸層色
        gradient.updateColors(with: cgColors)

        // 取得漸層的底部三分之一位置的顏色，作為交界色
        guard let bottomThirdColor = gradient.color(atPosition: 0.45)?.cgColor else {
            return
        }
        // 建立包含三種顏色的漸層色陣列，用於更新 playerVC 的漸層色
        let playerVCColors = [
            bottomThirdColor.copy(alpha: 0.05)!,
            bottomThirdColor,
            cgColors[2]
        ]
        // 更新 playerVC 的漸層色
        playerVC.gradient.updateColors(with: playerVCColors)
        playerVC.advancedButtonSelectedColor = viewModel.colors.last
    }

    private func handleError(_ error: Error) {
        tableView.tableFooterView = nil
        Utils.toast(error.localizedDescription, at: .center)
    }

    private func hideCellsIfTouchingHeader() {
        // 隱藏 cell 與 header 接觸的部分
        for cell in tableView.visibleCells {
            cell.sectionHeaderMask(delegate: self)
        }
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension PlaylistViewController: UITableViewDataSource, UITableViewDelegate {
    // 滑動時觸發
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height

        if viewModel.totalCount == 0 {
            // 沒有資料時顯示播放器
            isPlayerHidden = false
        } else if contentOffset >= contentHeight - frameHeight {
            // 滑到最底部了，顯示播放器
            isPlayerHidden = false
        } else if contentOffset <= 0 {
            // 滑到最上方了，隱藏播放器
            isPlayerHidden = true
        } else if contentOffset > lastContentOffset {
            // 上滑，隱藏播放器
            isPlayerHidden = true
        } else {
            // 下滑，顯示播放器
            isPlayerHidden = false
        }

        lastContentOffset = contentOffset
        hideCellsIfTouchingHeader()
    }

    // 停止滑動時觸發
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let contentOffset = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height

        if contentOffset <= 0 {
            // 滑到最上方了，隱藏播放器
            isPlayerHidden = true
        } else if contentOffset >= contentHeight - frameHeight {
            // 滑到最底部了，顯示播放器
            isPlayerHidden = false
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.reuseIdentifier) as? TrackCell
        else {
            return UITableViewCell()
        }
        guard let track = viewModel.track(forCellAt: indexPath) else {
            return cell
        }
        cell.configure(artworkUrl: track.artworkUrl100, collectionName: track.collectionName, artistName: track.artistName, trackName: track.trackName)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 解除cell被選中的狀態
        tableView.deselectRow(at: indexPath, animated: true)
        // 更新選中歌曲
        viewModel.setCurrentTrack(forCellAt: indexPath)
        viewModel.play()
    }

    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion { [weak self] in
            let vc = TrackDetailViewController()
            vc.dataSource = self
            self?.dismiss(animated: false) {
                // 由 SearchViewController push
                let topVC = UIApplication.shared.getTopViewController()
                topVC?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    // context menu 的清單
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        viewModel.selectedIndexPath = indexPath
        let track = viewModel.track(forCellAt: indexPath)
        return tableView.createTrackContextMenuConfiguration(indexPath: indexPath, track: track)
    }

    // 解決開啟 context menu 後 cell 出現黑色背景的問題 (因為背景設為 .clear 引起)
    // 參考: https://reurl.cc/b73dgl
    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = viewModel.selectedIndexPath,
              let cell = tableView.cellForRow(at: indexPath)
        else {
            return nil
        }
        let targetedPreview = UITargetedPreview(view: cell)
        targetedPreview.parameters.backgroundColor = .clear
        return targetedPreview
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return tableView.deleteConfiguration { [weak self] in
            self?.viewModel.removeTrack(forCellAt: indexPath)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // 如果是待播清單，隱藏正在播放的項目(也就是清單內第一項)
        if viewModel.isFirstItemInPlaylist(indexPath) {
             cell.contentView.isHidden = true
             cell.accessoryType = .none
             cell.contentView.frame.size.height = 0
             cell.frame.size.height = 0
         }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if viewModel.isFirstItemInPlaylist(indexPath) {
            return CGFloat.leastNormalMagnitude
        }
        return cellHeight
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: PlayListHeaderView.reuseIdentifier) as? PlayListHeaderView else {
            return nil
        }

        if viewModel.isPlayedTracksSection(section) {
            let title = "播放記錄".localizedString()
            header.configure(title: title, subTitle: nil)
            header.onClearButtonTapped = { [weak self] _ in
                self?.viewModel.clearPlayRecords()
            }
        } else {
            let title = "待播清單".localizedString()
            header.configure(title: title, subTitle: nil)

            header.onShuffleButtonTapped = { [weak self] _ in
                guard let self else { return }
                self.viewModel.isShuffleMode.toggle()
                let isSelected = self.viewModel.isShuffleMode
                let tintColor = self.viewModel.headerButtonBgColor
                header.shuffleButton.setRoundCornerButtonAppearance(isSelected: isSelected, tintColor: tintColor)
            }

            header.onInfinityButtonTapped = { [weak self] _ in
                guard let self else { return }
                self.viewModel.isInfinityMode.toggle()
                let isSelected = self.viewModel.isInfinityMode
                let tintColor = self.viewModel.headerButtonBgColor
                let subTitle = isSelected ? "自動播放類似音樂".localizedString() : nil
                header.infinityButton.setRoundCornerButtonAppearance(isSelected: isSelected, tintColor: tintColor)
                header.configure(title: title, subTitle: subTitle)
            }

            header.onRepeatButtonTapped = { [weak self] _ in
                guard let self else { return }
                self.viewModel.repeatMode = self.viewModel.repeatMode.next()
                let isSelected = self.viewModel.repeatMode != .none
                let tintColor = self.viewModel.headerButtonBgColor
                let image = self.viewModel.repeatMode.image
                header.repeatButton.setRoundCornerButtonAppearance(isSelected: isSelected, tintColor: tintColor, image: image)
            }
        }

        return header
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.emptyView()
        // 避免點擊事件被 footer 攔截，因為使用 .plain 樣式的 footer 會擋到 cell
        view.isUserInteractionEnabled = false
        return view
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        playerContainerViewHeight
    }
}

// MARK: TrackDetailViewControllerDatasource

extension PlaylistViewController: TrackDetailViewControllerDatasource {
    func trackId(_ trackDetailViewController: TrackDetailViewController) -> Int? {
        return viewModel.currentTrack?.trackId
    }
}

public extension UITableViewCell {
    func sectionHeaderMask<T: UITableViewDelegate>(delegate: T, systemTopInset: CGFloat = 0) {
        guard let tableView = superview as? UITableView else { return }
        guard let indexPath = tableView.indexPath(for: self) else { return }
        guard let heightForHeader = delegate.tableView?(tableView, heightForHeaderInSection: indexPath.section) else { return }
        let hiddenFrameHeight = tableView.contentOffset.y - frame.origin.y + heightForHeader + tableView.contentInset.top + systemTopInset
        if hiddenFrameHeight >= 0 || hiddenFrameHeight <= frame.size.height {
            mask(margin: Float(hiddenFrameHeight))
        }
    }

    private func mask(margin: Float) {
        layer.mask = visibilityMask(location: margin / Float(frame.size.height))
        layer.masksToBounds = true
    }

    private func visibilityMask(location: Float) -> CAGradientLayer {
        let mask = CAGradientLayer()
        mask.frame = bounds
        mask.colors = [UIColor(white: 1, alpha: 0).cgColor, UIColor(white: 1, alpha: 1).cgColor]
        mask.locations = [NSNumber(value: location), NSNumber(value: location)]
        return mask
    }
}

extension UIView {
    // 參考連結 https://reurl.cc/zAD0pa
    /// cell 碰到 header 或 playerView 時添加遮罩讓碰到的部分隱藏
    func hideWhenScrolling(scrollView: UIScrollView, bottomView view: UIView) {
        let minY = frame.minY
        let maxY = frame.maxY

        // 上方 header view
        let tMaxY = scrollView.contentOffset.y + 60

        // 下方 player view
        let viewMinY = scrollView.convert(view.frame.origin, from: view.superview).y

        if maxY < viewMinY, minY > tMaxY {
            // 如果 cell 和 view 不相交，就移除遮罩
            layer.mask = nil
        } else {
            // 如果 cell 和 view 相交，就設置遮罩隱藏 cell 的部分
            if minY < tMaxY {
                // 往上碰到 header
                let hiddenFrameHeight = scrollView.contentOffset.y + 60 - frame.origin.y
                mask(margin: Float(hiddenFrameHeight))
            } else {
                // 往下碰到 player
                let maskRect = CGRect(x: 0, y: 0, width: frame.width, height: viewMinY - minY)
                let maskPath = UIBezierPath(rect: maskRect)
                let maskLayer = CAShapeLayer()
                maskLayer.path = maskPath.cgPath
                layer.mask = maskLayer
            }
        }
    }

    private func mask(margin: Float) {
        layer.mask = visibilityMask(location: margin / Float(frame.size.height))
        layer.masksToBounds = true
    }

    private func visibilityMask(location: Float) -> CAGradientLayer {
        let mask = CAGradientLayer()
        mask.frame = bounds
        // TODO: 為什麼這個顏色設置可以隱藏cell？ 試過用紅色配黃色不起作用
        mask.colors = [UIColor(white: 1, alpha: 0).cgColor, UIColor(white: 1, alpha: 1).cgColor]
        mask.locations = [NSNumber(value: location), NSNumber(value: location)]
        return mask
    }
}
