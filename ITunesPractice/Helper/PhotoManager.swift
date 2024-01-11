//
//  PhotoManager.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/11.
//

import UIKit
import Photos

class PhotoManager {
    // MARK: Lifecycle

    private init() {}

    // MARK: Internal

    static let shared = PhotoManager()

    func configure() {}

    /// 取得放在 App 照片資料夾內的照片路徑
    func getPhotoDocURL() -> URL {
        // 上層文件路徑
        let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // 照片資料夾路徑
        let fileUrl = docURL.appendingPathComponent(fileName)
        // 檢查路徑正確性
        Utils.createDirectoryIfNotExist(atPath: fileUrl.relativePath)
        return fileUrl
    }

    /// 寫入圖片到 App 照片資料夾
    func writeImage(_ image: UIImage?, with name: String) -> URL? {
        do {
            // 照片路徑
            let imageUrl = getPhotoDocURL().appendingPathComponent(name)
            // 照片檔（用 .png 檔才不會有白色背景）
            if let imgData = image?.pngData() {
                // 將照片檔存到指定路徑
                try imgData.write(to: imageUrl, options: .atomic)
                return imageUrl
            }
        } catch {
            Logger.log("Not save correctly")
        }
        return nil
    }

    /// 將照片存入用戶相簿，並取得照片路徑
    func savePhotoToAlbum(image: UIImage, _ completion: @escaping ((URL?) -> Void)) {
        var assetLocalIdentifier: String?

        PHPhotoLibrary.shared().performChanges({
            let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            assetLocalIdentifier = assetRequest.placeholderForCreatedAsset?.localIdentifier
        }, completionHandler: { success, error in
            if success {
                // 照片已存入相簿
                let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [assetLocalIdentifier!], options: nil)
                if let asset = fetchResult.firstObject {
                    let options = PHContentEditingInputRequestOptions()
                    options.canHandleAdjustmentData = { (_: PHAdjustmentData) -> Bool in
                        true
                    }
                    asset.requestContentEditingInput(with: options) { contentEditingInput, _ in
                        // 取得照片存放路徑
                        if let url = contentEditingInput?.fullSizeImageURL {
                            DispatchQueue.main.async {
                                completion(url)
                            }
                        }
                    }
                }
            } else {
                Logger.log("無法將照片存入相簿：\(error?.localizedDescription ?? "")")
            }
        })
    }

    /// 寫入貓貓預設圖到 App 照片資料夾，並紀錄圖片路徑到 UserDefaults 中
    func writePlaceholders() {
        for (index, placeholder) in catPlaceholders.enumerated() {
            if let url = writeImage(placeholder, with: "default_cat\(index)") {
                UserDefaults.placeholderUrls.append(url)
            }
        }
    }

    // MARK: Private

    /// 貓貓預設圖
    private let catPlaceholders: [UIImage?] = [
        AppImages.catMoutainGreen,
        AppImages.catMoutainDarkBlue,
        AppImages.catMoutainLightBlue
    ]

    /// App 內的照片資料夾名稱
    private let fileName: String = "Photo"
}
