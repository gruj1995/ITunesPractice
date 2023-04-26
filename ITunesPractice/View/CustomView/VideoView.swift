//
//  VideoView.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/24.
//

import AVFoundation
import UIKit

// MARK: - VideoView

// 參考： https://medium.com/@tarasuzy00/%E7%94%A8-swift-%E8%A3%BD%E4%BD%9C%E6%92%AD%E6%94%BE%E5%99%A8-ios-avplayer-%E6%95%99%E5%AD%B8-%E4%B8%80-%E8%A8%AD%E5%AE%9A%E4%B8%A6%E6%92%AD%E6%94%BE-avplayer-695dd145d9de

class VideoView: UIView {
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

//        player?.currentItem?.observe(\.status, options: [.new]) { [weak self] _, change in
//            guard let newVolume = change.newValue else { return }
////            self?.volumeChanged(newVolume)
//        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    private var loaderDelegat: SimpleResourceLoaderDelegate?

    deinit {
        loaderDelegat?.invalidate()
    }

    private func setDelegate(with url: URL) {
        loaderDelegat = SimpleResourceLoaderDelegate(withURL: url)
        let videoAsset = AVURLAsset(url: loaderDelegat!.streamingAssetURL)
        videoAsset.resourceLoader.setDelegate(loaderDelegat, queue: DispatchQueue.main)

        loaderDelegat?.completion = { localFileURL in
            if let localFileURL = localFileURL {
                print("Media file saved to: \(localFileURL)")
            } else {
                print("Failed to download media file.")
            }
        }

        let item = AVPlayerItem(asset: videoAsset)
        item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &playerItemContext)
        player = AVPlayer(playerItem: item)
    }

    func play(with url: URL) {
//        let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
//        let url = URL(string: "https://video-ssl.itunes.apple.com/itunes-assets/Video126/v4/9f/8d/c7/9f8dc7e7-6373-4e9b-9873-c2dc818ea07d/mzvf_12376652547626120255.720w.h264lc.U.p.m4v")!
        setDelegate(with: url)

//        initPlayerAsset(with: url) { (asset: AVAsset) in
//            let item = AVPlayerItem(asset: asset)
//            item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &self.playerItemContext)
//
//            DispatchQueue.main.async {
//                self.player = AVPlayer(playerItem: item)
////                self.player?.allowsExternalPlayback = false
//
////                let videoURL = URL(string: "https://music.apple.com/tw/music-video/burn/1452877653")!
////                let asset = AVURLAsset(url: videoURL)
////                asset.resourceLoader.setDelegate(ByteRangeLoaderDelegate(), queue: DispatchQueue.main)
////                let playerItem = AVPlayerItem(asset: asset)
//            }
//        }
    }

    // 透過 KVO 觀察播放狀態
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }

            // Switch over status value
            switch status {
            case .readyToPlay:
                print(".readyToPlay")
                self.player?.play()
            case .failed:
                print(".failed \(player?.currentItem?.error)")
            case .unknown:
                print(".unknown")
            @unknown default:
                print("@unknown default")
            }
        }
    }

    // MARK: Private

    private var playerItemContext = 0

    private var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }

    private func initPlayerAsset(with url: URL, completion: ((_ asset: AVAsset) -> Void)?) {
        let asset = AVAsset(url: url)
        asset.loadValuesAsynchronously(forKeys: ["playable"]) {
            completion?(asset)
        }
    }
}

//class ByteRangeLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
//
//    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
//        guard let url = loadingRequest.request.url else { return false }
//        let newRequest = NSMutableURLRequest(url: url)
//        newRequest.addValue("bytes=0-\(Int.max)", forHTTPHeaderField: "Range")
//
//        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)
//        let task = session.dataTask(with: newRequest as URLRequest)
//        task.resume()
//        return true
//    }
//}
//
//extension ByteRangeLoaderDelegate: URLSessionDataDelegate {
//
//    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
//        guard let response = dataTask.response as? HTTPURLResponse else { return }
//        if let contentRangeHeader = response.allHeaderFields["Content-Range"] as? String,
//           let totalLength = contentRangeHeader.components(separatedBy: "/").last,
//           let rangeEnd = Int(totalLength) {
//            let rangeLength = data.count
//            let rangeStart = rangeEnd - rangeLength
//            let dataRange = NSRange(location: rangeStart, length: rangeLength)
////            loadingRequest.dataRequest?.respond(with: data.subdata(in: dataRange))
////            loadingRequest.finishLoading()
//        } else {
////            loadingRequest.finishLoading(with: NSError(domain: "ByteRangeLoaderDelegate", code: -1, userInfo: nil))
//        }
//    }
//}
