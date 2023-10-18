//
//  AudioSearchResultViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/19.
//

import AVKit
import Combine

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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = topView.bounds
        coverImageView.frame = CGRect(x: 0, y: 0, width: Constants.screenWidth, height: Constants.screenHeight * 0.6)
    }

    // MARK: Private

    private let viewModel: AudioSearchResultViewModel
    private var cancellables: Set<AnyCancellable> = []

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        // 避免自動加上 content inset
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()

    private lazy var contentView: UIView = .init()

    private lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.addSublayer(gradient)
        return view
    }()

    private lazy var gradient: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        return gradientLayer
    }()

    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.opacity = 0.8
        return imageView
    }()

    private lazy var videoView: VideoView = {
        let videoView = VideoView(frame: .zero)
        return videoView
    }()

    private lazy var sharedButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.imagePadding = 10
        config.contentInsets = .init(top: 10, leading: 0, bottom: 10, trailing: 0)
        config.attributedTitle = AttributedString(
            "分享歌曲".localizedString(),
            attributes: AttributeContainer(
                [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .semibold)]
            )
        )
        config.titleAlignment = .center
        config.image = AppImages.squareAndArrowUp?.withConfiguration(roundConfiguration)
        config.imagePlacement = .leading // 圖片位置
        config.baseBackgroundColor = UIColor(hex: "#F97B22")
        config.baseForegroundColor = .white // 圖片及文字顏色
        config.cornerStyle = .capsule // 圓角
        button.configuration = config
        button.addTarget(self, action: #selector(shareTrack), for: .touchUpInside)
        return button
    }()

    private lazy var trackNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 21, weight: .heavy)
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()

    private lazy var artistNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [trackNameLabel, artistNameLabel])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.setContentHuggingPriority(.required, for: .vertical)
        return stackView
    }()

    private func setupUI() {
        view.backgroundColor = .black
        setupLayout()

        trackNameLabel.text = viewModel.track.trackName
        artistNameLabel.text = viewModel.track.artistName

        if let url = viewModel.track.videoUrl {
            Task {
                await videoView.playMusicVideo(with: url)
            }
        } else {
            coverImageView.loadCoverImage(with: viewModel.track.getArtworkImageWithSize(size: .square800))
        }
    }

    private func setupLayout() {
        let backgroundView = viewModel.hasVideo ? videoView : coverImageView
        backgroundView.backgroundColor = viewModel.randomBgColor

        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
        }

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view) // scrollView 寬度
        }

        contentView.addSubview(topView)
        topView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(150)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(view).multipliedBy(0.45)
        }

        topView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-80)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(700)
            make.bottom.equalToSuperview().offset(0) // scrollView 底部
        }

        bottomView.addSubview(sharedButton)
        sharedButton.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(120)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(50)
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
    private func shareTrack() {
        Utils.shareTrack(viewModel.track)
    }
}
