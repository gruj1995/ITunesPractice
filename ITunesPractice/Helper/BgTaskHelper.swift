////
////  BgTaskHelper.swift
////  ITunesPractice
////
////  Created by 李品毅 on 2023/10/18.
////
//
//import UIKit
//import BackgroundTasks
//
//class BgTaskHelper {
//    static let shared = BgTaskHelper()
//
//    var playerView: YoutubePlayerView?
//
//    let playVideoBgTaskId = "com.pinyi.itunesmusic.play"
//
//    func registerBackgroundTask() {
//        BGTaskScheduler.shared.register(forTaskWithIdentifier: playVideoBgTaskId, using: nil) { task in
//             self.handleAppRefresh(task: task as! BGAppRefreshTask)
//        }
//    }
//
//    func scheduleProcessing() {
//        guard let playerView else { return }
//
//        let request = BGAppRefreshTaskRequest(identifier: playVideoBgTaskId)
//        do {
//            try BGTaskScheduler.shared.submit(request)
//        } catch {
//            Logger.log("Could not schedule app refresh: \(error)")
//        }
//    }
//
//    func handleAppRefresh(task: BGAppRefreshTask) {
//       // Schedule a new refresh task.
//        scheduleProcessing()
//
//       let operationQueue = OperationQueue()
//
//       // Create an operation that performs the main part of the background task.
//       let operation = PlayVideoOperation()
//        operation.playerView = playerView
//
//       // Provide the background task with an expiration handler that cancels the operation.
//       task.expirationHandler = {
//          operation.cancel()
//       }
//
//       // Inform the system that the background task is complete
//       // when the operation completes.
//       operation.completionBlock = {
//          task.setTaskCompleted(success: !operation.isCancelled)
//       }
//
//       // Start the operation.
//       operationQueue.addOperation(operation)
//     }
//}
//
//class PlayVideoOperation: Operation {
//    var playerView: YoutubePlayerView?
//
//    override func main() {
//        playerView?.playerView
//        playerView?.playVideo()
////        playerView?.playerView.webView?.evaluateJavaScript("player.playVideo();")
//    }
//}
