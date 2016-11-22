//
//  DetailProductVideoCollectionViewCell.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 10/28/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class DetailProductVideoCollectionViewCell: UICollectionViewCell {

    @IBOutlet var youtubePlayerView: YTPlayerView!
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
