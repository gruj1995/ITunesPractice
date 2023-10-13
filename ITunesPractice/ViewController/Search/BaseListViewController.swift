//
//  BaseListViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/13.
//

import Combine
import UIKit

// MARK: - BaseListViewController

class BaseListViewController<VM: BaseListViewModel>: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: Lifecycle

    init(viewModel: VM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        bindViewModel()
    }

    // MARK: Private

    let viewModel: BaseListViewModel
    var cancellables: Set<AnyCancellable> = .init()

    // 下拉 tableView 更新資料
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .lightGray
        let attributedString = NSAttributedString(string: "更新資料".localizedString(), attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
            NSAttributedString.Key.foregroundColor: UIColor.lightGray
        ])
        refreshControl.attributedTitle = attributedString
        refreshControl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        refreshControl.addTarget(self, action: #selector(reloadItems), for: .valueChanged)
        return refreshControl
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag // 捲動就隱藏鍵盤
        tableView.addSubview(refreshControl)
        return tableView
    }()

    lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.configure(title: "沒有結果".localizedString(), message: "嘗試新的搜尋項目。".localizedString())
        view.isHidden = true
        return view
    }()

    // MARK: Setup

    func setupUI() {
        view.backgroundColor = .appColor(.background)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
    }

    func setupLayout() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        emptyStateView.snp.makeConstraints { make in
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.centerY.equalTo(view.safeAreaLayoutGuide).multipliedBy(0.9)
            make.width.equalToSuperview().multipliedBy(0.8)
        }
    }

    func bindViewModel() {
        viewModel.statePublisher
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
    func updateUI() {
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

    func showTableView() {
        emptyStateView.isHidden = true
        tableView.isHidden = false
    }

    func showNoResultView() {
        emptyStateView.isHidden = false
        tableView.isHidden = true
    }

    func handleError(_ error: Error) {
        refreshControl.endRefreshing()
        tableView.tableFooterView = nil
        showNoResultView()
        if NetworkMonitor.shared.isConnected {
            Utils.toast(error.localizedDescription, at: .center)
        }
    }

    @objc
    func reloadItems() {
        viewModel.reloadItems()
    }

    // MARK: UITableViewDataSource, UITableViewDelegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.totalCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return
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

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        return
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        return
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        nil
    }
}
