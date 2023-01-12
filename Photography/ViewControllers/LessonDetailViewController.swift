//
//  LessonDetailView.swift
//  Photography
//
//  Created by Filip Karas on 12/01/2023.
//

import UIKit
import SDWebImage
import AVKit

class LessonDetailViewController: UIViewController, DownloadDelegate {
    
    var lesson: LessonModel!
    var lessons: [LessonModel] = []
    var dataModel: DataModel!
    var player: AVPlayer?
    var playerVC = AVPlayerViewController()
    var downloadButton = UIBarButtonItem()
    
    var nextLessonAvailable: Bool {
        guard let index = lessons.firstIndex(where: { $0.id == lesson.id }) else { return false }
        return index < lessons.count - 1
    }
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nextLessonButton: UIButton!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var downloadView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playButton.imageView?.layer.transform = CATransform3DMakeScale(2, 2, 2)
        
        let downloadImage = UIImage(systemName: "icloud.and.arrow.down")!
        let rightButton = UIButton(type: UIButton.ButtonType.custom)
        rightButton.setImage(downloadImage, for: .normal)
        rightButton.setTitle(" Download", for: .normal)
        rightButton.setTitleColor(UIColor.systemBlue, for: .normal)
        rightButton.frame.size = CGSize(width: 100, height: 30)
        rightButton.addTarget(self, action: #selector(self.download), for: .touchUpInside)
        downloadButton = UIBarButtonItem(customView: rightButton)
        
        dataModel.delegate = self
        
        updateUI()
        
        AppDelegate.orientationLock = UIInterfaceOrientationMask.all
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stop()
        dataModel.stopDownload()
        
        AppDelegate.orientationLock = UIInterfaceOrientationMask.portrait
    }
    
    @objc func download() {
        progressView.progress = 0
        dataModel.downloadFromUrlString(lesson.video_url)
        updateUI()
    }
    
    @IBAction func cancelDownload() {
        dataModel.stopDownload()
        updateUI()
    }
    
    func downloadProgressUpdated(for progress: Float) {
        DispatchQueue.main.async {
            self.progressView.progress = progress
        }
    }
    
    func downloadFinished() {
        self.updateUI()
    }
    
    func updateUI() {
        thumbnailImageView.sd_setImage(with: URL(string: lesson.thumbnail))
        nameLabel.text = lesson.name
        descriptionLabel.text = lesson.description
        nextLessonButton.isHidden = !nextLessonAvailable
        
        downloadView.isHidden = dataModel.activeDownload == nil
        
        if dataModel.activeDownload == nil && !dataModel.localFileExistsForUrlString(lesson.video_url) {
            DispatchQueue.main.async {
                self.navigationController?.navigationBar.topItem?.rightBarButtonItems = [self.downloadButton]
            }
        } else {
            DispatchQueue.main.async {
                self.navigationController?.navigationBar.topItem?.rightBarButtonItems = []
            }
        }
    }
    
    @IBAction func play() {
        if dataModel.localFileExistsForUrlString(lesson.video_url) {
            player = AVPlayer(url: dataModel.localFileUrlForUrlString(lesson.video_url)!)
        } else {
            player = AVPlayer(url: URL(string: lesson.video_url)!)
        }
        videoView.isHidden = false
        playerVC.player = player!
        playerVC.view.frame = videoView.frame
        videoView.addSubview(playerVC.view)
        player?.play()
    }
    
    func stop() {
        videoView.isHidden = true
        player?.pause()
        player = nil
    }
    
    @IBAction func switchToNextLesson() {
        if !nextLessonAvailable { return }
        let index = lessons.firstIndex(where: { $0.id == lesson.id })!
        lesson = lessons[index + 1]
        updateUI()
        stop()
        dataModel.stopDownload()
        updateUI()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if UIDevice.current.orientation.isLandscape {
            playerVC.view.removeFromSuperview()
            playerVC.view.frame = parent!.view.frame
            parent!.view.addSubview(playerVC.view)
            navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            playerVC.view.removeFromSuperview()
            playerVC.view.frame = videoView.frame
            videoView.addSubview(playerVC.view)
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
}
