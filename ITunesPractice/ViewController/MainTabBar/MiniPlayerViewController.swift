//
//  MiniPlayerViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/13.
//

import Combine
import SnapKit
import UIKit

// MARK: - MiniPlayerViewController

/*
 迷你播放器規則
   1. miniPlayer 點擊按鈕後，通知目前顯示的頁面執行對應動作
   2. 如果目前顯示的頁面是彈窗，會關閉彈窗，同時按鈕動作不會進行(e.g. 點擊播放按鈕，不會變成暫停的樣子)
   3. 目前顯示的頁面選中歌曲時，通知 miniPlayer 更換歌曲並自動點擊播放按鈕，接續執行1.的行為
   4. 現正播放的音樂即使使剛查到的，cell 上的動畫也會顯示正播放中 (蓋上遮罩並顯示動畫)
   5. 預設文字是未在播放
 */

// 參考 https://github.com/LeoNatan/LNPopupController
class MiniPlayerViewController: BottomFloatingPanelViewController {
    // MARK: Internal

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        bindViewModel()
    }

    // MARK: Private

    private var viewModel: MiniPlayerViewModel = .init()
    private var cancellables: Set<AnyCancellable> = .init()

    private lazy var highlightBlurView: HighlightBlurView = .init()

    private lazy var coverImageView: UIImageView = .coverImageView()

    private lazy var songTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()

    private lazy var playPauseButton: RippleEffectButton = {
        let button = RippleEffectButton()
        var config = UIButton.Configuration.borderless()
        config.buttonSize = .large
        config.image = AppImages.play
        config.baseForegroundColor = .white
        button.configuration = config
        button.addTarget(self, action: #selector(togglePlayPauseButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var nextButton: RippleEffectButton = {
        let button = RippleEffectButton()
        var config = UIButton.Configuration.borderless()
        config.buttonSize = .large
        config.image = AppImages.forward
        config.baseForegroundColor = .white
        button.configuration = config
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()

    private func bindViewModel() {
        viewModel.currentTrackIndexPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.updateCurrentTrackUI()
            }.store(in: &cancellables)

        viewModel.isPlayingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.updatePlayOrPauseButtonUI()
            }.store(in: &cancellables)
    }

    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(highlightBlurViewTapped))
        highlightBlurView.isUserInteractionEnabled = true
        highlightBlurView.addGestureRecognizer(tapGesture)
    }

    private func updateCurrentTrackUI() {
        guard let currentTrack = viewModel.currentTrack,
              let url = currentTrack.getArtworkImageWithSize(size: .square800)
        else {
            coverImageView.image = DefaultTrack.coverImage
            songTitleLabel.text = DefaultTrack.trackName
            return
        }
        coverImageView.loadCoverImage(with: url)
        songTitleLabel.text = currentTrack.trackName
    }

    private func setupUI() {
        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview().inset(8)
            make.width.equalTo(coverImageView.snp.height)
        }

        view.addSubview(songTitleLabel)
        songTitleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(coverImageView.snp.trailing).offset(8)
        }

        view.addSubview(playPauseButton)
        playPauseButton.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.leading.equalTo(songTitleLabel.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }

        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.width.height.centerY.equalTo(playPauseButton)
            make.leading.equalTo(playPauseButton.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(20)
        }

        view.insertSubview(highlightBlurView, at: 0)
        highlightBlurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(0.3)
        }
    }

    private func updatePlayOrPauseButtonUI() {
        let isPlaying = viewModel.isPlaying
        let image = isPlaying ? AppImages.pause : AppImages.play
        playPauseButton.setImage(image, for: .normal)
    }

    private func presentPlaylistVC() {
        let vc = PlaylistViewController()
        // fullScreen 背景遮罩會是黑色的，所以設 overFullScreen
        vc.modalPresentationStyle = .pageSheet

        let fpc = getFpc()
        fpc.set(contentViewController: vc)
        fpc.track(scrollView: vc.tableView)
        present(fpc, animated: true)
    }

    @objc
    private func highlightBlurViewTapped() {
        presentPlaylistVC()
    }

    @objc
    private func togglePlayPauseButtonTapped(_ sender: UIButton) {
        viewModel.isPlaying.toggle()
    }

    @objc
    private func nextButtonTapped(_ sender: UIButton) {
        viewModel.next()
    }
}
