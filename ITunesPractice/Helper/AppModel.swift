//
//  AppModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/10/16.
//

import PythonSupport
import YoutubeDL
import Combine
import UIKit
import AVFoundation
import Photos
import PythonKit

typealias FormatsContinuation = CheckedContinuation<([Format], TimeRange?), Never>
typealias YTDownloadResult = (info: PythonObject?, files: [String], infos: [PythonObject])

class AppModel {
    static let shared = AppModel()

//    @Published var url: URL?

    @Published var youtubeDL = YoutubeDL()

//    @Published var enableChunkedDownload = true
//
//    @Published var enableTranscoding = true
//
//    @Published var supportedFormatsOnly = true
//
//    @Published var exportToPhotos = true
//
//    @Published var fileURL: URL?

    @Published var downloads: [URL] = []

    @Published var showProgress = false

    var progress = Progress()

    @Published var error: Error?

    @Published var exception: PythonObject?

    @Published var info: Info?

    /// mp3 資料夾路徑
    lazy var mp3DocumentUrl: URL = {
        // 上層文件路徑
        let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // 照片資料夾路徑
        let fileUrl = docURL.appendingPathComponent("Mp3")
        // 檢查路徑正確性
        Utils.createDirectoryIfNotExist(atPath: fileUrl.relativePath)
        return fileUrl
    }()

    var formatSelector: YoutubeDL.FormatSelector?

    var formatsContinuation: FormatsContinuation?

    var formats: ([([Format], String)])?

    lazy var subscriptions = Set<AnyCancellable>()

    init() {
        changeCurrentDirectoryPath()

//        $url
//            .compactMap { $0 }
//            .sink { url in
//                Task {
//                    await self.startDownload(url: url)
//                }
////                Task {
////                    do {
////                        try await self.extractInfo(url: url)
////                    } catch {
////                        // FIXME: ...
////                        print(#function, error)
////                    }
////                }
//            }
//            .store(in: &subscriptions)

        updateDownloads()
    }

    /// 取得音樂資訊
    func extractInfo (url: URL) async throws {
//        let youtubeDL: PythonObject = try await YtDlp().yt_dlp.YoutubeDL(["nocheckcertificate": true])
//        let info = try PythonDecoder()
//            .decode(
//                Info.self,
//                from: youtubeDL
//                    .extract_info
//                    .throwing
//                    .dynamicallyCall(withKeywordArguments: ["": url.lastPathComponent, "download": false])
//            )
//        print("__++ 1 info __+", info)

//        let result = try await youtubeDL.extractInfo(url: url)
//        print("__++ 1 format __+", result.0)
//        print("__++ 2 infos  __+", result.1)
    }

