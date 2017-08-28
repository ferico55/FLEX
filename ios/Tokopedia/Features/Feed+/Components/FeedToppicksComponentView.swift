//
//  FeedToppicksComponentView.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 8/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render
import RxSwift

class FeedToppicksComponentView: ComponentView<FeedCardContentState> {
    override func construct(state: FeedCardContentState?, size: CGSize) -> NodeType {
        guard let state = state, let toppicks = state.toppicks else { return NilNode() }
        
        if toppicks.count == 4 {
            return phoneLayout(state: state, size: size)
        }
        
        return padLayout(state: state, size: size)
    }
    
    private func phoneLayout(state: FeedCardContentState, size: CGSize) -> NodeType {
        guard let toppicks = state.toppicks, toppicks.count == 4 else {
            return NilNode()
        }
        
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
                self.titleView(),
                self.phoneItemLayout(toppicks: toppicks, size: size),
                self.seeAll()
            ]),
            self.blankSpace()
        ])
    }
    
    private func padLayout(state: FeedCardContentState, size: CGSize) -> NodeType {
        guard let toppicks = state.toppicks, toppicks.count == 5 else {
            return NilNode()
        }
        
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
                self.titleView(),
                self.horizontalLine(size: size),
                self.padItemLayout(toppicks: toppicks, size: size),
                self.seeAll()
            ]),
            self.blankSpace()
        ])
    }
    
    private func titleView() -> NodeType {
        return Node<UIView>(identifier: "title-view") { view, layout, size in
            view.backgroundColor = .white
            
            layout.width = size.width
        }.add(child: Node<UILabel>(identifier: "title-label") { label, layout, _ in
            label.text = "Top Picks"
            label.font = .largeThemeSemibold()
            label.textColor = UIColor.tpPrimaryBlackText()
            
            layout.marginLeft = 10
            layout.marginTop = 16
            layout.marginBottom = 16
        })
    }
    
    private func phoneItemLayout(toppicks: [FeedCardToppicksState], size: CGSize) -> NodeType {
        return Node<UIView>(identifier: "phone-item-layout") { _, layout, size in
            layout.flexDirection = .column
            layout.width = size.width
        }.add(children: [
            self.horizontalLine(size: size),
            Node<UIView>(identifier: "main-content") { _, layout, _ in
                layout.flexDirection = .row
                layout.alignItems = .stretch
            }.add(children: [
                self.phoneItem(state: toppicks[0]),
                self.verticalLine(size: size),
                self.phoneItem(state: toppicks[1])
            ]),
            self.horizontalLine(size: size),
            Node<UIView>(identifier: "main-content") { _, layout, _ in
                layout.flexDirection = .row
                layout.alignItems = .stretch
            }.add(children: [
                self.phoneItem(state: toppicks[2]),
                self.verticalLine(size: size),
                self.phoneItem(state: toppicks[3])
            ])
        ])
    }
    
    private func padItemLayout(toppicks: [FeedCardToppicksState], size: CGSize) -> NodeType {
        return Node<UIView>(identifier: "pad-item-layout") { _, layout, size in
            layout.padding = 6
            layout.height = 272
            layout.flexDirection = .row
            layout.width = size.width
        }.add(children: [
            self.padItem(state: toppicks[0]),
            Node<UIView>(identifier: "grid-layout") { _, layout, _ in
                layout.flexDirection = .column
            }.add(children: [
                Node<UIView>(identifier: "first-row") { _, layout, _ in
                    layout.flexDirection = .row
                }.add(children: [
                    self.padItem(state: toppicks[1]),
                    self.padItem(state: toppicks[2])
                ]),
                Node<UIView>(identifier: "second-row") { _, layout, _ in
                    layout.flexDirection = .row
                }.add(children: [
                    self.padItem(state: toppicks[3]),
                    self.padItem(state: toppicks[4])
                ])
            ])
        ])
    }
    
    private func phoneItem(state: FeedCardToppicksState) -> NodeType {
        return Node<UIView>(identifier: "small-cell") { view, layout, _ in
            view.backgroundColor = .white
            
            layout.flexGrow = 1
            layout.flexShrink = 1
            layout.flexBasis = 1
            layout.padding = 5
            layout.aspectRatio = 1
        }.add(child: Node<UIImageView>(identifier: "phone-toppick-item") { imageView, layout, _ in
            imageView.setImageWith(URL(string: state.imageURL), placeholderImage: #imageLiteral(resourceName: "grey-bg.png"))
            imageView.contentMode = .scaleAspectFit
            imageView.isUserInteractionEnabled = true
            
            let gestureRecognizer = UITapGestureRecognizer()
            gestureRecognizer.rx.event.subscribe(onNext: { _ in
                guard let urlString = URL(string: state.redirectURL) else { return }
                AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: GA_EVENT_ACTION_CLICK, label: "Toppicks - \(state.name)")
                TPRoutes.routeURL(urlString)
            }).disposed(by: self.rx_disposeBag)
            
            imageView.addGestureRecognizer(gestureRecognizer)
            
            layout.aspectRatio = 1
        })
    }
    
    private func padItem(state: FeedCardToppicksState) -> NodeType {
        return Node<UIView>(identifier: "cell") { view, layout, _ in
            view.backgroundColor = .white
            
            layout.flexGrow = 1
            layout.flexShrink = 1
            layout.padding = 4
            
            if !state.isParent {
                layout.width = 130
                layout.aspectRatio = 1
            }
        }.add(child: Node<UIImageView>(identifier: "phone-toppick-item") { imageView, layout, _ in
            imageView.setImageWith(URL(string: state.imageURL), placeholderImage: #imageLiteral(resourceName: "grey-bg.png"))
            imageView.contentMode = state.isParent ? .scaleAspectFill : .scaleAspectFit
            imageView.isUserInteractionEnabled = true
            imageView.cornerRadius = 3
            imageView.clipsToBounds = true
            
            let gestureRecognizer = UITapGestureRecognizer()
            gestureRecognizer.rx.event.subscribe(onNext: { _ in
                guard let urlString = URL(string: state.redirectURL) else { return }
                AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: GA_EVENT_ACTION_CLICK, label: "Toppicks - \(state.name)")
                TPRoutes.routeURL(urlString)
            }).disposed(by: self.rx_disposeBag)
            
            imageView.addGestureRecognizer(gestureRecognizer)
            
            if !state.isParent {
                layout.aspectRatio = 1
            }
            
            layout.flexGrow = 1
            layout.flexShrink = 1
        })
    }
    
    private func seeAll() -> NodeType {
        return Node<UIView>() { view, layout, _ in
            view.backgroundColor = .white
            view.borderWidth = 1
            view.borderColor = UIColor.fromHexString("#e0e0e0")
            
            layout.flexDirection = .row
            layout.justifyContent = .flexEnd
            layout.alignItems = .center
            layout.paddingTop = 11
            layout.paddingBottom = 11
            
        }.add(children: [
            Node<UIButton>() { button, layout, _ in
                button.setTitle("Lihat Semua", for: .normal)
                button.backgroundColor = .white
                button.titleLabel?.font = .smallThemeSemibold()
                button.setTitleColor(.tpGreen(), for: .normal)
                
                layout.width = 94
                layout.marginRight = 10
                
                button.bk_(whenTapped: {
                    AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: GA_EVENT_ACTION_CLICK, label: "Toppicks - Lihat Semua")
                    TPRoutes.routeURL(URL(string: "tokopedia://toppicks")!)
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
    }
    
    private func blankSpace() -> NodeType {
        return Node<UIView>(identifier: "blank-space") { view, layout, size in
            layout.height = 15
            layout.width = size.width
            
            view.backgroundColor = .tpBackground()
        }
    }
    
    private func horizontalLine(size: CGSize) -> NodeType {
        return Node<UIView>(identifier: "horizontal-line") { view, layout, _ in
            layout.height = 1
            
            view.backgroundColor = UIColor.fromHexString("#e0e0e0")
        }
    }
    
    private func verticalLine(size: CGSize) -> NodeType {
        return Node<UIView>(identifier: "vertical-line") { view, layout, _ in
            layout.width = 1
            
            view.backgroundColor = UIColor.fromHexString("#e0e0e0")
        }
    }
}
