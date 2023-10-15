//
//  YTPlayerViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/10.
//

import UIKit
import Combine
import YouTubeiOSPlayerHelper

class YTPlayerViewController: BaseListViewController<YTPlayerViewModel> {

    override func viewDidLoad() {
        super.viewDidLoad()
        addNotification()
        reloadItems()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let tabBarVC = tabBarController as? MainTabBarController {
            tabBarVC.miniPlayerVC.view.isHidden = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let tabBarVC = tabBarController as? MainTabBarController {
            tabBarVC.miniPlayerVC.view.isHidden = false
        }
    }

    lazy var playerView: YoutubePlayerView = {
        let view = YoutubePlayerView()
        view.delegate = self
        return view
    }()

    var unwrappedVM: YTPlayerViewModel? {
        viewModel as? YTPlayerViewModel
    }

    /// 當前播放影音於影音列表中的位置(預設=0)
    private var currentIndex: Int = 0 {
        didSet {
            unwrappedVM?.setSelectedItem(index: currentIndex)
        }
    }
    private var isFullScreenMode: Bool = false
    private var playerHeightRatio: CGFloat = 0.33

    override func setupUI() {
        super.setupUI()
        view.addSubview(playerView)

        tableView.register(VideoCell.self, forCellReuseIdentifier: VideoCell.reuseIdentifier)
        tableView.register(YTPlayerHeaderView.self, forHeaderFooterViewReuseIdentifier: YTPlayerHeaderView.reuseIdentifier)
        tableView.rowHeight = 100

        emptyStateView.configure(title: "沒有結果".localizedString(), message: "無相關推薦影片".localizedString())
    }

    override func setupLayout() {
        playerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(playerHeightRatio)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(playerView.snp.bottom)
            $0.bottom.leading.trailing.equalToSuperview()
        }
        emptyStateView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(tableView)
            $0.width.equalToSuperview().multipliedBy(0.8)
        }
    }

    /// 加入APP到背景通知
    private func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(enteredFullScreen), name: UIWindow.didBecomeVisibleNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(leaveFullScreen), name: UIWindow.didBecomeHiddenNotification, object: nil)
    }

    /// 播放中影片的View
    private func setVideoView() {
        guard let videoID = unwrappedVM?.videoId else {
            return
        }
        playerView.loadVideo(videoID: videoID)
    }

    override func showTableView() {
        emptyStateView.isHidden = true
        setVideoView()
    }

    override func showNoResultView() {
        emptyStateView.isHidden = false
    }

    /// 進入全螢幕
    @objc
    private func enteredFullScreen() {
        if !isFullScreenMode {
            isFullScreenMode = true
        }
    }

    /// 離開全螢幕
    @objc
    private func leaveFullScreen() {
        isFullScreenMode = false
    }

    // MARK: UITableViewDataSource, UITableViewDelegate

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VideoCell.reuseIdentifier, for: indexPath) as? VideoCell,
              let video = unwrappedVM?.videoInfos[safe: indexPath.row] else {
            return UITableViewCell()
        }
        cell.configure(video)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentIndex = indexPath.row
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: YTPlayerHeaderView.reuseIdentifier) as? YTPlayerHeaderView else {
            return nil
        }
        guard let videoDetailInfo = unwrappedVM?.videoDetailInfo else {
            return header
        }
        header.configure(videoDetailInfo)
        header.onMoreButtonTapped = { [weak self] _ in
            self?.presentInfoAlert(info: videoDetailInfo)
        }
        return header
    }

    private func presentInfoAlert(info: VideoDetailInfo) {
        let vm = VideoDetailBottomAlertViewModel(videoDetailInfo: info)
        let vc = VideoDetailBottomAlert(viewModel: vm)
        if let sheet = vc.sheetPresentationController {
            // 自訂彈窗高度
            if #available(iOS 16.0, *) {
                let fraction = UISheetPresentationController.Detent.custom { _ in
                    (Constants.screenHeight - Constants.statusBarHeight) * (1 - self.playerHeightRatio)
                }
                sheet.detents = [fraction]
            } else {
                sheet.detents = [.medium()]
            }
            sheet.prefersGrabberVisible = true // 顯示頂部 grabber
        }
        present(vc, animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        loadMoreIfNeeded(index: indexPath.row)
    }

    /// 檢查是否需要加載更多影片
    private func loadMoreIfNeeded(index: Int) {
//        let totalCount = tableView.numberOfRows(inSection: 0)
//        let reloadCount = (totalCount - 1 > 0) ? totalCount - 1 : 0
//        if index >= reloadCount {
//            viewModel.fetchVideoList(needReload: false)
//        }
    }
}

// MARK: - Extension YoutubePlayerViewDelegate
extension YTPlayerViewController: YoutubePlayerViewDelegate {
    func currentVideoDidFinish() {
//        guard currentIndex <= viewModel.totalCount - 2 else {
//            return
//        }
//        // 自動播放下一支影片
//        loadMoreIfNeeded(index: currentIndex)
//        currentIndex += 1
        currentIndex = 0
    }

    func didPlayTime(playTime: Float) {

    }
}
