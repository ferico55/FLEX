//
//  TKPDSearchBarViewController.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 4/18/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

extension UISearchController {
    
    func setSearchBarToTop(viewController: UIViewController, title: String) {
        
        delegate = self
        searchResultsUpdater = self
        searchBar.placeholder = "Cari Produk atau Toko"
        searchBar.tintColor = .black
        searchBar.barTintColor = UIColor(red: 66/255.0, green: 189/255.0, blue: 66/255.0, alpha: 1.0)
        searchBar.layer.borderColor = UIColor(red: 66/255.0, green: 189/255.0, blue: 66/255.0, alpha: 1.0).cgColor
        hidesNavigationBarDuringPresentation = false
        dimsBackgroundDuringPresentation = false
        searchBar.text = title
        searchBar.sizeToFit()
        let searchWrapper = UIView(frame: self.searchBar.bounds)
        searchWrapper.addSubview(self.searchBar)
        searchWrapper.backgroundColor = .clear
        searchBar.layer.borderWidth = 1
        searchBar.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(searchWrapper)
        }
        viewController.navigationItem.titleView = searchWrapper
    }
}

extension UISearchController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        DispatchQueue.main.async {
            searchController.searchResultsController?.view.isHidden = false
        }
    }
}

extension UISearchController: UISearchControllerDelegate {
    public func willPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {
            searchController.searchResultsController?.view.isHidden = false
        }
    }
    
    public func didPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {
            searchController.searchResultsController?.view.isHidden = false
        }
    }
}
