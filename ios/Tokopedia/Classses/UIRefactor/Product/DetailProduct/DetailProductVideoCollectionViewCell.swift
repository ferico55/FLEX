//
//  DetailProductVideoCollectionViewCell.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 10/28/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class DetailProductVideoCollectionViewCell: UICollectionViewCell, YTPlayerViewDelegate{

    @IBOutlet fileprivate var youtubePlayerView: YTPlayerView!
    @IBOutlet fileprivate var thumbnailImageView: UIImageView!
    @IBOutlet fileprivate var activityIndicator: UIActivityIndicatorView!
    @IBOutlet fileprivate var thumbnailContainerView: UIView!
    var playerVars = [
        "origin" : "https://www.tokopedia.com"
    ]
    
    var video: DetailProductVideo! {
        didSet {
            self.youtubePlayerView.load(withVideoId: video.url, playerVars: playerVars)
            self.youtubePlayerView.webView?.allowsInlineMediaPlayback = false
            self.youtubePlayerView.delegate = self
            self.thumbnailImageView.isHidden = true
            self.thumbnailImageView.setImageWith(URL(string: "https://img.youtube.com/vi/\(video.url)/0.jpg"))
            
            if UI_USER_INTERFACE_IDIOM() == .pad {
                switch UIDevice.current.systemVersion.compare("10.0.0", options: NSString.CompareOptions.numeric) {
                // jika di bawah iOS 10.0.0, karena untuk iPad dengan OS di bawah 10 tidak dapat memutar video Youtube secara full screen ketika pertama kali di-play
                case .orderedAscending:
                    self.thumbnailContainerView.isHidden = true
                    self.youtubePlayerView.isHidden = false
                default:
                    break
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func playVideo(){
        self.youtubePlayerView.playVideo()
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        self.thumbnailImageView.isHidden = false
        self.activityIndicator.stopAnimating()
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        switch state {
        case .paused, .ended:
            self.activityIndicator.stopAnimating()
        case .buffering:
            self.activityIndicator.startAnimating()
        default:
            break
        }
    }

}
