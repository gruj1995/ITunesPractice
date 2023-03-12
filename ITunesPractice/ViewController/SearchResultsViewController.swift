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
        bindViewModel()

        NetStatus.shared.netStatusChangeHandler = {
            DispatchQueue.main.async { [unowned self] in
                self.updateUI()
            }
        }

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: Private

    private let viewModel: SearchResultsViewModel = .init()

    // 觀察者
    private var cancellables: Set<AnyCancellable> = []

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TrackCell.self, forCellReuseIdentifier: TrackCell.reuseIdentifier)
        tableView.rowHeight = 60
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.prefetchDataSource = self // 懶加載
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag // 捲動就隱藏鍵盤
        return tableView
    }()

    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.isHidden = true
        return view
    }()

    private func setupUI() {
        view.backgroundColor = .black
        setupLayout()
    }

    private func bindViewModel() {
        viewModel.statePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .loading:
                    self.tableView.reloadData()
                case .success:
                    self.updateUI()
                case .failed(let error):
                    self.handleError(error)
                case .none:
                    break
                }
            }
            .store(in: &cancellables)
    }

    private func updateUI() {
        if viewModel.totalCount == 0, !viewModel.searchTerm.isEmpty {
            showNoResultView()
        } else if !NetStatus.shared.isConnected {
            showEmptyView()
        } else {
            showTableView()
        }
    }

    private func showTableView() {
        tableView.isHidden = false
        emptyStateView.isHidden = true
        tableView.reloadData()
    }

    private func showNoResultView() {
        emptyStateView.configure(title: "沒有結果".localizedString(), message: "嘗試新的搜尋項目。".localizedString())
        emptyStateView.isHidden = false
        tableView.isHidden = true
    }

    private func showEmptyView() {
        emptyStateView.configure(title: "您已離線".localizedString(), message: "關閉「飛航模式」或連接 Wi-Fi。".localizedString())
        emptyStateView.isHidden = false
        tableView.isHidden = true
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

    private func handleError(_ error: Error) {
        Utils.toast(error.localizedDescription, at: .center)
//        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//        alert.addAction(okAction)
//        present(alert, animated: true, completion: nil)
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
        let lastRowIndex = tableView.numberOfRows(inSection: 0) - 1
        let lastVisibleRowIndex = tableView.indexPathsForVisibleRows?.last?.row ?? 0

        // 如果目前正在載入中或還沒滑到最底，不做事
        if case .loading = viewModel.state, lastVisibleRowIndex != lastRowIndex {
            return
        }

        // 載入下一頁資料
        viewModel.loadNextPage()
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
        return viewModel.contextMenuConfiguration(forCellAt: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
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
    }
}
