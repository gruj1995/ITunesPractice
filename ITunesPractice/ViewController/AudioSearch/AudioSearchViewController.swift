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

        NotificationCenter.default.addObserver(self, selector: #selector(startAnimation), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startAnimation()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopAnimation()
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

    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.isHidden = true
        return view
    }()

    private lazy var micImageView: UIImageView = {
        let imageView = UIImageView(image: AppImages.micFill)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var hintStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [micImageView, hintLabel])
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

    private func setupUI() {
        view.backgroundColor = .black
        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(sparkleView)
        sparkleView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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

        view.addSubview(emptyStateView)
        emptyStateView.snp.makeConstraints { make in
            make.top.equalTo(shazamImageView.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
        }
    }

    private func bindViewModel() {
        viewModel.matchingHelper.$isRecording
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] isRecording in
                guard let self else { return }
                self.updateRecordState(isRecording)
            }.store(in: &cancellables)

        viewModel.trackPublisher
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] track in
                guard let self else { return }
                self.updateTrackInfo(track)
            }.store(in: &cancellables)

        viewModel.$searchStage
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                guard let self else { return }
                self.updateState()
            }.store(in: &cancellables)

    }

    private func updateState() {
        let searchStage = viewModel.searchStage
        let animated = searchStage != .listening
        emptyStateView.updateLabelsWithAnimation(title: searchStage.title, message: searchStage.subtitle, animated: animated)
    }

    private func updateRecordState(_ isRecording: Bool) {
        sparkleView.velocity = isRecording ? 1 : 0
        emptyStateView.isHidden = !isRecording
    }

    private func updateTrackInfo(_ track: Track?) {
        viewModel.stopTimer()
        viewModel.searchStage = .none

        if let track {
            presentAudioSearchResultVC(track: track)
        } else {
            presentFailedVC()
        }
    }

    private func presentAudioSearchResultVC(track: Track) {
        let vc = AudioSearchResultViewController(track: track)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    // TODO: 改成彈窗
    private func presentFailedVC() {
        Utils.toast("辨識失敗")
    }

    @objc
    private func startAnimation() {
        let animationDuration = 1.0         // 動畫持續時間
        let animationScale: CGFloat = 1.05   // 縮放比例

        // 動畫縮放
        let transform = CABasicAnimation(keyPath: AnimationKeyPath.transformScale.rawValue)
        transform.fromValue = 1.0
        transform.toValue = animationScale
        transform.duration = animationDuration
        transform.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut) // 動畫過度方式
        transform.autoreverses = true // 是否自動反向播放
        transform.repeatCount = .infinity

        shazamImageView.layer.add(transform, forKey: "shazamImageScaleAnimation")
    }

    private func stopAnimation() {
        shazamImageView.layer.removeAllAnimations()
    }

    @objc
    private func shazamImageViewTapped(_ sender: UITapGestureRecognizer) {
        sparkleView.velocity = 1
        viewModel.listenMusic()
    }
}
