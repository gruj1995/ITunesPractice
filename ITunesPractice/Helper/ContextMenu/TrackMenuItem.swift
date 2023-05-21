//
//  TrackMenuItem.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/6.
//

import UIKit

// MARK: - TrackMenuType

enum TrackMenuType: TrackMenuItem {
    case addOrRemoveFromLibrary // 加入資料庫/從資料庫刪除
    case editPlaylist // 修改待播清單
    case share // 分享歌曲

    // MARK: Internal

    func getMenuElement(for track: Track) -> UIMenuElement {
        switch self {
        case .addOrRemoveFromLibrary:
            if track.isInLibrary {
                return DeleteMenuItem().getMenuElement(for: track)
            } else {
                return AddMenuItem().getMenuElement(for: track)
            }
        case .editPlaylist:
//            let trackWithNewID = track.autoIncrementID()
//            return EditPlaylistMenuItem().getMenuElement(for: trackWithNewID)
            return EditPlaylistMenuItem().getMenuElement(for: track)
        case .share:
            return ShareMenuItem().getMenuElement(for: track)
        }
    }
}

// MARK: - TrackMenuItem

protocol TrackMenuItem {
    func getMenuElement(for track: Track) -> UIMenuElement
}

// MARK: - AddMenuItem

/// 加入資料庫
struct AddMenuItem: TrackMenuItem {
    func getMenuElement(for track: Track) -> UIMenuElement {
        let addAction = UIAction(title: "加入資料庫".localizedString(), image: AppImages.plus) { _ in
            // 新的插入到最前面
            let newTrack = track.autoIncrementID()
            print("__+ \(newTrack.id)")
            UserDefaults.defaultPlaylist.tracks.insert(newTrack, at: 0)
            Utils.toast("已加入資料庫".localizedString())
        }
        return UIMenu(title: "", options: .displayInline, children: [addAction])
    }
}

// MARK: - DeleteMenuItem

/// 從資料庫刪除
struct DeleteMenuItem: TrackMenuItem {
    func getMenuElement(for track: Track) -> UIMenuElement {
        let deleteAction = UIAction(title: "從資料庫中刪除".localizedString(), image: AppImages.trash, attributes: .destructive) { _ in
            let alertController = ActionButtonAlertController(title: "確定要從您的資料庫刪除這首歌嗎？這也會從播放列表中移除".localizedString(), message: nil, preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "刪除歌曲".localizedString(), style: .destructive) { _ in
                UserDefaults.defaultPlaylist.tracks.removeAll { $0 == track }
                Utils.toast("已從資料庫中刪除".localizedString())
            }
            let cancelAction = UIAlertAction(title: "取消".localizedString(), style: .cancel, handler: nil)
            alertController.view.tintColor = .systemRed
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            let rootVC = UIApplication.shared.rootViewController
            rootVC?.present(alertController, animated: true, completion: nil)
        }
        return UIMenu(title: "", options: .displayInline, children: [deleteAction])
    }
}

// MARK: - ShareMenuItem

/// 分享歌曲
struct ShareMenuItem: TrackMenuItem {
    func getMenuElement(for track: Track) -> UIMenuElement {
        let shareAction = UIAction(title: "分享歌曲".localizedString(), image: AppImages.squareAndArrowUp) { _ in
            Utils.shareTrack(track)
        }
        return shareAction
    }
}

// MARK: - EditPlaylistMenuItem

/// 修改待播清單
struct EditPlaylistMenuItem: TrackMenuItem {
    // MARK: Internal

    func getMenuElement(for track: Track) -> UIMenuElement {
        let insertToFirstAction = UIAction(title: "插播".localizedString(), image: AppImages.insertToFirst) { _ in
            guard let _ = URL(string: track.previewUrl) else {
                Utils.toast(MusicPlayerError.invalidTrack.unwrapDescription)
                return
            }
            musicPlayer.insertTrackToPlaylist(track)
            Utils.toast("已插播".localizedString())
        }
        let addToLastAction = UIAction(title: "最後播放".localizedString(), image: AppImages.addToLast) { _ in
            guard let _ = URL(string: track.previewUrl) else {
                Utils.toast(MusicPlayerError.invalidTrack.unwrapDescription)
                return
            }
            musicPlayer.addTrackToPlaylist(track)
            Utils.toast("將於最後播放".localizedString())
        }
        return UIMenu(title: "", options: .displayInline, children: [insertToFirstAction, addToLastAction])
    }

    // MARK: Private

    private let musicPlayer: MusicPlayer = .shared
}
