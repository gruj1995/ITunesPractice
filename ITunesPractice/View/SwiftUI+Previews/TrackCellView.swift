//
//  TrackCellView.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/7.
//

import SwiftUI

// MARK: - TrackCellView

struct TrackCellView: UIViewRepresentable {
    typealias UIViewType = TrackCell

    func makeUIView(context: Context) -> TrackCell {
        let cell = TrackCell(frame: .zero)
        cell.configure(artworkUrl: "https://is3-ssl.mzstatic.com/image/thumb/Music124/v4/e3/87/01/e3870192-6159-7638-16eb-4d5f3ce0b0d6/mzi.khdqfrzm.jpg/100x100bb.jpg", collectionName: "#1 Club Hits 2010 - Best of Dance & Techno", artistName: "D, J & Charles Simmons", trackName: "Show No Mercy")
        return cell
    }

    func updateUIView(_ uiView: TrackCell, context: Context) {}
}

// MARK: - TrackCellView_Previews

struct TrackCellView_Previews: PreviewProvider {
    static var previews: some View {
        TrackCellView()
            .previewLayout(.fixed(width: Constants.screenWidth, height: 60))
    }
}
