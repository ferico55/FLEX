//
//  TopAdsComponentView.swift
//  Tokopedia
//
//  Created by Dhio Etanasti on 3/27/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import UIKit
import Render

struct TopAdsState: StateType {
    var topAds: [PromoResult]?
}

class TopAdsNode: NSObject, NodeType, TKPDAlertViewDelegate {
    
    private var rootNode: NodeType
    
    override init() {
        rootNode = Node(identifier: "topads")
    }
    
    convenience init(ads: [PromoResult]) {
        self.init()
        guard ads.count > 0 else {
            rootNode = Node(identifier: "topads")
            return
        }
        
        let theTopAds = ads
        let divider:CGFloat = (UIDevice.current.userInterfaceIdiom == .pad ?4:2)

        
        let mainWrapper = Node<UIView>(identifier: "topads") {
            view, layout, size in
            view.backgroundColor = .clear
            layout.width = size.width
        }
        
        func promotedInfoView() -> NodeType {
            let promotedInfoView = Node<UIView> {
                view, layout, size in
                view.backgroundColor = .clear
                layout.alignItems = .center
                layout.flexDirection = .row
                layout.width = size.width
                layout.height = 35
            }
            
            let promotedLabel = Node<UILabel> {
                view, layout, _ in
                view.text = "Promoted"
                view.font = view.font.withSize(14)
                layout.marginLeft = 8
            }
            
            let infoButtonImageView = Node<UIImageView>(create: {
                let tapGesture = UITapGestureRecognizer()
                tapGesture.rx.event
                    .subscribe(onNext: { _ in
                        let alert = PromoInfoAlertView.newview() as! PromoInfoAlertView
                        alert.delegate = self
                        alert.show()
                    })
                
                let imageView = UIImageView()
                imageView.isUserInteractionEnabled = true
                imageView.contentMode = .center
                imageView.image = UIImage(named:"info.png")
                imageView.backgroundColor = .clear
                imageView.addGestureRecognizer(tapGesture)
                
                return imageView
            }) {
                view, layout, size in
                
                layout.width = 30
                layout.right = 8
                layout.position = .absolute
            }
            
            return promotedInfoView.add(children: [
                promotedLabel,
                infoButtonImageView
            ])
        }
        
        let adsWrapper = Node<UIView> {
            view, layout, size in
            view.backgroundColor = .tpLine()
            layout.width = size.width
            layout.flexDirection = .row
            layout.flexWrap = .wrap
        }
        
        func adView(topAdsResult: PromoResult, index: Int) -> NodeType {
            
            let product = topAdsResult.viewModel!
            
            //        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.topAdsTapped(_:)))
            
            let adView = Node<UIView>(
                create: {
                    let tapGesture = UITapGestureRecognizer()
                    tapGesture.rx.event
                        .subscribe(onNext: { _ in
                            if let url = URL(string: topAdsResult.applinks) {
                                TopAdsService.sendClickImpression(clickURLString: topAdsResult.product_click_url)
                                TPRoutes.routeURL(url)
                            }
                        })
                    
                    let view = UIView()
                    view.backgroundColor = UIColor.white
                    view.addGestureRecognizer(tapGesture)
                    
                    return view
                }
            ) {
                _, layout, size in
                
                layout.flexDirection = .column
                layout.width = (size.width - (divider-1)) / divider
                
                if (index+1) != Int(divider) {
                    layout.marginRight = 1
                }
            }
            
            let productImageView = Node<UIImageView> {
                view, layout, size in
                view.setImageWith(URL(string: product.productThumbUrl), placeholderImage: UIImage(named: "grey-bg.png"))
                layout.width = size.width / divider - 11
                layout.height = layout.width
                layout.marginHorizontal = 5
                layout.marginTop = 5
                layout.marginBottom = 2
            }
            
            let productNameLabel = Node<UILabel> {
                view, layout, _ in
                view.text = product.productName
                view.textColor = UIColor.fromHexString("FF0A7E07")
                view.font = UIFont.smallThemeMedium()
                layout.marginHorizontal = 5
            }
            
            let productPriceLabel = Node<UILabel> {
                view, layout, _ in
                view.textColor = UIColor.tpOrange()
                view.font = UIFont.smallThemeMedium()
                view.text = product.productPrice
                layout.marginHorizontal = 5
            }
            
            func statusWrapper() -> NodeType {
                let statusWrapper = Node<UIView> {
                    _, layout, _ in
                    layout.height = 18
                    layout.marginTop = 3
                    layout.marginBottom = 3
                    layout.marginHorizontal = 5
                    layout.flexDirection = .row
                }
                
                func statusLabel(label: ProductLabel) -> NodeType {
                    let statusLabel = Node<UILabel> {
                        view, layout, _ in
                        view.layer.borderWidth = 1
                        view.layer.cornerRadius = 3
                        view.layer.backgroundColor = UIColor.fromHexString(label.color).cgColor
                        view.layer.borderColor = label.color == "#ffffff" ? UIColor.lightGray.cgColor : UIColor.fromHexString(label.color).cgColor
                        view.textColor = label.color == "#ffffff" ? UIColor.lightGray : UIColor.white
                        view.text = label.title
                        view.textAlignment = .center
                        view.font = UIFont.microTheme()
                        layout.paddingHorizontal = 2
                        layout.marginRight = 2
                    }
                    
                    return statusLabel
                }
                
                if let labels = product.labels {
                    statusWrapper.add(children: (0..<labels.count).map { index in
                        statusLabel(label: labels[index] as! ProductLabel)
                    })
                }
                
                return statusWrapper
            }
            
            let productShopLabel = Node<UILabel> {
                view, layout, _ in
                view.textColor = UIColor.lightGray
                view.font = UIFont.microTheme()
                view.text = product.productShop
                layout.marginHorizontal = 5
            }
            
            func bottomWrapper() -> NodeType {
                let bottomWrapper = Node<UIView> {
                    _, layout, _ in
                    layout.height = 15
                    layout.marginHorizontal = 5
                    layout.marginBottom = 5
                    layout.flexDirection = .row
                    layout.alignItems = .center
                }
                
                let pinIcon = Node<UIImageView> {
                    view, layout, _ in
                    view.image = UIImage(named: "icon_location.png")
                    layout.width = 11
                    layout.height = 11
                }
                
                let locationLabel = Node<UILabel> {
                    view, _, _ in
                    view.textColor = UIColor.lightGray
                    view.text = product.shopLocation
                    view.textAlignment = .center
                    view.font = UIFont.microTheme()
                }
                
                let badgesWrapper = Node<UIView> {
                    _, layout, _ in
                    layout.flexDirection = .row
                    layout.justifyContent = .flexEnd
                    layout.height = 14
                    layout.right = 0
                    layout.position = .absolute
                }
                
                func badgeView(badge: ProductBadge) -> NodeType {
                    let badgeView = Node<UIImageView> {
                        view, layout, _ in
                        view.setImageWith(URL(string: badge.image_url))
                        layout.marginLeft = 2
                        layout.height = 14
                        layout.width = layout.height
                    }
                    return badgeView
                }
                
                if let badges = product.badges {
                    badgesWrapper.add(children: (0..<badges.count).map { index in
                        badgeView(badge: badges[index] as! ProductBadge)
                    })
                }
                
                return bottomWrapper.add(children: [
                    pinIcon,
                    locationLabel,
                    badgesWrapper
                ])
            }
            
            return adView.add(children: [
                productImageView,
                productNameLabel,
                productPriceLabel,
                statusWrapper(),
                productShopLabel,
                bottomWrapper()
            ])
        }
        
        adsWrapper.add(children: (0..<theTopAds.count).map { index in
            adView(topAdsResult: theTopAds[index], index: index)
        })
        mainWrapper.add(children:[
            promotedInfoView(),
            adsWrapper
        ])
        
        rootNode = mainWrapper
    }
    
