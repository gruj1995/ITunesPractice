//
//  Utils.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/6.
//

import UIKit
import UniformTypeIdentifiers // 文件類型id

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

extension Utils {
    /// 取得所有檔案類型
    /// https://stackoverflow.com/questions/70102279/how-to-get-all-extensions-for-uttype-image-audio-and-video
    ///
    static func allUTITypes() -> [UTType] {
        let types: [UTType] =
            [.item,
             .content,
             .compositeContent,
             .diskImage,
             .data,
             .directory,
             .resolvable,
             .symbolicLink,
             .executable,
             .mountPoint,
             .aliasFile,
             .urlBookmarkData,
             .url,
             .fileURL,
             .text,
             .plainText,
             .utf8PlainText,
             .utf16ExternalPlainText,
             .utf16PlainText,
             .delimitedText,
             .commaSeparatedText,
             .tabSeparatedText,
             .utf8TabSeparatedText,
             .rtf,
             .html,
             .xml,
             .yaml,
             .sourceCode,
             .assemblyLanguageSource,
             .cSource,
             .objectiveCSource,
             .swiftSource,
             .cPlusPlusSource,
             .objectiveCPlusPlusSource,
             .cHeader,
             .cPlusPlusHeader]

        let types1: [UTType] =
            [.script,
             .appleScript,
             .osaScript,
             .osaScriptBundle,
             .javaScript,
             .shellScript,
             .perlScript,
             .pythonScript,
             .rubyScript,
             .phpScript,
             .makefile, // 'makefile' is only available in iOS 15.0 or newer
             .json,
             .propertyList,
             .xmlPropertyList,
             .binaryPropertyList,
             .pdf,
             .rtfd,
             .flatRTFD,
             .webArchive,
             .image,
             .jpeg,
             .tiff,
             .gif,
             .png,
             .icns,
             .bmp,
             .ico,
             .rawImage,
             .svg,
             .livePhoto,
             .heif,
             .heic,
             .webP,
             .threeDContent,
             .usd,
             .usdz,
             .realityFile,
             .sceneKitScene,
             .arReferenceObject,
             .audiovisualContent]

        let types2: [UTType] =
            [.movie,
             .video,
             .audio,
             .quickTimeMovie,
             UTType("com.apple.quicktime-image"),
             .mpeg,
             .mpeg2Video,
             .mpeg2TransportStream,
             .mp3,
             .mpeg4Movie,
             .mpeg4Audio,
             .appleProtectedMPEG4Audio,
             .appleProtectedMPEG4Video,
             .avi,
             .aiff,
             .wav,
             .midi,
             .playlist,
             .m3uPlaylist,
             .folder,
             .volume,
             .package,
             .bundle,
             .pluginBundle,
             .spotlightImporter,
             .quickLookGenerator,
             .xpcService,
             .framework,
             .application,
             .applicationBundle,
             .applicationExtension,
             .unixExecutable,
             .exe,
             .systemPreferencesPane,
             .archive,
             .gzip,
             .bz2,
             .zip,
             .appleArchive,
             .spreadsheet,
             .presentation,
             .database,
             .message,
             .contact,
             .vCard,
             .toDoItem,
             .calendarEvent,
             .emailMessage,
             .internetLocation,
             .internetShortcut,
             .font,
             .bookmark,
             .pkcs12,
             .x509Certificate,
             .epub,
             .log]
            .compactMap { $0 }

        return types + types1 + types2
    }
}
