//
//  SearchViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/6.
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
        bindViewModel()
        setupUI()

        NetStatus.shared.netStatusChangeHandler = {
            DispatchQueue.main.async { [unowned self] in
                self.updateUI()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 只有在當前的 navigationBar 的 prefersLargeTitles 属性true時, largeTitleDisplayMode才會起作用
        // 不要寫成 self.navigationController.navigationItem.largeTitleDisplayMode == ...
        navigationController?.navigationBar.prefersLargeTitles = true

        // 捲動時是否隱藏搜尋框
        navigationItem.hidesSearchBarWhenScrolling = false

        navigationItem.title = "搜尋".localizedString()
    }

    // MARK: Private

    private let viewModel: SearchViewModel = .init()

    // 觀察者
    private var cancellables: Set<AnyCancellable> = []

    private lazy var searchResultsVC: SearchResultsViewController = {
        let searchResultsVC = SearchResultsViewController()
        return searchResultsVC
    }()

    private lazy var searchController: UISearchController = {
        // 参数searchResultsController為nil，表示沒有單獨的顯示搜索结果的界面，也就是使用當前畫面顯示
        let searchController = UISearchController(searchResultsController: searchResultsVC)
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
        searchController.searchResultsUpdater = searchResultsVC
        // 搜尋框進入搜尋狀態時，要不要在當前頁面上顯示一層半透明遮罩(會擋住點擊)
        searchController.obscuresBackgroundDuringPresentation = false
        // searchResultsController 是否被加入此VC的view層級中，並跟隨VC生命週期。預設值為false
        searchController.definesPresentationContext = false
        // 轉場方式是否由 searchResultsController 決定，預設值為 false 由系統決定
//        searchController.providesPresentationContextTransitionStyle = true
        return searchController
    }()

    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.isHidden = true
        return view
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
        viewModel.statePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .loading:
                    break
//                    self.tableView.reloadData()
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
        if !NetStatus.shared.isConnected {
            showEmptyView()
        }
//        if viewModel.totalCount == 0, !viewModel.searchTerm.isEmpty {
//            showNoResultView()
//        } else if !NetStatus.shared.isConnected {
//            showEmptyView()
//        } else {
//            showTableView()
//        }
    }

    private func showTableView() {
//        tableView.isHidden = false
        emptyStateView.isHidden = true
//        tableView.reloadData()
    }

    private func showNoResultView() {
        emptyStateView.configure(title: "沒有結果".localizedString(), message: "嘗試新的搜尋項目。".localizedString())
        emptyStateView.isHidden = false
//        tableView.isHidden = true
    }

    private func showEmptyView() {
        emptyStateView.configure(title: "您已離線".localizedString(), message: "關閉「飛航模式」或連接 Wi-Fi。".localizedString())
        emptyStateView.isHidden = false
//        tableView.isHidden = true
    }

    private func setupLayout() {
//        view.addSubview(tableView)
//        tableView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }

        view.addSubview(emptyStateView)
        emptyStateView.snp.makeConstraints { make in
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.centerY.equalTo(view.safeAreaLayoutGuide).multipliedBy(0.9)
            make.width.equalToSuperview().multipliedBy(0.8)
        }
    }

    private func handleError(_ error: Error) {
        Utils.toast(error.localizedDescription, at: .center)
    }
}
