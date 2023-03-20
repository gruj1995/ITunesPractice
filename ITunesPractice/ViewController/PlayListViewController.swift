//
//  PlayListViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/12.
//

import Combine
import SnapKit
import UIKit

// MARK: - PlayListViewController

/*
  - 沒網路時，網路音樂文字變灰色且不可選擇，本地音樂維持白字可選擇
  - tableView 滑動到待播清單時：
        上滑隱藏播放器; 下滑顯示播放器
    其他時候
        上滑顯示播放器; 下滑隱藏播放器
  - cell 拖曳排序功能
 */

class PlayListViewController: UIViewController {
    // MARK: Lifecycle

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Internal

//    override func viewDidLayoutSubviews() {
//        gradient.frame = view.bounds
//    }

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(TrackCell.self, forCellReuseIdentifier: TrackCell.reuseIdentifier)
        tableView.rowHeight = 60
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.clipsToBounds = true
        tableView.keyboardDismissMode = .onDrag // 捲動就隱藏鍵盤
        return tableView
    }()

    var lastVelocityYSign = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupUI()

        NetStatus.shared.netStatusChangeHandler = {
            DispatchQueue.main.async { [unowned self] in
                self.updateUI()
            }
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        gradient2.frame = UIScreen.main.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: Private

    private let cellHeight: CGFloat = 60

    private let viewModel: PlayListViewModel = .init()

    // mini 音樂播放器
    private lazy var playerVC: PlaylistPlayerViewController = {
        let vc = UIStoryboard(name: "PlayListPlayer", bundle: nil).instantiateViewController(withIdentifier: PlaylistPlayerViewController.storyboardIdentifier) as! PlaylistPlayerViewController
        return vc
    }()

    // 觀察者
    private var cancellables: Set<AnyCancellable> = []

    private var animator: UIViewPropertyAnimator!

    private lazy var playerContainerView: UIView = .init()

    private lazy var gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        // 增加 layer 高度，讓漸變過度更加自然
        gradient.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        // 顏色起始點與終點
//        gradient.locations = [0.3, 0.8, 1]
        view.layer.insertSublayer(gradient, at: 0)
        return gradient
    }()

//    private lazy var gradient2: CAGradientLayer = {
//        let gradient = CAGradientLayer()
//        gradient.frame = UIScreen.main.bounds
//        return gradient
//    }()

    private var lastContentOffset: CGFloat = 0

    /// 是否滑動到tableview最後一個section
    private var isLastSectionReached: Bool {
        tableView.isLastSectionReached()
    }

    private func setupUI() {
        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 150, left: 0, bottom: 0, right: 0))
        }

        let height = Constants.screenHeight * 0.27
        view.addSubview(playerContainerView)
        playerContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(height)
            make.bottom.equalToSuperview()
