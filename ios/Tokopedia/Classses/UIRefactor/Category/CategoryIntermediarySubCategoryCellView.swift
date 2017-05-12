//
//  CategoryIntermediarySubCategoryCellView.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 3/2/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class CategoryIntermediarySubCategoryCellView: UIView {

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var categoryNameLabel: UILabel!
    
    func setData(data: CategoryIntermediaryChild) {
        let urlThumbnail: URL? = URL(string: data.thumbnailImage)
        if let urlThumbnail = urlThumbnail {
            self.imageView.setImageWith(urlThumbnail)
        }
        self.categoryNameLabel.text = data.name.uppercased()
        self.bk_(whenTapped: {
            
            AnalyticsManager.trackEventName("clickIntermediary", category: GA_EVENT_INTERMEDIARY_PAGE, action: GA_EVENT_ACTION_CATEGORY, label: data.id)
            let navigateViewController = NavigateViewController()
            navigateViewController.navigateToIntermediaryCategory(from: UIApplication.topViewController(), withCategoryId: data.id, categoryName: data.name, isIntermediary: false)
        })
        
        // if phone size is below than 4" (iphone 5s, 5, 4s, SE)
        if (UIScreen.main.applicationFrame.size.height <= 568) {
            categoryNameLabel.font = UIFont.systemFont(ofSize: 10.0)
        }
    }

}
