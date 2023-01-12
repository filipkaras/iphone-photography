//
//  DataManager.swift
//  Photography
//
//  Created by Filip Karas on 12/01/2023.
//

import Foundation

protocol DownloadDelegate: AnyObject {
    
    func downloadProgressUpdated(for progress: Float)
    func downloadFinished()
}

final class Download {
  
    var url: URL
    var downloadTask: URLSessionDownloadTask?
    
    init(url: URL) {
        self.url = url
    }
}

class DataModel: NSObject, ObservableObject {
    
    @Published var data: Data?
    var activeDownload: Download?
    var activeUrlString: String?
    weak var delegate: DownloadDelegate?
    
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
        self.activeDownload = Download(url: url)
        self.activeUrlString = urlString
        guard let activeDownload = self.activeDownload else { return }
        activeDownload.downloadTask = downloadsSession.downloadTask(with: url)
        activeDownload.downloadTask?.resume()
    }
    
    func stopDownload() {
        guard let activeDownload = self.activeDownload else { return }
        activeDownload.downloadTask?.cancel()
        activeDownload.downloadTask = nil
        self.activeDownload = nil
        self.downloadsSession.invalidateAndCancel()
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

extension DataModel: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        if let data = try? Data(contentsOf: location) {
            DispatchQueue.main.async { [weak self] in
                self?.data = data
                self?.saveDataToFile()
                self?.activeDownload = nil
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
