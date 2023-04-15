//
//  PlaylistPlayerViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/15.
//

import AVKit
import Combine
import SnapKit
import UIKit

// MARK: - PlaylistPlayerViewController

/**
  - 有3種顯示模式，值的變更會儲存在userdefault中：
    1. 顯示歌詞
    2. 顯示音樂清單
    3. 顯示歌曲資訊
  - 當音樂有歌詞時，歌詞按鈕才會亮起
  - 下一曲按鈕
    1. 長按觸發快轉，並且會越來越快
    2. 播放按鈕顯示暫停，等放開快轉按鈕後變回播放
  - 音樂進度條
    1. 拖動時圓點會放大
    2. 拖到兩邊快碰到數字時，數字會進行動畫往下，拖離開後會回到原位
    3. 拖動時音樂正常播放，拖曳結束才切到選中的時間點
    4. 圓點是半透明白色，歌曲無法播放時還是能拖動進度條，圓點變透明色
  - 音量滑軌可以調系統聲音，目前觀察是使用原生slider
  - 在背景時也要能繼續播放歌曲
 */

class PlaylistPlayerViewController: UIViewController {
    // MARK: Internal

    class var storyboardIdentifier: String {
        return String(describing: self)
    }

    @IBOutlet var musicProgressSlider: AnimatedThumbSlider!

    @IBOutlet var volumeSlider: UISlider!

    @IBOutlet var playButtons: [RippleEffectButton]!

    @IBOutlet var contentStackView: UIStackView!

    @IBOutlet var advancedFeaturesStackView: UIStackView!

    var advancedButtonSelectedColor: UIColor? {
        didSet {
            updateAdvancedButtons()
        }
    }

    // 由 PlaylistVC 更新漸層色
    lazy var gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        // 指定第一個顏色佔 15 px 高度
        let firstColorHeightPercentage = NSNumber(value: 15.0 / view.bounds.height)
        // 顏色起始點與終點
        gradient.locations = [0, firstColorHeightPercentage, 0.37]
        view.layer.insertSublayer(gradient, at: 0)
        return gradient
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        bindViewModel()
    }

    // MARK: IBAction

//    @IBAction func presentPickerView(_ sender: UIButton) {
//        routePickerView.present()
//    }

    // MARK: Private

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

    private lazy var lyricsButton: UIButton = UIButton.createRoundCornerButton(image: AppImages.quoteBubble, target: self, action: #selector(lyricsButtonTapped))

    private lazy var airPlayButton: UIButton = UIButton.createRoundCornerButton(image: AppImages.airplayaudio, target: self, action: #selector(airPlayButtonTapped))

    private lazy var listButton: UIButton = UIButton.createRoundCornerButton(image: AppImages.listBullet, target: self, action: #selector(listButtonTapped))

    private lazy var advancedButtons: [UIButton] = [lyricsButton, airPlayButton, listButton]

    private lazy var routePickerView: AVRoutePickerView = {
        let routePickerView = AVRoutePickerView(frame: .zero)
        routePickerView.backgroundColor = .green
        routePickerView.tintColor = .yellow
        routePickerView.activeTintColor = .red
        routePickerView.isHidden = true
        return routePickerView
    }()

    private let viewModel: PlaylistPlayerViewModel = .init()
    private var cancellables: Set<AnyCancellable> = .init()
    private var isManualSeeking = false

    private func setupUI() {
        view.backgroundColor = .clear
        setupLayout()

        playButtons.indices.forEach {
            playButtons[$0].tintColor = .white
            playButtons[$0].tag = $0 + 1
        }

        setupVolumeSlider()
        setupMusicProgressSlider()
    }

    private func setupGestures() {
        if playButtons.count == 3 {
            let previousButton = playButtons[0]
            let playOrPauseButton = playButtons[1]
            let nextButton = playButtons[2]

            previousButton.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
            playOrPauseButton.addTarget(self, action: #selector(togglePlayPauseButtonTapped), for: .touchUpInside)
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
        advancedButtons.forEach { button in
            advancedFeaturesStackView.addArrangedSubview(button)
            button.snp.makeConstraints { make in
                make.width.equalTo(button.snp.height)
            }
        }

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

        airPlayButton.addSubview(routePickerView)
        routePickerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(view).inset(10)
            make.height.equalTo(400)
        }
    }

    private func bindViewModel() {
        viewModel.playbackTimePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.updateMusicSlider()
                self.updateTimeLabels()
            }.store(in: &cancellables)

        viewModel.isPlayingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.updateTogglePlayPauseButton()
            }.store(in: &cancellables)
    }

    private func updateTogglePlayPauseButton() {
        let isPlaying = viewModel.isPlaying
        let image = isPlaying ? AppImages.pause : AppImages.play
        playButtons[1].setImage(image, for: .normal)
    }

    // 更新已播放時間和剩餘時間標籤
    // TODO: 修正拖曳放開slider後閃爍問題
    private func updateMusicSlider() {
        let isTracking = musicProgressSlider.isTracking
        viewModel.updateDisplayedTime(isTracking: isTracking)
        if isTracking {
            musicProgressSlider.value = viewModel.newPlaybackPercentage
        } else {
            musicProgressSlider.value = viewModel.playbackPercentage
        }
    }

    private func updateTimeLabels() {
        currentTimeLabel.text = viewModel.$displayedCurrentTime
        remainingTimeLabel.text = viewModel.$displayedRemainingTime
    }

    private func updateAdvancedButtons() {
        let selectedColor = advancedButtonSelectedColor

        let isLyricsMode = viewModel.displayMode == .lyrics
        let lyricsButtonImage = isLyricsMode ? AppImages.quoteBubbleFill : AppImages.quoteBubble
        lyricsButton.setRoundCornerButtonAppearance(isSelected: isLyricsMode, tintColor: selectedColor, image: lyricsButtonImage)

        let isPlaylistMode = viewModel.displayMode == .playlist
        listButton.setRoundCornerButtonAppearance(isSelected: isPlaylistMode, tintColor: selectedColor)
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

    // 播放/暫停
    @objc
    private func togglePlayPauseButtonTapped(_ sender: UIButton) {
        viewModel.isPlaying.toggle()
    }

    // 下一曲
    @objc
    private func nextButtonTapped(_ sender: UIButton) {
        viewModel.next()
    }

    // 上一曲
    @objc
    private func previousButtonTapped(_ sender: UIButton) {
        viewModel.previous()
    }

    @objc
    private func airPlayButtonTapped() {
        let menuController = UIMenuController.shared
//        menuController.delegate = self

        let routePickerItem = UIMenuItem(title: "AirPlay", action: #selector(showRoutePicker(_:)))

        let menuItems = [routePickerItem]
        menuController.menuItems = menuItems

        menuController.showMenu(from: airPlayButton, rect: view.bounds)
    }

    @objc
    private func lyricsButtonTapped(_ sender: UIButton) {
        viewModel.handleLyricsButtonTapped()
        updateAdvancedButtons()
    }

    @objc
    private func listButtonTapped(_ sender: UIButton) {
        viewModel.handleListButtonTapped()
        updateAdvancedButtons()
    }

    @objc
    private func showRoutePicker(_ sender: UIMenuController) {
        routePickerView.isHidden = false
    }
}

private extension AVRoutePickerView {
    func present() {
        let routePickerButton = subviews.first { $0 is UIButton } as? UIButton
        routePickerButton?.sendActions(for: .touchUpInside)
    }
}
