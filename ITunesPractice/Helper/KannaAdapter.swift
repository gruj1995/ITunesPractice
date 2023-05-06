//
//  KannaAdapter.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/5.
//

import Foundation
import Kanna

/// HTML/XML 解析
class KannaAdapter {
    static let shared = KannaAdapter()

    /// 解析Itunes網站的HTML，取得MV檔案的路徑
    func parseAppleMusicVideoHTML(_ htmlString: String?) -> String? {
        if let htmlString, let doc = try? HTML(html: htmlString, encoding: .utf8) {
            // 使用 XPath 來獲取 meta 標籤中的 content 屬性
            if let videoUrl = doc.at_xpath("//meta[@property='og:video']/@content")?.text {
                Logger.log("音樂網址： \(videoUrl)")
                return videoUrl
            }
        }
        return nil
    }
}
