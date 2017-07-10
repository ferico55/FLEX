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
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: IndexPath) -> UICollectionReusableView;
}

@objc class ProductDataSource : NSObject, UICollectionViewDataSource {
    static let productCellIdentifier: String = "ProductCellIdentifier"
    
    var _collectionView: UICollectionView!
    var _products: Array<Array<SearchAWSProduct>>!
    var _supplementaryDataSource: CollectionViewSupplementaryDataSource!

    init(collectionView:UICollectionView, supplementaryDataSource: CollectionViewSupplementaryDataSource?) {
        super.init()
        _supplementaryDataSource = supplementaryDataSource
        _products = Array<Array<SearchAWSProduct>>()
        _collectionView = collectionView
        _collectionView.dataSource = self
        
        let cellNib = UINib(nibName: "ProductCell", bundle: nil)
        _collectionView.register(cellNib, forCellWithReuseIdentifier: ProductDataSource.productCellIdentifier)
        
        let footerNib = UINib(nibName: "FooterCollectionReusableView", bundle: nil)
        _collectionView.register(footerNib, forCellWithReuseIdentifier: "FooterView")
        
        let retryNib = UINib(nibName: "RetryCollectionReusableView", bundle: nil)
        _collectionView.register(retryNib, forCellWithReuseIdentifier: "RetryView")
        
        let promoNib = UINib(nibName: "PromoCollectionReusableView", bundle: nil)
        _collectionView.register(promoNib, forCellWithReuseIdentifier: "PromoCollectionReusableView")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return _products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _products[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellNib = UINib(nibName: "ProductCell", bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: ProductDataSource.productCellIdentifier)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductDataSource.productCellIdentifier, for: indexPath) as! ProductCell
        
        let product = _products[indexPath.section][indexPath.row]
        cell.viewModel = product.viewModel
        cell.removeWishlistButton()
        return cell
    }
    
    func addProducts(_ products:Array<SearchAWSProduct>) {
        _products.append(products)
        _collectionView.reloadData()
    }
    
    func indexPathForInsertions(_ products: Array<SearchAWSProduct>) -> [IndexPath] {
        var indexPaths:[IndexPath] = []

        for index in 0 ..< products.count {
            indexPaths.append(IndexPath(row: index + _products.count, section: 0))
        }
        
        return indexPaths
    }

    func replaceProductsWith(_ products:Array<SearchAWSProduct>) {
        _products.removeAll()
        _products.append(products)
        _collectionView.reloadData()
    }
    
    func removeAllProducts() {
        _products.removeAll()
        _collectionView.reloadData()
    }
    
    func productAtIndex(_ indexPath:NSIndexPath) -> SearchAWSProduct {
        return _products[indexPath.section][indexPath.row]
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if _supplementaryDataSource != nil {
            return _supplementaryDataSource.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath)
        } else {
            return UICollectionReusableView()
        }
    }
    
    func sizeForItemAtIndexPath(_ indexPath: IndexPath) -> CGSize {
        let type = 1
        return ProductCellSize.sizeWithType(type)
    }
    
    func isProductFeedEmpty() -> Bool{
        return _products.isEmpty;
    }
}
