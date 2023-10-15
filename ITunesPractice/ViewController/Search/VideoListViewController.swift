//
//  VideoListViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/12.
//

import Combine
import UIKit

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

    private let cellHeight: CGFloat = 100

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(VideoCell.self, forCellReuseIdentifier: VideoCell.reuseIdentifier)
        tableView.rowHeight = cellHeight
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
        view.isHidden = true
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
            .sink { [weak self] state in
                guard let self else { return }
                switch state {
                case .success:
                    self.updateUI()
                case .failed(let error):
                    self.handleError(error)
                case .loading, .none:
                    return
                }
            }.store(in: &cancellables)

        NetworkMonitor.shared.$isConnected
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
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
        let fpc = getFpc()
        // 隱藏頂部拖動指示器
        fpc.surfaceView.grabberHandle.isHidden = true
        fpc.set(contentViewController: vc)
        present(fpc, animated: true)
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
        cell.configure(video)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentYTPlayerVC(index: indexPath.row)
    }

//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let lastRowIndex = tableView.numberOfRows(inSection: 0) - 1
//        viewModel.loadMoreIfNeeded(currentRowIndex: indexPath.row, lastRowIndex: lastRowIndex)
//    }
//
//    /*
//     點擊 context menu 的預覽圖後觸發，如果沒實作此 funtion，則點擊預覽圖後直接關閉 context menu
//     - animator  跳轉動畫執行者，可以添加要跳轉到的頁面和跳轉動畫
//     */
//    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
//            animator.addCompletion { [weak self] in
//                guard let self else { return }
//                let vc = TrackDetailViewController()
//                vc.dataSource = self
//                // 由 SearchViewController push
//                self.presentingViewController?.navigationController?.pushViewController(vc, animated: true)
//            }
//    }
//
//    // context menu 的清單
//    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
//        viewModel.setSelectedTrack(forCellAt: indexPath.row)
//        return tableView.createTrackContextMenuConfiguration(indexPath: indexPath, track: viewModel.selectedTrack)
//    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView.emptyView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        cellHeight
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView.emptyView()
    }
}
