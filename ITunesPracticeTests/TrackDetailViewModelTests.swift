//
//  TrackDetailViewModelTests.swift
//  ITunesPracticeTests
//
//  Created by 李品毅 on 2023/3/11.
//

import XCTest
import Combine
@testable import ITunesPractice

class TrackDetailViewModelTests: XCTestCase {

    var viewModel: TrackDetailViewModel!
    var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        viewModel = TrackDetailViewModel(trackId: 123)
    }

    override func tearDown() {
        viewModel = nil
        cancellables = []
        super.tearDown()
    }

    func testTrackDetailViewModel_lookupSuccess() {
        // Given
        let expectedTrack = Track(artistName: "Test Artist", trackName: "Test Track", previewUrl: "https://test.preview.url")
        let service = MockITunesService(result: .success(expectedTrack))
        viewModel.lookupService = service

        // When
        viewModel.lookup(trackId: 123)

        // Then
        XCTAssertEqual(viewModel.track, expectedTrack)
    }

    func testTrackDetailViewModel_lookupFailure() {
        // Given
        let expectedError = ITunesServiceError.invalidResponse
        let service = MockITunesService(result: .failure(expectedError))
        viewModel.lookupService = service

        // When
        viewModel.lookup(trackId: 123)

        // Then
        XCTAssertNil(viewModel.track)
    }

    func testTrackDetailViewModel_urlString_artist() {
        // Given
        let expectedUrlString = "https://test.artist.url"
        viewModel.track = Track(artistViewUrl: expectedUrlString)
        viewModel.selectedPreviewType = .artist

        // When
        let urlString = viewModel.urlString

        // Then
        XCTAssertEqual(urlString, expectedUrlString)
    }

    func testTrackDetailViewModel_urlString_album() {
        // Given
        let expectedUrlString = "https://test.album.url"
        viewModel.track = Track(collectionViewUrl: expectedUrlString)
        viewModel.selectedPreviewType = .album

        // When
        let urlString = viewModel.urlString

        // Then
        XCTAssertEqual(urlString, expectedUrlString)
    }

    func testTrackDetailViewModel_urlString_track() {
        // Given
        let expectedUrlString = "https://test.preview.url"
        viewModel.track = Track(previewUrl: expectedUrlString)
        viewModel.selectedPreviewType = .track

        // When
        let urlString = viewModel.urlString

        // Then
        XCTAssertEqual(urlString, expectedUrlString)
    }

}

class MockITunesService: ITunesServiceProtocol {

    let result: Result<Track, ITunesServiceError>

    init(result: Result<Track, ITunesServiceError>) {
        self.result = result
    }

    func lookup(trackId: Int) -> AnyPublisher<Track, ITunesServiceError> {
        return result.publisher.eraseToAnyPublisher()
    }

}
