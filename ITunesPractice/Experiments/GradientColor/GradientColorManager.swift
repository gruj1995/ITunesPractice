//
//  GradientColorManager.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/19.
//

import UIKit

class GradientColorManager {
    static let shared = GradientColorManager()

    let pixelThinner = 10

    func findColors(_ image: UIImage, completion: @escaping ([String: Int]) -> Void) {
        guard let pixelData = image.cgImage?.dataProvider?.data else { completion([:]); return }
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        var countedColors: [String: Int] = [:]

        let pixelsWide = Int(image.size.width * image.scale)
        let pixelsHigh = Int(image.size.height * image.scale)

        //  let widthRange = 0..<pixelsWide
        //  let heightRange = 0..<pixelsHigh
        let widthThinner = Int(pixelsWide / pixelThinner) + 1
        let heightThinner = Int(pixelsHigh / pixelThinner) + 1
        let widthRange = stride(from: 0, to: pixelsWide, by: widthThinner)
        let heightRange = stride(from: 0, to: pixelsHigh, by: heightThinner)

        for x in widthRange {
            for y in heightRange {
                let pixelInfo: Int = ((pixelsWide * y) + x) * 4
                let color = "\(data[pixelInfo]).\(data[pixelInfo + 1]).\(data[pixelInfo + 2])"
                if countedColors[color] == nil {
                    countedColors[color] = 0
                } else {
                    countedColors[color]! += 1
                }
            }
        }

        completion(countedColors)
    }

    func findMainColors(_ colors: [String: Int]) -> (UIColor?, UIColor?, UIColor?) {
        var primaryColor: UIColor?, secondaryColor: UIColor?, detailColor: UIColor?
        for (colorString, _) in colors.sorted(by: { $0.value > $1.value }) {
            let colorParts: [String] = colorString.components(separatedBy: ".")
            let color = UIColor(red: CGFloat(Int(colorParts[0])!) / 255,
                                green: CGFloat(Int(colorParts[1])!) / 255,
                                blue: CGFloat(Int(colorParts[2])!) / 255,
                                alpha: 1).color(withMinimumSaturation: 0.15)

            guard !color.isBlackOrWhite() else { continue }
            if primaryColor == nil {
                primaryColor = color
            } else if secondaryColor == nil {
                if primaryColor!.isDistinct(color) {
                    secondaryColor = color
                }
            } else if detailColor == nil {
                if secondaryColor!.isDistinct(color), primaryColor!.isDistinct(color) {
                    detailColor = color
                    break
                }
            }
        }
        return (primaryColor, secondaryColor, detailColor)
    }
}

//import UIImageColors

///// 從圖檔提取出主要顏色、次要顏色、背景顏色、細節顏色
//private func generateColors(by image: UIImage) {
//    image.getColors(quality: .high) { [weak self] imageColors in
//        guard let self = self,
//              let imageColors = imageColors
//        else {
//            return
//            Logger.log("Get colors failed!")
//        }
//        //            let colors: [UIColor] = [
//        //                imageColors.primary,
//        //                imageColors.secondary,
//        //                imageColors.background,
//        //                imageColors.detail
//        //            ]
//        let colors: [UIColor] = [
//            imageColors.secondary,
//            imageColors.primary
//        ]
//
//        self.colorsSubject.send(colors)
//    }
//}
