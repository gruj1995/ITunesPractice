//
//  SearchViewModel.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/2/19.
//

import Foundation

class SearchViewModel {

    private let limit: Int = 10

    @Published var tracks: [Track] = []

    var dataCount: Int {
        tracks.count
    }

    func search(text: String?) {
        guard let text = text,
              !text.isEmpty else {
            tracks = []
            return
        }

        let request = ITunesService.SearchRequest(term: text, limit: limit, offset: 0)
        request.fetchTracks { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let trackList):
                self.tracks = trackList.results
            case .failure(let error):
                Logger.log(error.localizedDescription)
            }
        }
    }
}

// func search(){
//
//    //        request.send { (albums, response, error) in
//    //            if let error = error {
//    //                completion(.failure(error))
//    //            }
//    //            print("_+++ albums \(albums)")
//    //            completion(.success(true))
//    //        }
//    //
//    //        ApiSendHelper(request).send { result in
//    //            print("_+++ result \(result)")
//    //            switch result {
//    //            case .success:
//    //                let json = JSON(result)
//    //                print("_+++ \(result)")
//    //                completion(.success(true))
//    //            case .failure(let error):
//    //                completion(.failure(error))
//    //            }
//    //        }
// }
