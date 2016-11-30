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

    @IBOutlet var youtubePlayerView: YTPlayerView!
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var thumbnailContainerView: UIView!
    var playerVars = [
        "origin" : "https://www.tokopedia.com"
    ]
    
    var video: DetailProductVideo! {
        didSet {
            self.youtubePlayerView.loadWithVideoId(video.url, playerVars: playerVars)
            self.youtubePlayerView.webView?.allowsInlineMediaPlayback = false
            self.youtubePlayerView.delegate = self
            self.thumbnailImageView.setImageWithURL(NSURL(string: "https://img.youtube.com/vi/\(video.url)/0.jpg"))
        }
    }
    
    var playerViewDidBecomeReady: ((playerView: YTPlayerView) -> Void)?
    var playerViewDidChangeToState: ((playerView: YTPlayerView, didChangeToState: YTPlayerState) -> Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func playVideo(){
        self.youtubePlayerView.playVideo()
    }
    
    func playerViewDidBecomeReady(playerView: YTPlayerView) {
        playerViewDidBecomeReady?(playerView: playerView)
    }
    
    func playerView(playerView: YTPlayerView, didChangeToState state: YTPlayerState) {
        playerViewDidChangeToState?(playerView: playerView, didChangeToState: state)
    }

}
