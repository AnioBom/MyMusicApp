//
//  PlaybackManager.swift
//  MyMusicApp
//
//  Created by Andrey on 19.06.2023.
//

import Foundation
import UIKit
import AVFoundation

protocol PlayerDataSource {
    var songName: String? { get }
    var subtitle: String? { get }
    var imageURL: URL? { get }
}

class PlaybackManager {
    
    var isPlaying: Bool = false
    
    static let shared  = PlaybackManager()
    
    var track: SpotifySimplifiedTrack?
    private var tracks = [SpotifySimplifiedTrack]()
    
    var currentTrack: SpotifySimplifiedTrack? {
        if let track = track, tracks.isEmpty {
            return track
        } else if !tracks.isEmpty {
            return tracks.first
        }
        
        return nil
    }
    
    var player: AVPlayer?
    var playerViewController = PlayViewController()
    
    /// For single track
    func startPlayback(
        from viewController: UIViewController,
        track: SpotifySimplifiedTrack
    ) {
        playerViewController.modalPresentationStyle = .fullScreen
        isPlaying = true
        
        guard let url = URL(string: track.preview_url ?? "") else {
            let alertController = UIAlertController(title: "Ooops",
                                                    message: "Track without preview. We're working on it.",
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
            viewController.present(alertController, animated: true)
            return
        }
        player = AVPlayer(url: url)
        player?.volume = 0.5
        
        // Calculate and set Track's duration
        let playerItem: AVPlayerItem = AVPlayerItem(url: url)
        let duration : CMTime = playerItem.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        playerViewController.songEndLabel.text = self.stringFromTimeInterval(interval: seconds)
        
        // Set up slider maximum value
        playerViewController.songTimeSlider.maximumValue = Float(seconds)
        playerViewController.songTimeSlider.isContinuous = true
        
        // Calculate and set current time
        let currentDuration : CMTime = playerItem.currentTime()
        let currentSeconds : Float64 = CMTimeGetSeconds(currentDuration)
        playerViewController.songStartLabel.text = self.stringFromTimeInterval(interval: currentSeconds)
        
        //Configure labels
        playerViewController.songNameLabel.text = track.name
        playerViewController.groupNameLabel.text = track.artists.first?.name
        let image = track.album?.images?.first ?? SpotifyImage(url: nil, height: nil, width: nil)
        playerViewController.setupImage(imageAlbum: image)
           
        // Add observer for update slider in realtime
        player!.addPeriodicTimeObserver(
            forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1),
            queue: DispatchQueue.main
        ) { (CMTime) -> Void in
            if self.player!.currentItem?.status == .readyToPlay {
                let time : Float64 = CMTimeGetSeconds(self.player!.currentTime());
                self.playerViewController.songTimeSlider.value = Float ( time );
                self.playerViewController.songStartLabel.text = self.stringFromTimeInterval(interval: time)
            }
        }
        
        self.track = track
        self.tracks = []
        
        viewController.present(playerViewController, animated: true) { [weak self] in
            self?.player?.play()
            self?.playerViewController.isPlay = true
        }
    }
    
    /// For playlist
    func startPlayback(
        from viewController: UIViewController,
        tracks: [SpotifySimplifiedTrack]
    ) {
        self.tracks = tracks
        self.track = nil
        playerViewController.modalPresentationStyle = .fullScreen
        viewController.present(playerViewController, animated: true)
    }
    
    func playPausePlayback() {
        if let player = player {
            if player.timeControlStatus == .playing {
                player.pause()
            } else if player.timeControlStatus == .paused {
                player.play()
            }
        }
    }
    
    func forwardPlayback() {
        if let _ = player {
            if tracks.isEmpty {
//                player.pause()
            } else {
                // Next track in playlist
            }
        }
    }
    
    func backwardPlayback() {
        if let player = player {
            if tracks.isEmpty {
                player.pause()
                player.seek(to: .zero)
                player.play()
            } else {
                // Pervious track in playlist
            }
        }
    }
    
    func seekTrack(to time: Int64) {
        let seconds : Int64 = time
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        player!.seek(to: targetTime)
        if player!.rate == 0 {
//            player?.play()
        }
    }
    func saveCurrentTrack() {
        StorageManager.shared.save(track: track! )
    }
    func deleteCurrentTrack() {
        StorageManager.shared.deleteItem(by: track!.id)
    }
    func hasCurrentTrackInStorange() -> Bool {
        StorageManager.shared.hasObjectInStorage(with: track!.id)
    }
    
    func downloadTrack() {
        if let currentItem = player?.currentItem, let asset = currentItem.asset as? AVURLAsset {
            let url = asset.url
            checkBookFileExists(withLink: url){ [weak self] downloadedURL in
                guard let self = self else{
                    return
                }
                // Save url in Realm
                StorageManager.shared.save(track: self.track!)
                StorageManager.shared.updateitem(with: self.track!.id, value: downloadedURL.absoluteString)
            }
        }
    }
}

//MARK: - Helper functions
extension PlaybackManager {
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func checkBookFileExists(withLink link: URL, completion: @escaping ((_ filePath: URL)->Void)){
        let fileManager = FileManager.default
        if let documentDirectory = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create: false){
            
            let filePath = documentDirectory.appendingPathComponent(link.lastPathComponent + ".mp3", isDirectory: false)
            
            do {
                if try filePath.checkResourceIsReachable() {
                    print("file exist")
                    completion(filePath)
                    
                } else {
                    print("file doesnt exist")
                    downloadFile(withUrl: link, andFilePath: filePath, completion: completion)
                }
            } catch {
                print("file doesnt exist")
                downloadFile(withUrl: link, andFilePath: filePath, completion: completion)
            }
        }else{
            print("file doesnt exist")
        }
    }
    
    func downloadFile(withUrl url: URL, andFilePath filePath: URL, completion: @escaping ((_ filePath: URL)->Void)){
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try Data.init(contentsOf: url)
                try data.write(to: filePath, options: .atomic)
                print("saved at \(filePath.absoluteString)")
                DispatchQueue.main.async {
                    completion(filePath)
                }
            } catch {
                print("an error happened while downloading or saving the file")
            }
        }
    }
}

extension PlaybackManager: PlayerDataSource {
    var songName: String? {
        return currentTrack?.name
    }

    var subtitle: String? {
        return currentTrack?.artists.first?.name
    }

    var imageURL: URL? {
        return URL(string: currentTrack?.album?.images?.first?.url ?? "")
    }
}
