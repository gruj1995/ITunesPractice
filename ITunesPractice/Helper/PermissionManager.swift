//
//  PermissionManager.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/10.
//

import AVFoundation
import Foundation
import Photos

/// 請求App權限
class PermissionManager {
    static let shared = PermissionManager()

    func configure() {}

    /// 請求相機權限
    func checkCameraPermission(_ completion: @escaping (Bool) -> Void) {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

        switch cameraAuthorizationStatus {
        case .authorized:
            // 相機權限已授予
            completion(true)
        case .denied, .restricted:
            // 相機權限已拒絕或受限制
            completion(false)
        case .notDetermined:
            // 還沒詢問過相機權限，請求權限
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        default:
            completion(false)
        }
    }

    /// 請求相簿權限
    func checkPhotoLibraryPermission(_ completion: @escaping (Bool) -> Void) {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()

        switch photoAuthorizationStatus {
        case .authorized:
            // 相簿權限已授予
            completion(true)
        case .denied, .restricted:
            // 相簿權限已拒絕或受限制
            completion(false)
        case .notDetermined:
            // 還沒詢問過相簿權限，請求權限
            PHPhotoLibrary.requestAuthorization { status in
                // 相簿權限已授予
                let isAuthorized = status == .authorized
                completion(isAuthorized)
            }
        default:
            completion(false)
        }
    }
}
