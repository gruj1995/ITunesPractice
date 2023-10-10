//
//  PhotoMenuItem.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/9.
//

import UIKit

// MARK: - Photographable

protocol Photographable: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {}

// MARK: - PhotoMenuItem

struct PhotoMenuItem {
    // MARK: Internal

    func getMenuElement(_ vc: Photographable) -> UIMenuElement {
        let photographAction = UIAction(title: "拍照".localizedString(), image: AppImages.camera) { _ in
            photograph(vc)
        }
        let selectAction = UIAction(title: "選擇照片 ".localizedString(), image: AppImages.photoOnRectangle) { _ in
            selectPhoto(vc)
        }
        return UIMenu(title: "", options: .displayInline, children: [photographAction, selectAction])
    }

    // MARK: Private

    /// 拍照
    private func photograph(_ vc: Photographable) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // 確認相機權限
            PermissionManager.shared.checkCameraPermission { isAuthorized in
                DispatchQueue.main.async {
                    guard isAuthorized else {
                        showCameraPermissionAlert()
                        return
                    }
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = vc
                    imagePicker.sourceType = .camera // 透過拍照取得照片
                    imagePicker.cameraFlashMode = .off // 關閉閃光燈
                    imagePicker.allowsEditing = true
                    vc.present(imagePicker, animated: true)
                }
            }
        } else {
            Utils.toast("當前裝置不支援拍攝")
        }
    }

    /// 選擇照片
    private func selectPhoto(_ vc: Photographable) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            // 確認相簿權限
            PermissionManager.shared.checkPhotoLibraryPermission { isAuthorized in
                DispatchQueue.main.async {
                    guard isAuthorized else {
                        showPhotoLibraryPermissionAlert()
                        return
                    }
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = vc
                    imagePicker.sourceType = .photoLibrary // 透過相簿取得照片
                    imagePicker.allowsEditing = true
                    vc.present(imagePicker, animated: true)
                }
            }
        } else {
            Utils.toast("相簿取得失敗")
        }
    }

    /// 相機權限未啟用彈窗
    private func showCameraPermissionAlert() {
        AlertManager.shared.showSettingAlert(
            title: "請開啟相機權限".localizedString(),
            message: "請到設定啟用「相機」權限，才能開啟相機的功能".localizedString(),
            settingURL: UIApplication.openSettingsURLString)
    }

    /// 相簿權限未啟用彈窗
    private func showPhotoLibraryPermissionAlert() {
        AlertManager.shared.showSettingAlert(
            title: "請開啟相簿權限".localizedString(),
            message: "請到設定修改「照片」權限，才能存取您的相簿".localizedString(),
            settingURL: UIApplication.openSettingsURLString)
    }
}
