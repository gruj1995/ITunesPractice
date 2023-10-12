////
////  YTPlayerViewController.swift
////  ITunesPractice
////
////  Created by 李品毅 on 2023/10/10.
////
//
//import UIKit
//import YouTubeiOSPlayerHelper
//
//
//class YTPlayerViewController: UIViewController {
//
//    // MARK: - view properties
//
//    private(set) lazy var statusView: UIView = {
//        return UIView()
//    }()
//
//    private lazy var downButton: UIButton = {
//        let button = UIButton()
//        button.setImage(AppImages.down, for: .normal)
//        button.tintColor = .white
//        button.addTarget(self, action: #selector(downButtonTapped), for: .touchUpInside)
//        return button
//    }()
//
//    @objc
//    private func downButtonTapped() {
//    
//    }
//
//    private(set) lazy var videoView: YoutubePlayerView = {
//        let view = YoutubePlayerView()
//        return view
//    }()
//
//    private(set) lazy var infoView: EpisodeInfoView = {
//        let view = EpisodeInfoView()
//        return view
//    }()
//
//    private lazy var sectionHeaderLabel: UILabel = {
//        let label = UILabel()
//        label.text = RemoteConfigManager.getVideoMoreListTitle()
//        label.textColor = .white
//        label.font = UIFont.gJGRegular(size: 16)
//        return label
//    }()
//
//    /// 更多影片列表
//    private(set) lazy var tableView: UITableView = {
//        let tableView = UITableView()
//        tableView.backgroundColor = .gray30
//        tableView.separatorStyle = .none
//        tableView.register(EpisodeTableViewCell.self, forCellReuseIdentifier: EpisodeTableViewCell.reuseIdentifier)
//        tableView.register(ErrorTableViewCell.self, forCellReuseIdentifier: ErrorTableViewCell.reuseIdentifier)
//        tableView.delegate = self
//        tableView.dataSource = self
//        return tableView
//    }()
//
//    private lazy var stackView: UIStackView = {
//        let stackView = UIStackView(arrangedSubviews: [statusView, videoView, infoView, tableView])
//        stackView.distribution = .fill
//        stackView.axis = .vertical
//        stackView.alignment = .fill
//        return stackView
//    }()
//
//    // MARK: - 其他 properties
//
//    /// 影音播放器高度
//    private lazy var videoHeight = DeviceInfo.screenWidth * 211 / 375
//
//    /// 更多影音列表狀態
//    private lazy var videoListStatus: ListStatus = {
//        let listCount = viewModel.getListCount() ?? 0
//        if listCount > 0 {
//            return .success
//        }
//        return .empty
//    }()
//
//    /// 當前播放影音於影音列表中的位置(預設=0)
//    private var currentIndex: Int
//
//    private var viewModel: EpisodeViewModel
//
//    /// 一開始進入影片內頁的類型
//    var originEnterType: EpisodePageEnterType
//
//    /// 進入影片內頁的類型(會隨著切換影片改變)
//    private var enterType: EpisodePageEnterType
//
//    private lazy var isFirstGetVideo: Bool = {
//        let count = viewModel.getListCount() ?? 0
//        return count == 0
//    }()
//
//    private var isFullScreenMode: Bool = false
//
//    // MARK: - life cycle
//    init(listType: VideoListType? = nil, index: Int, enterType: EpisodePageEnterType, videoInfo: VideoInfo? = nil) {
//        self.originEnterType = enterType
//        self.enterType = enterType
//        self.currentIndex = index
//        self.viewModel = EpisodeViewModel(videoInfo: videoInfo)
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    deinit{
//        viewModel.clearVideoCache()
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        addNotification()
//        firstLoadVideoList()
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.isNavigationBarHidden = true
//        tabBarController?.tabBar.isHidden = true
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        removeNotification()
//    }
//
//    /// 加入APP到背景通知
//    private func addNotification() {
//        NotificationCenter.default.addObserver(self, selector: #selector(enteredFullScreen), name: UIWindow.didBecomeVisibleNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(leaveFullScreen), name: UIWindow.didBecomeHiddenNotification, object: nil)
//    }
//
//    private func removeNotification() {
//        NotificationCenter.default.removeObserver(self, name: UIWindow.didBecomeVisibleNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: UIWindow.didBecomeHiddenNotification, object: nil)
//    }
//
//    private func setupUI() {
//        view.backgroundColor = .gray30
//        view.addConstraintToView(subView: stackView)
//        NSLayoutConstraint.activate([
//            statusView.heightAnchor.constraint(equalToConstant: DeviceInfo.statusBarHeight),
//            topView.heightAnchor.constraint(equalToConstant: 42),
//            videoView.heightAnchor.constraint(equalToConstant: videoHeight + 36),
//            infoView.heightAnchor.constraint(equalToConstant: 66)
//        ])
//
//        setInfoView()
//        setVideoView()
//    }
//
//    /// 影片資訊
//    private func setInfoView() {
//        guard let videoInfo = viewModel.getVideoInfo(at: currentIndex) else { return }
//        infoView.clickMoreInfo = { [weak self] in
//            self?.showChannelInfo()
//        }
//        infoView.setContent(imageURL: videoInfo.channel.imageURL, name: videoInfo.channel.channelName, title: videoInfo.title, viewCount: videoInfo.viewCountString)
//    }
//
//    /// 播放中影片的View
//    private func setVideoView() {
//        guard let videoInfo = viewModel.getVideoInfo(at: currentIndex) else { return }
//        videoView.loadVideo(videoID: videoInfo.videoID)
//    }
//
    // MARK: - private method
//
//    private func firstLoadVideoList() {
//        viewModel.delegate = self
//        guard isFirstGetVideo else { return }
//        addLoadingView()
//        viewModel.fetchVideoList(needReload: true)
//    }
//
//    /// 顯示頻道資訊
//    private func showChannelInfo() {
//        guard let videoInfo = viewModel.getVideoInfo(at: currentIndex) else { return }
//        let presenter = Presenter()
//        let popupHeight = DeviceInfo.screenHeight * 320 / 812
//        presenter.popupSize = CGSize(width: DeviceInfo.screenWidth, height: popupHeight)
//        presenter.center = CGPoint(x: DeviceInfo.screenWidth / 2, y: DeviceInfo.screenHeight - popupHeight / 2)
//        presenter.isViewBottomHidden = true
//        let vc = ChannelInfoViewController()
//        vc.setContent(imageURL: videoInfo.channel.imageURL, name: videoInfo.channel.channelName, infoText: videoInfo.channel.description ?? "")
//        presenter.presentViewController(presentingVC: self, presentedVC: vc, animated: true, completion: nil)
//        presenter.backgroundOnClicked = { [weak vc] in
//            vc?.dismiss(animated: true, completion: nil)
//        }
////        AnalyticsHelper.logClickViewMoreChannelInfo()
//    }
//
//    /// 分享影片
//    private func shareVideo() {
//        guard let videoInfo = viewModel.getVideoInfo(at: currentIndex) else { return }
//        let url = URL(string: videoInfo.imageURL)
//        let preview = DynamicLinkPreviewModel(title: videoInfo.title, descriptionText: videoInfo.description, imageURL: url)
//        self.shareVideo(videoTitle: videoInfo.title, videoID: videoInfo.videoID, dynamicLinkPreview: preview)
////        AnalyticsHelper.logClickShareVideo(videoID: videoInfo.videoID)
//    }
//
//}
//
// MARK: - 全螢幕通知
//extension EpisodeViewController {
//
//    /// 進入全螢幕
//    @objc private func enteredFullScreen() {
//        if !isFullScreenMode {
//            isFullScreenMode = true
////            AnalyticsHelper.logClickFullScreen()
//        }
//    }
//
//    /// 離開全螢幕
//    @objc private func leaveFullScreen() {
//        isFullScreenMode = false
//    }
//
//}
//
// MARK: - Extension UITableViewDataSource
//extension EpisodeViewController: UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return viewModel.getListCount() ?? 1
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        switch videoListStatus {
//        case .success:
//            return getEpisodeTableCell(indexPath: indexPath)
//        case .empty:
//            return getEmptyViewCell(indexPath: indexPath)
//        case .failed:
//            return getNetworkViewCell(indexPath: indexPath)
//        }
//    }
//
//    private func getEpisodeTableCell(indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: EpisodeTableViewCell.reuseIdentifier, for: indexPath) as? EpisodeTableViewCell,
//              let video = viewModel.getVideoInfo(at: indexPath.row) else {
//            return UITableViewCell()
//        }
//        cell.setContent(imageURL: video.imageURL, title: video.title, channelName: video.channel.channelName, time: video.playDurationString, viewCount: video.viewCountString)
//        cell.didSelectCell = { [weak self] in
//            guard let self = self else { return }
//            self.updateCurrentVideo(indexPath.row)
////            AnalyticsHelper.logClickVideoInMoreList(videoID: video.videoID)
//        }
//        return cell
//    }
//
//    private func updateCurrentVideo(_ index: Int) {
//        self.currentIndex = index
//        setInfoView()
//        setVideoView()
//    }
//
//    private func getEmptyViewCell(indexPath: IndexPath) -> UITableViewCell {
//        if let cell = tableView.dequeueReusableCell(withIdentifier: ErrorTableViewCell.reuseIdentifier, for: indexPath) as? ErrorTableViewCell {
//            cell.setStyle(style: .emptyView(imageName: "no_video", message: "系統目前無該分類影音\n敬請期待！"))
//            return cell
//        }
//        return UITableViewCell()
//    }
//
//    private func getNetworkViewCell(indexPath: IndexPath) -> UITableViewCell {
//        if let cell = tableView.dequeueReusableCell(withIdentifier: ErrorTableViewCell.reuseIdentifier, for: indexPath) as? ErrorTableViewCell {
//            cell.setStyle(style: .commonStyle(offsetY: 0))
//            cell.didClickReload = { [weak self] in
//                self?.viewModel.fetchVideoList(needReload: true)
//            }
//            return cell
//        }
//        return UITableViewCell()
//    }
//}
//
// MARK: - Extension UITableViewDelegate
//extension EpisodeViewController: UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        switch videoListStatus {
//        case .success:
//            return 84
//        case .empty, .failed:
//            return 250
//        }
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView()
//        view.backgroundColor = .gray30
//        view.addConstraintToView(subView: sectionHeaderLabel, edgeInsets: UIEdgeInsets(top: 16, left: 16, bottom: 8, right: 16))
//        return view
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 48
//    }
//
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        loadMoreIfNeeded(index: indexPath.row)
//    }
//
//    /// 檢查是否需要加載更多影片
//    private func loadMoreIfNeeded(index: Int) {
//        let totalCount = tableView.numberOfRows(inSection: 0)
//        let reloadCount = (totalCount - 1 > 0) ? totalCount - 1 : 0
//        if index >= reloadCount {
//            viewModel.fetchVideoList(needReload: false)
//        }
//    }
//}
//
// MARK: - Extension YoutubePlayerViewDelegate
//extension EpisodeViewController: YoutubePlayerViewDelegate {
//
//    /// 當前影片播放完畢
//    func currentVideoDidFinish() {
//        let isLastVideo = viewModel.isLastVideo(index: currentIndex)
//        if isLastVideo {
//            return
//        }
//        // 自動播放下一支影片
//        playNextVideo()
////        AnalyticsHelper.logAutoPlayNextVideo()
//    }
//
//    func didPlayTime(playTime: Float) {
//
//    }
//
//    private func playNextVideo() {
//        loadMoreIfNeeded(index: currentIndex)
//        currentIndex += 1
//        updateCurrentVideo(currentIndex)
//    }
//}
//
// MARK: - Extension EpisodeViewModelDelegate
//extension EpisodeViewController: EpisodeViewModelDelegate {
//
//    func getVideoListFailed() {
//        removeLoadingView()
//        if let count = viewModel.getListCount(),
//           count > 0 {
//            videoListStatus = .success
//        } else {
//            videoListStatus = .failed
//        }
//        tableView.reloadData()
//    }
//
//    func didGetVideoList() {
//        removeLoadingView()
//        if viewModel.getListCount() == 0 {
//            videoListStatus = .empty
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
