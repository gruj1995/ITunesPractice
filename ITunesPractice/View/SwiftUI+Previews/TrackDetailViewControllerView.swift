//
//  TrackDetailViewControllerView.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/7.
//

import SwiftUI

// MARK: - TrackDetailViewControllerView

struct TrackDetailViewControllerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = TrackDetailViewController

    func makeUIViewController(context: Context) -> TrackDetailViewController {
        // 要檢視資料可以到 viewDidLoad() 中進行修改:
        // viewModel = TrackDetailViewModel(trackId: 353554373)
        TrackDetailViewController()
    }

    func updateUIViewController(_ uiViewController: TrackDetailViewController, context: Context) {}
}

// MARK: - TrackDetailViewControllerPreview

struct TrackDetailViewControllerPreview: PreviewProvider {
    static var previews: some View {
        TrackDetailViewControllerView()
    }
}
