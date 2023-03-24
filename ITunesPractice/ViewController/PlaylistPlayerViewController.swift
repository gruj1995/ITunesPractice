//
//  PlaylistPlayerViewController.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/15.
//

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

    @IBOutlet var musicProgressSlider: UISlider!

    @IBOutlet var playButtons: [RippleEffectButton]!

    @IBOutlet var advancedButtons: [UIButton]!

    @IBOutlet var volumeSlider: UISlider!

    @IBOutlet weak var stackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()

        let notificationPublisher = NotificationCenter.default.publisher(for: .addTrack)

//        musicProgressSlider.publisher
//            .sink { <#UISlider#> in
//            <#code#>
//        }
    }

    // MARK: Private

    private lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "1:20"
        label.textColor = .lightText
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 10)
        return label
    }()

    private lazy var remainingTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "2:45"
        label.textColor = .lightText
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 10)
        return label
    }()

    private let viewModel: PlaylistPlayerViewModel = .init()

    private func updateUI() {}

    private func setupUI() {
        view.backgroundColor = .clear
        setupLayout()

        playButtons.forEach { $0.tintColor = .white }
        advancedButtons.forEach { $0.tintColor = .white }
        setupVolumeSlider()
        setupMusicProgressSlider()
    }

    private func setupMusicProgressSlider() {
        // 滑軌填滿時顏色
        musicProgressSlider.minimumTrackTintColor = .white
        // 滑軌未填滿時顏色
        musicProgressSlider.maximumTrackTintColor = .lightText
        musicProgressSlider.minimumValue = 0
        musicProgressSlider.maximumValue = 100
    }

//    private func

    private func setupVolumeSlider() {
        // 圓點圖換小一點
        // 這邊要注意官方文件說不能同時設置圖案跟 thumbTintColor，因為只會取用一邊的結果
        volumeSlider.setThumbImage(AppImages.circleFill, for: .normal)
        volumeSlider.setThumbImage(AppImages.circleFill, for: .highlighted)
        // slider 兩側 icon
        volumeSlider.minimumValueImage = AppImages.speakerSmall
        volumeSlider.maximumValueImage = AppImages.speakerWaveSmall
        // icon 圖片顏色
        volumeSlider.tintColor = .white
        volumeSlider.minimumTrackTintColor = .white
        volumeSlider.maximumTrackTintColor = .lightText
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 100
    }

    private func setupLayout() {
        view.addSubview(currentTimeLabel)
        currentTimeLabel.snp.makeConstraints { make in
            make.height.equalTo(15)
            make.leading.equalTo(musicProgressSlider)
            make.top.equalTo(musicProgressSlider.snp.bottom)
        }

        view.addSubview(remainingTimeLabel)
        remainingTimeLabel.snp.makeConstraints { make in
            make.height.equalTo(15)
            make.trailing.equalTo(musicProgressSlider)
            make.top.equalTo(musicProgressSlider.snp.bottom)
        }
    }

    @objc
    private func playPauseButtonTapped(_ sender: UIButton) {
//        isPlaying.toggle()
    }

    @objc
    private func nextButtonTapped(_ sender: UIButton) {}
}
