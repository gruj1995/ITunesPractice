//
//  ITunesImageSize.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/1.
//

import Foundation

// https://stackoverflow.com/questions/13382208/getting-bigger-artwork-images-from-itunes-web-search

/// iTunes API 回傳的圖片尺寸（太小看起來圖片模糊）
/// 但是並非所有 iTunes 專輯都具有特定尺寸大小的圖片，如果沒有的話可能要往下找
enum ITunesImageSize: Int {
    case square30 = 30
    case square60 = 60
    case square80 = 80
    case square100 = 100
    case square400 = 400
    case square600 = 600
    case square800 = 800
    case square1200 = 1200
}
