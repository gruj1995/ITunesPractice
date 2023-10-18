//
//  SearchViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/6.
//

import Combine
import UIKit

// MARK: - SearchViewController

class SearchViewController: UIViewController {
    // MARK: Lifecycle

    // 使用 code 或 Xib 檔案生成 ViewController
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    // 使用 Storyboard 生成 ViewController
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Internal

    override func viewDidLoad() {
        super.viewDidLoad()
//        bindViewModel()
        setupUI()
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
    private var cancellables: Set<AnyCancellable> = .init()
    private lazy var searchSuggestVC: SearchSuggestViewController = .init()
    private lazy var searchResultsVC: SearchResultsViewController = .init()

    private lazy var searchController: UISearchController = {
        // 参数searchResultsController為nil，表示沒有單獨的顯示搜索结果的界面，也就是使用當前畫面顯示
        searchSuggestVC.delegate = self
        let searchController = UISearchController(searchResultsController: searchSuggestVC)
        searchController.searchBar.tintColor = .appColor(.red1)
        searchController.searchBar.barTintColor = .appColor(.red1)
        // barStyle 設為 .black 文字顯示(白色)
        searchController.searchBar.barStyle = .black
        // 預設文字
        searchController.searchBar.placeholder = "搜尋影片".localizedString()
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
        searchController.definesPresentationContext = true
        // 進入搜尋狀態時持續顯示 showsSearchResultsController
        searchController.showsSearchResultsController = true
        // 轉場方式是否由 searchResultsController 決定，預設值為 false 由系統決定
//        searchController.providesPresentationContextTransitionStyle = true
        searchController.searchBar.textField?.delegate = self
        return searchController
    }()

    private func setupUI() {
        view.backgroundColor = .black
        navigationItem.searchController = searchController // 添加搜尋框
        if let searchBar = navigationItem.searchController?.searchBar,
           let textField = searchBar.textField {
            // 調整搜尋框左邊放大鏡顏色
            if let glassIconView = textField.leftView as? UIImageView {
                glassIconView.tintColor = UIColor.lightText
            }
            // 調整 searchBar 取消按鈕的文案
            UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "取消".localizedString()
        }
        view.addSubview(searchResultsVC.view)
        addChild(searchResultsVC)
        searchResultsVC.didMove(toParent: self)
        setupLayout()
    }

    private func setupLayout() {
        searchResultsVC.view.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

//    private func bindViewModel() {
//        viewModel.statePublisher
//            .receive(on: RunLoop.main)
//            .sink { [weak self] state in
//                guard let self else { return }
//                switch state {
//                case .success:
//                    self.updateUI()
//                case .failed(let error):
//                    self.handleError(error)
//                case .loading, .none:
//                    break
//                }
//            }.store(in: &cancellables)
//
//        NetworkMonitor.shared.$isConnected
//            .receive(on: DispatchQueue.main)
//            .removeDuplicates()
//            .sink {  [weak self] _ in
//                self?.updateUI()
//            }.store(in: &cancellables)
//
//        viewModel.app.$downloads
//            .receive(on: RunLoop.main)
//            .sink { [weak self] downloads in
//                guard let self else { return }
//                print("_+__+ \(downloads)")
//            }.store(in: &cancellables)
//    }
//
//    private func updateUI() {
//        searchResultsVC.update
//        if !NetworkMonitor.shared.isConnected {
//            showDisconnectView()
//        } else {
//            emptyStateView.isHidden = true
//        }
//    }

    private func searchVideo(by term: String) {
        // 結束輸入狀態（不進行動畫過度）
        UIView.performWithoutAnimation {
          self.searchController.isActive = false
        }
        guard !term.isEmpty else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let vm = VideoListViewModel(searchTerm: term)
            let vc = VideoListViewController(viewModel: vm)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: SearchSuggestViewControllerDelegate

extension SearchViewController: SearchSuggestViewControllerDelegate {
    // 更改關鍵字
    func didTapAddButton(_ vc: SearchSuggestViewController, keyword: String) {
        searchController.searchBar.text = keyword
    }

    // 搜尋
    func didSelectItemAt(_ vc: SearchSuggestViewController, keyword: String) {
        searchSuggestVC.search(with: nil) // 清空本次搜尋
        viewModel.updateHistoryItems(term: keyword)
        searchVideo(by: keyword)
    }
}

// MARK: UITextFieldDelegate

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let keyword = textField.text ?? ""
        viewModel.updateHistoryItems(term: keyword)
        searchVideo(by: keyword)
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        searchSuggestVC.search(with: newString)
        return true
    }
}
