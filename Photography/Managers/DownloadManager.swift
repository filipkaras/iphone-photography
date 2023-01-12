//
//  DownloadManager.swift
//  Photography
//
//  Created by Filip Karas on 12/01/2023.
//

import Foundation

protocol DownloadManagerDelegate: AnyObject {
    
    func downloadProgressUpdated(for progress: Float)
    func downloadFinished()
}

class DownloadManager: NSObject, ObservableObject {

    // basic download manager to download large files from internet using URLSession
    // after download, we are saving the file to the local document directory
    
    var data: Data?
    var downloadTask: URLSessionDownloadTask?
    var activeUrlString: String?
    weak var delegate: DownloadManagerDelegate?
    
    func fileNameForUrlString(_ urlString: String) -> String? {
        guard let url = URL(string: urlString) else { return nil }
        return url.lastPathComponent
    }
    
    func localFileUrlForUrlString(_ urlString: String) -> URL? {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last,
              let fileName = fileNameForUrlString(urlString) else { return nil }
        return directory.appendingPathComponent(fileName)
    }
    
    func localFileExistsForUrlString(_ urlString: String) -> Bool {
        guard let fileUrl = self.localFileUrlForUrlString(urlString) else { return false }
        return FileManager.default.fileExists(atPath: fileUrl.path)
    }
    
    func downloadFromUrlString(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLCache.shared.removeCachedResponse(for: URLRequest(url: url))
        activeUrlString = urlString
        downloadTask = downloadsSession.downloadTask(with: url)
        downloadTask?.resume()
    }
    
    func stopDownload() {
        downloadTask?.cancel()
        downloadTask = nil
        downloadsSession.invalidateAndCancel()
    }
    
    func saveDataToFile() {
        guard
            let urlString = self.activeUrlString,
            let fileUrl = self.localFileUrlForUrlString(urlString),
            let data = self.data else { return }
        
        if !localFileExistsForUrlString(urlString) {
            do {
                try data.write(to: fileUrl, options: .atomic)
            } catch {
                print("Unable to save data to file.")
            }
        }
    }
}

extension DownloadManager: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        if let data = try? Data(contentsOf: location) {
            DispatchQueue.main.async { [weak self] in
                self?.data = data
                self?.saveDataToFile()
                self?.downloadTask = nil
                self?.downloadsSession.invalidateAndCancel()
                self?.delegate?.downloadFinished()
            }
        }
    }
  
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        self.delegate?.downloadProgressUpdated(for: Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
    }
  
    var downloadsSession: URLSession {
        get {
            let config = URLSessionConfiguration.background(withIdentifier: "background")
            let queue = OperationQueue()
            return URLSession(configuration: config, delegate: self, delegateQueue: queue)
        }
    }
}
