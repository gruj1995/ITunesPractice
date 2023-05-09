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
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = vc
            imagePicker.sourceType = .camera // 透過拍照取得照片
            imagePicker.allowsEditing = true // 取得照片後是否可編輯
            imagePicker.cameraFlashMode = .off // 關閉閃光燈
            vc.present(imagePicker, animated: true, completion: nil)
        }
    }

    /// 選擇照片
    private func selectPhoto(_ vc: Photographable) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = vc
            imagePicker.sourceType = .photoLibrary // 透過相簿取得照片
            imagePicker.allowsEditing = true
            vc.present(imagePicker, animated: true, completion: nil)
        }
    }
}
