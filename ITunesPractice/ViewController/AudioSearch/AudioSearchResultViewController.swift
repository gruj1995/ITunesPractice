//
//  AudioSearchResultViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/19.
//

import Combine
import SnapKit
import UIKit

// MARK: - AudioSearchViewController

class AudioSearchResultViewController: UIViewController {

    init(track: Track) {
        self.track = track
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

    var track: Track

    // MARK: Private

    private let viewModel: AudioSearchResultViewModel = .init()
    private var cancellables: Set<AnyCancellable> = []

    // TODO: 改成放影片
    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        imageView.layer.opacity = 0.8
        return imageView
    }()

    private lazy var closeButton: CircleButton = {
        let button = CircleButton(backgroundAlpha: 0.5)
        button.setImage(AppImages.xmark, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(clossButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var trackNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .heavy)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()

    private lazy var artistNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textAlignment = .left
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [trackNameLabel, artistNameLabel])
        stackView.axis = .vertical
        stackView.spacing = 5
//        stackView.alignment = .leading
        return stackView
    }()

    private func setupUI() {
        view.backgroundColor = .black
        setupLayout()

        trackNameLabel.text = track.trackName
        artistNameLabel.text = track.artistName
        coverImageView.loadCoverImage(with: track.getArtworkImageWithSize(size: .square800))
    }

    private func setupLayout() {
        view.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
        }

        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview().inset(20)
            make.width.height.equalTo(30)
        }

        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(coverImageView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }

    private func bindViewModel() {
//        viewModel.trackPublisher
//            .receive(on: DispatchQueue.main)
//            .dropFirst()
//            .removeDuplicates()
//            .sink { [weak self] track in
//                guard let self else { return }
//                self.updateTrackInfo(track)
//            }.store(in: &cancellables)
    }

    @objc
    private func clossButtonTapped() {
        dismiss(animated: true)
    }
}
