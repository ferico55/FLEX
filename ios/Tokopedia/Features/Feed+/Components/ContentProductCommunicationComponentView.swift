//
//  ContentProductCommunicationComponentView.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 12/29/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render
import RxSwift

class ContentProductCommunicationComponentView: ComponentView<FeedCardContentProductCommunicationState> {
    private let onPad = UI_USER_INTERFACE_IDIOM() == .pad
    
    override func construct(state: FeedCardContentProductCommunicationState?, size: CGSize) -> NodeType {
        guard let state = state else {
            return Node<UIView>() { _, _, _ in
                
            }
        }
        
        return self.componentContainer(state: state, size: size)
    }
    
    private func componentContainer(state: FeedCardContentProductCommunicationState, size: CGSize) -> NodeType {
        return Node<UIView>() { view, layout, size in
            view.backgroundColor = .tpBackground()
            
            layout.flexDirection = .column
            layout.width = size.width
        }.add(children: [
            Node<UIView>() { view, layout, size in
                layout.flexDirection = .column
                layout.width = size.width
                
                view.borderWidth = 1
                view.borderColor = .fromHexString("#e0e0e0")
                view.backgroundColor = .white
            }.add(children: [
                self.bannerImage(imageURL: state.imageURL),
                self.titleView(text: state.title),
                self.contentView(text: state.description),
                self.buttonView(title: state.buttonTitle, url: state.redirectURL),
            ]),
            self.blankSpace(),
        ])
    }
    
    private func bannerImage(imageURL: String) -> NodeType {
        if imageURL == "" {
            return NilNode()
        }
        
        return Node<UIImageView>() { view, layout, _ in
            layout.width = (UI_USER_INTERFACE_IDIOM() == .pad) ? 560 : UIScreen.main.bounds.width
            
            view.contentMode = .scaleAspectFit
            view.setImageWith(URL(string: imageURL), placeholderImage: #imageLiteral(resourceName: "grey-bg"))
            view.isUserInteractionEnabled = true
            
            if let url = URL(string: imageURL) {
                do {
                    let imageData = try Data(contentsOf: url)
                    if let image = UIImage(data: imageData) {
                        let width = image.size.width
                        let height = image.size.height
                        
                        if height != 0 {
                            let aspectRatio = width / height
                            
                            layout.height = layout.width / aspectRatio
                        }
                    }
                } catch {
                    print("Unable to load data: \(error)")
                }
            }
        }
    }
    
    private func titleView(text: String) -> NodeType {
        if text == "" {
            return NilNode()
        }
        
        return Node<UIView>() { view, layout, size in
            view.backgroundColor = .white
            
            layout.width = size.width
            layout.alignItems = .center
            layout.justifyContent = .center
            
            layout.marginTop = 16
            layout.marginBottom = 8
        }.add(child: Node<UILabel>() { label, _, _ in
            label.text = text
            label.font = self.onPad ? .semiboldSystemFont(ofSize: 16) : .largeThemeSemibold()
            label.textColor = .tpPrimaryBlackText()
            label.textAlignment = .center
            label.numberOfLines = 0
        })
    }
    
    private func contentView(text: String) -> NodeType {
        if text == "" {
            return NilNode()
        }
        
        return Node<UIView>() { view, layout, size in
            view.backgroundColor = .white
            
            layout.width = size.width
            layout.alignItems = .center
            layout.justifyContent = .center
            
            layout.marginBottom = 16
            layout.paddingRight = 24
            layout.paddingLeft = 24
        }.add(child: Node<UILabel>() { label, _, _ in
            label.text = text
            label.font = self.onPad ? .largeTheme() : .microTheme()
            label.textColor = .tpSecondaryBlackText()
            label.textAlignment = .center
            label.numberOfLines = 0
        })
    }
    
    private func buttonView(title: String, url: String) -> NodeType {
        if title == "" || url == "" {
            return NilNode()
        }
        
        return Node<UIView>() { view, layout, size in
            view.backgroundColor = .white
            
            layout.width = size.width
            layout.alignItems = .center
            layout.justifyContent = .center
            
            layout.marginTop = 0
            layout.marginBottom = 16
        }.add(child: Node<UIButton>() { button, layout, _ in
            button.setTitle(title, for: .normal)
            button.backgroundColor = .tpGreen()
            button.titleLabel?.font = .smallThemeMedium()
            button.setTitleColor(.white, for: .normal)
            button.cornerRadius = 3
            button.rx.tap
                .subscribe(onNext: {
                    if let redirectURL = URL(string: url) {
                        TPRoutes.routeURL(redirectURL)
                    }
                })
                .disposed(by: self.rx_disposeBag)
            
            layout.height = self.onPad ? 40 : 32
            layout.width = self.onPad ? 200 : 110
        })
    }
    
    private func blankSpace() -> NodeType {
        return Node<UIView>(identifier: "blank-space") { view, layout, size in
            layout.height = 15
            layout.width = size.width
            
            view.backgroundColor = .tpBackground()
        }
    }
}