    func alertView(_ alertView: TKPDAlertView!, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            let urlString = "https://www.tokopedia.com/iklan?source=tooltip&medium=ios"
            UIApplication.shared.openURL(URL(string: urlString)!)
        }
    }
    
    var renderedView: UIView? {
        return rootNode.renderedView
    }
    
    var identifier: String {
        return rootNode.identifier
    }
    
    var children: [NodeType] {
        set {}
        get {
            return rootNode.children
        }
    }
    
    func add(children: [NodeType]) -> NodeType {
        return self
    }
    
    var index: Int = 0
    
    func render(in bounds: CGSize) {
        rootNode.render(in: bounds)
    }
    
    func internalConfigure(in bounds: CGSize) {
        rootNode.internalConfigure(in: bounds)
    }
    
    func willRender() {
        rootNode.willRender()
    }
    
    func didRender() {
        rootNode.didRender()
    }
    
    func build(with reusable: UIView?) {
        rootNode.build(with: reusable)
    }
}

class TopAdsComponentView: ComponentView<TopAdsState>, TKPDAlertViewDelegate {
    
    override init() {
        super.init()
    }
    
    convenience init(ads: [PromoResult]) {
        self.init()
        let theState = TopAdsState(topAds: ads)
        self.state = theState
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func construct(state: TopAdsState?, size: CGSize) -> NodeType {
        guard let theTopAds = state?.topAds, theTopAds.count > 0 else {
            return Node<UIView> {
                _, _, _ in
            }
        }
        
        let topAdsNode = TopAdsNode(ads: theTopAds)
        return topAdsNode
    }
    
}
