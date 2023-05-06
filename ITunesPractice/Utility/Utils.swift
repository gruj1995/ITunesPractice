//
//  Utils.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/6.
//

import UIKit

struct Utils {
    /// 獲取App的根目錄路徑
    static func applicationSupportDirectoryPath() -> String {
        NSHomeDirectory()
    }

    /// 顯示 toast
    /// - Parameters:
    ///  - msg: toast message
    ///  - position: 出現位置
    ///  - textAlignment: 文字對齊方式
    static func toast(_ msg: String, at position: ToastHelper.Position = .bottom, alignment: NSTextAlignment = .center) {
        ToastHelper.shared.showToast(text: msg, position: position, alignment: alignment)
    }

    /// 生成做為火花的小圓點圖片，注意顏色如果設太深會導致變化不多且可能看不見
    static func createSparkleImage(width: Double, color: UIColor?) -> UIImage {
        let size = CGSize(width: width, height: width)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            color?.setFill()
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
        return image
    }

    static func shareTrack(_ track: Track) {
        guard let sharedUrl = URL(string: track.trackViewUrl) else {
            Logger.log("Shared url is nil")
            Utils.toast("分享失敗".localizedString())
            return
        }

        let activityVC = UIActivityViewController(activityItems: [sharedUrl], applicationActivities: nil)
        // 分享完成後的事件
        activityVC.completionWithItemsHandler = { _, completed, _, error in
            if completed {
                Utils.toast("分享成功".localizedString())
            } else {
                // 關閉分享彈窗也算分享失敗
                Logger.log(error?.localizedDescription ?? "")
                Utils.toast("分享失敗".localizedString())
            }
        }
        let topVC = UIApplication.shared.getTopViewController()
        topVC?.present(activityVC, animated: true)
    }
}
