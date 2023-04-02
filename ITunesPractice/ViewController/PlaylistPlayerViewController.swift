//
//  PlaylistPlayerViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/15.
//

import Combine
import SnapKit
import UIKit

/*
 https://reurl.cc/9V7KjV
  - view 上方有模糊邊緣，同時整個view應該是透明背景
  - 下一曲按鈕
    1. 長按觸發快轉，並且會越來越快
    2. 播放按鈕顯示暫停，等放開快轉按鈕後變回播放
  - 音樂進度條
    1. 拖動時圓點會放大
    2. 拖到兩邊快碰到數字時，數字會進行動畫往下，拖離開後會回到原位
    3. 拖動時音樂正常播放，拖曳結束才切到選中的時間點
    4. 圓點是半透明白色，歌曲無法播放時還是能拖動進度條，圓點變透明色
  - 音量滑軌可以調系統聲音，目前觀察是使用原生slider
  - 當音樂有歌詞時，左下角按鈕才會亮起
  - 在背景時也要能繼續播放歌曲
 */

// MARK: - PlaylistPlayerViewController

class PlaylistPlayerViewController: UIViewController {
    // MARK: Internal

    class var storyboardIdentifier: String {
        return String(describing: self)
    }

    @IBOutlet var musicProgressSlider: AnimatedThumbSlider!

    @IBOutlet var volumeSlider: UISlider!

    @IBOutlet var playButtons: [RippleEffectButton]!

    @IBOutlet var advancedButtons: [UIButton]!

    @IBOutlet var stackView: UIStackView!

    lazy var gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds

        // 指定第一個顏色佔 15 px 高度
        let firstColorHeightPercentage = NSNumber(value: 15.0 / view.bounds.height)
        // 顏色起始點與終點
        gradient.locations = [0, firstColorHeightPercentage, 0.4]
        view.layer.insertSublayer(gradient, at: 0)
        return gradient
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        bindViewModel()
    }

    // MARK: Private

    private var cancellables: Set<AnyCancellable> = .init()

    private lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightText
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 10)
        return label
    }()

    private lazy var remainingTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightText
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 10)
        return label
    }()

    private let viewModel: PlaylistPlayerViewModel = .init()

    private var isManualSeeking = false

    private func setupUI() {
        view.backgroundColor = .clear
        setupLayout()

        playButtons.indices.forEach {
            playButtons[$0].tintColor = .white
            playButtons[$0].tag = $0 + 1
        }
        advancedButtons.forEach { $0.tintColor = .white }
        setupVolumeSlider()
        setupMusicProgressSlider()
    }

    private func bindViewModel() {
        viewModel.playbackTimePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.updateMusicSlider()
                self.updateTimeLabels()
            }.store(in: &cancellables)
    }

    private func setupGestures() {
        if playButtons.count == 3 {
            let previousButton = playButtons[0]
            let playOrPauseButton = playButtons[1]
            let nextButton = playButtons[2]

            previousButton.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
            playOrPauseButton.addTarget(self, action: #selector(playOrPauseButtonTapped), for: .touchUpInside)
            nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        }
    }

    private func setupMusicProgressSlider() {
        // 圓點圖換小一點
        // 這邊要注意官方文件說不能同時設置圖案跟 thumbTintColor，因為只會取用一邊的結果
        musicProgressSlider.setImage(AppImages.circleFill)
        musicProgressSlider.isContinuous = true // 拖動時會不會發送事件
        musicProgressSlider.minimumTrackTintColor = .white // 滑軌填滿時顏色
        musicProgressSlider.maximumTrackTintColor = .lightText // 滑軌未填滿時顏色
        musicProgressSlider.tintColor = .white // 影響 icon 圖片顏色
        musicProgressSlider.minimumValue = 0
        musicProgressSlider.maximumValue = 1
        musicProgressSlider.addTarget(self, action: #selector(musicProgressSliderValueChanged), for: .valueChanged)
        musicProgressSlider.addTarget(self, action: #selector(musicProgressSliderTouchUpInside), for: .touchUpInside)
    }

    private func setupVolumeSlider() {
        volumeSlider.setThumbImage(AppImages.circleFillSmall, for: .normal)
        volumeSlider.setThumbImage(AppImages.circleFillSmall, for: .highlighted)
        volumeSlider.isContinuous = true
        // slider 兩側 icon
        volumeSlider.minimumValueImage = AppImages.speakerSmall
        volumeSlider.maximumValueImage = AppImages.speakerWaveSmall
        volumeSlider.tintColor = .white
        volumeSlider.minimumTrackTintColor = .white
        volumeSlider.maximumTrackTintColor = .lightText
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 1
        volumeSlider.value = viewModel.volume
        volumeSlider.addTarget(self, action: #selector(volumeSliderValueChanged), for: .valueChanged)
    }

    private func setupLayout() {
        view.addSubview(currentTimeLabel)
        currentTimeLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.leading.equalTo(musicProgressSlider)
            make.top.equalTo(musicProgressSlider.snp.bottom).offset(3)
        }

        view.addSubview(remainingTimeLabel)
        remainingTimeLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.trailing.equalTo(musicProgressSlider)
            make.top.equalTo(musicProgressSlider.snp.bottom).offset(3)
        }
    }

    private func updatePlayOrPauseButtonUI() {
        let isPlaying = viewModel.isPlaying
        let image = isPlaying ? AppImages.pause : AppImages.play
        playButtons[1].setImage(image, for: .normal)
    }

    // 更新已播放時間和剩餘時間標籤
    private func updateMusicSlider() {
        let updateType: SliderUpdateType = musicProgressSlider.isTracking ? .manual : .automatic
        viewModel.updateDisplayedTime(type: updateType)

        if updateType == .manual {
            musicProgressSlider.value = viewModel.newPlaybackPercentage
        } else {
            musicProgressSlider.value = viewModel.playbackPercentage
        }
    }

    private func updateTimeLabels() {
        currentTimeLabel.text = viewModel.$displayedCurrentTime
        remainingTimeLabel.text = viewModel.$displayedRemainingTime
    }

    // 拖動音樂時間軸
    @objc
    private func musicProgressSliderValueChanged(_ sender: UISlider) {
        viewModel.newPlaybackPercentage = sender.value
        updateTimeLabels()
    }

    // 結束拖動音樂時間軸
    @objc
    private func musicProgressSliderTouchUpInside(_ sender: UISlider) {
        viewModel.seekToNewTime()
    }

    // 拖動音量時間軸
    @objc
    private func volumeSliderValueChanged(_ sender: UISlider) {
        viewModel.volume = sender.value
    }

    @objc
    private func playOrPauseButtonTapped(_ sender: UIButton) {
        viewModel.isPlaying.toggle()
    }

    @objc
    private func nextButtonTapped(_ sender: UIButton) {
        viewModel.next()
    }

    @objc
    private func previousButtonTapped(_ sender: UIButton) {
        viewModel.previous()
    }
}
