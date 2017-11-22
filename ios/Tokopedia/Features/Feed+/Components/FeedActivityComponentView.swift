//
//  FeedActivityComponentView.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 10/31/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render
import RxSwift

class FeedActivityComponentView: ComponentView<FeedCardState> {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func construct(state: FeedCardState?, size: CGSize) -> NodeType {
        return self.activityCard(state: state, size: size)
    }
    
    private func activityCard(state: FeedCardState?, size: CGSize) -> NodeType {
        guard let state = state, let vc = self.viewController else {
            return Node<UIView> { _, _, _ in
                
            }
        }
        
        let feedContent: NodeType = self.productCellLayout(state: state, size: size)
        
        let card = Node<UIView> { view, layout, _ in
            layout.flexDirection = .column
            layout.alignItems = .stretch
            layout.flexShrink = 1
            layout.flexGrow = 1
            
            view.borderColor = UIColor.fromHexString("#e0e0e0")
            view.borderWidth = 1
        }.add(children: [
            FeedHeaderComponentView(viewController: vc).construct(state: state, size: size),
            feedContent,
            state.oniPad ? NilNode() : self.shareButton(withSize: size)
        ])
        
        return Node<UIView> { _, layout, _ in
            layout.flexDirection = .row
            layout.maxWidth = 560
            layout.alignItems = .stretch
            
        }.add(children: [
            Node<UIView> { _, layout, _ in
                layout.flexDirection = .column
                layout.alignItems = .stretch
                layout.flexShrink = 1
                layout.flexGrow = 1
                
            }.add(children: [
                card,
                Node<UIView>(identifier: "blank-space") { view, layout, size in
                    layout.height = 15
                    layout.width = size.width
                    view.backgroundColor = .tpBackground()
                }
            ])
        ])
    }
    
    private func productCellLayout(state: FeedCardState, size: CGSize) -> NodeType {
        let amount = state.content.product.count
        
        if amount > 0 {
            let mainContent: NodeType = Node<UIView>(identifier: "main-content") { _, layout, size in
                layout.flexDirection = .column
                layout.width = size.width
            }
            
            if amount == 1 {
                mainContent.add(children: [
                    Node<UIView>(identifier: "main-content") { _, layout, _ in
                        layout.flexDirection = .row
                    }.add(children: [
                        ProductCellComponentView().construct(state: state.content.product[0], size: size)
                    ]),
                    self.horizontalLine(withSize: size)
                ])
            } else if amount == 2 {
                mainContent.add(children: [
                    Node<UIView>(identifier: "main-content") { _, layout, _ in
                        layout.flexDirection = .row
                    }.add(children: [
                        ProductCellComponentView().construct(state: state.content.product[0], size: size),
                        self.verticalLine(withSize: size),
                        ProductCellComponentView().construct(state: state.content.product[1], size: size)
                    ]),
                    self.horizontalLine(withSize: size)
                ])
            } else if amount == 3 {
                mainContent.add(children: [
                    Node<UIView>(identifier: "main-content") { _, layout, _ in
                        layout.flexDirection = .row
                    }.add(children: [
                        ProductCellComponentView().construct(state: state.content.product[0], size: size),
                        self.verticalLine(withSize: size),
                        ProductCellComponentView().construct(state: state.content.product[1], size: size),
                        self.verticalLine(withSize: size),
                        ProductCellComponentView().construct(state: state.content.product[2], size: size)
                    ]),
                    self.horizontalLine(withSize: size)
                ])
            } else if amount == 4 {
                mainContent.add(children: [
                    Node<UIView>(identifier: "main-content") { _, layout, _ in
                        layout.flexDirection = .row
                    }.add(children: [
                        ProductCellComponentView().construct(state: state.content.product[0], size: size),
                        self.verticalLine(withSize: size),
                        ProductCellComponentView().construct(state: state.content.product[1], size: size)
                    ]),
                    self.horizontalLine(withSize: size),
                    Node<UIView>(identifier: "main-content") { _, layout, _ in
                        layout.flexDirection = .row
                    }.add(children: [
                        ProductCellComponentView().construct(state: state.content.product[2], size: size),
                        self.verticalLine(withSize: size),
                        ProductCellComponentView().construct(state: state.content.product[3], size: size)
                    ]),
                    self.horizontalLine(withSize: size)
                ])
            } else if amount == 5 {
                mainContent.add(children: [
                    Node<UIView>(identifier: "main-content") { _, layout, _ in
                        layout.flexDirection = .row
                    }.add(children: [
                        ProductCellComponentView().construct(state: state.content.product[0], size: size),
                        self.verticalLine(withSize: size),
                        ProductCellComponentView().construct(state: state.content.product[1], size: size)
                    ]),
                    self.horizontalLine(withSize: size),
                    Node<UIView>(identifier: "main-content") { _, layout, _ in
                        layout.flexDirection = .row
                    }.add(children: [
                        ProductCellComponentView().construct(state: state.content.product[2], size: size),
                        self.verticalLine(withSize: size),
                        ProductCellComponentView().construct(state: state.content.product[3], size: size),
                        self.verticalLine(withSize: size),
                        ProductCellComponentView().construct(state: state.content.product[4], size: size)
                    ]),
                    self.horizontalLine(withSize: size)
                ])
            } else if amount > 5 {
                mainContent.add(children: [
                    Node<UIView>(identifier: "main-content") { _, layout, _ in
                        layout.flexDirection = .row
                    }.add(children: [
                        ProductCellComponentView().construct(state: state.content.product[0], size: size),
                        self.verticalLine(withSize: size),
                        ProductCellComponentView().construct(state: state.content.product[1], size: size),
                        self.verticalLine(withSize: size),
                        ProductCellComponentView().construct(state: state.content.product[2], size: size)
                    ]),
                    self.horizontalLine(withSize: size),
                    Node<UIView>(identifier: "main-content") { _, layout, _ in
                        layout.flexDirection = .row
                    }.add(children: [
                        ProductCellComponentView().construct(state: state.content.product[3], size: size),
                        self.verticalLine(withSize: size),
                        ProductCellComponentView().construct(state: state.content.product[4], size: size),
                        self.verticalLine(withSize: size),
                        ProductCellComponentView().construct(state: state.content.product[5], size: size)
                    ]),
                    self.horizontalLine(withSize: size)
                ])
            }
            
            return mainContent
        }
        
        return Node<UIView>() { _, _, _ in
            
        }
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
    
    private func shareButton(withSize size: CGSize) -> NodeType {
        guard let state = state else { return NilNode() }
        
        return Node<UIView>(identifier: "share-button-view") { _, layout, size in
            layout.flexDirection = .column
            layout.width = size.width
        }.add(children: [
            Node<UIButton>(identifier: "share-button") { button, layout, _ in
                button.setTitle(" Bagikan", for: .normal)
                button.setImage(#imageLiteral(resourceName: "icon_button_share"), for: .normal)
                button.backgroundColor = .white
                button.cornerRadius = 5.0
                button.titleLabel?.font = .smallThemeSemibold()
                button.setTitleColor(UIColor.tpDisabledBlackText(), for: .normal)
                
                button.rx.tap
                    .subscribe(onNext: { [weak self] in
                        AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: GA_EVENT_ACTION_CLICK, label: "Share - Feed")
                        if let viewController = UIApplication.topViewController() {
                            ReferralManager().share(object: state.source.shopState, from: viewController, anchor: button)
                        }
                    })
                    .disposed(by: self.rx_disposeBag)
                
                layout.height = 52.0
            }
        ])
    }
}
