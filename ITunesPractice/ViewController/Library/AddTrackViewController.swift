//
//  AddTrackViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/21.
//

import Combine
import SnapKit
import UIKit

// MARK: - AddTrackViewControllerDelegate

protocol AddTrackViewControllerDelegate: AnyObject {
    func didFinish(_ vc: AddTrackViewController, select tracks: [Track])
}

// MARK: - AddTrackViewController

class AddTrackViewController: UIViewController {
    // MARK: Lifecycle

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    weak var delegate: AddTrackViewControllerDelegate?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        dismissKeyboard()
    }

    // MARK: Private

    private var viewModel: AddTrackViewModel = .init()
    private var cancellables: Set<AnyCancellable> = .init()
    private let cellHeight: CGFloat = 60

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TrackCell.self, forCellReuseIdentifier: TrackCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .black
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.allowsMultipleSelection = true // 允許多選
        return tableView
    }()

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.tintColor = .appColor(.red1)
        searchController.searchBar.barTintColor = .appColor(.red1)
        // barStyle 設為 .black 文字顯示(白色)
        searchController.searchBar.barStyle = .black
        // 預設文字
        searchController.searchBar.placeholder = "搜尋".localizedString()
        // 搜尋框樣式: .minimal -> SearchBar 沒有背景，且搜尋欄位為半透明
        searchController.searchBar.searchBarStyle = .minimal
        // 首字自動變大寫
        searchController.searchBar.autocapitalizationType = .none
        // 搜尋時是否隱藏 NavigationBar
        searchController.hidesNavigationBarDuringPresentation = true
        // 監聽搜尋事件
        searchController.searchResultsUpdater = self
        return searchController
    }()

    private lazy var finishBarButtonItem = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(finish))

    // MARK: Setup

    private func setupUI() {
        view.backgroundColor = .black
        setNavigationBar()
        setupLayout()
    }

    private func setNavigationBar() {
        navigationItem.title = "加入音樂"
        navigationItem.searchController = searchController
        navigationItem.rightBarButtonItem = finishBarButtonItem
        // 在delegate實作避免下滑關閉的邏輯
        navigationController?.presentationController?.delegate = self
    }

    private func setupLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
    }

    private func bindViewModel() {
        viewModel.$filteredTracks
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.updateUI()
            }.store(in: &cancellables)
    }

    private func updateUI() {
        tableView.reloadData()
    }

    private func confirmCancel() {
        let alert = UIAlertController(title: "確定要捨棄此所選範圍嗎？", message: nil, preferredStyle: .alert)
        let abandonAction = UIAlertAction(title: "捨棄所選範圍".localizedString(), style: .destructive) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        let continueAction = UIAlertAction(title: "保留選取".localizedString(), style: .cancel, handler: nil)
        alert.view.tintColor = .systemRed
        alert.addAction(abandonAction)
        alert.addAction(continueAction)
        present(alert, animated: true, completion: nil)
    }

    @objc
    private func finish() {
        delegate?.didFinish(self, select: viewModel.selectedTracks)
        dismiss(animated: true)
    }

    @objc
    private func cancel() {
        dismiss(animated: true)
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension AddTrackViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.totalCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.reuseIdentifier) as? TrackCell else {
            return UITableViewCell()
        }
        guard let track = viewModel.track(forCellAt: indexPath.row) else {
            return cell
        }

        cell.configure(artworkUrl: track.artworkUrl100, collectionName: track.collectionName, artistName: track.artistName, trackName: track.trackName)

        // 右側圖片
        let isSelected = viewModel.isSelected(track)
        let image = isSelected ? AppImages.checkmark : AppImages.plusCircle
        cell.accessoryView = UIImageView(image: image)
        cell.tintColor = .appColor(.red1)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.toggleSelect(forCellAt: indexPath.row)
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        cellHeight
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        5
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView.emptyView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        cellHeight
    }
}

// MARK: UIAdaptivePresentationControllerDelegate

extension AddTrackViewController: UIAdaptivePresentationControllerDelegate {
    /// 是否允許下滑關閉頁面
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        if viewModel.isModified {
            confirmCancel()
            return false // 禁止關閉
        } else {
            return true // 允許關閉
        }
    }
}

// MARK: UISearchResultsUpdating

extension AddTrackViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchTerm = searchController.searchBar.text ?? ""
        tableView.scrollToTop(animated: false)
    }
}
