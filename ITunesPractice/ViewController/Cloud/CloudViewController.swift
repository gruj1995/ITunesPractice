//
//  CloudViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/7.
//

// import MobileCoreServices
import UIKit
import SafariServices // Google Drive

// MARK: - CloudViewController

class CloudViewController: UIViewController {
    // MARK: Internal

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "雲端資源".localizedString()
    }

    // MARK: Private

    private let viewModel: CloudViewModel = .init()
    private let cellHeight: CGFloat = 60

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CloudOptionCell.self, forCellReuseIdentifier: CloudOptionCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = cellHeight
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        return tableView
    }()

    // MARK: Setup

    private func setupUI() {
        view.backgroundColor = .black
        setupLayout()
    }

    private func bindViewModel() {
//        // 使用 $ 屬性獲取 @Published 屬性的 Publisher，監聽資料模型的變化
//        viewModel.$tracks
//            .receive(on: RunLoop.main)
//            .sink { [weak self] _ in
//                self?.tableView.reloadData()
//            }.store(in: &cancellables)
    }

    private func setupLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing
                .equalToSuperview()
        }
    }

    private func presentOptionVC(_ option: CloudOption) {
        switch option {
        case .iCloud:
            presentICloudPickerVC()
        case .googleDrive:
            presentGoogleDriveVC()
        }
    }

    /// 文件選取頁面
    private func presentICloudPickerVC() {
        // asCopy 為 true 才能存取檔案
        let vc = UIDocumentPickerViewController(forOpeningContentTypes: Utils.allUTITypes(), asCopy: true)
        vc.allowsMultipleSelection = true // 允許多選
        vc.delegate = self
        present(vc, animated: true)
    }

    /// Google Drive 頁面
    private func presentGoogleDriveVC() {
        if let url = URL(string: "https://drive.google.com") {
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true)
        }
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension CloudViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.totalCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CloudOptionCell.reuseIdentifier) as? CloudOptionCell else {
            return UITableViewCell()
        }
        guard let cloudOption = viewModel.cloudOption(forCellAt: indexPath.row) else {
            return cell
        }
        cell.configure(option: cloudOption)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 解除cell被選中的狀態
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cloudOption = viewModel.cloudOption(forCellAt: indexPath.row) else {
            return
        }
        presentOptionVC(cloudOption)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView.emptyView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return cellHeight
    }
}

// MARK: UIDocumentPickerDelegate

extension CloudViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let tracks = viewModel.convertToTracks(urls: urls)
        if tracks.isEmpty {
            Utils.toast("不支援的檔案格式")
        } else {
            UserDefaults.defaultPlaylist.tracks.append(contentsOf: tracks)
            Utils.toast("新增檔案成功！")
        }
    }
}
