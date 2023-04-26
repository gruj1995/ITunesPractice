//
//  AudioSearchResultViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/19.
//

import AVKit
import Combine
import SnapKit
import UIKit

// MARK: - AudioSearchViewController

class AudioSearchResultViewController: UIViewController {
    // MARK: Lifecycle

    init(track: Track) {
        self.viewModel = AudioSearchResultViewModel(track: track)
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
        bindViewModel()
    }

    // MARK: Private

    private let viewModel: AudioSearchResultViewModel
    private var cancellables: Set<AnyCancellable> = []

//    private var player: AVPlayer?

    // TODO: 改成放影片
    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        imageView.layer.opacity = 0.8
        return imageView
    }()

    private lazy var videoView: VideoView = {
        let videoView = VideoView(frame: .zero)
        videoView.backgroundColor = .darkGray
        return videoView
    }()

    private lazy var closeButton: CircleButton = {
        let button = CircleButton(bgColor: .white.withAlphaComponent(0.4))
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
        return stackView
    }()

    private func setupUI() {
        view.backgroundColor = .black
        setupLayout()

        trackNameLabel.text = viewModel.track.trackName
        artistNameLabel.text = viewModel.track.artistName

        print("__++ url \(viewModel.track.videoUrl)")
        if viewModel.hasVideo {
            playVideo()
        } else {
            coverImageView.loadCoverImage(with: viewModel.track.getArtworkImageWithSize(size: .square800))
        }
    }

    private func playVideo() {
        guard let url = viewModel.track.videoUrl else { return }
        videoView.play(with: url)
    }

    private func setupLayout() {
        let backgroundView = viewModel.hasVideo ? videoView : coverImageView

        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
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
            make.top.equalTo(backgroundView.snp.bottom).offset(10)
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
