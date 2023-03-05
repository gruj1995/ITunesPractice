//
//  String+Extensins.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Foundation

extension String {
    /// 轉成多語系化文字
    ///  - comment: 可填入翻譯文案的註解，預設填空字串即可
    func localizedString(comment: String = "") -> String {
        // 將安卓的格式化符號替換成iOS的
        return NSLocalizedString(self, comment: comment).replace(target: "%1$s", withString: "%@")
    }

    func replace(target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}
