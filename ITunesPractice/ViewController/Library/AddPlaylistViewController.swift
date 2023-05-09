//
//  AddPlaylistViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/8.
//

import Combine
import Photos
import SnapKit
import UIKit

protocol AddPlaylistViewControllerDataSource: AnyObject {
    func playlist(_ vc: AddPlaylistViewController) -> Playlist?
}

// MARK: - AddPlaylistViewController

class AddPlaylistViewController: UIViewController {
    // MARK: Internal

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = AddPlaylistViewModel(dataSource?.playlist(self))
        setupUI()
        setNavigationBar()
        bindViewModel()
        dismissKeyboard()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: Private

    private weak var dataSource: AddPlaylistViewControllerDataSource?
    private var viewModel: AddPlaylistViewModel!
    private let cellHeight: CGFloat = 60
    private var cancellables: Set<AnyCancellable> = []
    private var isEditingMode: Bool = false
    private lazy var menu: UIMenu = {
        ContextMenuManager.shared.createPhotoMenu(self)
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PlaylistInfoCell.self, forCellReuseIdentifier: PlaylistInfoCell.reuseIdentifier)
        tableView.register(AddTrackCell.self, forCellReuseIdentifier: AddTrackCell.reuseIdentifier)
        tableView.register(TrackCell.self, forCellReuseIdentifier: TrackCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .black
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.allowsSelectionDuringEditing = true
        tableView.isEditing = true
        return tableView
    }()

    // MARK: Setup

    private func setupUI() {
        view.backgroundColor = .black
        // 設置 presentation controller 的代理
        navigationController?.presentationController?.delegate = self
        setupLayout()
    }

    private func bindViewModel() {
        viewModel.$tracks
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .combineLatest(viewModel.$imageUrl)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }.store(in: &cancellables)
    }

    private func setNavigationBar() {
        let cancelBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(close))
        let finishBarButtonItem = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem = finishBarButtonItem
        navigationItem.leftBarButtonItem = cancelBarButtonItem
        navigationItem.title = "新增播放列表"
    }

    private func setupLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
    }

    private func confirmCancel() {
        let alert = UIAlertController(title: "新增播放列表", message: "確定要捨棄新的播放列表嗎？", preferredStyle: .actionSheet)
        let abandonAction = UIAlertAction(title: "捨棄所作更動".localizedString(), style: .destructive) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        let continueAction = UIAlertAction(title: "繼續編輯".localizedString(), style: .cancel, handler: nil)
        alert.view.tintColor = .systemRed
        alert.addAction(abandonAction)
        alert.addAction(continueAction)
        present(alert, animated: true, completion: nil)
    }

    @objc
    private func save() {
        viewModel.savePlaylist()
        dismiss(animated: true)
    }

    @objc
    private func close() {
        dismiss(animated: true)
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension AddPlaylistViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.totalCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // 播放清單資訊
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistInfoCell.reuseIdentifier) as? PlaylistInfoCell else {
                return UITableViewCell()
            }
            cell.configure(name: viewModel.name, imageUrl: viewModel.imageUrl, menu: menu)
            cell.textChanged = { [weak self] name in
                self?.viewModel.name = name
            }
            return cell
        } else if indexPath.row == 1 {
            // 新增音樂
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddTrackCell.reuseIdentifier) as? AddTrackCell else {
                return UITableViewCell()
            }
            return cell
        } else {
            // 在播放清單中的音樂
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.reuseIdentifier) as? TrackCell else {
                return UITableViewCell()
            }
            guard let track = viewModel.track(forCellAt: indexPath.row) else {
                return cell
            }
            cell.configure(artworkUrl: track.artworkUrl100, collectionName: track.collectionName, artistName: track.artistName, trackName: track.trackName)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.setSelectedTrack(forCellAt: indexPath.row)
    }

    // 個別 cell 是否進入編輯狀態
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        indexPath.row != 0
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        switch indexPath.row {
        case 0:
            return .none
        case 1:
            return .insert
        default:
            return .delete
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .insert {
            print("__+++++")
        } else if editingStyle == .delete {
            let rows = viewModel.totalCount
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return view.frame.width * 0.6 + 80
        default:
            return cellHeight
        }
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

extension AddPlaylistViewController: UIAdaptivePresentationControllerDelegate {
    /// 是否允許下滑關閉頁面
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        if viewModel.isEdited {
            confirmCancel()
            return false // 禁止關閉
        } else {
            return true // 允許關閉
        }
    }
}

// MARK: Photographable

extension AddPlaylistViewController: Photographable {
    /// 取得相片
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.editedImage] as? UIImage {
            savePhotoToAlbum(image: image)
        }
        dismiss(animated: true)
    }

    /// 將照片存入相簿，並取得照片路徑
    private func savePhotoToAlbum(image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            self.viewModel.assetLocalIdentifier = assetRequest.placeholderForCreatedAsset?.localIdentifier
        }, completionHandler: { success, error in
            if success {
                // 照片已存入相簿
                let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [self.viewModel.assetLocalIdentifier!], options: nil)
                if let asset = fetchResult.firstObject {
                    let options = PHContentEditingInputRequestOptions()
                    options.canHandleAdjustmentData = { (_: PHAdjustmentData) -> Bool in
                        true
                    }
                    asset.requestContentEditingInput(with: options) { contentEditingInput, _ in
                        if let url = contentEditingInput?.fullSizeImageURL {
                            DispatchQueue.main.async {
                                self.viewModel.imageUrl = url
                                self.tableView.reloadData()
                            }
                            print("照片 URL：\(url.absoluteString)")
                        }
                    }
                }
            } else {
                print("保存照片失敗：\(error?.localizedDescription ?? "")")
            }
        })
    }
}
