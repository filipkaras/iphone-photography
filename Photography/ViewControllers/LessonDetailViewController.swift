//
//  LessonDetailView.swift
//  Photography
//
//  Created by Filip Karas on 12/01/2023.
//

import UIKit
import SDWebImage
import AVKit

class LessonDetailViewController: UIViewController, DownloadManagerDelegate {
    
    var lesson: LessonModel!
    var lessons: [LessonModel] = []
    var downloadManager: DownloadManager!
    var player: AVPlayer?
    var playerVC = AVPlayerViewController()
    var downloadButton = UIBarButtonItem()
    var landscapeMode = false
    var videoPlaying = false
    
    var nextLessonAvailable: Bool {
        guard let index = lessons.firstIndex(where: { $0.id == lesson.id }) else { return false }
        return index < lessons.count - 1
    }
    
    var hideStatusBar: Bool = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
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
        
        // device orientation is locked to portrait mode, so we need to monitor device rotation
        // to react when device is rotated to landscape mode we need to play video in fullscreen mode
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        // detect, when video finished, if fullscreen landscape mode - switch to portrait and exit fullscreen
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        // make play button over video larger to match provided design
        playButton.imageView?.layer.transform = CATransform3DMakeScale(2, 2, 2)
        
        // create download button prototype, we will hide / show this button depending on download progress / file exists
        let downloadImage = UIImage(systemName: "icloud.and.arrow.down")!
        let rightButton = UIButton(type: UIButton.ButtonType.custom)
        rightButton.setImage(downloadImage, for: .normal)
        rightButton.setTitle(" Download", for: .normal)
        rightButton.setTitleColor(UIColor.systemBlue, for: .normal)
        rightButton.frame.size = CGSize(width: 100, height: 30)
        rightButton.addTarget(self, action: #selector(self.download), for: .touchUpInside)
        downloadButton = UIBarButtonItem(customView: rightButton)
        
        downloadManager.delegate = self
        
        updateUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // we will stop possible download process and playback process, when navigating back to the list
        stopVideoPlayback()
        downloadManager.stopDownload()
    }
    
    @objc func download() {
        // start downloading video - reset progress bar to avoid flashing from previous status and start download
        progressView.progress = 0
        downloadManager.downloadFromUrlString(lesson.video_url)
        
        // update UI to display progress, cancel button and hide download button
        updateUI()
    }
    
    @IBAction func cancelDownload() {
        // stop current downloading process
        downloadManager.stopDownload()
        
        // update UI to hide the progress, show download button
        updateUI()
    }
    
    func downloadProgressUpdated(for progress: Float) {
        // update progress bar while downloading video
        // do it on main queue
        DispatchQueue.main.async {
            self.progressView.progress = progress
        }
    }
    
    func downloadFinished() {
        // we need to update UI when download is finished - hide progress bar, cancel button and show video or thumb
        self.updateUI()
    }
    
    func updateUI() {
        // we are using SDWebImage to load thumb image from the web and cache it
        thumbnailImageView.sd_setImage(with: URL(string: lesson.thumbnail))
        
        // updating basic UI elements
        nameLabel.text = lesson.name
        descriptionLabel.text = lesson.description
        nextLessonButton.isHidden = !nextLessonAvailable
        downloadView.isHidden = downloadManager.downloadTask == nil
        
        // if we are not downloading and the video does not exists locally and we are not in fullscreen mode, show download button
        if downloadManager.downloadTask == nil && !downloadManager.localFileExistsForUrlString(lesson.video_url) && !landscapeMode {
            DispatchQueue.main.async {
                self.navigationController?.navigationBar.topItem?.rightBarButtonItems = [self.downloadButton]
            }
        } else {
            DispatchQueue.main.async {
                self.navigationController?.navigationBar.topItem?.rightBarButtonItems = []
            }
        }
    }
    
    @IBAction func startVideoPlayback() {
        // if the video is available locally, play it from ther, otherwise stream from web
        if downloadManager.localFileExistsForUrlString(lesson.video_url) {
            player = AVPlayer(url: downloadManager.localFileUrlForUrlString(lesson.video_url)!)
        } else {
            player = AVPlayer(url: URL(string: lesson.video_url)!)
        }
        
        // setup AVPlayerViewController and start playing
        videoView.isHidden = false
        playerVC.player = player!
        playerVC.view.frame = videoView.frame
        videoView.addSubview(playerVC.view)
        player?.play()
        videoPlaying = true
        
        // user can start playing video when in landscape mode, we need to cover this situation as well
        deviceRotated()
    }
    
    func stopVideoPlayback() {
        videoView.isHidden = true
        player?.pause()
        player = nil
        videoPlaying = false
    }
    
    @IBAction func switchToNextLesson() {
        if !nextLessonAvailable { return }
        // if we are downloading video, switching to next lesson will stop the process
        // we didn't implement download queue for demo purposes
        // but we want to be polite and ask user, if he/she want to stop the process, he might be almost done with downloading :)
        if downloadManager.downloadTask != nil {
            let alert = UIAlertController(title: "iPhone Photography", message: "You are currently downloading this video, jumping to the next one will cancel the download process. Do you want to proceed?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                self.nextLesson()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel))
            present(alert, animated: true)
        } else {
            // if there is no downloading process, just go to the next lesson
            nextLesson()
        }
    }
    
    func nextLesson() {
        // find index of the current lesson in the list, increase it by 1 and update UI
        let index = lessons.firstIndex(where: { $0.id == lesson.id })!
        lesson = lessons[index + 1]
        stopVideoPlayback()
        downloadManager.stopDownload()
        updateUI()
    }
    
    @objc func deviceRotated() {
        // I have chosen transform approach to show fullscreen video in landscape mode
        // we have videoView placeholder in the view hierarchy, where the AVPlayerViewController is located by default
        // if user rotate the phone to the landscape mode, we will detach the AVPlayerViewController from this view, attach it to the main view (fullscreen)
        // and rotate the player by 90 degrees
        if videoPlaying && UIDevice.current.orientation.isLandscape {
            playerVC.view.removeFromSuperview()
            playerVC.view.transform = CGAffineTransform(rotationAngle: UIDevice.current.orientation == .landscapeRight ? -.pi/2 : .pi/2)
            playerVC.view.frame = parent!.view.frame
            parent!.view.addSubview(playerVC.view)
            
            // we also need to hide all bars and buttons :)
            navigationController?.setNavigationBarHidden(true, animated: true)
            splitViewController?.presentsWithGesture = false
            landscapeMode = true
            hideStatusBar = true
            updateUI()
        }
        // when user rotate the phone back to portrait mode or the playback finish, just revert all changes to AVPlayerViewController
        else {
            playerVC.view.removeFromSuperview()
            playerVC.view.transform = .identity
            playerVC.view.frame = videoView.frame
            videoView.addSubview(playerVC.view)
            navigationController?.setNavigationBarHidden(false, animated: true)
            splitViewController?.presentsWithGesture = true
            landscapeMode = false
            hideStatusBar = false
            updateUI()
        }
    }
    
    @objc func playerDidFinishPlaying() {
        stopVideoPlayback()
        deviceRotated()
    }
    
    override var prefersStatusBarHidden: Bool {
        return hideStatusBar
    }
}
