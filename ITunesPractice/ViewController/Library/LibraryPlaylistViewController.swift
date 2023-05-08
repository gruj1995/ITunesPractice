//
//  LibraryPlaylistViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/8.
//

import Combine
import SnapKit
import UIKit

// MARK: - LibraryPlaylistViewController

class LibraryPlaylistViewController: UIViewController {
    // MARK: Internal

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "資料庫".localizedString()
    }

    // MARK: Private

    private let viewModel: LibraryPlaylistViewModel = .init()
    private let cellHeight: CGFloat = 60
    private var cancellables: Set<AnyCancellable> = []
    private var isEditingMode: Bool = false

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TrackCell.self, forCellReuseIdentifier: TrackCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = cellHeight
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        /*
         - StoryBoard 中，除了 Row Height 是預設 Automatic 自動計算的，Header Height 和 Footer Height 都不是預設 Automatic
         - 如果純 code 拉 tableView，預設都是 Automatic，所以下面要將 estimatedSectionFooterHeight 設置為0才能讓 heightForFooterInSection 生效
          */
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.allowsMultipleSelection = true // 允許多選
        tableView.allowsMultipleSelectionDuringEditing = true // 允許編輯模式時可以多選cell
        return tableView
    }()

    private lazy var editBarButtonItem: UIBarButtonItem = .init(title: "編輯".localizedString(), style: .plain, target: self, action: #selector(toggleEditMode))

    private lazy var menuBarButtonItem: UIBarButtonItem = {
        let menu = ContextMenuManager.shared.createLibraryMenu([])
        let barButtonItem = UIBarButtonItem(image: nil, primaryAction: nil, menu: menu)
        return barButtonItem
    }()

    // MARK: Setup

    private func setupUI() {
        view.backgroundColor = .black
        navigationItem.rightBarButtonItems = [editBarButtonItem, menuBarButtonItem]
        setupLayout()
    }

    private func bindViewModel() {
        // 使用 $ 屬性獲取 @Published 屬性的 Publisher，監聽資料模型的變化
        viewModel.$tracks
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }.store(in: &cancellables)
    }

    private func setupLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing
                .equalToSuperview()
        }
    }

    private func updateMenuBarButtonItem() {
        let menu = ContextMenuManager.shared.createLibraryMenu(viewModel.selectedTracks)
        menuBarButtonItem.menu = menu
    }

    @objc
    private func toggleEditMode() {
        isEditingMode.toggle()
        tableView.isEditing = isEditingMode
        menuBarButtonItem.image = isEditingMode ? AppImages.ellipsis : nil
        navigationItem.rightBarButtonItem?.title = isEditingMode ? "完成".localizedString() : "編輯".localizedString()
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension LibraryPlaylistViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tracks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.reuseIdentifier) as? TrackCell else {
            return UITableViewCell()
        }
        guard let track = viewModel.track(forCellAt: indexPath.row) else {
            return cell
        }
        cell.configure(artworkUrl: track.artworkUrl100, collectionName: track.collectionName, artistName: track.artistName, trackName: track.trackName)
        cell.accessoryType = .disclosureIndicator // 右側箭頭
        cell.selectionStyle = .default // 要顯示多選的勾選效果需要 selectionStyle 為 .default
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditingMode {
            viewModel.selectedIndicies.append(indexPath)
            updateMenuBarButtonItem()
        } else {
            // 解除cell被選中的狀態
            tableView.deselectRow(at: indexPath, animated: true)
            viewModel.setSelectedTrack(forCellAt: indexPath.row)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if isEditingMode {
            viewModel.selectedIndicies.removeAll { $0 == indexPath }
            updateMenuBarButtonItem()
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let rows = viewModel.tracks.count
            viewModel.removeTrack(forCellAt: indexPath.row)
            if rows == 1 {
                tableView.reloadData()
            } else {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        "移除"
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        10
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView.emptyView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        cellHeight
    }

    /*
     點擊 context menu 的預覽圖後觸發，如果沒實作此 funtion，則點擊預覽圖後直接關閉 context menu
     - animator  跳轉動畫執行者，可以添加要跳轉到的頁面和跳轉動畫
     */
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion { [weak self] in
            let vc = TrackDetailViewController()
            vc.dataSource = self
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }

    // context menu 的清單
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        viewModel.setSelectedTrack(forCellAt: indexPath.row)
        return tableView.createTrackContextMenuConfiguration(indexPath: indexPath, track: viewModel.selectedTrack)
    }
}

// MARK: TrackDetailViewControllerDatasource

extension LibraryPlaylistViewController: TrackDetailViewControllerDatasource {
    func track(_ trackDetailViewController: TrackDetailViewController) -> Track? {
        return viewModel.selectedTrack
    }
}
