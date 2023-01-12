//
//  PhotographyUITests.swift
//  PhotographyUITests
//
//  Created by Filip Karas on 11/01/2023.
//

import XCTest

final class PhotographyUITests: XCTestCase {

    let lessonName: String = "3 Secret iPhone Camera Features For Perfect Focus"
    
    func test_goToDetailAndBack() throws {
        
        let app = XCUIApplication()
        app.launch()

        let collectionViewsQuery = app.collectionViews
        let theKeyToSuccessInIphonePhotographyButton = collectionViewsQuery.buttons[lessonName]
        let exists = NSPredicate(format: "exists == 1")

        expectation(for: exists, evaluatedWith: theKeyToSuccessInIphonePhotographyButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        theKeyToSuccessInIphonePhotographyButton.tap()
        
        let backButton = app.buttons["Lessons"]
        backButton.tap()
        
        XCTAssertTrue(theKeyToSuccessInIphonePhotographyButton.exists)
    }
    
    func test_goToNextDetailFromDetailAndBack() throws {
        
        let app = XCUIApplication()
        app.launch()

        let collectionViewsQuery = app.collectionViews
        let theKeyToSuccessInIphonePhotographyButton = collectionViewsQuery.buttons[lessonName]
        let exists = NSPredicate(format: "exists == 1")

        expectation(for: exists, evaluatedWith: theKeyToSuccessInIphonePhotographyButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        theKeyToSuccessInIphonePhotographyButton.tap()
        
        let nextButton = app.buttons["Next Lesson "]
        nextButton.tap()
        
        let backButton = app.buttons["Lessons"]
        backButton.tap()
        
        XCTAssertTrue(theKeyToSuccessInIphonePhotographyButton.exists)
    }
    
    func test_downloadAndStopDownloadingVideo() {
                
        let app = XCUIApplication()
        app.launch()

        let collectionViewsQuery = app.collectionViews
        let theKeyToSuccessInIphonePhotographyButton = collectionViewsQuery.buttons[lessonName]
        let exists = NSPredicate(format: "exists == 1")

        expectation(for: exists, evaluatedWith: theKeyToSuccessInIphonePhotographyButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        theKeyToSuccessInIphonePhotographyButton.tap()
        
        let downloadButton = app.buttons[" Download"]
        downloadButton.tap()
        
        let cancelDownloadButton = app.buttons["Cancel download"]
        cancelDownloadButton.tap()
        
        XCTAssertTrue(downloadButton.exists)
    }
    
    func test_videoPlaybackAndStop() {
        
        let app = XCUIApplication()
        app.launch()

        let collectionViewsQuery = app.collectionViews
        let theKeyToSuccessInIphonePhotographyButton = collectionViewsQuery.buttons[lessonName]
        let exists = NSPredicate(format: "exists == 1")

        expectation(for: exists, evaluatedWith: theKeyToSuccessInIphonePhotographyButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        theKeyToSuccessInIphonePhotographyButton.tap()
        
        let playButton = app.buttons["play"]
        playButton.tap()
        
        sleep(10)
        
        let backButton = app.buttons["Lessons"]
        backButton.tap()
        
        XCTAssertTrue(theKeyToSuccessInIphonePhotographyButton.exists)
    }
}
