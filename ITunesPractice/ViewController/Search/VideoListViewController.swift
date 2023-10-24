//
//  VideoListViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/12.
//

import Combine
import UIKit
import YoutubeDL

// MARK: - VideoListViewController

class VideoListViewController: FullScreenFloatingPanelViewController {
    // MARK: Lifecycle

    init(viewModel: VideoListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.fetchVideos()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    // MARK: Private

    private let viewModel: VideoListViewModel
    private var cancellables: Set<AnyCancellable> = .init()

    // 下拉 tableView 更新資料
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .lightGray
        let attributedString = NSAttributedString(string: "更新資料".localizedString(), attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
            NSAttributedString.Key.foregroundColor: UIColor.lightGray
        ])
        refreshControl.attributedTitle = attributedString
        refreshControl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        refreshControl.addTarget(self, action: #selector(reloadVideos), for: .valueChanged)
        return refreshControl
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(VideoCell.self, forCellReuseIdentifier: VideoCell.reuseIdentifier)
        tableView.rowHeight = Constants.videoCellHeight
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag // 捲動就隱藏鍵盤
        tableView.addSubview(refreshControl)
        return tableView
    }()

    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        return view
    }()

    // MARK: Setup

    private func setupUI() {
        view.backgroundColor = .appColor(.background)
        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        view.addSubview(emptyStateView)
        emptyStateView.snp.makeConstraints {
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.centerY.equalTo(view.safeAreaLayoutGuide).multipliedBy(0.9)
            $0.width.equalToSuperview().multipliedBy(0.8)
        }
    }

    private func bindViewModel() {
        viewModel.$state
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] state in
                guard let self else { return }
                switch state {
                case .success:
                    self.updateUI()
                case .failed(let error):
                    self.handleError(error)
                 default:
                    return
                }
            }.store(in: &cancellables)

        NetworkMonitor.shared.$isConnected
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] _ in
                self?.updateUI()
            }.store(in: &cancellables)
    }

    @objc
    private func updateUI() {
        refreshControl.endRefreshing()

        if viewModel.totalCount == 0 {
            showNoResultView()
        } else {
            // 要放在 tableView.reloadData() 前
            tableView.tableFooterView = nil
            tableView.reloadData()
            showTableView()
        }
    }

    private func showTableView() {
        emptyStateView.isHidden = true
        tableView.isHidden = false
    }

    private func showNoResultView() {
        emptyStateView.configure(title: "沒有結果".localizedString(), message: "")
        emptyStateView.isHidden = false
        tableView.isHidden = true
    }

    private func handleError(_ error: Error) {
        refreshControl.endRefreshing()
        tableView.tableFooterView = nil
        showNoResultView()
        if NetworkMonitor.shared.isConnected {
            Utils.toast(error.localizedDescription, at: .center)
        }
    }

    private func presentYTPlayerVC(index: Int) {
        guard let videoInfo = viewModel.videoInfos[safe: index],
              let channelName = videoInfo.channelTitle else {
            return
        }
        let vm = YTPlayerViewModel(videoId: videoInfo.videoId, channelName: channelName)
        let vc = YTPlayerViewController(viewModel: vm)

        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true // 顯示頂部 grabber
        }
        present(vc, animated: true)
//        let fpc = getFpc()
//        // 隱藏頂部拖動指示器
//        fpc.surfaceView.grabberHandle.isHidden = true
//        fpc.set(contentViewController: vc)
//        present(fpc, animated: true)
    }

    @objc
    private func reloadVideos() {
        viewModel.fetchVideos()
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension VideoListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.totalCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VideoCell.reuseIdentifier) as? VideoCell else {
            return UITableViewCell()
        }
        guard let video = viewModel.videoInfos[safe: indexPath.row] else {
            return cell
        }
        let showDownload = !video.isLive && !UserDefaults.defaultPlaylist.tracks.contains { $0.ytId == video.videoId }
        cell.configure(video, showDownload: showDownload)
        cell.onDownloadButtonTapped = { [weak self] _ in
            Task {
                guard let url = URL(string: "https://www.youtube.com/watch?v=\(video.videoId)"),
                      showDownload else {
                    return
                }
                self?.loadingAction()
                await self?.viewModel.app.startDownload(url: url)
                self?.tableView.reloadRows(at: [indexPath], with: .none)
                Utils.toast("下載歌曲成功！")
                self?.finishLoading()
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentYTPlayerVC(index: indexPath.row)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView.emptyView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        Constants.videoCellHeight
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView.emptyView()
    }
}
