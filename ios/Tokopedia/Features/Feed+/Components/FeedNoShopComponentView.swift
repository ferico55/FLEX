//
//  FeedNoShopComponentView.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 11/24/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render
import RxSwift

class FeedNoShopComponentView: ComponentView<FeedCardFavoriteCTAState> {
    
    private let onPad = UI_USER_INTERFACE_IDIOM() == .pad
    
    override func construct(state: FeedCardFavoriteCTAState?, size: CGSize) -> NodeType {
        if let state = state {
            return self.onPad ? self.padLayout(state: state) : self.phoneLayout(state: state)
        }
        
        return Node<UIView>() { _, _, _ in
            
        }
    }
    
    private func phoneLayout(state: FeedCardFavoriteCTAState) -> NodeType {
        return Node<UIView> { _, layout, size in
            layout.flexDirection = .column
            layout.width = size.width
        }.add(children: [
            Node<UIView>() { view, layout, _ in
                layout.flexDirection = .column
                layout.justifyContent = .center
                layout.alignItems = .center
                
                layout.paddingTop = 22
                layout.paddingLeft = 8
                layout.paddingRight = 8
                layout.paddingBottom = 8
                
                view.backgroundColor = .white
                view.borderWidth = 1
                view.borderColor = .fromHexString("#e0e0e0")
            }.add(children: [
                self.magnifierImage(),
                self.titleLabel(title: state.title),
                self.subtitleLabel(subtitle: state.subtitle),
                self.actionButton()
            ]),
            self.blankSpace()
        ])
    }
    
    private func padLayout(state: FeedCardFavoriteCTAState) -> NodeType {
        return Node<UIView> { _, layout, size in
            layout.flexDirection = .column
            layout.width = size.width
        }.add(children: [
            Node<UIView>() { view, layout, _ in
                layout.flexDirection = .row
                layout.justifyContent = .center
                layout.alignItems = .center
                layout.paddingTop = 18
                layout.paddingBottom = 18
                
                view.backgroundColor = .white
                view.borderWidth = 1
                view.borderColor = .fromHexString("#e0e0e0")
            }.add(children: [
                Node<UIView>() { view, layout, size in
                    view.backgroundColor = .white
                    
                    layout.justifyContent = .center
                    layout.alignItems = .center
                    layout.marginRight = 40
                    }.add(child: self.magnifierImage()),
                Node<UIView>() { view, layout, size in
                    layout.flexDirection = .column
                    layout.justifyContent = .center
                    layout.alignItems = .flexStart
                    layout.marginRight = 10
                    layout.maxWidth = 305
                    
                    view.backgroundColor = .white
                    }.add(children: [
                        self.titleLabel(title: state.title),
                        self.subtitleLabel(subtitle: state.subtitle),
                        self.actionButton()
                        ])
                
            ]),
            self.blankSpace()
        ])
    }
    
    private func blankSpace() -> NodeType {
        return Node<UIView>() { view, layout, size in
            layout.height = 15
            layout.width = size.width
            
            view.backgroundColor = .tpBackground()
        }
    }
    
    private func magnifierImage() -> NodeType {
        return Node<UIImageView>() { view, layout, _ in
            layout.width = self.onPad ? 160 : 131
            layout.height = self.onPad ? 124 : 101
            layout.marginBottom = self.onPad ? 0 : 10
            
            view.image = #imageLiteral(resourceName: "icon_find_shop")
        }
    }
    
    private func titleLabel(title: String) -> NodeType {
        return Node<UILabel>() { label, layout, _ in
            label.text = title
            label.font = .largeThemeSemibold()
            label.textColor = .tpPrimaryBlackText()
            label.numberOfLines = 0
            label.textAlignment = self.onPad ? .left: .center
            
            layout.marginBottom = self.onPad ? 8 : 5
        }
    }
    
    private func subtitleLabel(subtitle: String) -> NodeType {
        return Node<UILabel>() { label, layout, _ in
            label.text = subtitle
            label.font = .microTheme()
            label.textColor = .tpSecondaryBlackText()
            label.numberOfLines = 0
            label.textAlignment = self.onPad ? .left: .center
            
            layout.marginBottom = 16
        }
    }
    
    private func actionButton() -> NodeType {
        return Node<UIButton>() { button, layout, size in
            button.setTitle("Cari Toko", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .tpGreen()
            button.cornerRadius = 3
            button.titleLabel?.font = .smallThemeSemibold()
            
            button.rx.tap
                .subscribe(onNext: {
                    NotificationCenter.default.post(name: Notification.Name("didSwipeHomePage"), object: self, userInfo: ["page": 5])
                })
                .disposed(by: self.rx_disposeBag)
            
            layout.width = self.onPad ? 200 : size.width - 14
            layout.height = 40
        }
    }
}
