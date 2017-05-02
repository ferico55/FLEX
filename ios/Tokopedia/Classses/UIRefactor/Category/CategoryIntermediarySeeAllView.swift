//
//  CategoryIntermediarySeeAllView.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 3/8/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class CategoryIntermediarySeeAllView: UIView {
    
    var didTapSeeAllButton: (() -> Void)?

    @IBOutlet private var seeMoreButton: UIButton!
    @IBOutlet private var arrowDownImageView: UIImageView! {
        didSet {
            arrowDownImageView.tintColor = UIColor.tpGreen()
        }
    }
    @IBAction private func didTapSeeAllButton(_ sender: Any) {
        AnalyticsManager .trackEventName(GA_EVENT_CLICK_CATEGORY, category: GA_EVENT_CATEGORY_PAGE
, action: GA_EVENT_ACTION_CATEGORY_BREAKDOWN, label: "Lihat Lainnya")
        didTapSeeAllButton?()
    }
    
    func setExpanded(isExpanded: Bool) {
        if isExpanded {
            seeMoreButton.setTitle("Sembunyikan Lainnya", for: .normal)
            self.arrowDownImageView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI));
        }
        else {
            seeMoreButton.setTitle("Lihat Lainnya", for: .normal)
            self.arrowDownImageView.transform = .identity
        }
    }
}
