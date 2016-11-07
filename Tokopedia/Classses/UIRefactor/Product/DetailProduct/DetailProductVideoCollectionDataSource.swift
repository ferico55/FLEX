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
class DetailProductVideoCollectionDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    var detailProductVideoDataArray: [DetailProductVideoArray]?
    
    var cellNib = UINib.init(nibName: "DetailProductVideoCollectionViewCell", bundle: nil)
    
    var didSelectItem: ((playerView: YTPlayerView) -> Void)?
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
        cell.youtubePlayerView.loadWithVideoId(videoId)
//        cell.youtubePlayerView.loadWithVideoId("M7lc1UVf-VE", playerVars: ["showinfo" : 0])
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("pdpVideoCollectionViewCell", forIndexPath: indexPath) as! DetailProductVideoCollectionViewCell
        if let didSelectItem = didSelectItem {
            didSelectItem(playerView: cell.youtubePlayerView)
        }
    }
    
    
    
}
