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

    /// 檢查 email 參數是否符合電子郵件地址的格式
    func isValidEmail(_ email: String) -> Bool {
       let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
       let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
       return emailPred.evaluate(with: email)
   }

    func toInt() -> Int {
        Int(self) ?? 0
    }
}

// MARK: 影片

extension String {
    func formatViewCount() -> String {
        let viewCount = replacingOccurrences(of: "觀看次數：", with: "").replacingOccurrences(of: "次", with: "").replacingOccurrences(of: ",", with: "")
        return "\(getDealNum(with: viewCount))次"
    }

    func getDealNum(with string: String) -> String {
        let numberA = NSDecimalNumber(string: string)
        var numberB: NSDecimalNumber?
        var unitStr: String = ""

        switch string.count {
        case 5..<7:
            numberB = NSDecimalNumber(string: "10000")
            unitStr = "萬"
        case 7:
            numberB = NSDecimalNumber(string: "1000000")
            unitStr = "百萬"
        case 8:
            numberB = NSDecimalNumber(string: "10000000")
            unitStr = "千萬"
        case 9...:
            numberB = NSDecimalNumber(string: "100000000")
            unitStr = "億"
        default:
            return string
        }

        let roundingBehavior = NSDecimalNumberHandler(
            roundingMode: .plain,
            scale: 0,
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: false
        )

        let numResult = numberA.dividing(by: numberB ?? NSDecimalNumber.one, withBehavior: roundingBehavior)
        return numResult.stringValue + unitStr
    }
}
