//
//  PhotographyTests.swift
//  PhotographyTests
//
//  Created by Filip Karas on 11/01/2023.
//

import XCTest
import Combine
@testable import Photography

final class PhotographyTests: XCTestCase, DataModelDelegate {
    
    var cancellables = Set<AnyCancellable>()
    let urlString = "https://embed-ssl.wistia.com/deliveries/cc8402e8c16cc8f36d3f63bd29eb82f99f4b5f88/accudvh5jy.mp4"
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_LessonListViewModel_getLessons_shouldReturnLiveItems() {
        // Given
        let vm = LessonListViewModel(url: URL(string: K.Api.Url)!)
        
        // When
        let expectation = XCTestExpectation(description: "Should return lessons from API")
        
        vm.$lessons
            .dropFirst()
            .sink { returnedLessons in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 10.0)
        XCTAssertGreaterThan(vm.lessons.count, 0)
    }
    
    func test_DownloadManager_fileNameForUrlString_shouldReturnSomething() {
        // Given
        let downloadManager = DownloadManager()
        
        // When
        let fileName = downloadManager.fileNameForUrlString(urlString)
        
        // Then
        XCTAssertNotNil(fileName)
    }
    
    func test_DownloadManager_localFileUrlForUrlString_shouldReturnSomething() {
        // Given
        let downloadManager = DownloadManager()
        
        // When
        let fileUrl = downloadManager.localFileUrlForUrlString(urlString)
        
        // Then
        XCTAssertNotNil(fileUrl)
    }
    
    private var downloadFileExpectation: XCTestExpectation!
    
    func test_DownloadManager_downloadFromUrlString_shouldDownloadVideo() {
        // Given
        let downloadManager = DownloadManager()
        downloadManager.delegate = self
        downloadFileExpectation = XCTestExpectation(description: "Video file should be downloaded")
        
        // When
        downloadManager.downloadFromUrlString(urlString)
        
        // Then
        wait(for: [downloadFileExpectation], timeout: 120.0)
        let fileUrl = downloadManager.localFileExistsForUrlString(urlString)
        XCTAssertNotNil(fileUrl)
    }
    
    func downloadProgressUpdated(for progress: Float) {
        print(progress)
    }
    
    func downloadFinished() {
        downloadFileExpectation.fulfill()
    }
}
