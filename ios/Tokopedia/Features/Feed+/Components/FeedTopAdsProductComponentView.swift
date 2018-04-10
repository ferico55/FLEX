//
//  FeedTopAdsProductComponentView.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 1/30/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Render
import UIKit

internal class FeedTopAdsProductComponentView: ComponentView<FeedCardTopAdsState> {
    
    override internal func construct(state: FeedCardTopAdsState?, size: CGSize) -> NodeType {
        if let state = state {
            return self.componentContainer(state: state, size: size)
        }
        
        return Node<UIView>() { _, _, _ in
            
        }
    }
    
    private func componentContainer(state: FeedCardTopAdsState, size: CGSize) -> NodeType {
        return Node<UIView>() { view, layout, size in
            view.backgroundColor = .tpBackground()
            layout.flexDirection = .column
            layout.width = size.width
        }.add(children: [
            Node<UIView>() { view, layout, size in
                layout.flexDirection = .column
                layout.width = size.width
                
                view.borderWidth = 1
                view.borderColor = #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1)
                view.backgroundColor = .white
            }.add(children: [
                self.titleView(),
                state.onPad ? self.iPadLayout(state: state, size: size) : self.iPhoneLayout(state: state, size: size)
            ]),
            self.blankSpace(),
        ])
    }
    
    private func titleView() -> NodeType {
        return Node<UIView>() { view, layout, size in
            view.backgroundColor = .white
            view.isUserInteractionEnabled = true
            view.bk_(whenTapped: {
                let alertController = TopAdsInfoActionSheet()
                alertController.show()
            })
            
            layout.width = size.width
            layout.flexDirection = .row
            layout.paddingVertical = 16
        }.add(children: [
            Node<UILabel>() { label, layout, _ in
                label.text = "Promoted"
                label.font = .microTheme()
                label.textColor = .tpDisabledBlackText()
                
                layout.marginLeft = 10
                layout.marginRight = 4
            },
            Node<UIImageView>() { view, layout, _ in
                view.contentMode = .center
                view.image = #imageLiteral(resourceName: "icon_info_grey")
                view.backgroundColor = .clear
                
                layout.width = 16
                layout.height = 16
            },
        ])
    }
    
    private func iPhoneLayout(state: FeedCardTopAdsState, size: CGSize) -> NodeType {
        return Node<UIView>() { _, layout, size in
            layout.flexDirection = .column
            layout.width = size.width
        }.add(children: [
            self.horizontalLine(),
            Node<UIView>() { _, layout, _ in
                layout.flexDirection = .row
            }.add(children: [
                ProductCellComponentView().construct(state: state.products[0], size: size),
                self.verticalLine(),
                ProductCellComponentView().construct(state: state.products[1], size: size),
            ]),
            self.horizontalLine(),
            Node<UIView>() { _, layout, _ in
                layout.flexDirection = .row
            }.add(children: [
                ProductCellComponentView().construct(state: state.products[2], size: size),
                self.verticalLine(),
                ProductCellComponentView().construct(state: state.products[3], size: size),
            ]),
        ])
    }
    
    private func iPadLayout(state: FeedCardTopAdsState, size: CGSize) -> NodeType {
        return Node<UIView>() { _, layout, size in
            layout.flexDirection = .column
            layout.width = size.width
            }.add(children: [
                self.horizontalLine(),
                Node<UIView>() { _, layout, _ in
                    layout.flexDirection = .row
                    }.add(children: [
                        ProductCellComponentView().construct(state: state.products[0], size: size),
                        self.verticalLine(),
                        ProductCellComponentView().construct(state: state.products[1], size: size),
                        self.verticalLine(),
                        ProductCellComponentView().construct(state: state.products[2], size: size),
                        ]),
                self.horizontalLine(),
                Node<UIView>() { _, layout, _ in
                    layout.flexDirection = .row
                    }.add(children: [
                        ProductCellComponentView().construct(state: state.products[3], size: size),
                        self.verticalLine(),
                        ProductCellComponentView().construct(state: state.products[4], size: size),
                        self.verticalLine(),
                        ProductCellComponentView().construct(state: state.products[5], size: size),
                        ]),
                ])
    }
    
    private func horizontalLine() -> NodeType {
        return Node<UIView>() { view, layout, _ in
            layout.height = 1
            
            view.backgroundColor = .fromHexString("#e0e0e0")
        }
    }
    
    private func verticalLine() -> NodeType {
        return Node<UIView>() { view, layout, _ in
            layout.width = 1
            
            view.backgroundColor = .fromHexString("#e0e0e0")
        }
    }
    
    private func blankSpace() -> NodeType {
        return Node<UIView>(identifier: "blank-space") { view, layout, size in
            layout.height = 15
            layout.width = size.width
            
            view.backgroundColor = .tpBackground()
        }
    }
}
