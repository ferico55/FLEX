//
//  CategoryIntermediarySubCategoryNoRevampView.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 3/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class CategoryIntermediarySubCategoryNoRevampView: UIView {

    @IBOutlet private var categoryNameLabel: UILabel!
    @IBOutlet private var arrowImageView: UIImageView!
    @IBOutlet private var horizontalSeparatorLeading: NSLayoutConstraint!
    @IBOutlet private var horizontalSeparatorTrailing: NSLayoutConstraint!
    @IBOutlet private var verticalSeparatorView: UIView!
    @IBOutlet private var upperHorizontalSeparatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        arrowImageView.tintColor = UIColor.tpPrimaryBlackText()
        // Initialization code
    }
    
    func setRightMode() {
        horizontalSeparatorTrailing.constant = 10
        horizontalSeparatorLeading.constant = 0
        verticalSeparatorView.isHidden = true
    }
    
    func setUnderlinedBottom() {
        horizontalSeparatorTrailing.constant = 0
        horizontalSeparatorLeading.constant = 0

    }
    
    func setBlankMode(){
        horizontalSeparatorTrailing.constant = 0
        horizontalSeparatorLeading.constant = 0
        arrowImageView.isHidden = true
        categoryNameLabel.isHidden = true
    }
    
    func unhideTopSeparatorView() {
        upperHorizontalSeparatorView.isHidden = false
    }

    
    func setData(data: CategoryIntermediaryChild) {
        self.categoryNameLabel.text = data.name
        self.bk_(whenTapped: {
            AnalyticsManager.trackEventName(GA_EVENT_CLICK_CATEGORY, category: GA_EVENT_CATEGORY_PAGE, action: GA_EVENT_ACTION_CATEGORY, label: data.id)
            let navigateViewController = NavigateViewController()
            navigateViewController.navigateToIntermediaryCategory(from: UIApplication.topViewController(), withCategoryId: data.id, categoryName: data.name)
        })
    }
}
