//
//  FeedOfficialStoreComponentView.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 7/4/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render
import RxSwift

class FeedOfficialStoreComponentView: ComponentView<FeedCardContentState> {
    override func construct(state: FeedCardContentState?, size: CGSize) -> NodeType {
        guard let state = state, let officialStore = state.officialStore else { return NilNode() }
        
        if officialStore[0].isCampaign {
            return officialStoreCampaign(state: state, size: size)
        } else {
            return officialStoreBrand(state: state, size: size)
        }
    }
    
    private func officialStoreBrand(state: FeedCardContentState?, size: CGSize) -> NodeType {
        guard let state = state, let officialStore = state.officialStore, officialStore.count == 6 else {
            return NilNode()
        }
        
        let titleView = self.titleView(title: "Official Store")
        
        let brandLayout = Node<UIView>(identifier: "brand-layout") { _, layout, size in
            layout.flexDirection = .column
            layout.width = size.width
        }.add(children: [
            self.horizontalLine(withSize: size),
            Node<UIView>(identifier: "main-content") { _, layout, _ in
                layout.flexDirection = .row
                layout.alignItems = .stretch
            }.add(children: [
                self.brandImage(state: state, imageURL: officialStore[0].shopImageURL, shopURL: officialStore[0].shopURL),
                self.verticalLine(withSize: size),
                self.brandImage(state: state, imageURL: officialStore[1].shopImageURL, shopURL: officialStore[1].shopURL),
                self.verticalLine(withSize: size),
                self.brandImage(state: state, imageURL: officialStore[2].shopImageURL, shopURL: officialStore[2].shopURL)
            ]),
            self.horizontalLine(withSize: size),
            Node<UIView>(identifier: "main-content") { _, layout, _ in
                layout.flexDirection = .row
                layout.alignItems = .stretch
            }.add(children: [
                self.brandImage(state: state, imageURL: officialStore[3].shopImageURL, shopURL: officialStore[3].shopURL),
                self.verticalLine(withSize: size),
                self.brandImage(state: state, imageURL: officialStore[4].shopImageURL, shopURL: officialStore[4].shopURL),
                self.verticalLine(withSize: size),
                self.brandImage(state: state, imageURL: officialStore[5].shopImageURL, shopURL: officialStore[5].shopURL)
            ])
        ])
        
        return Node<UIView>() { _, layout, size in
            layout.flexDirection = .column
            layout.width = size.width
        }.add(children: [
            Node<UIView>() { view, layout, size in
                view.borderWidth = 1
                view.borderColor = UIColor.fromHexString("#e0e0e0")
                
                layout.flexDirection = .column
                layout.width = size.width
            }.add(children: [
                titleView,
                brandLayout,
                self.seeAll(redirectURL: officialStore[0].redirectURL, isBrand: true, page: state.page, row: state.row)
            ]),
            Node<UIView>(identifier: "blank-space") { view, layout, size in
                layout.height = 15
                layout.width = size.width
                view.backgroundColor = .tpBackground()
            }
        ])
    }
    
    private func officialStoreCampaign(state: FeedCardContentState?, size: CGSize) -> NodeType {
        guard let state = state, let officialStore = state.officialStore else { return NilNode() }
        
        let campaign = officialStore[0]
        
        let titleView = self.titleView(title: campaign.title)
        
        let campaignBanner = Node<UIView>() { view, _, _ in
            view.backgroundColor = UIColor.fromHexString(campaign.borderHexString)
            
        }.add(child: Node<UIImageView>() { imageView, layout, size in
            layout.width = size.width
            layout.aspectRatio = 3.76
            
            imageView.setImageWith(URL(string: campaign.bannerURL))
            imageView.isUserInteractionEnabled = true
            
            let gestureRecognizer = UITapGestureRecognizer()
            _ = gestureRecognizer.rx.event.subscribe(onNext: { _ in
                AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: GA_EVENT_ACTION_CLICK, label: "\(state.page).\(state.row) Official Store Campaign - Banner")
                TPRoutes.routeURL(URL(string: state.redirectURL)!)
            })
            
            imageView.addGestureRecognizer(gestureRecognizer)
        })
        
