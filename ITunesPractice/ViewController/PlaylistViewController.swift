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

/*
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
        tableView.rowHeight = 60
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

        NetStatus.shared.netStatusChangeHandler = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }
    }

    // MARK: Private

    private let viewModel: PlaylistViewModel = .init()

    private var cancellables: Set<AnyCancellable> = .init()

    private var lastVelocityYSign = 0

    private let cellHeight: CGFloat = 60

    private var lastContentOffset: CGFloat = 0

    private var playerContainerViewBottom: Constraint?

    private let playerContainerViewHeight = Constants.screenHeight * 0.35

    private var animator: UIViewPropertyAnimator!

    private lazy var playerContainerView: UIView = .init()

    private lazy var currentTrackView: CurrentTrackView = {
        let currentTrackView = CurrentTrackView()
        currentTrackView.configure(trackName: "abcccccccccccccccccccccccccccccccccccccccccccc", artistName: "sssssss")
        return currentTrackView
    }()

    // 音樂播放器
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
        // 10 是 playerContainerView 隱藏時上方要露出的高度
        -playerContainerViewHeight + 10
    }

    private func setupUI() {
        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(currentTrackView)
        currentTrackView.snp.makeConstraints { make in
            // 與頂部的距離和 fpc.surfaceView.grabberHandlePadding 有關
            make.top.equalToSuperview().offset(50)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(currentTrackView.snp.bottom)
            make.bottom.leading.trailing.equalToSuperview()
//            tableViewBottom = make.bottom.equalToSuperview().constraint
//            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 150, left: 0, bottom: 0, right: 0))
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
        viewModel.statePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .success:
                    self.updateUI()
                case .failed(let error):
                    self.handleError(error)
                case .loading, .none:
                    return
                }
            }.store(in: &cancellables)

        viewModel.colorsSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] colors in
                guard let self = self else { return }
                self.updateGradientLayers(with: colors)
            }.store(in: &cancellables)
    }

    private func updateGradientLayers(with colors: [UIColor]) {
        let animator = UIViewPropertyAnimator(duration: 1, curve: .easeInOut) { [weak self] in
            guard let self = self else { return }
            let cgColors = colors.map { $0.cgColor }
            self.gradient.colors = cgColors

            // 取得 gradient 由上往下幾 % 位置的漸層顏色作為交界色
            guard let bottomThirdColor = self.gradient.color(atPosition: 0.45)?.cgColor else {
                return
            }
            let playerVCColors = [bottomThirdColor.copy(alpha: 0.05)!, bottomThirdColor, cgColors[2]]

            self.playerVC.gradient.colors = playerVCColors
        }
        animator.startAnimation()
    }

    private func updateUI() {
        // 要放在 tableView.reloadData() 前
        tableView.tableFooterView = nil
        tableView.reloadData()
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

        if contentOffset <= 0 {
            // 滑到最上方了，隱藏播放器
            isPlayerHidden = true
        } else if contentOffset >= contentHeight - frameHeight {
            // 滑到最底部了，顯示播放器
            isPlayerHidden = false
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
        guard let track = viewModel.track(forCellAt: indexPath.row) else {
            return cell
        }
        cell.configure(artworkUrl: track.artworkUrl100, collectionName: track.collectionName, artistName: track.artistName, trackName: track.trackName)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 解除cell被選中的狀態
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.setSelectedTrack(forCellAt: indexPath.row)

        let vc = TrackDetailViewController()
        vc.dataSource = self
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // 用戶滑到最底時載入下一頁資料
        let lastRowIndex = tableView.numberOfRows(inSection: 0) - 1
        if indexPath.row == lastRowIndex {
//            viewModel.loadNextPage()
        }
    }

    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        if let identifier = configuration.identifier as? String, let index = Int(identifier) {
            animator.addCompletion { [weak self] in
                guard let self = self else { return }
                self.viewModel.setSelectedTrack(forCellAt: index)
                let vc = TrackDetailViewController()
                vc.dataSource = self
                //                self.presentingViewController?.navigationController?.pushViewController(vc, animated: true)
                self.show(vc, sender: self)
            }
        }
    }

    // context menu 的清單
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        viewModel.setSelectedTrack(forCellAt: indexPath.row)
        viewModel.selectedIndexPath = indexPath
        return tableView.createTrackContextMenuConfiguration(indexPath: indexPath, track: viewModel.selectedTrack)
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

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        guard !viewModel.bookKeepDayGroups.isEmpty, let bookKeepDayGroup = viewModel.bookKeepDayGroup(forHeaderAt: section) else {
//            return nil
//        }
        let header = PlayListHeaderView()
        header.configure(title: "待播清單", subTitle: nil)
        return header
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView.emptyView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return playerContainerViewHeight
    }
}

// MARK: TrackDetailViewControllerDatasource

extension PlaylistViewController: TrackDetailViewControllerDatasource {
    func trackId(_ trackDetailViewController: TrackDetailViewController) -> Int? {
        return viewModel.selectedTrack?.trackId
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
