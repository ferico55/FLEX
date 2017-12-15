//
//  FeedInspirationComponentView.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 6/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render
import RxSwift

class FeedInspirationComponentView: ComponentView<FeedCardInspirationState> {
    override func construct(state: FeedCardInspirationState?, size: CGSize) -> NodeType {
        guard let state = state else {
            return Node<UIView>() { _, _, _ in
                
            }
        }
        
        return self.inspirationCard(state: state, size: size)
    }
    
    private func inspirationCard(state: FeedCardInspirationState, size: CGSize) -> NodeType {
        let titleView = state.title == "" ? NilNode() : Node<UIView>(identifier: "title-view") { view, layout, size in
            view.backgroundColor = .white
            
            layout.width = size.width
        }
        .add(child: Node<UILabel>(identifier: "title") { label, layout, _ in
            label.text = state.title
            label.font = .largeThemeSemibold()
            label.textColor = UIColor.tpPrimaryBlackText()
            
            layout.marginLeft = 10
            layout.marginTop = 16
            layout.marginBottom = 16
        })
        
        let card = Node<UIView>(identifier: "inspiration-card") { _, layout, _ in
            layout.flexDirection = .column
            layout.alignItems = .stretch
            layout.flexShrink = 1
            layout.flexGrow = 1
        }.add(children: [
            Node<UIView>() { view, layout, _ in
                view.borderWidth = 1
                view.borderColor = UIColor.fromHexString("#e0e0e0")
                
                layout.flexDirection = .column
                layout.alignItems = .stretch
                layout.flexShrink = 1
                layout.flexGrow = 1
            }.add(children: [
                titleView,
                self.horizontalLine(),
                self.productCellLayout(state: state, size: size)
            ]),
            Node<UIView>(identifier: "blank-space") { view, layout, size in
                layout.height = 15
                layout.width = size.width
                view.backgroundColor = .tpBackground()
            }
        ])
        
        return card
    }
    
    private func productCellLayout(state: FeedCardInspirationState, size: CGSize) -> NodeType {
        let mainContent: NodeType = Node<UIView>(identifier: "main-content") { _, layout, size in
            layout.flexDirection = .column
            layout.width = size.width
        }
        
        if state.onPad {
            mainContent.add(children: [
                Node<UIView>(identifier: "main-content") { _, layout, _ in
                    layout.flexDirection = .row
                }.add(children: [
                    ProductCellComponentView().construct(state: state.products[0], size: size),
                    self.verticalLine(),
                    ProductCellComponentView().construct(state: state.products[1], size: size),
                    self.verticalLine(),
                    ProductCellComponentView().construct(state: state.products[2], size: size)
                ]),
                self.horizontalLine(),
                Node<UIView>(identifier: "main-content") { _, layout, _ in
                    layout.flexDirection = .row
                }.add(children: [
                    ProductCellComponentView().construct(state: state.products[3], size: size),
                    self.verticalLine(),
                    ProductCellComponentView().construct(state: state.products[4], size: size),
                    self.verticalLine(),
                    ProductCellComponentView().construct(state: state.products[5], size: size)
                ])
            ])
        } else {
            mainContent.add(children: [
                Node<UIView>(identifier: "main-content") { _, layout, _ in
                    layout.flexDirection = .row
                }.add(children: [
                    ProductCellComponentView().construct(state: state.products[0], size: size),
                    self.verticalLine(),
                    ProductCellComponentView().construct(state: state.products[1], size: size)
                ]),
                self.horizontalLine(),
                Node<UIView>(identifier: "main-content") { _, layout, _ in
                    layout.flexDirection = .row
                }.add(children: [
                    ProductCellComponentView().construct(state: state.products[2], size: size),
                    self.verticalLine(),
                    ProductCellComponentView().construct(state: state.products[3], size: size)
                ])
            ])
        }
        
        return mainContent
    }
    
    private func horizontalLine() -> NodeType {
        return Node<UIView>(identifier: "line") { view, layout, _ in
            layout.height = 1
            
            view.backgroundColor = UIColor.fromHexString("#e0e0e0")
        }
    }
    
    private func verticalLine() -> NodeType {
        return Node<UIView>(identifier: "line") { view, layout, _ in
            layout.width = 1
            
            view.backgroundColor = UIColor.fromHexString("#e0e0e0")
        }
    }
}
