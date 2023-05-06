//
//  AudioSearchHistoryViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/5/6.
//

import Combine
import Foundation

// MARK: - AudioSearchHistoryViewModel

class AudioSearchHistoryViewModel {
    // MARK: Lifecycle

    init() {
//        mockData()
        uploadData()
    }

//    private func mockData() {
//        var tracks = UserDefaults.mainPlaylist
//        if tracks.count > 5 {
//            // 昨天
//            tracks[1].searchDate = Date(timeIntervalSince1970: 1683257462)
//            // 週四
//            tracks[2].searchDate = Date(timeIntervalSince1970: 1683129600)
//            // 2/6
//            tracks[3].searchDate = Date(timeIntervalSince1970: 1675612800)
//            // 2022/2/17
//            tracks[4].searchDate = Date(timeIntervalSince1970: 1645068779)
//        }
//        self.tracks = tracks
//    }

    // MARK: Internal

    /// 依照日期分組
    private(set) var trackDayGroups: [TrackGroupByDate] = []

    @Published var state: ViewState = .none

    private(set) var selectedTrack: Track?

    var totalCount: Int {
        tracks.count
    }

    var tracks: [Track] {
        get { UserDefaults.shazamSearchRecords }
        set { UserDefaults.shazamSearchRecords = newValue
            uploadData()
        }
    }

    /// 取得以天分組的資料
    func trackDayGroup(forHeaderAt section: Int) -> TrackGroupByDate? {
        guard section < trackDayGroups.count else { return nil }
        return trackDayGroups[section]
    }

    /// 取得一天內某筆歌曲
    func track(forCellAt indexPath: IndexPath) -> Track? {
        guard let trackDayGroup = trackDayGroup(forHeaderAt: indexPath.section) else {
            return nil
        }
        guard indexPath.row < trackDayGroup.value.count else { return nil }
        return trackDayGroup.value[indexPath.row]
    }

    /// 移除選取的歌曲
    func removeTrack(forCellAt indexPath: IndexPath) {
        if let track = track(forCellAt: indexPath) {
            tracks.removeAll { $0.id == track.id }
        }
    }

    /// 設定選取的歌曲
    func setSelectedTrack(forCellAt indexPath: IndexPath) {
        if let track = track(forCellAt: indexPath) {
            selectedTrack = track
        }
    }

    private func uploadData() {
        state = .loading
        let sortedTracks = tracks.sorted { $0.searchDate > $1.searchDate }
        trackDayGroups = sortedTracks.groupByDay().sortedByDate(isDesc: true)
        state = .success
    }
}

typealias TrackGroupByDate = Dictionary<Date, [Track]>.Element

extension Array where Element == Track {
    /// 按照相同日期分組
    func groupByDay() -> [Date: [Track]] {
        return Dictionary(grouping: self) { Calendar.current.startOfDay(for: $0.searchDate) }
    }
}

extension Dictionary where Key == Date, Value == [Track] {
    /// 將按照時間分組的 Track 透過時間排序
    /// - Parameters:
    ///   - isDesc: 是否按照倒序排列
    /// - Returns: 依時間排序的 Track 分組
    func sortedByDate(isDesc: Bool) -> [Dictionary<Date, [Track]>.Element] {
        return sorted {
            if isDesc {
                return $0.key > $1.key
            } else {
                return $0.key < $1.key
            }
        }
    }
}
