//
//  AppImages.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/13.
//

import UIKit

// 因為 SF Symbols 是向量圖，所以要改變 icon 尺寸的話要透過 SymbolConfiguration 設置
let speakerConfiguration = UIImage.SymbolConfiguration(pointSize: 13, weight: .regular, scale: .small)
let roundConfiguration = UIImage.SymbolConfiguration(pointSize: 15, weight: .heavy, scale: .default)
let roundConfiguration2 = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold, scale: .medium)

/// 使用 enum 搭配 static let 有兩個原因:
/// 1. 因為無法初始化沒有case的enum，更能表達常數的概念
/// 2. 將相關的常數放在 enum 中可能感覺更自然，因為 enum 用於儲存一組相關值
/// https://forums.swift.org/t/static-let-in-enum-vs-struct/36152/12
///
enum AppImages {
    // tabbar
    static let musicHouse = UIImage(systemName: "music.note.house.fill")
    static let magnifyingGlass = UIImage(systemName: "magnifyingglass")
    static let waveformAndMic = UIImage(systemName: "waveform.and.mic")

    // shazam
    static let micFill = UIImage(systemName: "mic.fill", withConfiguration: roundConfiguration)
    static let shazamLarge = UIImage(named: "shazam_large")
    static let xmark = UIImage(systemName: "xmark", withConfiguration: roundConfiguration)

    // 播放器
    static let pause = UIImage(systemName: "pause.fill")
    static let play = UIImage(systemName: "play.fill")
    static let forward = UIImage(systemName: "forward.fill")
    static let backward = UIImage(systemName: "backward.fill")
    static let shuffle = UIImage(systemName: "shuffle", withConfiguration: roundConfiguration)
    static let repeat0 = UIImage(systemName: "repeat", withConfiguration: roundConfiguration)
    static let repeat1 = UIImage(systemName: "repeat.1", withConfiguration: roundConfiguration)
    static let infinity = UIImage(systemName: "infinity", withConfiguration: roundConfiguration)
    static let speakerSmall = UIImage(systemName: "speaker.fill", withConfiguration: speakerConfiguration)
    static let speakerWaveSmall = UIImage(systemName: "speaker.wave.3.fill", withConfiguration: speakerConfiguration)
    static let ellipsis = UIImage(systemName: "ellipsis")
    static let insertToFirst = UIImage(systemName: "text.line.first.and.arrowtriangle.forward")
    static let addToLast = UIImage(systemName: "text.line.last.and.arrowtriangle.forward")

    static let quoteBubble = UIImage(systemName: "quote.bubble", withConfiguration: roundConfiguration2)
    static let quoteBubbleFill = UIImage(systemName: "quote.bubble.fill", withConfiguration: roundConfiguration2)
    static let listBullet = UIImage(systemName: "list.bullet", withConfiguration: roundConfiguration2)

    // context menu
    static let plus = UIImage(systemName: "plus")
    static let trash = UIImage(systemName: "trash")
    static let squareAndArrowUp = UIImage(systemName: "square.and.arrow.up")
    // 右側箭頭
    static let chevronRight = UIImage(systemName: "chevron.right")

    // PreviewType
    static let person = UIImage(systemName: "person.fill")
    static let musicList = UIImage(systemName: "music.note.list")

    // 這張圖透過 pinterest 找圖和 figma 修改尺寸與透明度做出來的～
    static let musicNote = UIImage(named: "music.note")

    // 圓形
    static let circleFill = UIImage(named: "circle.fill.normal") // 正常尺寸
    static let circleFillSmall = UIImage(named: "circle.fill.small")
    static let circleFillTiny = UIImage(named: "circle.fill.tiny") // 最小
}
