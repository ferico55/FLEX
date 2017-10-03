//
//  FeedHeaderComponentView.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 4/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render
import RxSwift

class FeedHeaderComponentView: ComponentView<FeedCardState> {
    private var disposeBag = DisposeBag()
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func construct(state: FeedCardState?, size: CGSize) -> NodeType {
        guard let state = state else { return NilNode() }
        
        let authorImage: NodeType = Node<UIButton>() { button, _, _ in
            button.bk_(whenTapped: {
                if !(state.source.fromTokopedia) {
                    AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: GA_EVENT_ACTION_VIEW, label: "\(state.page).\(state.row) Feed - Shop")
                    TPRoutes.routeURL(URL(string: state.source.shopState.shopURL)!)
                } else {
                    AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: GA_EVENT_ACTION_CLICK, label: "\(state.page).\(state.row) Promotion - Promo Page Header")
                    NotificationCenter.default.post(name: Notification.Name("didSwipeHomePage"), object: self, userInfo: ["page": 3])
                }
            })
            
        }.add(child: Node<UIImageView>(identifier: "author-image") { imageView, layout, _ in
            layout.width = 52
            layout.height = 52
            
            imageView.borderWidth = 1.0
            imageView.borderColor = UIColor.fromHexString("#e0e0e0")
            imageView.cornerRadius = 3.0
            
            if state.source.fromTokopedia {
                imageView.image = #imageLiteral(resourceName: "icon_source_tokopedia")
            } else {
                imageView.setImageWith(URL(string: state.source.shopState.shopImage))
            }
            
        })
        
        let authorInfo = Node<UIButton> { view, layout, _ in
            layout.flexDirection = .column
            layout.flexShrink = 1
            layout.flexGrow = 1
            layout.marginLeft = state.oniPad ? 10.0 : 8.0
            
            view.rx.tap
                .subscribe(onNext: {
                    if !(state.source.fromTokopedia) {
                        AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: GA_EVENT_ACTION_VIEW, label: "\(state.page).\(state.row) Feed - Product List")
                        NavigateViewController().navigateToFeedDetail(from: self.viewController, withFeedCardID: state.cardID)
                    } else {
                        AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: GA_EVENT_ACTION_CLICK, label: "\(state.page).\(state.row) Promotion - Promo Page Header")
                        NotificationCenter.default.post(name: Notification.Name("didSwipeHomePage"), object: self, userInfo: ["page": 3])
                    }
                })
                .disposed(by: self.disposeBag)
        }.add(children: [
            Node<UILabel>(identifier: "title") { label, layout, _ in
                var activity: NSMutableAttributedString?
                
                layout.flexShrink = 1
                layout.marginBottom = 3
                
                if state.source.fromTokopedia {
                    let boldAttribute: [String: Any] = [
                        NSFontAttributeName: UIFont.largeThemeSemibold(),
                        NSForegroundColorAttributeName: UIColor.tpPrimaryBlackText()
                    ]
                    
                    activity = NSMutableAttributedString(string: "Tokopedia", attributes: boldAttribute)
                } else {
                    activity = self.attributedStringHeader(withActivity: state.content.activity, state: state.source)
                }
                
                label.numberOfLines = 0
                label.attributedText = activity
            },
            Node<UILabel>(identifier: "timestamp") { label, _, _ in
                label.text = state.source.fromTokopedia ? "Promo" : FeedService.feedCreateTimeFormatted(withCreatedTime: state.createTime!)
                label.font = .microTheme()
                label.textColor = UIColor.tpDisabledBlackText()
            }
        ])
        
        let shareButton = Node<UIButton>(identifier: "share-button-ipad") { button, layout, _ in
            button.setTitle(" Bagikan", for: .normal)
            button.setImage(#imageLiteral(resourceName: "icon_button_share"), for: .normal)
            button.backgroundColor = .white
            button.cornerRadius = 3.0
            button.titleLabel?.font = .smallThemeSemibold()
            button.setTitleColor(UIColor.tpDisabledBlackText(), for: .normal)
            button.borderWidth = 1
            button.borderColor = UIColor.fromHexString("#e0e0e0")
            
            button.rx.tap
                .subscribe(onNext: {
                    AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: GA_EVENT_ACTION_CLICK, label: "\(state.page).\(state.row) Share - Feed")
                    let title = state.source.shopState.shareDescription
                    let url = state.source.shopState.shareURL
                    
                    let controller = UIActivityViewController.shareDialog(withTitle: title, url: URL(string: url), anchor: button)
                    
                    self.viewController?.present(controller!, animated: true, completion: nil)
                })
                .disposed(by: self.rx_disposeBag)
            
            layout.height = 40.0
            layout.width = 100
            layout.marginRight = 0
        }
        
        let author = Node<UIView>(identifier: "author-header") { _, layout, _ in
            layout.flexDirection = .row
            layout.alignItems = .center
            layout.justifyContent = .spaceBetween
            layout.paddingTop = 16
            layout.paddingBottom = 16
            layout.paddingLeft = 8
            layout.paddingRight = 8
        }.add(children: [
            Node<UIView>(identifier: "author-info-container") { _, layout, _ in
                layout.flexDirection = .row
                layout.alignItems = .center
                layout.flexShrink = 1
            }.add(children: [
                authorImage,
                authorInfo
            ]),
            
            (state.oniPad && !(state.source.fromTokopedia)) ? shareButton : NilNode()
        ])
        
        let horizontalLine = Node<UIView>(identifier: "line") { view, layout, _ in
            layout.height = 1
            
            view.backgroundColor = UIColor.fromHexString("#e0e0e0")
        }
        
        let header = Node<UIView>() { view, layout, size in
            layout.flexDirection = .column
            layout.width = size.width
            
            view.backgroundColor = .white
        }.add(children: [
            author,
            horizontalLine
        ])
        
        return header
    }
    
    private func attributedStringHeader(withActivity activity: FeedCardActivityState, state: FeedCardSourceState) -> NSMutableAttributedString {
        let attString = NSMutableAttributedString()
        
        let bold: [String: Any] = [
            NSFontAttributeName: UIFont.largeThemeSemibold(),
            NSForegroundColorAttributeName: UIColor.tpPrimaryBlackText()
        ]
        let normal: [String: Any] = [
            NSFontAttributeName: UIFont.largeTheme(),
            NSForegroundColorAttributeName: UIColor.tpPrimaryBlackText()
        ]
        
        var badges: NSAttributedString?
        
        if !state.fromTokopedia && (state.shopState.shopIsGold || state.shopState.shopIsOfficial) {
            let attachment = NSTextAttachment()
            
            if state.shopState.shopIsGold {
                attachment.image = UIImage(named: "icon_gold_merchant")
            }
            
            if state.shopState.shopIsOfficial {
                attachment.image = UIImage(named: "icon_official_store")
            }
            
            attachment.bounds = CGRect(x: 0, y: -3, width: (attachment.image?.size.width)!, height: (attachment.image?.size.height)!)
            
            badges = NSAttributedString(attachment: attachment)
        }
        
        if let badge = badges {
            attString.append(badge)
            attString.append(NSAttributedString(string: " ", attributes: bold))
        }
        
        attString.append(NSAttributedString(string: "\(activity.source) ", attributes: bold))
        attString.append(NSAttributedString(string: "\(activity.activity) ", attributes: normal))
        attString.append(NSAttributedString(string: "\(activity.amount) produk", attributes: bold))
        
        return attString
    }
}
