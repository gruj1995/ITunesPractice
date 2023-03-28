//
//  CAGradientLayer+Extensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/28.
//

import UIKit

// github 參考連結: https://stackoverflow.com/questions/34241739/cagradientlayer-get-color-at-pixel

extension CAGradientLayer {

    /// 在漸層的位置上取得對應的顏色。
    ///
    /// - Parameters:
    ///   - position: 漸層的位置，值為 0 到 1 之間。
    /// - Returns: 在此位置上的顏色，若無效的顏色則回傳 `nil`。
    func color(atPosition position: CGFloat) -> UIColor? {
        // 將 CGColor 類型轉換為 UIColor 類型。
        let cgColors = self.colors?.map { $0 as! CGColor }
        // 若顏色為空或無效，則回傳 `nil`。
        guard let colors = cgColors,
              !colors.isEmpty else {
            return nil
        }
        // 計算顏色的數量和漸層的分界點。
        let colorCount = colors.count
        let colorCutoff = 1.0 / Double(colorCount)
        // 計算此位置對應的顏色索引。
        var index = Int(floor(position * CGFloat(colorCount)))
        if index >= colorCount {
            index = colorCount - 1
        }
        // 計算前後兩個顏色的索引。
        let firstColorIndex = index
        let secondColorIndex = min(index + 1, colorCount - 1)
        // 計算前後兩個顏色在此位置上的比例。 (fmod是用於浮點數取餘數的方法)
        let firstInterp = 1.0 - (fmod(position, CGFloat(colorCutoff)) / CGFloat(colorCutoff))
        let secondInterp = 1.0 - firstInterp
        // 取得前後兩個顏色。
        let firstColor = UIColor(cgColor: colors[firstColorIndex])
        let secondColor = UIColor(cgColor: colors[secondColorIndex])
        // 計算在此位置上的 RGB 值。
        let red = firstColor.redValue * firstInterp + secondColor.redValue * secondInterp
        let green = firstColor.greenValue * firstInterp + secondColor.greenValue * secondInterp
        let blue = firstColor.blueValue * firstInterp + secondColor.blueValue * secondInterp
        // 回傳在此位置上的顏色。
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
