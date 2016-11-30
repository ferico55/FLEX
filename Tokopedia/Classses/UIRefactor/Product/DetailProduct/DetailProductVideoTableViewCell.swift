//
//  DetailProductVideoTableViewCell.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 10/28/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class DetailProductVideoTableViewCell: UITableViewCell {

    @IBOutlet private var videoCollectionView: UICollectionView!
    
    private var detailProductVideoCollectionDataSource: DetailProductVideoCollectionDataSource?
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
