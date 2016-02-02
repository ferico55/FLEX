//
//  ProductDataSource.swift
//  Tokopedia
//
//  Created by Tonito Acen on 2/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation
import UIKit

@objc class ProductDataSource : NSObject, UICollectionViewDataSource {
    static let productCellIdentifier: String = "ProductCellIdentifier"
    
    var _collectionView: UICollectionView!
    var _products: Array<ProductFeedList>!
//
    init(collectionView:UICollectionView) {
        super.init()
        _products = Array<ProductFeedList>()
        _collectionView = collectionView
        _collectionView.dataSource = self
        
        let cellNib = UINib.init(nibName: "ProductCell", bundle: nil)
        _collectionView.registerNib(cellNib, forCellWithReuseIdentifier: ProductDataSource.productCellIdentifier)
        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _products.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ProductDataSource.productCellIdentifier, forIndexPath: indexPath) as! ProductCell
        
        let product = _products[indexPath.row]
        cell.setViewModel(product.viewModel)
        return cell
    }
    
    func addProducts(products:Array<ProductFeedList>) {
        _products.appendContentsOf(products)
        _collectionView.reloadData()
    }

}

/*
_dataSource = [ProductDataSource alloc] init]

[_dataSource addObjects:products]






_collectionView.dataSource = [ProductDataSource alloc] initWithData:products atCollectionView:collectionView
*/