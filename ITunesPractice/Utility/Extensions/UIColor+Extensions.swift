//
//  UIColor+Extensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import UIKit

// MARK: - AssetsColor

enum AssetsColor {
    case red1
    case primaryText
    case secondaryText
    case background
    case gray1
    case gray2
    case gray3
}

extension UIColor {
    static func appColor(_ name: AssetsColor) -> UIColor? {
        switch name {
        case .red1: return UIColor(named: "red_1")
        case .primaryText: return UIColor(named: "primary_text")
        case .secondaryText: return UIColor(named: "secondary_text")
        case .background: return UIColor(named: "background")
        case .gray1: return UIColor(named: "gray_1")
        case .gray2: return UIColor(named: "gray_2")
        case .gray3: return UIColor(named: "gray_3")
        }
    }
}

extension UIColor {
    func toHexString() -> String {
        var rValue: CGFloat = 0
        var gValue: CGFloat = 0
        var bValue: CGFloat = 0
        var alpha: CGFloat = 0

        getRed(&rValue, green: &gValue, blue: &bValue, alpha: &alpha)

        let rgb = Int(rValue * 255)<<16 | Int(gValue * 255)<<8 | Int(bValue * 255)<<0

        return String(format: "#%06x", rgb)
    }

    /// 用16進制色碼生成顏色，前面可帶入#符號
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        var rgbValue: UInt64 = 0 // color #999999 if string has wrong format

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if (cString.count) == 6 {
            Scanner(string: cString).scanHexInt64(&rgbValue)
        }

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

extension UIColor {
    var redValue: CGFloat {
        var r: CGFloat = 0.0
        getRed(&r, green: nil, blue: nil, alpha: nil)
        return r
    }

    var greenValue: CGFloat {
        var g: CGFloat = 0.0
        getRed(nil, green: &g, blue: nil, alpha: nil)
        return g
    }

    var blueValue: CGFloat {
        var b: CGFloat = 0.0
        getRed(nil, green: nil, blue: &b, alpha: nil)
        return b
    }

    /**
     grayvalue越大的顏色代表越深。因為這個grayValue是由RGB三個色道的值經過加權平均得到的，其中綠色的權重最高，紅色次之，藍色最低。而深色通常具有較高的RGB值，因此這樣的計算方法會得到較高的grayValue。因此，grayValue越大的顏色代表其在人眼中看起來越黑暗、越深。
     */
    var grayValue: CGFloat {
        guard let components = cgColor.components else { return 0 }
        switch components.count {
        case 1: return components[0]
        // 假設只有 Alpha 和 Gray 值，根據 Alpha 值調整 Gray 值
        case 2: return components[1] * components[0]
        default: return 0.299 * components[0] + 0.587 * components[1] + 0.114 * components[2]
        }
    }

    // TODO: 待驗證效果
    /// 將兩色相加
    func add(overlay: UIColor) -> UIColor {
        var bgR: CGFloat = 0
        var bgG: CGFloat = 0
        var bgB: CGFloat = 0
        var bgA: CGFloat = 0

        var fgR: CGFloat = 0
        var fgG: CGFloat = 0
        var fgB: CGFloat = 0
        var fgA: CGFloat = 0

        self.getRed(&bgR, green: &bgG, blue: &bgB, alpha: &bgA)
        overlay.getRed(&fgR, green: &fgG, blue: &fgB, alpha: &fgA)

        let r = fgA * fgR + (1 - fgA) * bgR
        let g = fgA * fgG + (1 - fgA) * bgG
        let b = fgA * fgB + (1 - fgA) * bgB

        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}

extension Array where Element == UIColor {
    /**
     如果使用了範圍從 0 到 255 的 RGB 值來創建顏色，排序時使用了範圍從 0 到 1 的值，就可能會導致顏色的順序相反
     所以下面進行修正
     */
    func sortedByGrayValue(isDesc: Bool) -> [UIColor] {
        return self.sorted { color1, color2 -> Bool in
            if isDesc {
                return color1.grayValue < color2.grayValue
            } else {
                return color1.grayValue > color2.grayValue
            }
        }
    }
}
