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
class DetailProductVideoCollectionDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIWebViewDelegate{
    
    var videos: [DetailProductVideo]!
    
    private var activityIndicatorArray: [UIActivityIndicatorView]?
    
    private let videoCollectionView: UICollectionView
    
    private let VIDEO_CELL_IDENTIFIER = "pdpVideoCollectionViewCell"
    
    init(videoCollectionView: UICollectionView, videos: [DetailProductVideo]) {
        self.videoCollectionView = videoCollectionView
        super.init()
        self.videoCollectionView.delegate = self
        self.videoCollectionView.dataSource = self
        self.videos = videos
        let cellNib = UINib.init(nibName: "DetailProductVideoCollectionViewCell", bundle: nil)
        self.videoCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: VIDEO_CELL_IDENTIFIER)
        activityIndicatorArray = []
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return videos.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 120, height: 68)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(VIDEO_CELL_IDENTIFIER, forIndexPath: indexPath) as! DetailProductVideoCollectionViewCell
        cell.youtubePlayerView.tag = indexPath.item
        activityIndicatorArray?.append(cell.activityIndicator)

        cell.thumbnailImageView.hidden = true
        cell.video = self.videos[indexPath.row]
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
    
        cell.playerViewDidBecomeReady = { [unowned self] playerView in
            let indexPath = NSIndexPath(forItem: playerView.tag, inSection: 0)
            
            let cell = self.videoCollectionView.cellForItemAtIndexPath(indexPath) as! DetailProductVideoCollectionViewCell
            cell.thumbnailImageView.hidden = false
            self.activityIndicatorArray? [playerView.tag].stopAnimating()
        }
        cell.playerViewDidChangeToState = { [unowned self] playerView, state in
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
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! DetailProductVideoCollectionViewCell
        cell.playVideo()
    }
    
    
}
