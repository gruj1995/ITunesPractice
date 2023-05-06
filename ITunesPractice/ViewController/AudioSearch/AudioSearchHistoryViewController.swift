//
//  AudioSearchHistoryViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/6.
//

import Combine
import SnapKit
import UIKit

// MARK: - AudioSearchHistoryViewController

class AudioSearchHistoryViewController: UIViewController {
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

    private let viewModel: AudioSearchHistoryViewModel = .init()
    private var cancellables: Set<AnyCancellable> = .init()

    private let cellHeight: CGFloat = 60

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(TrackCell.self, forCellReuseIdentifier: TrackCell.reuseIdentifier)
        tableView.rowHeight = cellHeight
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag // 捲動就隱藏鍵盤
        return tableView
    }()

    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.isHidden = true
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "近期 Shazam"
        label.textAlignment = .left
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()

    // MARK: Setup

    private func setupUI() {
        view.backgroundColor = .black
        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(30)
            make.leading.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.bottom.trailing.leading.equalToSuperview()
        }

        view.addSubview(emptyStateView)
        emptyStateView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.9)
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
    }

    @objc
    private func updateUI() {
        if viewModel.totalCount == 0 {
            showNoResultView()
        } else {
            tableView.reloadData()
            showTableView()
        }
    }

    private func showTableView() {
        emptyStateView.isHidden = true
        tableView.isHidden = false
    }

    private func showNoResultView() {
        emptyStateView.configure(title: "尚無搜尋記錄".localizedString(), message: "快去 Shazam 一些音樂吧！".localizedString())
        emptyStateView.isHidden = false
        tableView.isHidden = true
    }

    private func handleError(_ error: Error) {
        showNoResultView()
        if NetworkMonitor.shared.isConnected {
            Utils.toast(error.localizedDescription, at: .center)
        }
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension AudioSearchHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.trackDayGroups.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.trackDayGroup(forHeaderAt: section)?.value.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.reuseIdentifier) as? TrackCell
        else {
            return UITableViewCell()
        }
        guard let track = viewModel.track(forCellAt: indexPath) else {
            return cell
        }
        // 右邊選單按鈕
        cell.addRightMenuButton(track)
        cell.configure(artworkUrl: track.artworkUrl100, collectionName: track.collectionName, artistName: track.artistName, trackName: track.trackName, showsHighlight: true)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 解除cell被選中的狀態
        tableView.deselectRow(at: indexPath, animated: true)
    }

    /*
     點擊 context menu 的預覽圖後觸發，如果沒實作此 funtion，則點擊預覽圖後直接關閉 context menu
     - animator  跳轉動畫執行者，可以添加要跳轉到的頁面和跳轉動畫
     */
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
            animator.addCompletion { [weak self] in
                guard let self else { return }
                let vc = TrackDetailViewController()
                vc.dataSource = self
                // 由父VC push
                self.presentingViewController?.navigationController?.pushViewController(vc, animated: true)
            }
    }

    // context menu 的清單
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        viewModel.setSelectedTrack(forCellAt: indexPath)
        return tableView.createTrackContextMenuConfiguration(indexPath: indexPath, track: viewModel.selectedTrack)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let trackDayGroup = viewModel.trackDayGroup(forHeaderAt: section) else {
            return nil
        }
        return trackDayGroup.key.toString(dateFormat: "yyyy/M/d")
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let rows = viewModel.trackDayGroup(forHeaderAt: indexPath.section)?.value.count ?? 0
            viewModel.removeTrack(forCellAt: indexPath)

            // 當 section 只剩一個 row 時，使用 deleteRows 會 crash，要改用 deleteSections
            if rows == 1 {
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
            } else {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        "移除"
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView.emptyView()
    }
}

// MARK: TrackDetailViewControllerDatasource

extension AudioSearchHistoryViewController: TrackDetailViewControllerDatasource {
    func trackId(_ trackDetailViewController: TrackDetailViewController) -> Int? {
        return viewModel.selectedTrack?.trackId
    }
}

extension Date {
    func getDisplayLastestTime() -> String {
        let currentTime = Int(Date().timeIntervalSince1970)
        let diffTime = currentTime - Int(timeIntervalSince1970)

        if diffTime >= 172800 {
            // 超過2天

            DateUtility.dateFormatter.dateFormat = "MM月dd日"
            return DateUtility.dateFormatter.string(from: self)
        } else if diffTime > 86400, diffTime < 172800 {
            // 大於等於1天
            return NSLocalizedString("昨天", comment: "")
        } else if diffTime >= 3600 {
            // 大於等於1小
            return NSLocalizedString("\(diffTime / 3600)小時前", comment: "")
        } else if diffTime > 60 {
            // 最少顯示一分鐘
            return NSLocalizedString("\(diffTime / 60)分鐘前", comment: "")
        } else if diffTime > 0 {
            return NSLocalizedString("剛剛", comment: "")
        }

        return "剛剛"
    }
}
