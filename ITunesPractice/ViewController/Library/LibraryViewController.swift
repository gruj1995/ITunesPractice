//
//  LibraryViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Combine
import SnapKit
import UIKit

// MARK: - LibraryViewController

class LibraryViewController: UIViewController {
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.title = ""
    }

    // MARK: Private

    private let viewModel: LibraryViewModel = .init()
    private var cancellables: Set<AnyCancellable> = []
    private var isEditingMode: Bool = false
    private let cellSpacing: CGFloat = 15
    private let columnCount: Double = 2
    private let sectionPadding: Double = 20

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = cellSpacing
        layout.minimumInteritemSpacing = cellSpacing
        layout.sectionInset = UIEdgeInsets(top: 14, left: sectionPadding, bottom: 80, right: sectionPadding)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PlaylistCell.self, forCellWithReuseIdentifier: PlaylistCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private lazy var addBarButtonItem: UIBarButtonItem = .init(image: AppImages.plus?.withConfiguration(roundConfiguration2), style: .plain, target: self, action: #selector(createPlaylist))

    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.isHidden = true
        return view
    }()

    // MARK: Setup

    private func setupUI() {
        view.backgroundColor = .black
        navigationItem.rightBarButtonItem = addBarButtonItem
        setupLayout()
    }

    private func bindViewModel() {
        // 使用 $ 屬性獲取 @Published 屬性的 Publisher，監聽資料模型的變化
        viewModel.$playlists
            .receive(on: RunLoop.main)
            .sink { [weak self] playlists in
                if playlists.isEmpty {
                    self?.showNoResultView()
                } else {
                    self?.showCollectionView()
                }
            }.store(in: &cancellables)
    }

    private func showCollectionView() {
        emptyStateView.isHidden = true
        collectionView.isHidden = false
        collectionView.reloadData()
    }

    private func showNoResultView() {
        emptyStateView.configure(title: "尚無資料".localizedString(), message: "趕快建立播放清單吧".localizedString())
        emptyStateView.isHidden = false
        collectionView.isHidden = true
    }

    private func setupLayout() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.bottom.leading.trailing.equalToSuperview()
        }

        view.addSubview(emptyStateView)
        emptyStateView.snp.makeConstraints { make in
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.centerY.equalTo(view.safeAreaLayoutGuide).multipliedBy(0.9)
            make.width.equalToSuperview().multipliedBy(0.8)
        }
    }

    @objc
    private func createPlaylist() {
        let vc = AddPlaylistViewController(displayMode: .add, playlist: nil)
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .pageSheet
        present(navVC, animated: true)
    }

    @objc
    private func showPlaylist() {
        let vc = AddPlaylistViewController(displayMode: .normal, playlist: viewModel.selectedPlaylist)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource

extension LibraryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.totalCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistCell.reuseIdentifier, for: indexPath) as? PlaylistCell else {
            return UICollectionViewCell()
        }
        guard let playlist = viewModel.item(forCellAt: indexPath.item) else {
            return cell
        }
        cell.configure(playlist)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.setSelectedItem(forCellAt: indexPath.item)
        showPlaylist()
//        let vc = LibraryPlaylistViewController()
//        navigationController?.pushViewController(vc, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        viewModel.setSelectedItem(forCellAt: indexPath.item)

        guard let playlist = viewModel.item(forCellAt: indexPath.item) else {
            return nil
        }
        return PlaylistContextMenuConfiguration(indexPath: indexPath, playlist: playlist).createContextMenuConfiguration()
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension LibraryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = floor((collectionView.bounds.width - cellSpacing * (columnCount - 1) - (sectionPadding * 2)) / columnCount)
        let height = width + 50
        return CGSize(width: width, height: height)
    }
}
