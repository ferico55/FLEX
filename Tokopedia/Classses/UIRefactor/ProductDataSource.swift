//
//  ProductDataSource.swift
//  Tokopedia
//
//  Created by Tonito Acen on 2/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation
import UIKit

@objc protocol CollectionViewSupplementaryDataSource {
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView;
}

@objc class ProductDataSource : NSObject, UICollectionViewDataSource {
    static let productCellIdentifier: String = "ProductCellIdentifier"
    
    var _collectionView: UICollectionView!
    var _products: Array<SearchAWSProduct>!
    var _supplementaryDataSource: CollectionViewSupplementaryDataSource!

    init(collectionView:UICollectionView, supplementaryDataSource: CollectionViewSupplementaryDataSource?) {
        super.init()
        _supplementaryDataSource = supplementaryDataSource
        _products = Array<SearchAWSProduct>()
        _collectionView = collectionView
        _collectionView.dataSource = self
        
        let cellNib = UINib.init(nibName: "ProductCell", bundle: nil)
        _collectionView.registerNib(cellNib, forCellWithReuseIdentifier: ProductDataSource.productCellIdentifier)
        
        let footerNib = UINib.init(nibName: "FooterCollectionReusableView", bundle: nil)
        _collectionView.registerNib(footerNib, forCellWithReuseIdentifier: "FooterView")
        
        let retryNib = UINib.init(nibName: "RetryCollectionReusableView", bundle: nil)
        _collectionView.registerNib(retryNib, forCellWithReuseIdentifier: "RetryView")
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
    
    func addProducts(products:Array<SearchAWSProduct>) {
        let indexPaths = indexPathForInsertions(products)
        _products.appendContentsOf(products)
        //_collectionView.insertItemsAtIndexPaths(indexPaths)
        _collectionView.reloadData()
    }
    
    func indexPathForInsertions(products: Array<SearchAWSProduct>) -> [NSIndexPath] {
        var indexPaths:[NSIndexPath] = []
        
        for var index = 0; index < products.count; index++ {
            indexPaths.append(NSIndexPath(forItem: index + _products.count, inSection: 0))
        }
        
        return indexPaths
    }

    func replaceProductsWith(products:Array<SearchAWSProduct>) {
        _products = products
        _collectionView.reloadData()
    }
    
    func removeAllProducts() {
        _products.removeAll()
        _collectionView.reloadData()
    }
    
    func productAtIndex(index: Int) -> SearchAWSProduct {
        return _products[index]
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if _supplementaryDataSource != nil {
            return _supplementaryDataSource.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath)
        } else {
            return UICollectionReusableView()
        }
    }
    
    func sizeForItemAtIndexPath(indexPath: NSIndexPath) -> CGSize {
        let type = 1
        return ProductCellSize.sizeWithType(type)
    }
    
    func isProductFeedEmpty() -> Bool{
        return _products.isEmpty;
    }
}
