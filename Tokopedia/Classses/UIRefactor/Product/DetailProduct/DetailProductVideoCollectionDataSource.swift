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
    
    var videos: [DetailProductVideo]
    
    private let videoCollectionView: UICollectionView
    
    private let VIDEO_CELL_IDENTIFIER = "pdpVideoCollectionViewCell"
    
    init(videoCollectionView: UICollectionView, videos: [DetailProductVideo]) {
        self.videoCollectionView = videoCollectionView
        self.videos = videos
        super.init()
        self.videoCollectionView.delegate = self
        self.videoCollectionView.dataSource = self
        let cellNib = UINib(nibName: "DetailProductVideoCollectionViewCell", bundle: nil)
        self.videoCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: VIDEO_CELL_IDENTIFIER)
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
        cell.video = self.videos[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! DetailProductVideoCollectionViewCell
        cell.playVideo()
    }
    
    
}
