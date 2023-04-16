//
//  AudioSearchViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/4/16.
//

import Combine
import Foundation

class AudioSearchViewModel {
    // MARK: Lifecycle

    init() {}

    // MARK: Internal

    var track: Track?

    // MARK: Private

    private var cancellables = Set<AnyCancellable>()

}
