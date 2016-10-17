//
//  PulsaKeyboardManager.swift
//  Tokopedia
//
//  Created by Tonito Acen on 8/8/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

class PulsaKeyboardManager: NSObject {
    var homePageScrollView: UIScrollView?
    
    override init() {
        super.init()
    }
    
    func beginObservingKeyboard() {
        NSNotificationCenter .defaultCenter().addObserver(self, selector: #selector(didHideKeyboard), name: UIKeyboardDidHideNotification, object: nil)
        NSNotificationCenter .defaultCenter().addObserver(self, selector: #selector(didShowKeyboard), name: UIKeyboardDidShowNotification, object: nil)
    }
    
    func endObservingKeyboard() {
        NSNotificationCenter .defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter .defaultCenter().removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
    }
    
    func didHideKeyboard() {
        if let homePageScrollView = homePageScrollView {
            homePageScrollView.contentInset = UIEdgeInsetsZero
            homePageScrollView.scrollIndicatorInsets = UIEdgeInsetsZero
        }
    }
    
    func didShowKeyboard() {
//        let attributes = self.collectionView.layoutAttributesForSupplementaryElementOfKind(UICollectionElementKindSectionHeader, atIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        if let homePageScrollView = homePageScrollView {
            let edgeInsets = UIEdgeInsetsMake(0, 0, 194, 0)
            homePageScrollView.contentInset = edgeInsets
            homePageScrollView.scrollIndicatorInsets = edgeInsets
            homePageScrollView.setContentOffset(CGPointMake(0, 194), animated: true)
        }
    }
}
