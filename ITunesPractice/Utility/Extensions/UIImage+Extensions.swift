//
//  UIImage+Extensions.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/28.
//

import UIKit

extension UIImage {
    class func coverImageView(cornerRadius: CGFloat = 5) -> UIImageView {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = cornerRadius
        imageView.clipsToBounds = true
        return imageView
    }
    
    /// 取得圖片指定位置 pixel 的顏色
    func getPixelColor(_ pos: CGPoint) -> UIColor {
        guard let pixelData = cgImage?.dataProvider?.data else {
            return UIColor.clear
        }
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let pixelInfo: Int = ((Int(size.width) * Int(pos.y)) + Int(pos.x)) * 4
        let red = CGFloat(data[pixelInfo]) / 255.0
        let green = CGFloat(data[pixelInfo+1]) / 255.0
        let blue = CGFloat(data[pixelInfo+2]) / 255.0
        let alpha = CGFloat(data[pixelInfo+3]) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
