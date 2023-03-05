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
        observe()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "資料庫".localizedString()

        // TODO: 改成combine
        viewModel.loadTracksFromUserDefaults()
    }

    // MARK: Private

    private let viewModel: LibraryViewModel = .init()

    private var cancellables: Set<AnyCancellable> = []

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TrackCell.self, forCellReuseIdentifier: TrackCell.reuseIdentifier)
        tableView.rowHeight = 60
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        return tableView
    }()

    private func setupUI() {
        view.backgroundColor = .black

        setupLayout()
    }

    private func observe() {
        // 使用 $ 屬性獲取 @Published 屬性的 Publisher，監聽數據模型的變化
        viewModel.$tracks
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.tableView.reloadData()
            }.store(in: &cancellables)
    }

    private func setupLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing
                .equalToSuperview()
        }
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension LibraryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tracks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.reuseIdentifier) as? TrackCell
        else {
            fatalError()
        }
        let track = viewModel.tracks[indexPath.row]
        cell.configure(artworkUrl: track.artworkUrl100, collectionName: track.collectionName, artistName: track.artistName, trackName: track.trackName)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 解除cell被選中的狀態
        tableView.deselectRow(at: indexPath, animated: true)
//        viewModel.setSelectedTrack(forCellAt: indexPath.row)
//        let vc = TrackDetailViewController()
//        vc.dataSource = self
//        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }
}
