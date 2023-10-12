//
//  SearchSuggestViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/11.
//

import Combine
import SnapKit
import UIKit

protocol SearchSuggestViewControllerDelegate: AnyObject {
    func didTapAddButton(_ vc: SearchSuggestViewController, item: String)
    func didSelectItemAt(_ vc: SearchSuggestViewController, item: String)
}

// MARK: - SearchSuggestViewController

class SearchSuggestViewController: UIViewController {
    // MARK: Lifecycle

    init() {
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        reloadTracks()
    }

    // MARK: Private

    weak var delegate: SearchSuggestViewControllerDelegate?
    private let viewModel: SearchSuggestViewModel = .init()
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

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SuggestCell.self, forCellReuseIdentifier: SuggestCell.identifier)
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

extension SearchSuggestViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.totalCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SuggestCell.identifier) as? SuggestCell else {
            return UITableViewCell()
        }
        guard let item = viewModel.items[safe: indexPath.row] else {
            return cell
        }
        let image = indexPath.row < viewModel.filteredHistoryItems.count ? AppImages.clockArrowCirclepath : AppImages.magnifyingGlass
        cell.configure(title: item, image: image)
        cell.onArrowButtonTapped = { [weak self] in
            guard let self else { return }
            self.delegate?.didTapAddButton(self, item: item)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.setSelectedItem(forCellAt: indexPath.row)
        if let item = viewModel.selectedItem {
            delegate?.didSelectItemAt(self, item: item)
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView.emptyView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        60
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView.emptyView()
    }
}

// MARK: UISearchResultsUpdating

extension SearchSuggestViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchTerm = searchController.searchBar.text ?? ""
        tableView.scrollToTop(animated: false)
    }
}
