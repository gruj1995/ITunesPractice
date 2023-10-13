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
//        setupUI()
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

    override func setupUI() {
        super.setupUI()
        view.addSubview(videoView)

        tableView.register(VideoCell.self, forCellReuseIdentifier: VideoCell.reuseIdentifier)
        tableView.register(YTPlayerHeaderView.self, forHeaderFooterViewReuseIdentifier: YTPlayerHeaderView.reuseIdentifier)
        tableView.rowHeight = 100

        emptyStateView.configure(title: "沒有結果".localizedString(), message: "無相關推薦影片".localizedString())
    }

    override func setupLayout() {
        videoView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.33)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(videoView.snp.bottom)
            $0.bottom.leading.trailing.equalToSuperview()
        }
        emptyStateView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(tableView)
            $0.width.equalToSuperview().multipliedBy(0.8)
        }
    }

    /// 當前播放影音於影音列表中的位置(預設=0)
    private var currentIndex: Int = 0 {
        didSet {
            unwrappedVM?.setSelectedItem(index: currentIndex)
        }
    }
    private var isFullScreenMode: Bool = false

    private(set) lazy var videoView: YoutubePlayerView = YoutubePlayerView()

    /// 加入APP到背景通知
    private func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(enteredFullScreen), name: UIWindow.didBecomeVisibleNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(leaveFullScreen), name: UIWindow.didBecomeHiddenNotification, object: nil)
    }

    var unwrappedVM: YTPlayerViewModel? {
        viewModel as? YTPlayerViewModel
    }

    /// 播放中影片的View
    private func setVideoView() {
        guard let videoID = unwrappedVM?.videoId else {
            return
        }
        videoView.loadVideo(videoID: videoID)
    }

    override func showTableView() {
        emptyStateView.isHidden = true
        setVideoView()
    }

    override func showNoResultView() {
        emptyStateView.isHidden = false
    }

//    /// 分享影片
//    private func shareVideo() {
//        guard let videoInfo = viewModel.getVideoInfo(at: currentIndex) else { return }
//        let url = URL(string: videoInfo.imageURL)
//        let preview = DynamicLinkPreviewModel(title: videoInfo.title, descriptionText: videoInfo.description, imageURL: url)
//        self.shareVideo(videoTitle: videoInfo.title, videoID: videoInfo.videoID, dynamicLinkPreview: preview)
////        AnalyticsHelper.logClickShareVideo(videoID: videoInfo.videoID)
//    }

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
        return header
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

    /// 當前影片播放完畢
    func currentVideoDidFinish() {
//        let isLastVideo = viewModel.isLastVideo(index: currentIndex)
//        if isLastVideo {
//            return
//        }
//        // 自動播放下一支影片
//        playNextVideo()
//        AnalyticsHelper.logAutoPlayNextVideo()
    }

    func didPlayTime(playTime: Float) {

    }

    private func playNextVideo() {
        loadMoreIfNeeded(index: currentIndex)
        currentIndex += 1
//        setVideoView()
    }
}

// MARK: - Extension EpisodeViewModelDelegate
//extension YTPlayerViewController: EpisodeViewModelDelegate {
//
//    func getVideoListFailed() {
//        finishLoading()
//        if let count = viewModel.getListCount(),
//           count > 0 {
//            videoListStatus = .success
//        } else {
//            videoListStatus = .failed(error: AppError.unknown)
//        }
//        tableView.reloadData()
//    }
//
//    func didGetVideoList() {
//        finishLoading()
//        if viewModel.getListCount() == 0 {
//            videoListStatus = .none
//        } else {
//            videoListStatus = .success
//        }
//        tableView.reloadData()
//        setVideoIfNeeded()
//    }
//
//    private func setVideoIfNeeded() {
//        guard isFirstGetVideo else { return }
//        isFirstGetVideo = false
//        setInfoView()
//        setVideoView()
//    }
//}
