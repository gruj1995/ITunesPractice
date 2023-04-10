//
//  MPVolumeView+Extensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/27.
//

import MediaPlayer

extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        guard let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            slider.value = volume
        }
    }
}
