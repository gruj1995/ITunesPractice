//
//  AppImages.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/13.
//

import UIKit

// 因為 SF Symbols 是向量圖，所以要放大icon的話要透過SymbolConfiguration設置
let playerButtonConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .large)

enum AppImages {
    // 放大境
    static let magnifyingGlass = UIImage(systemName: "magnifyingglass")

    // tabbar
    static let musicHouse = UIImage(systemName: "music.note.house.fill")

    // 播放器
    static let pause = UIImage(systemName: "pause.fill")
    static let play = UIImage(systemName: "play.fill")
    static let forward = UIImage(systemName: "forward.fill")
    static let pauseLarge = UIImage(systemName: "pause.fill", withConfiguration: playerButtonConfiguration)
    static let playLarge = UIImage(systemName: "play.fill", withConfiguration: playerButtonConfiguration)
    static let forwardLarge = UIImage(systemName: "forward.fill", withConfiguration: playerButtonConfiguration)

    // context menu
    static let plus = UIImage(systemName: "plus")
    static let trash = UIImage(systemName: "trash")
    static let squareAndArrowUp = UIImage(systemName: "square.and.arrow.up")
    // 右側箭頭
    static let chevronRight = UIImage(systemName: "chevron.right")

    // PreviewType
    static let person = UIImage(systemName: "person.fill")
    static let musicList = UIImage(systemName: "music.note.list")

    // 透過 pinterest 找圖和 figma 修改尺寸與透明度產生
    static let musicNote = UIImage(named: "music.note")
}

