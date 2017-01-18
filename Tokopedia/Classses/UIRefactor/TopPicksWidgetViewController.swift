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

class TopPicksWidgetViewController: UIViewController {
    
    private var outerVerticalStackView: OAStackView = OAStackView()
    private var innerVerticalStackView: OAStackView = OAStackView()
    private var horizontalStackView: OAStackView = OAStackView()
    private var topPicksData: TopPicksResponseData!

    var didGetTopPicksData: (() -> Void)?
    
    private var separatorGrayColor = UIColor(red: 241.0/255, green: 241.0/255, blue: 241.0/255, alpha: 1.0)
    private var horizontalStackViewSpacing: CGFloat = 25.0

    override func viewDidLoad() {
        super.viewDidLoad()
        requestTopPicksData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Request Method
    private func requestTopPicksData() {
        let topPicksNetworkManager = TokopediaNetworkManager()
        topPicksNetworkManager.isUsingHmac = true
        topPicksNetworkManager.requestWithBaseUrl(NSString.aceUrl(), path: "/hoth/toppicks/widget", method: .GET, parameter: ["random" : "true" ,"source" : "home"], mapping: TopPicksResponse.mapping(), onSuccess: { [unowned self](mappingResult, operation) in
            let result: NSDictionary = (mappingResult as RKMappingResult).dictionary()
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
    private func setupOuterVerticalStackView(){
        self.view.removeAllSubviews()
        self.view.addSubview(outerVerticalStackView)
        outerVerticalStackView.setAttribute(.Vertical, alignment: .Fill, distribution: .Fill, spacing: 0.0)
        outerVerticalStackView.layoutMarginsRelativeArrangement = true
        outerVerticalStackView.layoutMargins = UIEdgeInsets(top: 5, left: 20, bottom: 0, right: 20)
        outerVerticalStackView.mas_makeConstraints { (make) in
            make.edges.mas_equalTo()(self.view)
        }
        
        setTopPicksHeaderTitleLabel()
        
        setHeaderUpperSeparator()
        
        setTopPicksCell()
    
        setSeeAllViewContainerContainer()
       
    }
    
    private func setSeeAllViewContainerContainer() {
        let seeAllViewContainer = UIView()
        seeAllViewContainer.mas_makeConstraints { (make) in
            make.height.mas_equalTo()(42)
        }
        
        outerVerticalStackView.addArrangedSubview(seeAllViewContainer)
        
        let horizontalSeparator = UIView()
        horizontalSeparator.backgroundColor = separatorGrayColor
        seeAllViewContainer.addSubview(horizontalSeparator)
        horizontalSeparator.mas_makeConstraints { (make) in
            make.left.right().mas_equalTo()(self.view)
            make.top.mas_equalTo()(seeAllViewContainer.mas_top)
            make.height.mas_equalTo()(1)
        }
        
        let seeAllArrowImageView = UIImageView(image: UIImage(named: "icon_forward"))
        
        seeAllViewContainer.addSubview(seeAllArrowImageView)
        seeAllArrowImageView.mas_makeConstraints { (make) in
            make.centerY.mas_equalTo()(seeAllViewContainer.mas_centerY)
            make.right.mas_equalTo()(seeAllViewContainer.mas_right)
        }
        
        let seeAllButton = UIButton(type: .Custom)
        seeAllButton.setTitle("Lihat Semua", forState: .Normal)
        seeAllButton.setTitleColor(UIColor(red: 66.0/255, green: 181.0/255, blue: 73.0/255, alpha: 1.0), forState: .Normal)
        seeAllButton.titleLabel!.font = UIFont.largeThemeMedium()
        seeAllButton.bk_whenTapped { [unowned self] in
            self.goToWebView("https://www.tokopedia.com/toppicks?flag_app=1")
        }
        seeAllViewContainer.addSubview(seeAllButton)
        seeAllButton.mas_makeConstraints { (make) in
            make.centerY.mas_equalTo()(seeAllViewContainer.mas_centerY).offset()(-1)
            make.right.mas_equalTo()(seeAllArrowImageView.mas_left).offset()(-8)
        }
    }
    
    private func setTopPicksCell() {
        let topPicksVerticalStackViewContainer = UIView()
        outerVerticalStackView.addArrangedSubview(topPicksVerticalStackViewContainer)
        innerVerticalStackView.setAttribute(.Vertical, alignment: .Fill, distribution: .Fill, spacing: 0.0)
        topPicksVerticalStackViewContainer.addSubview(innerVerticalStackView)
        innerVerticalStackView.layoutMarginsRelativeArrangement = true
        innerVerticalStackView.layoutMargins = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
        innerVerticalStackView.mas_makeConstraints { (make) in
            make.edges.mas_equalTo()(topPicksVerticalStackViewContainer)
        }
        refreshHorizontalStackView()
        
        for topPick in topPicksData.groups.first!.toppicks {
            let topPicksImageViewContainer = UIView()
            horizontalStackView.addArrangedSubview(topPicksImageViewContainer)
            let topPicksImageView = UIImageView()
            topPicksImageView.layer.cornerRadius = 2
            topPicksImageView.layer.masksToBounds = true
            topPicksImageView.setImageWithURL(NSURL(string: topPick.imageUrl))
            topPicksImageViewContainer.addSubview(topPicksImageView)
            topPicksImageView.mas_makeConstraints({ (make) in
                make.edges.mas_equalTo()(topPicksImageViewContainer)
            })
            
            let tapGestureRecognizer = UITapGestureRecognizer.bk_recognizerWithHandler({[unowned self] (recognizer, state, point) in
                self.didTapTopPicks(recognizer as! UITapGestureRecognizer)
            }) as! UITapGestureRecognizer
            topPicksImageView.addGestureRecognizer(tapGestureRecognizer)
            topPicksImageView.userInteractionEnabled = true
            let verticalSeparatorView = UIView()
            verticalSeparatorView.backgroundColor = separatorGrayColor
            topPicksImageViewContainer.addSubview(verticalSeparatorView)
            verticalSeparatorView.mas_makeConstraints({ (make) in
                make.left.mas_equalTo()(topPicksImageViewContainer.mas_right).offset()(self.horizontalStackViewSpacing / 2)
                make.top.bottom().mas_equalTo()(topPicksImageViewContainer)
                make.width.mas_equalTo()(1)
            })
            
            setTopPicksItemCell(topPick)
        }
    }
    
    private func setTopPicksItemCell(topPick: TopPick) {
        for (index,topPickItem) in topPick.items.enumerate() {
            let topPicksItemContainerView = UIView()
            topPicksItemContainerView.layer.borderColor = separatorGrayColor.CGColor
            topPicksItemContainerView.layer.cornerRadius = 2
            topPicksItemContainerView.layer.borderWidth = 1
            topPicksItemContainerView.tag = index
            let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer.bk_recognizerWithHandler({[unowned self] (recognizer, state, point) in
                self.didTapTopPicksItem(topPickItem)
            }) as! UITapGestureRecognizer
            topPicksItemContainerView.addGestureRecognizer(tapGestureRecognizer)
            let topPicksItemImageView = UIImageView()
            topPicksItemImageView.setImageWithURL(NSURL(string: topPickItem.imageUrl))
            topPicksItemImageView.layer.cornerRadius = 2
            topPicksItemImageView.layer.masksToBounds = true
            topPicksItemContainerView.addSubview(topPicksItemImageView)
            topPicksItemImageView.mas_makeConstraints({ (make) in
                make.top.left().mas_equalTo()(topPicksItemContainerView).offset()(3)
                make.bottom.right().mas_equalTo()(topPicksItemContainerView).offset()(-3)
            })
            
            horizontalStackView.addArrangedSubview(topPicksItemContainerView)
            
            if changeRowFormula(index) {
                innerVerticalStackView.addArrangedSubview(horizontalStackView)
                horizontalStackView.mas_makeConstraints({ (make) in
                    make.height.mas_equalTo()(topPicksItemContainerView.mas_width)
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
    
    private func changeRowFormula(index: Int) -> Bool{
        return UI_USER_INTERFACE_IDIOM() == .Pad ? index % 4 == 2 : index % 2 == 0
    }
    
    private func refreshHorizontalStackView() {
        horizontalStackView = OAStackView()
        horizontalStackView.setAttribute(.Horizontal, alignment: .Fill, distribution: .FillEqually, spacing: horizontalStackViewSpacing)
    }
    
    private func setTopPicksItemHorizontalSeparator(withLine: Bool) {
        let horizontalSeparatorContainerView = UIView()
        horizontalSeparatorContainerView.mas_makeConstraints({ (make) in
            make.height.mas_equalTo()(23)
        })
        innerVerticalStackView.addArrangedSubview(horizontalSeparatorContainerView)
        
        if withLine {
            let horizontalSeparatorView = UIView()
            horizontalSeparatorView.backgroundColor = separatorGrayColor
            horizontalSeparatorContainerView.addSubview(horizontalSeparatorView)
            horizontalSeparatorView.mas_makeConstraints({ (make) in
                make.height.mas_equalTo()(1)
                make.left.right().mas_equalTo()(horizontalSeparatorContainerView)
                make.centerY.mas_equalTo()(horizontalSeparatorContainerView.mas_centerY)
            })
        }
    }
    
    private func setTopPicksVerticalSeparator(topPicksItemContainerView: UIView) {
        let verticalSeparatorView = UIView()
        topPicksItemContainerView.addSubview(verticalSeparatorView)
        verticalSeparatorView.backgroundColor = separatorGrayColor
        verticalSeparatorView.mas_makeConstraints({ (make) in
            make.width.mas_equalTo()(1)
            make.top.bottom().mas_equalTo()(topPicksItemContainerView)
            make.left.mas_equalTo()(topPicksItemContainerView.mas_right).offset()(self.horizontalStackViewSpacing/2)
        })
    }
    
    private func setTopPicksHeaderTitleLabel() {
        HomePageHeaderSectionStyle.setHeaderTitle(forStackView: outerVerticalStackView, title: topPicksData.groups.first!.name)
    }
    
    private func setHeaderUpperSeparator() {
        HomePageHeaderSectionStyle.setHeaderUpperSeparator(forStackView: outerVerticalStackView)
    }
    
    // MARK: Action Handler
    
    private func didTapTopPicksItem(topPickItem: TopPickItem) {
        let topPickItemURL = NSURL(string: topPickItem.url)!
        let urlPaths = topPickItemURL.path?.componentsSeparatedByString("/")
        
        // contoh url nya: https://www.tokopedia.com/hot/choker-necklace
        guard let guardedUrlPaths = urlPaths else { return }
        AnalyticsManager.trackEventName("clickToppicks", category: "Toppicks Home", action: topPickItem.name, label: guardedUrlPaths.last)
        TPRoutes.routeURL(topPickItemURL)
    }
    
    private func didTapTopPicks(recognizer: UITapGestureRecognizer) {
        AnalyticsManager.trackEventName("clickToppicks", category: "Toppicks Home", action: GA_EVENT_ACTION_CLICK, label: topPicksData.groups.first?.toppicks.first?.name)
        self.goToWebView((topPicksData.groups.first?.toppicks.first?.url)! + "?flag_app=1")
    }
    
    private func goToWebView(urlString: String) {
        let webViewVC = WebViewController()
        webViewVC.strURL = urlString
        self.navigationController?.pushViewController(webViewVC, animated: true)
    }

}