        let productsContainer = Node<UIView>() { view, layout, size in
            view.backgroundColor = UIColor.fromHexString(campaign.borderHexString)
            
            layout.width = size.width
            layout.paddingLeft = 10
            layout.paddingRight = 10
            layout.paddingBottom = 16
        }
        
        if campaign.products.count == 4 {
            productsContainer.add(child:
                Node<UIView>() { _, layout, _ in
                    layout.flexDirection = .column
                    layout.alignItems = .stretch
                }.add(children: [
                    self.horizontalLine(withSize: size),
                    Node<UIView>(identifier: "main-content-1") { _, layout, _ in
                        layout.flexDirection = .row
                        layout.alignItems = .stretch
                    }.add(children: [
                        self.verticalLine(withSize: size),
                        ProductCellComponentView().construct(state: campaign.products[0].productDetail, size: size),
                        self.verticalLine(withSize: size),
                        ProductCellComponentView().construct(state: campaign.products[1].productDetail, size: size),
                        self.verticalLine(withSize: size)
                    ]),
                    self.horizontalLine(withSize: size),
                    Node<UIView>(identifier: "main-content-2") { _, layout, _ in
                        layout.flexDirection = .row
                        layout.alignItems = .stretch
                    }.add(children: [
                        self.verticalLine(withSize: size),
                        ProductCellComponentView().construct(state: campaign.products[2].productDetail, size: size),
                        self.verticalLine(withSize: size),
                        ProductCellComponentView().construct(state: campaign.products[3].productDetail, size: size),
                        self.verticalLine(withSize: size)
                    ]),
                    self.seeAll(redirectURL: campaign.redirectURL, isBrand: false, page: state.page, row: state.row)
                ])
            )
        } else if campaign.products.count == 6 {
            productsContainer.add(child:
                Node<UIView>() { _, layout, _ in
                    layout.flexDirection = .column
                    layout.alignItems = .stretch
                }.add(children: [
                    self.horizontalLine(withSize: size),
                    Node<UIView>(identifier: "main-content-1") { view, layout, _ in
                        layout.flexDirection = .row
                        layout.alignItems = .stretch
                        
                        view.backgroundColor = .white
                    }.add(children: [
                        self.verticalLine(withSize: size),
                        ProductCellComponentView().construct(state: campaign.products[0].productDetail, size: size),
                        self.verticalLine(withSize: size),
                        ProductCellComponentView().construct(state: campaign.products[1].productDetail, size: size),
                        self.verticalLine(withSize: size),
                        ProductCellComponentView().construct(state: campaign.products[2].productDetail, size: size),
                        self.verticalLine(withSize: size)
                    ]),
                    self.horizontalLine(withSize: size),
                    Node<UIView>(identifier: "main-content-2") { view, layout, _ in
                        layout.flexDirection = .row
                        layout.alignItems = .stretch
                        
                        view.backgroundColor = .white
                    }.add(children: [
                        self.verticalLine(withSize: size),
                        ProductCellComponentView().construct(state: campaign.products[3].productDetail, size: size),
                        self.verticalLine(withSize: size),
                        ProductCellComponentView().construct(state: campaign.products[4].productDetail, size: size),
                        self.verticalLine(withSize: size),
                        ProductCellComponentView().construct(state: campaign.products[5].productDetail, size: size),
                        self.verticalLine(withSize: size)
                    ]),
                    self.seeAll(redirectURL: campaign.redirectURL, isBrand: false, page: state.page, row: state.row)
                ])
            )
        }
        
