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
    
    fileprivate let videoCollectionView: UICollectionView
    
    fileprivate let VIDEO_CELL_IDENTIFIER = "pdpVideoCollectionViewCell"
    
    init(videoCollectionView: UICollectionView, videos: [DetailProductVideo]) {
        self.videoCollectionView = videoCollectionView
        self.videos = videos
        super.init()
        self.videoCollectionView.delegate = self
        self.videoCollectionView.dataSource = self
        let cellNib = UINib(nibName: "DetailProductVideoCollectionViewCell", bundle: nil)
        self.videoCollectionView.register(cellNib, forCellWithReuseIdentifier: VIDEO_CELL_IDENTIFIER)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 68)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VIDEO_CELL_IDENTIFIER, for: indexPath) as! DetailProductVideoCollectionViewCell
        cell.video = self.videos[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! DetailProductVideoCollectionViewCell
        cell.playVideo()
    }
    
}
