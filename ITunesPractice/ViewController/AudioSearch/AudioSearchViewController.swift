//
//  AudioSearchViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/16.
//

import Combine
import SnapKit
import UIKit

// MARK: - AudioSearchViewController

class AudioSearchViewController: UIViewController {
    // MARK: Internal

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        // App 從背景進入前景時啟動動畫
        NotificationCenter.default.addObserver(self, selector: #selector(playHeartbeatAnimation), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playHeartbeatAnimation()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopHeartbeatAnimation()
    }

    // MARK: Private

    private let viewModel: AudioSearchViewModel = .init()
    private var cancellables: Set<AnyCancellable> = []

    private lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.text = "輕觸 Shazam".localizedString()
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .heavy)
        return label
    }()

    private lazy var closeButton: CircleButton = {
        let button = CircleButton(bgColor: .lightGray.withAlphaComponent(0.8))
        button.setImage(AppImages.xmark, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(clossButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    private lazy var historyButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("搜尋記錄", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        button.tintColor = .white
        button.addTarget(self, action: #selector(historyButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var hintView: EmptyStateView = {
        let view = EmptyStateView()
        view.isHidden = true
        return view
    }()

    private lazy var microphoneImageView: UIImageView = {
        let imageView = UIImageView(image: AppImages.micFill)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var hintStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [microphoneImageView, hintLabel])
        stackView.axis = .horizontal
        stackView.spacing = 3
        return stackView
    }()

    // 有動畫的圓圈圖片
    private lazy var shazamImageView: UIImageView = {
        let imageView = UIImageView(image: AppImages.shazamLarge)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(shazamImageViewTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()

    // 背景火花
    private lazy var sparkleView: SparkleView = {
        let sparkImage = Utils.createSparkleImage(width: 2, color: .yellow)
        let sparkleView = SparkleView(frame: .zero, sparkImage: sparkImage)
        sparkleView.velocity = 0
        return sparkleView
    }()

    // 縮放動畫
    private lazy var scaleAnimation: CABasicAnimation = {
        let scaleAnimation = CABasicAnimation(keyPath: AnimationKeyPath.transformScale)
        scaleAnimation.fromValue = 1.0
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut) // 動畫過度方式
        scaleAnimation.autoreverses = true // 是否自動反向播放
        scaleAnimation.repeatCount = .infinity
        return scaleAnimation
    }()

    // MARK: Setup

    private func setupUI() {
        view.backgroundColor = .black
        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(sparkleView)
        sparkleView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(30)
        }

        view.addSubview(shazamImageView)
        shazamImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.4)
            make.height.equalTo(shazamImageView.snp.width)
        }

        view.addSubview(hintStackView)
        hintStackView.snp.makeConstraints { make in
            make.bottom.equalTo(shazamImageView.snp.top).offset(-40)
            make.centerX.equalToSuperview()
        }

        view.addSubview(hintView)
        hintView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(1.3)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
        }

        view.addSubview(historyButton)
        historyButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(1.4)
            make.centerX.equalToSuperview()
        }
    }

    private func bindViewModel() {
        viewModel.trackPublisher
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] track in
                guard let self else { return }
                self.updateTrackInfo(track)
            }.store(in: &cancellables)

        viewModel.isRecordingPublisher
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] isRecording in
                guard let self else { return }
                self.updateRecordingState(isRecording: isRecording)
            }.store(in: &cancellables)

        viewModel.volumePublisher
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            // 限制指定秒數內只能發送一次事件
            .throttle(for: .seconds(0.3), scheduler: DispatchQueue.main, latest: false)
            .sink { [weak self] volume in
                guard let self else { return }
                self.addPulse(volume: volume)
            }.store(in: &cancellables)

        viewModel.$searchStage
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                guard let self else { return }
                self.updateSearchStageUI()
            }.store(in: &cancellables)
    }

    private func updateSearchStageUI() {
        let searchStage = viewModel.searchStage
        let animated = searchStage != .listening
        let needHideHintView = searchStage == .none
        hintView.isHidden = needHideHintView
        hintView.updateUI(title: searchStage.title, message: searchStage.subtitle, animated: animated)
    }

    private func updateRecordingState(isRecording: Bool) {
        sparkleView.velocity = isRecording ? 1 : 0
        hintView.isHidden = !isRecording
        closeButton.isHidden = !isRecording
        historyButton.isHidden = isRecording
        playHeartbeatAnimation()
    }

    private func updateTrackInfo(_ track: Track?) {
        if !viewModel.isRecording {
            stopRecognition()
            if let track {
                presentAudioSearchResultVC(track: track)
            } else {
                presentFailedVC()
            }
        }
    }

    /// 添加一層水波紋動畫圖層
    private func addPulse(volume: Float) {
        let ratio = volume / viewModel.thresholdVolume
        let radius = shazamImageView.frame.width * 0.6 * CGFloat(ratio)
        let porition = shazamImageView.center
        let duration = TimeInterval(ratio)
        let targetScale = ratio * 1.5

//        Logger.log("___ 觸發心跳  volume: \(volume),  radius:\(radius), scale: \(ratio)")

        let pulseLayer = Pulsing(
            radius: radius,
            position: porition,
            animationDuration: duration,
            color: .darkGray,
            targetScale: targetScale)

        view.layer.insertSublayer(pulseLayer, at: 0)
    }

    private func presentAudioSearchResultVC(track: Track) {
        let vc = AudioSearchResultViewController(track: track)
        vc.modalPresentationStyle = .pageSheet
        vc.modalTransitionStyle = .coverVertical
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true // 顯示頂部 grabber
        }
        present(vc, animated: true)
    }

    private func presentAudioSearchHistoryVC() {
        let vc = AudioSearchHistoryViewController()
        vc.modalPresentationStyle = .pageSheet
        vc.modalTransitionStyle = .coverVertical
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true // 顯示頂部 grabber
        }
        present(vc, animated: true)
    }

    private func presentFailedVC() {
        stopRecognition()
        Utils.toast("辨識失敗")
    }

    private func startRecognition() {
        viewModel.startRecognition()
    }

    private func stopRecognition() {
        viewModel.stopRecognition()
    }

    @objc
    private func playHeartbeatAnimation() {
        viewModel.isRecording ? fast() : normal()
    }

    private func stopHeartbeatAnimation() {
        shazamImageView.layer.removeAllAnimations()
    }

    private func fast() {
        shazamImageView.layer.removeAllAnimations()
        scaleAnimation.toValue = 1.03
        scaleAnimation.duration = 0.4
        shazamImageView.layer.add(scaleAnimation, forKey: AnimationKeyPath.shazamImageScaleAnimation)
    }

    private func normal() {
        shazamImageView.layer.removeAllAnimations()
        scaleAnimation.toValue = 1.05
        scaleAnimation.duration = 1
        shazamImageView.layer.add(scaleAnimation, forKey: AnimationKeyPath.shazamImageScaleAnimation)
    }

    // 觸覺反饋(震動)
    private func vibrate() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    @objc
    private func clossButtonTapped() {
        stopRecognition()
    }

    @objc
    private func historyButtonTapped() {
        presentAudioSearchHistoryVC()
    }

    @objc
    private func shazamImageViewTapped(_ sender: UITapGestureRecognizer) {
        if viewModel.isRecording { return }
        vibrate()

        // 因為錄音時會禁止觸覺反饋和系統聲音，這邊等反饋結束再開始錄音
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.startRecognition()
        }
    }
}
