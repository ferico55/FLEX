//
//  TopPicksWidgetViewController.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 12/27/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import OAStackView
import JLRoutes
import RestKit

class TopPicksWidgetViewController: UIViewController {
    
    fileprivate var outerVerticalStackView: OAStackView = OAStackView()
    fileprivate var innerVerticalStackView: OAStackView = OAStackView()
    fileprivate var horizontalStackView: OAStackView = OAStackView()
    fileprivate var topPicksData: TopPicksResponseData!

    var didGetTopPicksData: (() -> Void)?
    
    fileprivate var separatorGrayColor = UIColor(red: 241.0/255, green: 241.0/255, blue: 241.0/255, alpha: 1.0)
    fileprivate var horizontalStackViewSpacing: CGFloat = 25.0

    override func viewDidLoad() {
        super.viewDidLoad()
        requestTopPicksData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Request Method
    fileprivate func requestTopPicksData() {
        let topPicksNetworkManager = TokopediaNetworkManager()
        topPicksNetworkManager.isUsingHmac = true
        topPicksNetworkManager.request(withBaseUrl: NSString.aceUrl(), path: "/hoth/toppicks/widget", method: .GET, parameter: ["random" : "true" ,"source" : "home"], mapping: TopPicksResponse.mapping(), onSuccess: { [unowned self](mappingResult, operation) in
            let result: NSDictionary = (mappingResult as RKMappingResult).dictionary() as NSDictionary
            let topPicksResponse: TopPicksResponse = result[""] as! TopPicksResponse
            self.topPicksData = topPicksResponse.data
            guard self.topPicksData.groups.count > 0 else {
                return
            }
            if self.topPicksData.groups.first!.toppicks.count > 0{
                self.didGetTopPicksData?()
                self.setupOuterVerticalStackView()
            }
            }, onFailure: { (error) in
                let stickyAlertView: StickyAlertView = StickyAlertView(errorMessages: [error.localizedDescription], delegate: self)
                stickyAlertView.show()
        })
    }
    
    //MARK: Layout Builder
    fileprivate func setupOuterVerticalStackView(){
        self.view.removeAllSubviews()
        self.view.addSubview(outerVerticalStackView)
        outerVerticalStackView.setAttribute(.vertical, alignment: .fill, distribution: .fill, spacing: 0.0)
        outerVerticalStackView.isLayoutMarginsRelativeArrangement = true
        outerVerticalStackView.layoutMargins = UIEdgeInsets(top: 5, left: 20, bottom: 0, right: 20)
        outerVerticalStackView.mas_makeConstraints { (make) in
            make?.edges.mas_equalTo()(self.view)
        }
        
        setTopPicksHeaderTitleLabel()
        
        setHeaderUpperSeparator()
        
        setTopPicksCell()
    
        setSeeAllViewContainerContainer()
       
    }
    
    fileprivate func setSeeAllViewContainerContainer() {
        let seeAllViewContainer = UIView()
        seeAllViewContainer.mas_makeConstraints { (make) in
            make?.height.mas_equalTo()(42)
        }
        
        outerVerticalStackView.addArrangedSubview(seeAllViewContainer)
        
        let horizontalSeparator = UIView()
        horizontalSeparator.backgroundColor = separatorGrayColor
        seeAllViewContainer.addSubview(horizontalSeparator)
        horizontalSeparator.mas_makeConstraints { (make) in
            make?.left.right().mas_equalTo()(self.view)
            make?.top.mas_equalTo()(seeAllViewContainer.mas_top)
            make?.height.mas_equalTo()(1)
        }
        
        let seeAllArrowImageView = UIImageView(image: UIImage(named: "icon_forward"))
        
        seeAllArrowImageView.tintColor = UIColor.tpGreen()
        seeAllViewContainer.addSubview(seeAllArrowImageView)
        seeAllArrowImageView.mas_makeConstraints { (make) in
            make?.centerY.mas_equalTo()(seeAllViewContainer.mas_centerY)
            make?.right.mas_equalTo()(seeAllViewContainer.mas_right)
        }
        
        let seeAllButton = UIButton(type: .custom)
        seeAllButton.setTitle("Lihat Semua", for: UIControlState())
        seeAllButton.setTitleColor(UIColor.tpGreen(), for: UIControlState())
        seeAllButton.titleLabel!.font = UIFont.largeThemeMedium()
        seeAllButton.bk_(whenTapped: { [unowned self] in
            self.goToWebView("https://www.tokopedia.com/toppicks?flag_app=1")
        })
        seeAllViewContainer.addSubview(seeAllButton)
        seeAllButton.mas_makeConstraints { (make) in
            make?.centerY.mas_equalTo()(seeAllViewContainer.mas_centerY)?.offset()(-1)
            make?.right.mas_equalTo()(seeAllArrowImageView.mas_left)?.offset()(-8)
        }
    }
    
    fileprivate func setTopPicksCell() {
        let topPicksVerticalStackViewContainer = UIView()
        outerVerticalStackView.addArrangedSubview(topPicksVerticalStackViewContainer)
        innerVerticalStackView.setAttribute(.vertical, alignment: .fill, distribution: .fill, spacing: 0.0)
        topPicksVerticalStackViewContainer.addSubview(innerVerticalStackView)
        innerVerticalStackView.isLayoutMarginsRelativeArrangement = true
        innerVerticalStackView.layoutMargins = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
        innerVerticalStackView.mas_makeConstraints { (make) in
            make?.edges.mas_equalTo()(topPicksVerticalStackViewContainer)
        }
        refreshHorizontalStackView()
        
        for topPick in topPicksData.groups.first!.toppicks {
            let topPicksImageViewContainer = UIView()
            horizontalStackView.addArrangedSubview(topPicksImageViewContainer)
            let topPicksImageView = UIImageView()
            topPicksImageView.layer.cornerRadius = 2
            topPicksImageView.layer.masksToBounds = true
            topPicksImageView.setImageWith(NSURL(string: topPick.imageUrl) as URL!)
            topPicksImageViewContainer.addSubview(topPicksImageView)
            topPicksImageView.mas_makeConstraints({ (make) in
                make?.edges.mas_equalTo()(topPicksImageViewContainer)
            })
            
            let tapGestureRecognizer = UITapGestureRecognizer.bk_recognizer(handler: {[unowned self] (recognizer, state, point) in
                self.didTapTopPicks(recognizer as! UITapGestureRecognizer)
            }) as! UITapGestureRecognizer
            topPicksImageView.addGestureRecognizer(tapGestureRecognizer)
            topPicksImageView.isUserInteractionEnabled = true
            let verticalSeparatorView = UIView()
            verticalSeparatorView.backgroundColor = separatorGrayColor
            topPicksImageViewContainer.addSubview(verticalSeparatorView)
            verticalSeparatorView.mas_makeConstraints({ (make) in
                make?.left.mas_equalTo()(topPicksImageViewContainer.mas_right)?.offset()(self.horizontalStackViewSpacing / 2)
                make?.top.bottom().mas_equalTo()(topPicksImageViewContainer)
                make?.width.mas_equalTo()(1)
            })
            
            setTopPicksItemCell(topPick)
        }
    }
    
    fileprivate func setTopPicksItemCell(_ topPick: TopPick) {
        for (index,topPickItem) in topPick.items.enumerated() {
            let topPicksItemContainerView = UIView()
            topPicksItemContainerView.layer.borderColor = separatorGrayColor.cgColor
            topPicksItemContainerView.layer.cornerRadius = 2
            topPicksItemContainerView.layer.borderWidth = 1
            topPicksItemContainerView.tag = index
            let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer.bk_recognizer(handler: {[unowned self] (recognizer, state, point) in
                self.didTapTopPicksItem(topPickItem)
            }) as! UITapGestureRecognizer
            topPicksItemContainerView.addGestureRecognizer(tapGestureRecognizer)
            let topPicksItemImageView = UIImageView()
            topPicksItemImageView.setImageWith(NSURL(string: topPickItem.imageUrl) as URL!)
            topPicksItemImageView.layer.cornerRadius = 2
            topPicksItemImageView.layer.masksToBounds = true
            topPicksItemContainerView.addSubview(topPicksItemImageView)
            topPicksItemImageView.mas_makeConstraints({ (make) in
                make?.top.left().mas_equalTo()(topPicksItemContainerView)?.offset()(3)
                make?.bottom.right().mas_equalTo()(topPicksItemContainerView)?.offset()(-3)
            })
            
            horizontalStackView.addArrangedSubview(topPicksItemContainerView)
            
            if changeRowFormula(index) {
                innerVerticalStackView.addArrangedSubview(horizontalStackView)
                horizontalStackView.mas_makeConstraints({ (make) in
                    make?.height.mas_equalTo()(topPicksItemContainerView.mas_width)
                })
                refreshHorizontalStackView()
                var separatorWithLine = true
                if topPick.items.count - 1 == index {
                    separatorWithLine = false
                }
                setTopPicksItemHorizontalSeparator(separatorWithLine)
            } else {
                setTopPicksVerticalSeparator(topPicksItemContainerView)
            }
        }
    }
    
    fileprivate func changeRowFormula(_ index: Int) -> Bool{
        return UI_USER_INTERFACE_IDIOM() == .pad ? index % 4 == 2 : index % 2 == 0
    }
    
    fileprivate func refreshHorizontalStackView() {
        horizontalStackView = OAStackView()
        horizontalStackView.setAttribute(.horizontal, alignment: .fill, distribution: .fillEqually, spacing: horizontalStackViewSpacing)
    }
    
    fileprivate func setTopPicksItemHorizontalSeparator(_ withLine: Bool) {
        let horizontalSeparatorContainerView = UIView()
        horizontalSeparatorContainerView.mas_makeConstraints({ (make) in
            make?.height.mas_equalTo()(23)
        })
        innerVerticalStackView.addArrangedSubview(horizontalSeparatorContainerView)
        
        if withLine {
            let horizontalSeparatorView = UIView()
            horizontalSeparatorView.backgroundColor = separatorGrayColor
            horizontalSeparatorContainerView.addSubview(horizontalSeparatorView)
            horizontalSeparatorView.mas_makeConstraints({ (make) in
                make?.height.mas_equalTo()(1)
                make?.left.right().mas_equalTo()(horizontalSeparatorContainerView)
                make?.centerY.mas_equalTo()(horizontalSeparatorContainerView.mas_centerY)
            })
        }
    }
    
    fileprivate func setTopPicksVerticalSeparator(_ topPicksItemContainerView: UIView) {
        let verticalSeparatorView = UIView()
        topPicksItemContainerView.addSubview(verticalSeparatorView)
        verticalSeparatorView.backgroundColor = separatorGrayColor
        verticalSeparatorView.mas_makeConstraints({ (make) in
            make?.width.mas_equalTo()(1)
            make?.top.bottom().mas_equalTo()(topPicksItemContainerView)
            make?.left.mas_equalTo()(topPicksItemContainerView.mas_right)?.offset()(self.horizontalStackViewSpacing/2)
        })
    }
    
    fileprivate func setTopPicksHeaderTitleLabel() {
        HomePageHeaderSectionStyle.setHeaderTitle(forStackView: outerVerticalStackView, title: topPicksData.groups.first!.name)
    }
    
    fileprivate func setHeaderUpperSeparator() {
        HomePageHeaderSectionStyle.setHeaderUpperSeparator(forStackView: outerVerticalStackView)
    }
    
    // MARK: Action Handler
    
    fileprivate func didTapTopPicksItem(_ topPickItem: TopPickItem) {
        let topPickItemURL = URL(string: topPickItem.url)!
        let urlPaths = topPickItemURL.path.components(separatedBy: "/")
        
        // contoh url nya: https://www.tokopedia.com/hot/choker-necklace
        guard let urlPath = urlPaths.last else { return }
        
        AnalyticsManager.trackEventName("clickToppicks", category: "Toppicks Home", action: topPickItem.name, label: urlPath)
        TPRoutes.routeURL(topPickItemURL)
    }
    
    fileprivate func didTapTopPicks(_ recognizer: UITapGestureRecognizer) {
        AnalyticsManager.trackEventName("clickToppicks", category: "Toppicks Home", action: GA_EVENT_ACTION_CLICK, label: topPicksData.groups.first?.toppicks.first?.name)
        self.goToWebView((topPicksData.groups.first?.toppicks.first?.url)! + "?flag_app=1")
    }
    
    fileprivate func goToWebView(_ urlString: String) {
        let webViewVC = WebViewController()
        webViewVC.strURL = urlString
        self.navigationController?.pushViewController(webViewVC, animated: true)
    }

}
