//
//  DetailProductVideoCollectionDataSource.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 10/28/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import Foundation
import AVKit
import AVFoundation
import Masonry
import youtube_ios_player_helper

@objc(DetailProductVideoCollectionDataSource)
class DetailProductVideoCollectionDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, YTPlayerViewDelegate, UIWebViewDelegate{
    
    var detailProductVideoDataArray: [DetailProductVideoArray]?
    
    private var activityIndicatorArray: [UIActivityIndicatorView]?
    
    private var videoCollectionView: UICollectionView!
    
    private var cellNib = UINib.init(nibName: "DetailProductVideoCollectionViewCell", bundle: nil)
    
    private var VIDEO_CELL_IDENTIFIER = "pdpVideoCollectionViewCell"
    
    override init(){
        super.init()
    }
    
    init(videoCollectionView: UICollectionView, detailProductVideoDataArray: [DetailProductVideoArray]) {
        super.init()
        self.videoCollectionView = videoCollectionView
        self.videoCollectionView.delegate = self
        self.videoCollectionView.dataSource = self
        self.detailProductVideoDataArray = detailProductVideoDataArray
        self.videoCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: "pdpVideoCollectionViewCell")
        activityIndicatorArray = []
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if let detailProductVideoDataArray = self.detailProductVideoDataArray {
            if detailProductVideoDataArray.count > 0 {
                return 1
            }
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let detailProductVideoDataArray = self.detailProductVideoDataArray {
            return detailProductVideoDataArray.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 120, height: 68)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
      
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(VIDEO_CELL_IDENTIFIER, forIndexPath: indexPath) as! DetailProductVideoCollectionViewCell
        let videoId = self.detailProductVideoDataArray![indexPath.row].url
        let playerVars = [
            "origin" : "https://www.tokopedia.com"
        ]
        cell.youtubePlayerView.tag = indexPath.item
        cell.youtubePlayerView.delegate = self
        activityIndicatorArray?.append(cell.activityIndicator)
        cell.thumbnailImageView.setImageWithURL(NSURL(string: "https://img.youtube.com/vi/\(videoId)/0.jpg"))
        cell.thumbnailImageView.hidden = true
        cell.youtubePlayerView.loadWithVideoId(videoId, playerVars: playerVars)
        cell.youtubePlayerView.webView?.allowsInlineMediaPlayback = false
        
        if UI_USER_INTERFACE_IDIOM() == .Pad {
            switch UIDevice.currentDevice().systemVersion.compare("10.0.0", options: NSStringCompareOptions.NumericSearch) {
            // jika di bawah iOS 10.0.0, karena untuk iPad dengan OS di bawah 10 tidak dapat memutar video Youtube secara full screen ketika pertama kali di-play
            case .OrderedAscending:
                cell.thumbnailContainerView.hidden = true
                cell.youtubePlayerView.hidden = false
            default:
                break
            }
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! DetailProductVideoCollectionViewCell
        cell.youtubePlayerView.playVideo()
    }
    
    func playerViewDidBecomeReady(playerView: YTPlayerView) {
        let indexPath = NSIndexPath(forItem: playerView.tag, inSection: 0)
        
        let cell = self.videoCollectionView.cellForItemAtIndexPath(indexPath) as! DetailProductVideoCollectionViewCell
        cell.thumbnailImageView.hidden = false
        activityIndicatorArray? [playerView.tag].stopAnimating()
    }
    
    func playerView(playerView: YTPlayerView, didChangeToState state: YTPlayerState) {
        let indexPath = NSIndexPath(forItem: playerView.tag, inSection: 0)
        let cell = self.videoCollectionView.cellForItemAtIndexPath(indexPath) as! DetailProductVideoCollectionViewCell
        switch state {
        case .Paused, .Ended:
            cell.activityIndicator.stopAnimating()
        case .Buffering:
            cell.activityIndicator.startAnimating()
        default:
            break
        }
    }
}
