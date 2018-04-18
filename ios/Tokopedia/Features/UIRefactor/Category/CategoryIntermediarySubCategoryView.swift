//
//  CategoryIntermediarySubCategoryView.swift
//
//
//  Created by Billion Goenawan on 3/3/17.
//
//

import OAStackView
import SnapKit
import UIKit

internal class CategoryIntermediarySubCategoryView: UIView {
    private var innerHorizontalStackView: OAStackView = {
        return OAStackView()
    }()
    private var isRevamp: Bool = false
    
    internal var didTapSeeAllButton: (() -> Void)?
    
    override internal init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    internal func setIsRevamp(isRevamp: Bool) {
        self.isRevamp = isRevamp
    }
    
    internal func setChildrenData(categoryChildren: [CategoryIntermediaryChild], categoryResult: CategoryIntermediaryResult, isNeedSeeMoreButton: Bool) {
        self.removeAllSubviews()
        let stackView: OAStackView = OAStackView()
        self.addSubview(stackView)
        stackView.isLayoutMarginsRelativeArrangement = true
        if isRevamp {
            stackView.layoutMargins = UIEdgeInsetsMake(15, 10, 5, 10)
            stackView.setAttribute(.vertical, alignment: .fill, distribution: .fillEqually, spacing: 10)
              innerHorizontalStackView.setAttribute(.horizontal, alignment: .fill, distribution: .fillEqually, spacing: 12)
        } else {
            stackView.layoutMargins = UIEdgeInsetsMake(15, 0, 10, 0)
            stackView.setAttribute(.vertical, alignment: .fill, distribution: .fillEqually, spacing: 0)
              innerHorizontalStackView.setAttribute(.horizontal, alignment: .fill, distribution: .fillEqually, spacing: 0)
        }
        
        if !isNeedSeeMoreButton {
            stackView.snp.makeConstraints { (make) in
                make.edges.equalTo(self)
            }
        } else {
            let seeMoreView = (UINib(nibName: "CategoryIntermediarySeeAllView", bundle: nil).instantiate(withOwner: nil, options: [:])[0]) as! CategoryIntermediarySeeAllView
            let isExpanded = categoryChildren.count > (isRevamp ? 9 : 6) ? true : false

            seeMoreView.setExpanded(isExpanded: isExpanded)
            seeMoreView.didTapSeeAllButton = { [unowned self] in
                self.didTapSeeAllButton?()
            }
            self.addSubview(seeMoreView)
            seeMoreView.snp.makeConstraints({ (make) in
                make.bottom.left.right.equalTo(self)
                make.height.equalTo(38)
            })
            stackView.snp.makeConstraints { (make) in
                make.top.left.right.equalTo(self)
                make.bottom.equalTo(seeMoreView.snp.top)
            }
        }

        if isRevamp{
            for (index, data) in categoryChildren.enumerated() {
                let categoryViewCell = (UINib(nibName: "CategoryIntermediarySubCategoryCellView", bundle: nil).instantiate(withOwner: nil, options: [:])[0]) as! CategoryIntermediarySubCategoryCellView
                
                let eeDict: [String : Any] = [
                    "event": "promoClick",
                    "eventCategory" : "intermediary page",
                    "eventAction" : "click subcategory",
                    "eventLabel" : data.applinks,
                    "ecommerce": [
                        "promoClick": [
                            "promotions": [[
                                "id": data.id,
                                "name": "/intermediary/\(categoryResult.name) - promo 2 - subcategory",
                                "position": "\(index+1)",
                                "creative": data.name,
                                ]]
                        ]
                    ]
                ]
                
                categoryViewCell.layer.shadowOffset = .zero
                categoryViewCell.setData(data: data, trackerDict: eeDict)
                innerHorizontalStackView.addArrangedSubview(categoryViewCell)
                
                if index % totalColumnInOneRow() == totalColumnInOneRow() - 1 {
                    stackView.addArrangedSubview(innerHorizontalStackView)
                    innerHorizontalStackView = OAStackView()
                    innerHorizontalStackView.setAttribute(.horizontal, alignment: .fill, distribution: .fillEqually, spacing: 12)
                    
                } else if index == categoryChildren.count - 1 {
                    for _ in 1...self.totalColumnInOneRow() - (index % self.totalColumnInOneRow() + 1)
                    {
                        let emptyView = UIView()
                        emptyView.backgroundColor = UIColor.tpBackground()
                        innerHorizontalStackView.addArrangedSubview(emptyView)
                    }
                    stackView.addArrangedSubview(innerHorizontalStackView)
                    innerHorizontalStackView = OAStackView()
                }
            }
        } else {
            for (index, data) in categoryChildren.enumerated() {
                let categoryViewCell = (UINib(nibName: "CategoryIntermediarySubCategoryNoRevampView", bundle: nil).instantiate(withOwner: nil, options: [:])[0]) as! CategoryIntermediarySubCategoryNoRevampView
                
                let eeDict: [String : Any] = [
                    "event": "promoClick",
                    "eventCategory" : "intermediary page",
                    "eventAction" : "click subcategory",
                    "eventLabel" : data.applinks,
                    "ecommerce": [
                        "promoClick": [
                            "promotions": [[
                                "id": data.id,
                                "name": "/intermediary/\(categoryResult.name) - promo 2 - subcategory",
                                "position": "\(index+1)",
                                "creative": data.name,
                                ]]
                        ]
                    ]
                ]
                
                categoryViewCell.setData(data: data, trackerDict: eeDict)
                innerHorizontalStackView.addArrangedSubview(categoryViewCell)
                categoryViewCell.snp.makeConstraints({ (make) in
                    make.width.equalTo(UIScreen.main.bounds.size.width / CGFloat(totalColumnInOneRow()))
                })
                
                if index == 0 || index == 1 {
                    categoryViewCell.unhideTopSeparatorView()
                }
                
                if index % 2 == 0 && index == categoryChildren.count - 2 {
                    categoryViewCell.setUnderlinedBottom()
                }
                
                if index % totalColumnInOneRow() == totalColumnInOneRow() - 1 { 
                    categoryViewCell.setRightMode()
                    stackView.addArrangedSubview(innerHorizontalStackView)
                    innerHorizontalStackView = OAStackView()
                    innerHorizontalStackView.setAttribute(.horizontal, alignment: .fill, distribution: .fillEqually, spacing: 0)
                    
                } else if index == categoryChildren.count - 1 {
                    categoryViewCell.setUnderlinedBottom()
                    for _ in 1...self.totalColumnInOneRow() - (index % self.totalColumnInOneRow() + 1)
                    {
                        let emptyView = (UINib(nibName: "CategoryIntermediarySubCategoryNoRevampView", bundle: nil).instantiate(withOwner: nil, options: [:])[0]) as! CategoryIntermediarySubCategoryNoRevampView
                        emptyView.setBlankMode()
                        innerHorizontalStackView.addArrangedSubview(emptyView)
                    }
                    stackView.addArrangedSubview(innerHorizontalStackView)
                    innerHorizontalStackView = OAStackView()
                }
            }
        }
    }
    
    required internal init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func totalColumnInOneRow() -> Int {
        return isRevamp == true ? 3 : 2
    }
    
}
