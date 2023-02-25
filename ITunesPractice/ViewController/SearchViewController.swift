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

class SearchViewController: UIViewController {
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
        observe()
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    // MARK: Private

    // 觀察者
    private var cancellables: Set<AnyCancellable> = []

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TrackCell.self, forCellReuseIdentifier: TrackCell.reuseIdentifier)
        tableView.rowHeight = 60
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
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

    private let viewModel: SearchViewModel = .init()

    private func setupUI() {
        view.backgroundColor = .black

        // 只有在當前的 navigationBar 的 prefersLargeTitles 属性为true/YES时, largeTitleDisplayMode才會起作用
        // 注意: 不要寫成 self.navigationController.navigationItem.largeTitleDisplayMode == ...
        navigationController?.navigationBar.prefersLargeTitles = true

        // 添加搜尋框
        navigationItem.searchController = searchController

        // 捲動時是否隱藏搜尋框
        navigationItem.hidesSearchBarWhenScrolling = false

        navigationItem.title = "搜尋".localizedString()
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

    private func observe() {
        viewModel.$tracks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.tableView.reloadData()
            }.store(in: &cancellables)
    }

    private func setupLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing
                .equalToSuperview()
        }
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.reuseIdentifier) as? TrackCell
        else {
            return UITableViewCell()
        }
        let track = viewModel.tracks[indexPath.row]
        cell.configure(artworkUrl: track.artworkUrl, collectionName: track.collectionName, artistName: track.artistName, trackName: track.trackName)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 解除cell被選中的狀態
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Hami change: remove cell's themed background color
//        cell.contentView.backgroundColor = .black
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }
}

// MARK: UISearchResultsUpdating

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.search(text: searchController.searchBar.text)
    }
}
