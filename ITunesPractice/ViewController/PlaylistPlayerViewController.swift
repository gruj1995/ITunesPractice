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

    @IBOutlet var musicProgressView: UIProgressView!

    @IBOutlet var playButtons: [RippleEffectButton]!

    @IBOutlet var advancedButtons: [UIButton]!

    @IBOutlet var volumeSlider: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()

        let notificationPublisher = NotificationCenter.default.publisher(for: .addTrack)
    }

    // MARK: Private

    private func updateUI() {}

    private func setupUI() {
        playButtons.forEach { $0.tintColor = .white }
        advancedButtons.forEach { $0.tintColor = .white }

        // 圓點圖換小一點
        volumeSlider.setThumbImage(AppImages.circleFill, for: .normal)
        volumeSlider.setThumbImage(AppImages.circleFill, for: .highlighted)
        volumeSlider.tintColor = .white
        // 圓點顏色
        volumeSlider.thumbTintColor = .white
        // 填滿時顏色
        volumeSlider.minimumTrackTintColor = .white
        // 未填滿時顏色
        volumeSlider.maximumTrackTintColor = .lightText

        // 填滿時顏色
        musicProgressView.progressTintColor = .white

        // 未填滿時顏色
        musicProgressView.trackTintColor = .lightText

        setupLayout()
    }

    private func setupLayout() {
//        view.addSubview(playPauseButton)
//        view.addSubview(nextButton)

//        playPauseButton.snp.makeConstraints { make in
//            make.width.height.equalTo(40)
//            make.leading.equalTo(songTitleLabel.snp.trailing).offset(8)
//            make.centerY.equalToSuperview()
//        }

//        nextButton.snp.makeConstraints { make in
//            make.width.height.centerY.equalTo(playPauseButton)
//            make.leading.equalTo(playPauseButton.snp.trailing).offset(8)
//            make.trailing.equalToSuperview().inset(20)
//        }
    }

    @objc
    private func playPauseButtonTapped(_ sender: UIButton) {
//        isPlaying.toggle()
    }

    @objc
    private func nextButtonTapped(_ sender: UIButton) {}
}