        return Node<UIView>() { _, layout, _ in
            layout.flexDirection = .column
        }.add(children: [
            Node<UIView>() { view, layout, _ in
                view.borderColor = UIColor.fromHexString("#e0e0e0")
                view.borderWidth = 1
                
                layout.flexDirection = .column
            }.add(children: [
                titleView,
                self.horizontalLine(withSize: size),
                campaignBanner,
                productsContainer
            ]),
            Node<UIView>(identifier: "blank-space") { view, layout, size in
                layout.height = 15
                layout.width = size.width
                view.backgroundColor = .tpBackground()
            }
        ])
    }
    
    private func titleView(title: String) -> NodeType {
        return Node<UIView>(identifier: "title-view") { view, layout, size in
            view.backgroundColor = .white
            
            layout.width = size.width
        }.add(child: Node<UILabel>(identifier: "title-label") { label, layout, _ in
            label.text = title
            label.font = .largeThemeSemibold()
            label.textColor = UIColor.tpPrimaryBlackText()
            
            layout.marginLeft = 10
            layout.marginTop = 16
            layout.marginBottom = 16
        })
    }
    
    private func brandImage(state: FeedCardContentState, imageURL: String, shopURL: String) -> NodeType {
        return Node<UIView>() { view, layout, _ in
            layout.flexShrink = 1
            layout.flexGrow = 1
            layout.justifyContent = .center
            layout.alignItems = .center
            layout.padding = 5
            layout.height = 100
            layout.flexBasis = 1
            
            view.backgroundColor = .white
            view.bk_(whenTapped: {
                AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: GA_EVENT_ACTION_CLICK, label: "\(state.page).\(state.row) Official Store Brand - Shop")
                TPRoutes.routeURL(URL(string: shopURL)!)
            })
            view.contentMode = .scaleAspectFit
        }.add(child:
            Node<UIImageView>(identifier: "brand-image") { view, _, _ in
                view.setImageWith(URL(string: imageURL), placeholderImage: #imageLiteral(resourceName: "grey-bg"))
                view.contentMode = .scaleAspectFit
        })
    }
    
    private func seeAll(redirectURL: String, isBrand: Bool, page:Int, row:Int) -> NodeType {
        let cont = Node<UIView>() { view, layout, _ in
            view.backgroundColor = .white
            view.borderWidth = 1
            view.borderColor = UIColor.fromHexString("#e0e0e0")
            
            layout.flexDirection = .row
            layout.justifyContent = .flexEnd
            layout.alignItems = .center
            layout.height = 45
            
        }.add(children: [
            Node<UIButton>() { button, layout, _ in
                button.setTitle("Lihat Semua", for: .normal)
                button.backgroundColor = .white
                button.titleLabel?.font = .smallThemeSemibold()
                button.setTitleColor(.tpGreen(), for: .normal)
                
                layout.width = 94
                layout.marginRight = 10
                
                button.bk_(whenTapped: { [weak self] in
                    if isBrand {
                        AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: GA_EVENT_ACTION_CLICK, label: "\(page).\(row) Official Store Brand - Lihat Semua")
                    } else {
                        AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: GA_EVENT_ACTION_CLICK, label: "\(page).\(row) Official Store Campaign - Lihat Semua")
                    }
                    TPRoutes.routeURL(URL(string: redirectURL)!)
                })
            },
            Node<UIImageView>(identifier: "arrow") { view, layout, _ in
                view.image = #imageLiteral(resourceName: "icon_forward")
                view.tintColor = .tpGreen()
                
                layout.height = 16
                layout.width = 10
                layout.right = 10
            }
        ])
        
        return cont
    }
    
    private func horizontalLine(withSize size: CGSize) -> NodeType {
        return Node<UIView>(identifier: "line") { view, layout, _ in
            layout.height = 1
            
            view.backgroundColor = UIColor.fromHexString("#e0e0e0")
        }
    }
    
    private func verticalLine(withSize size: CGSize) -> NodeType {
        return Node<UIView>(identifier: "line") { view, layout, _ in
            layout.width = 1
            
            view.backgroundColor = UIColor.fromHexString("#e0e0e0")
        }
    }
}
