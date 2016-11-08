//
//  DetailProductVideoTableViewCell.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 10/28/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class DetailProductVideoTableViewCell: UITableViewCell {

    @IBOutlet var videoCollectionView: UICollectionView!
    
    var detailProductVideoCollectionDataSource: DetailProductVideoCollectionDataSource = DetailProductVideoCollectionDataSource()
    var detailProductVideoDataArray: [DetailProductVideoArray]? {
        didSet{
            detailProductVideoCollectionDataSource.detailProductVideoDataArray = detailProductVideoDataArray
            videoCollectionView.delegate = detailProductVideoCollectionDataSource
            videoCollectionView.dataSource = detailProductVideoCollectionDataSource
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
