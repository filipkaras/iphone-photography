//
//  DataManager.swift
//  Photography
//
//  Created by Filip Karas on 12/01/2023.
//

import Foundation

protocol DownloadDelegate: AnyObject {
    
    func downloadProgressUpdated(for progress: Double)
    func downloadFromUrlString(_ urlString: String)
}

final class Download {
  
    weak var delegate: DownloadDelegate?
    var url: URL
    var downloadTask: URLSessionDownloadTask?
    
    init(url: URL) {
        self.url = url
    }
    
    var progress: Double = 0.0 {
        didSet {
            updateProgress()
            if progress == 1 {
                downloadTask = nil
            }
        }
    }
    
    private func updateProgress() {
        if downloadTask != nil {
            delegate?.downloadProgressUpdated(for: progress)
        }
    }
}

class DataModel: NSObject, ObservableObject {
    
    @Published var progress: Double = 0
    @Published var data: Data?
    var activeDownload: Download?
    var activeUrlString: String?
    
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
}

extension DataModel: DownloadDelegate {
    
    func downloadProgressUpdated(for progress: Double) {
        DispatchQueue.main.async {
            self.progress = progress
        }
    }
    
    func downloadFromUrlString(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        self.activeDownload = Download(url: url)
        self.activeUrlString = urlString
        guard let activeDownload = self.activeDownload else { return }
        activeDownload.delegate = self
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
            }
        }
    }
  
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        if let download = activeDownload {
            download.progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
            print(download.progress)
        }
    }
  
    var downloadsSession: URLSession {
        get {
            let config = URLSessionConfiguration.background(withIdentifier: "background")
            let queue = OperationQueue()
            return URLSession(configuration: config, delegate: self, delegateQueue: queue)
        }
    }
}