    func updateDownloads() {
        do {
            downloads = try loadDownloads()
        } catch {
            // FIXME: ...
            print(#function, error)
        }
    }

    func startDownload(url: URL) async {
        print(#function, url)

        do {
            let result = try await download(url: url)
            showProgress = false
            appendTrack(info: result.info)
//            await setInfo(result.info)
//            updateDownloads()
        } catch YoutubeDLError.canceled {
            print(#function, "canceled")
        } catch PythonError.exception(let exception, traceback: _) {
            print(#function, exception)
            await MainActor.run {
                self.exception = exception
            }
        } catch {
            print(#function, error)
            await MainActor.run {
                self.error = error
            }
        }
    }

    func appendTrack(info: PythonObject?) {
        guard let info, let infoData = try? PythonDecoder().decode(Info.self, from: info) else {
            return
        }
        let mp3FileName = infoData.title
        let mp3URL = mp3DocumentUrl.appendingPathComponent(mp3FileName).appendingPathExtension(for: .mp3)

        var track = Track(trackName: infoData.title, previewUrl: mp3URL.relativeString)
        track.ytId = infoData.id
        track.videoUrl = URL(string: infoData.webpage_url ?? "")
        track.artworkUrl100 = infoData.thumbnail ?? ""
        if !UserDefaults.filePlaylist.contains(track) {
            UserDefaults.filePlaylist.append(track)
        }
    }

    func save(info: Info) throws -> URL {
        let title = info.safeTitle
        let fileManager = FileManager.default
        var url = URL(fileURLWithPath: title, relativeTo: mp3DocumentUrl)
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)

        // exclude from iCloud backup
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try url.setResourceValues(values)

        let data = try JSONEncoder().encode(info)
        try data.write(to: url.appendingPathComponent("Info.json"))

        return url
    }

    func loadDownloads() throws -> [URL] {
        let keys: Set<URLResourceKey> = [.nameKey, .isDirectoryKey]
        let documents = mp3DocumentUrl
        guard let enumerator = FileManager.default.enumerator(at: documents, includingPropertiesForKeys: Array(keys), options: .skipsHiddenFiles) else { fatalError() }
        var urls = [URL]()
        for case let url as URL in enumerator {
            let values = try url.resourceValues(forKeys: keys)
            guard enumerator.level == 2, url.lastPathComponent == "Info.json" else { continue }
            print(enumerator.level, url.path.replacingOccurrences(of: documents.path, with: ""), values.isDirectory ?? false ? "dir" : "file")
            urls.append(url.deletingLastPathComponent())
        }
        return urls
    }

    func download(url: URL) async throws -> YTDownloadResult {
        progress.localizedDescription = NSLocalizedString("Extracting info", comment: "progress description")

        showProgress = true

        var info: PythonObject?
        var files = [String]()
        var formats = [PythonObject]()
        var error: String?

//        let argv: [String] = (
//            url.pathExtension == "mp4"
//            ? ["-o", url.lastPathComponent]
//            : [
//                "-f", "bestvideo+bestaudio[ext=m4a]/best",
//                "--merge-output-format", "mp4",
//                "--postprocessor-args", "Merger+ffmpeg:-c:v h264",
//                "-o", "%(title).200B.%(ext)s" // https://github.com/yt-dlp/yt-dlp/issues/1136#issuecomment-932077195
//            ]
//        )
        let argv: [String] = (
            url.pathExtension == "mp3"
            ? ["-o", url.lastPathComponent]
            : [
                "-x",
                "--audio-format", "mp3",
                "--postprocessor-args", "-acodec libmp3lame",
                "-o", "%(title).200B.%(ext)s" // https://github.com/yt-dlp/yt-dlp/issues/1136#issuecomment-932077195
            ]
        )
        + [
            "--no-check-certificates",
            url.absoluteString
        ]
        print(#function, argv)
        try await yt_dlp(argv: argv) { dict in
            info = dict["info_dict"]
//            if self.info == nil {
//                DispatchQueue.main.async {
//                    self.info = try? PythonDecoder().decode(Info.self, from: info!)
//                }
//            }

            let status = String(dict["status"]!)

            self.progress.localizedDescription = nil

            switch status {
            case "downloading":
                self.progress.kind = .file
                self.progress.fileOperationKind = .downloading
                if #available(iOS 16.0, *) {
                    self.progress.fileURL = URL(filePath: String(dict["tmpfilename"]!)!)
                } else {
                    // Fallback on earlier versions
                }
                self.progress.completedUnitCount = Int64(dict["downloaded_bytes"]!) ?? -1
                self.progress.totalUnitCount = Int64(Double(dict["total_bytes"] ?? dict["total_bytes_estimate"] ?? Python.None) ?? -1)
                self.progress.throughput = Int(dict["speed"]!)
                // 剩餘下載時間
                self.progress.estimatedTimeRemaining = TimeInterval(dict["eta"]!)
            case "finished":
                print(#function, dict["filename"] ?? "no filename")
                files.append(String(dict["filename"] ?? "")!)
                formats.append(info!)
            default:
                print(#function, dict)
            }
        } log: { level, message in
            print(#function, level, message)

            if level == "error" || message.hasSuffix("has already been downloaded") {
                error = message
            }
        } makeTranscodeProgressBlock: {
            self.progress.kind = nil
            self.progress.localizedDescription = NSLocalizedString("Transcoding...", comment: "Progress description")
            self.progress.completedUnitCount = 0
            self.progress.totalUnitCount = 100

            let t0 = ProcessInfo.processInfo.systemUptime

            return { (progress: Double) in
                print(#function, "transcode:", progress)
                let elapsed = ProcessInfo.processInfo.systemUptime - t0
                let speed = progress / elapsed
                let eta = (1 - progress) / speed

                guard eta.isFinite else { return }

                self.progress.completedUnitCount = Int64(progress * 100)
                self.progress.estimatedTimeRemaining = eta
            }
        }

        if let error {
            throw NSError(domain: "App", code: 1, userInfo: [NSLocalizedDescriptionKey: error])
        }

        return (info, files, formats)
    }

    func transcode(videoURL: URL, transcodedURL: URL, timeRange: TimeRange?, bitRate: Double?) async throws {
        progress.kind = nil
        progress.localizedDescription = NSLocalizedString("Transcoding...", comment: "Progress description")
        progress.totalUnitCount = 100

        let t0 = ProcessInfo.processInfo.systemUptime

        let transcoder = Transcoder { progress in
            print(#function, "transcode:", progress)
            let elapsed = ProcessInfo.processInfo.systemUptime - t0
            let speed = progress / elapsed
            let eta = (1 - progress) / speed

            guard eta.isFinite else { return }

            self.progress.completedUnitCount = Int64(progress * 100)
            self.progress.estimatedTimeRemaining = eta
        }

        let _: Int = try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global().async {
                do {
                    try transcoder.transcode(from: videoURL, to: transcodedURL, timeRange: timeRange, bitRate: bitRate)
                    continuation.resume(returning: 0)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// 將影片 (videoURL) 與音樂檔 (audioURL) 合併成一個輸出文件 (outputURL) 的功能
    func mux(video videoURL: URL, audio audioURL: URL, out outputURL: URL, timeRange: TimeRange?) async throws -> Bool {
        let t0 = ProcessInfo.processInfo.systemUptime

        let videoAsset = AVAsset(url: videoURL)
        let audioAsset = AVAsset(url: audioURL)

        guard let videoAssetTrack = videoAsset.tracks(withMediaType: .video).first,
              let audioAssetTrack = audioAsset.tracks(withMediaType: .audio).first else {
            print(#function,
                  videoAsset.tracks(withMediaType: .video),
                  audioAsset.tracks(withMediaType: .audio))
            return false
        }

        let composition = AVMutableComposition()
        let videoCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)

        do {
            try videoCompositionTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: videoAssetTrack.timeRange.duration), of: videoAssetTrack, at: .zero)
            let range: CMTimeRange
            if let timeRange = timeRange {
                range = CMTimeRange(start: CMTime(seconds: timeRange.lowerBound, preferredTimescale: 1),
                                    end: CMTime(seconds: timeRange.upperBound, preferredTimescale: 1))
            } else {
                range = CMTimeRange(start: .zero, duration: audioAssetTrack.timeRange.duration)
            }
            try audioCompositionTrack?.insertTimeRange(range, of: audioAssetTrack, at: .zero)
            print(#function, videoAssetTrack.timeRange, range)
        } catch {
            print(#function, error)
            return false
        }

        guard let session = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetPassthrough) else {
            print(#function, "unable to init export session")
            return false
        }

        removeItem(at: outputURL)

        session.outputURL = outputURL
        session.outputFileType = .mp4
        print(#function, "merging...")

        DispatchQueue.main.async {
            let progress = self.progress
            progress.kind = nil
            progress.localizedDescription = NSLocalizedString("Merging...", comment: "Progress description")
            progress.localizedAdditionalDescription = nil
            progress.totalUnitCount = 0
            progress.completedUnitCount = 0
            progress.estimatedTimeRemaining = nil
        }

        Task {
            while session.status != .completed {
                print(#function, session.progress)
                progress.localizedDescription = "\(Int(session.progress * 100))%"
                try await Task.sleep(nanoseconds: 100_000_000)
            }
        }

        return try await withCheckedThrowingContinuation { continuation in
            session.exportAsynchronously {
                print(#function, "finished merge", session.status.rawValue)
                print(#function, "took", self.youtubeDL.downloader.dateComponentsFormatter.string(from: ProcessInfo.processInfo.systemUptime - t0) ?? "?")
                if session.status == .completed {
                    if !self.youtubeDL.keepIntermediates {
                        removeItem(at: videoURL)
                        removeItem(at: audioURL)
                    }
                } else {
                    print(#function, session.error ?? "no error?")
                }

                continuation.resume(with: Result {
                    if let error = session.error { throw error }
                    return true
                })
            }
        }
    }

    /// 將影片寫入到用戶相簿中
    func export(url: URL) {
        PHPhotoLibrary.shared().performChanges({
            _ = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) { success, error in
            print(#function, success, error ?? "")
            DispatchQueue.main.async {
                self.error = error
            }
        }
    }

    func pauseDownload() {

    }

    func resumeDownload() {

    }

    func cancelDownload() {

    }

    func share() {

    }
}

extension AppModel {
    /// 重要！ 目前的寫法不加這段會無法寫入檔案
    private func changeCurrentDirectoryPath() {
        FileManager.default.changeCurrentDirectoryPath(mp3DocumentUrl.path)
    }

    func setInfo(_ info: Info) async {
        formatSelector = { info in
            self.info = info
            Logger.log("下載資訊： \(info)")
            let (formats, timeRange): ([Format], TimeRange?) = await withCheckedContinuation { continuation in
                self.formatsContinuation = continuation
                self.formats = [([], "Transcode")]
            }

            var url: URL?
            if !formats.isEmpty {
                url = try? self.save(info: info)
            }

            self.showProgress = true

            return (formats, url, timeRange, formats.first?.vbr, "")
        }
    }
}
