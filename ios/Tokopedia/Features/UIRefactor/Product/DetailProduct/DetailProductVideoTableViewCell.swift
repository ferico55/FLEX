//
//  DetailProductVideoTableViewCell.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 10/28/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class DetailProductVideoTableViewCell: UITableViewCell {

    @IBOutlet fileprivate var videoCollectionView: UICollectionView!
    
    fileprivate var detailProductVideoCollectionDataSource: DetailProductVideoCollectionDataSource?
    var videos: [DetailProductVideo]! {
        didSet{
            detailProductVideoCollectionDataSource = DetailProductVideoCollectionDataSource(videoCollectionView: videoCollectionView, videos: videos)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
