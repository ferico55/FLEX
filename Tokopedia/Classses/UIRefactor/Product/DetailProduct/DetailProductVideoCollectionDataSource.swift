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
class DetailProductVideoCollectionDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, YTPlayerViewDelegate{
    
    var detailProductVideoDataArray: [DetailProductVideoArray]?
    
    private var activityIndicatorArray: [UIActivityIndicatorView]?
    
    private var cellNib = UINib.init(nibName: "DetailProductVideoCollectionViewCell", bundle: nil)
    
    override init(){
        super.init()
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
        collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "pdpVideoCollectionViewCell")
        activityIndicatorArray = []
        if let detailProductVideoDataArray = self.detailProductVideoDataArray {
            return detailProductVideoDataArray.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 120, height: 68)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
      
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("pdpVideoCollectionViewCell", forIndexPath: indexPath) as! DetailProductVideoCollectionViewCell
        let videoId = self.detailProductVideoDataArray![indexPath.row].url
        let playerVars = [
            "showinfo" : 0,
            "rel" : 0,
//            "modestbranding" : 1,
            "controls" : 1,
            "origin" : "https://www.tokopedia.com"
        ]
        cell.youtubePlayerView.tag = indexPath.row
        cell.youtubePlayerView.delegate = self
        activityIndicatorArray?.append(cell.activityIndicator)
        cell.youtubePlayerView.loadWithVideoId(videoId, playerVars: playerVars)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("pdpVideoCollectionViewCell", forIndexPath: indexPath) as! DetailProductVideoCollectionViewCell
        cell.youtubePlayerView.playVideo()
    }
    
    func playerViewDidBecomeReady(playerView: YTPlayerView) {
        activityIndicatorArray? [playerView.tag].stopAnimating()
    }
    
}
