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

    @IBOutlet private var youtubePlayerView: YTPlayerView!
    @IBOutlet private var thumbnailImageView: UIImageView!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var thumbnailContainerView: UIView!
    var playerVars = [
        "origin" : "https://www.tokopedia.com"
    ]
    
    var video: DetailProductVideo! {
        didSet {
            self.youtubePlayerView.loadWithVideoId(video.url, playerVars: playerVars)
            self.youtubePlayerView.webView?.allowsInlineMediaPlayback = false
            self.youtubePlayerView.delegate = self
            self.thumbnailImageView.hidden = true
            self.thumbnailImageView.setImageWithURL(NSURL(string: "https://img.youtube.com/vi/\(video.url)/0.jpg"))
            
            if UI_USER_INTERFACE_IDIOM() == .Pad {
                switch UIDevice.currentDevice().systemVersion.compare("10.0.0", options: NSStringCompareOptions.NumericSearch) {
                // jika di bawah iOS 10.0.0, karena untuk iPad dengan OS di bawah 10 tidak dapat memutar video Youtube secara full screen ketika pertama kali di-play
                case .OrderedAscending:
                    self.thumbnailContainerView.hidden = true
                    self.youtubePlayerView.hidden = false
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
    
    func playerViewDidBecomeReady(playerView: YTPlayerView) {
        self.thumbnailImageView.hidden = false
        self.activityIndicator.stopAnimating()
    }
    
    func playerView(playerView: YTPlayerView, didChangeToState state: YTPlayerState) {
        switch state {
        case .Paused, .Ended:
            self.activityIndicator.stopAnimating()
        case .Buffering:
            self.activityIndicator.startAnimating()
        default:
            break
        }
    }

}
