//
//  AddPlaylistViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/8.
//

import Combine
import SnapKit
import UIKit

// MARK: - AddPlaylistViewController

class AddPlaylistViewController: UIViewController {
    // MARK: Lifecycle

    init(displayMode: DisplayMode, playlist: Playlist?) {
        viewModel = AddPlaylistViewModel(
            displayMode: displayMode,
            playlist: playlist)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Internal

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

    private var viewModel: AddPlaylistViewModel!
    private let cellHeight: CGFloat = 60
    private var cancellables: Set<AnyCancellable> = []
    private var isEditingMode: Bool = false
    private lazy var photoMenu: UIMenu = ContextMenuManager.shared.createPhotoMenu(self)

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(EditPlaylistInfoCell.self, forCellReuseIdentifier: EditPlaylistInfoCell.reuseIdentifier)
        tableView.register(PlaylistInfoCell.self, forCellReuseIdentifier: PlaylistInfoCell.reuseIdentifier)
        tableView.register(AddTrackCell.self, forCellReuseIdentifier: AddTrackCell.reuseIdentifier)
        tableView.register(TrackCell.self, forCellReuseIdentifier: TrackCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .black
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        return tableView
    }()

    private lazy var menuBarButtonItem: UIBarButtonItem = {
        let playlistMenu = ContextMenuManager.shared.createPlaylistMenu(viewModel.playlist) { [weak self] in
            self?.viewModel.toggleDisplayMode()
        }
        let barButtonItem = UIBarButtonItem(image: nil, primaryAction: nil, menu: playlistMenu)
        barButtonItem.image = AppImages.ellipsis
        return barButtonItem
    }()

    private lazy var cancelBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancel))

    private lazy var finishBarButtonItem = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(finish))

    // MARK: Setup

    private func setupUI() {
        view.backgroundColor = .black
        // 在delegate實作避免下滑關閉的邏輯
        navigationController?.presentationController?.delegate = self
        setupLayout()
    }

    private func bindViewModel() {
        // TODO: 照片第一次進來有時會是蘑菇貓
        viewModel.$tracks
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .combineLatest(viewModel.$imageUrl)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }.store(in: &cancellables)

        viewModel.currentTrackIndexPublisher
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .combineLatest(viewModel.isPlayingPublisher)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }.store(in: &cancellables)

        viewModel.$displayMode
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.updateUI()
            }.store(in: &cancellables)
    }

    private func setNormalNavigationBar() {
        navigationItem.rightBarButtonItem = menuBarButtonItem
        navigationItem.leftBarButtonItem = nil
        navigationItem.title = ""
    }

    private func setEditableNavigationBar() {
        navigationItem.rightBarButtonItem = finishBarButtonItem
        navigationItem.leftBarButtonItem = cancelBarButtonItem
        navigationItem.title = viewModel.displayMode == .add ? "新增播放列表" : ""
    }

    private func setupLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
    }

    private func updateUI() {
        tableView.isEditing = viewModel.displayMode != .normal
        tableView.reloadData()

        if viewModel.displayMode == .normal {
            setNormalNavigationBar()
        } else {
            setEditableNavigationBar()
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
    private func finish() {
        if viewModel.displayMode == .add {
            viewModel.savePlaylist()
            dismiss(animated: true)
        } else {
            viewModel.toggleDisplayMode()
        }
    }

    @objc
    private func cancel() {
        if viewModel.displayMode == .add {
            dismiss(animated: true)
        } else {
            viewModel.toggleDisplayMode()
        }
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension AddPlaylistViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.totalCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = viewModel.cellType(forCellAt: indexPath.row)
        switch cellType {
        // 顯示播放清單資訊
        case .showPlaylistInfo:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistInfoCell.reuseIdentifier) as? PlaylistInfoCell else {
                return UITableViewCell()
            }
            cell.configure(
                name: viewModel.name,
                imageUrl: viewModel.imageUrl)
            // 播放
            cell.onPlayButtonTapped = { [weak self] _ in
                guard let self else { return }
                let firstTrackIndex = self.viewModel.prefixItemCount
                self.viewModel.setSelectedTrack(forCellAt: firstTrackIndex)
                self.viewModel.refreshPlaylistAndPlaySong(at: 0)
            }
            return cell

        // 編輯播放清單資訊
        case .editPlaylistInfo:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EditPlaylistInfoCell.reuseIdentifier) as? EditPlaylistInfoCell else {
                return UITableViewCell()
            }
            cell.configure(
                name: viewModel.name,
                imageUrl: viewModel.imageUrl,
                menu: photoMenu)
            cell.textChanged = { [weak self] name in
                self?.viewModel.name = name
            }
            return cell

        // 新增音樂
        case .addTrack:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddTrackCell.reuseIdentifier) as? AddTrackCell else {
                return UITableViewCell()
            }
            return cell

        // 在播放清單中的音樂
        case .track:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.reuseIdentifier) as? TrackCell else {
                return UITableViewCell()
            }
            guard let track = viewModel.track(forCellAt: indexPath.row) else {
                return cell
            }
            cell.configure(artworkUrl: track.artworkUrl100, collectionName: track.collectionName, artistName: track.artistName, trackName: track.trackName)
            // 被選中的歌曲顯示播放動畫
            let showAnimation = (track == viewModel.selectedTrack)
            let isPlaying = viewModel.isPlaying
            cell.updateAnimationState(showAnimation: showAnimation, isPlaying: isPlaying)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.setSelectedTrack(forCellAt: indexPath.row)

        let cellType = viewModel.cellType(forCellAt: indexPath.row)
        switch cellType {
        case .track:
            viewModel.refreshPlaylistAndPlaySong(at: indexPath.row)
        default:
            return
        }
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
        switch viewModel.cellType(forCellAt: indexPath.row) {
        case .track:
            return cellHeight
        default:
            return UITableView.automaticDimension
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
        guard let image = (info[.editedImage] as? UIImage) else {
            Logger.log("圖片為空")
            return
        }
        picker.dismiss(animated: true) {
            PhotoManager.shared.savePhotoToAlbum(image: image) { [weak self] url in
                self?.viewModel.imageUrl = url
                self?.tableView.reloadData()
            }
        }
    }
}
