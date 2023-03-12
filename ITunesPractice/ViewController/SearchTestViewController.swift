//
//  SearchViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/17.
//

import Combine
import SnapKit
import UIKit

// MARK: - SearchViewController

class SearchTestViewController: UIViewController {
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
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 只有在當前的 navigationBar 的 prefersLargeTitles 属性为true/YES时, largeTitleDisplayMode才會起作用
        // 注意: 不要寫成 self.navigationController.navigationItem.largeTitleDisplayMode == ...
        navigationController?.navigationBar.prefersLargeTitles = true

        // 捲動時是否隱藏搜尋框
        navigationItem.hidesSearchBarWhenScrolling = false

        navigationItem.title = "搜尋".localizedString()
    }

    // MARK: Private

    private let viewModel: SearchTestViewModel = .init()

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

    private lazy var searchController: UISearchController = {
        // 参数searchResultsController為nil，表示沒有單獨的顯示搜索结果的界面，也就是使用當前畫面顯示
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.tintColor = .appColor(.red1)
        searchController.searchBar.barTintColor = .appColor(.red1)
        // barStyle 設為 .black 文字顯示(白色)
        searchController.searchBar.barStyle = .black
        // 預設文字
        searchController.searchBar.placeholder = "歌曲".localizedString()
        // 搜尋框樣式: .minimal -> SearchBar 沒有背景，且搜尋欄位為半透明
        searchController.searchBar.searchBarStyle = .minimal
        // 首字自動變大寫
        searchController.searchBar.autocapitalizationType = .none
        // 搜尋時是否隱藏 NavigationBar
        searchController.hidesNavigationBarDuringPresentation = true
        // 監聽搜尋事件
        searchController.searchResultsUpdater = self
        // 搜尋框進入搜尋狀態時，要不要在當前頁面上顯示一層半透明遮罩(會擋住點擊)
        searchController.obscuresBackgroundDuringPresentation = false
        // 搜尋期間底層是否變暗
//        searchController.dimsBackgroundDuringPresentation = false
//        searchController.definesPresentationContext = true
//        searchController.providesPresentationContextTransitionStyle = true
        return searchController
    }()

    private func setupUI() {
        view.backgroundColor = .black

        // 添加搜尋框
        navigationItem.searchController = searchController

        if let searchBar = navigationItem.searchController?.searchBar,
           let textField = searchBar.textField {
            // 調整搜尋框左邊放大鏡顏色
            if let glassIconView = textField.leftView as? UIImageView {
                glassIconView.tintColor = UIColor.lightText
            }
            // 調整 searchBar 取消按鈕的文案
            UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "取消".localizedString()
        }
        setupLayout()
    }

    private func bindViewModel() {
        viewModel.$items
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    private func setupLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension SearchTestViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.reuseIdentifier) as? TrackCell
        else {
            fatalError()
        }
        let track = viewModel.items[indexPath.row]
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
//         let currentCount = viewModel.tracks.count
//         if indexPath.row == currentCount - 1 {
//             viewModel.search()
//         }
        guard indexPath.row >= viewModel.items.count - 1 else {
            return
        }
        viewModel.loadMoreItems { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let newItems):
                let newIndexPaths = (self.viewModel.items.count - newItems.count..<self.viewModel.items.count).map {
                    IndexPath(row: $0, section: 0)
                }
                DispatchQueue.main.async {
                    tableView.insertRows(at: newIndexPaths, with: .automatic)
                }
            case .failure(let error):
                print("Failed to load more items: \(error.localizedDescription)")
            }
        }
    }

//    // 當用戶滾動時，將在main thread上調用此方法，為可能顯示的單元格提供索引路徑
//    // 使用此方法的實現來啟動任何昂貴的數據加載操作
//    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
//        guard let lastIndexPath = indexPaths.last, lastIndexPath.row >= viewModel.items.count - 1 else {
//            return
//        }
//
//        viewModel.loadMoreItems { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let newItems):
//                let newIndexPaths = (self.viewModel.items.count - newItems.count..<self.viewModel.items.count).map {
//                    IndexPath(row: $0, section: 0)
//                }
//                DispatchQueue.main.async {
//                    self.tableView.insertRows(at: newIndexPaths, with: .automatic)
//                }
//            case .failure(let error):
//                print("Failed to load more items: \(error.localizedDescription)")
//            }
//        }
//    }
    
    /*
     * 點擊 context menu 的預覽圖後觸發，如果沒實作此 funtion，則點擊預覽圖後直接關閉 context menu
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

// MARK: UISearchResultsUpdating

extension SearchTestViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchTerm = searchController.searchBar.text ?? ""
    }
}

// MARK: TrackDetailViewControllerDatasource

extension SearchTestViewController: TrackDetailViewControllerDatasource {
    func trackId(_ trackDetailViewController: TrackDetailViewController) -> Int? {
        return viewModel.selectedTrack?.trackId
    }
}
