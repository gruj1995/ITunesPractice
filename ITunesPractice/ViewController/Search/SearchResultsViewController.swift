//
//  SearchResultViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/12.
//

import Combine
import SnapKit
import UIKit

// MARK: - SearchResultsViewController

class SearchResultsViewController: UIViewController {
    // MARK: Lifecycle

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Internal

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    // MARK: Private

    private let viewModel: SearchResultsViewModel = .init()
    private var cancellables: Set<AnyCancellable> = .init()

    // 抓取資料時的旋轉讀條 (可以搜尋"egaf"，觀察在資料筆數小的情況下怎麼顯示)
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.startAnimating()
        return activityIndicator
    }()

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
        refreshControl.addTarget(self, action: #selector(reloadTracks), for: .valueChanged)
        return refreshControl
    }()

    private let cellHeight: CGFloat = 60

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(TrackCell.self, forCellReuseIdentifier: TrackCell.reuseIdentifier)
        tableView.rowHeight = cellHeight
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.prefetchDataSource = self // 懶加載
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
        view.backgroundColor = .black
        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(emptyStateView)
        emptyStateView.snp.makeConstraints { make in
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.centerY.equalTo(view.safeAreaLayoutGuide).multipliedBy(0.9)
            make.width.equalToSuperview().multipliedBy(0.8)
        }
    }

    private func bindViewModel() {
        viewModel.currentTrackIndexPublisher
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .combineLatest(viewModel.isPlayingPublisher)
            .sink { [weak self] _ in
                guard let self else { return }
                self.updateUI()
            }.store(in: &cancellables)

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

        if viewModel.totalCount == 0, !viewModel.searchTerm.isEmpty {
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
        emptyStateView.configure(title: "沒有結果".localizedString(), message: "嘗試新的搜尋項目。".localizedString())
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

    @objc
    private func reloadTracks() {
        viewModel.reloadTracks()
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension SearchResultsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.totalCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.reuseIdentifier) as? TrackCell
        else {
            return UITableViewCell()
        }
        guard let track = viewModel.track(forCellAt: indexPath.row) else {
            return cell
        }
        cell.configure(artworkUrl: track.artworkUrl100, collectionName: track.collectionName, artistName: track.artistName, trackName: track.trackName, showsHighlight: true)

        let showAnimation = (track == viewModel.currentTrack)
        let isPlaying = viewModel.isPlaying
        cell.updateAnimationState(showAnimation: showAnimation, isPlaying: isPlaying)

        // 原生的右邊箭頭
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 解除cell被選中的狀態
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.setSelectedTrack(forCellAt: indexPath.row)

        let vc = TrackDetailViewController()
        vc.dataSource = self
        // 由 SearchViewController push
        presentingViewController?.navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastRowIndex = tableView.numberOfRows(inSection: 0) - 1
        viewModel.loadMoreIfNeeded(currentRowIndex: indexPath.row, lastRowIndex: lastRowIndex)
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

// MARK: TrackDetailViewControllerDatasource

extension SearchResultsViewController: TrackDetailViewControllerDatasource {
    func trackId(_ trackDetailViewController: TrackDetailViewController) -> Int? {
        return viewModel.selectedTrack?.trackId
    }
}

// MARK: UISearchResultsUpdating

extension SearchResultsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchTerm = searchController.searchBar.text ?? ""
        tableView.scrollToTop(animated: false)
    }
}