//            make.top.equalTo(tableView.snp.bottom).offset(-height)
        }

        addChild(playerVC)
        playerContainerView.addSubview(playerVC.view)
        playerVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        playerVC.didMove(toParent: self)
    }

    let theight = Constants.screenHeight - 150 - Constants.screenHeight * 0.27

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
            .receive(on: RunLoop.main)
            .sink { [weak self] colors in
                guard let self = self else { return }
                self.updateGradientLayer(with: colors)
            }.store(in: &cancellables)
    }

    private func updateGradientLayer(with colors: [UIColor]) {
        let animator = UIViewPropertyAnimator(duration: 1, curve: .easeInOut) { [weak self] in
            guard let self = self else { return }
            // UIColor 要轉換成 cgColor 才行
            // colors 至少要有兩個以上element才會正常顯示
            self.gradient.colors = colors.map { $0.cgColor }
//            self.gradient2.colors = colors.map { $0.cgColor }
//            self.playerVC.gradient.colors = colors.map { $0.cgColor }
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
//        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//        alert.addAction(okAction)
//        present(alert, animated: true, completion: nil)
    }

    private lazy var zeroPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: view.bounds.width, height: 700)).cgPath
    private lazy var tablePath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: view.bounds.width, height: theight)).cgPath

    var isPlayerHidden: Bool = false
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension PlayListViewController: UITableViewDataSource, UITableViewDelegate {
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

    /*
       點擊 context menu 的預覽圖後觸發，如果沒實作此 funtion，則點擊預覽圖後直接關閉 context menu
            - animator  跳轉動畫執行者，可以添加要跳轉到的頁面和跳轉動畫
     */
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        if let identifier = configuration.identifier as? String,
           let index = Int(identifier) {
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
        return tableView.createTrackContextMenuConfiguration(indexPath: indexPath, track: viewModel.selectedTrack)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        guard !viewModel.bookKeepDayGroups.isEmpty, let bookKeepDayGroup = viewModel.bookKeepDayGroup(forHeaderAt: section) else {
//            return nil
//        }
        let header = PlayListHeaderView()
        header.configure(title: "待播清單")
//        header.layer.insertSublayer(gradient2, at: 0)
//        header.clipsToBounds = true
        return header
    }

//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if lastContentOffset > scrollView.contentOffset.y {
//            // move up
//            playerContainerView.isHidden = isLastSectionReached ? true : false
//        } else if lastContentOffset < scrollView.contentOffset.y {
//            // move down
//            playerContainerView.isHidden = isLastSectionReached ? false : true
//        }
//
//        // update the new position acquired
//        lastContentOffset = scrollView.contentOffset.y
//    }

//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//     let currentVelocityY =  scrollView.panGestureRecognizer.velocity(in: scrollView.superview).y
//     let currentVelocityYSign = Int(currentVelocityY).signum()
//     if currentVelocityYSign != lastVelocityYSign && currentVelocityYSign != 0 {
//            lastVelocityYSign = currentVelocityYSign
//     }
//     if lastVelocityYSign < 0 {
//         playerContainerView.isHidden = isLastSectionReached ? true : false
//       print("SCROLLING DOWN")
//     } else if lastVelocityYSign > 0 {
//         playerContainerView.isHidden = isLastSectionReached ? false : true
//       print("SCOLLING UP")
//     }
//    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < lastContentOffset, playerContainerView.isHidden {
            isPlayerHidden = isLastSectionReached
        } else if scrollView.contentOffset.y > lastContentOffset, !playerContainerView.isHidden {
            isPlayerHidden = !isLastSectionReached
        }
        lastContentOffset = scrollView.contentOffset.y
//        updateView()
    }

    func updateView() {
        playerContainerView.isHidden = isPlayerHidden

        for cell in tableView.visibleCells {
            let hiddenFrameHeight = tableView.contentOffset.y + tableView(tableView, heightForHeaderInSection: 0) - cell.frame.origin.y

            if hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height {
                self.maskCell(cell: cell, fromTopWithMargin: hiddenFrameHeight)
            }
        }
    }

    func maskCell(cell: UITableViewCell, fromTopWithMargin margin: CGFloat) {
        cell.layer.mask = visibilityMaskForCell(cell: cell, withLocation: margin/cell.frame.size.height)
        cell.layer.masksToBounds = true
    }

    func visibilityMaskForCell(cell: UITableViewCell, withLocation location: CGFloat) -> CAGradientLayer {
        let mask = CAGradientLayer()
        mask.frame = cell.bounds
//        mask.colors = [RGB(255, a: 0.0).CGColor, RGB(255, a: 1.0).CGColor]
        mask.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor]
        mask.locations = [NSNumber(value: Float(location)), NSNumber(value: Float(location))]
        return mask
    }
}

// MARK: TrackDetailViewControllerDatasource

extension PlayListViewController: TrackDetailViewControllerDatasource {
    func trackId(_ trackDetailViewController: TrackDetailViewController) -> Int? {
        return viewModel.selectedTrack?.trackId
    }
}
