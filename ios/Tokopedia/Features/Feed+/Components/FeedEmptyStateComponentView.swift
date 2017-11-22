//
//  FeedEmptyStateComponentView.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 10/31/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render
import RxSwift
import Lottie

class FeedEmptyStateComponentView: ComponentView<FeedCardState> {
    private var onButtonPressed: ((FeedErrorType) -> Void)
    
    init(onButtonPressed: @escaping ((FeedErrorType) -> Void)) {
        self.onButtonPressed = onButtonPressed
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func construct(state: FeedCardState?, size: CGSize) -> NodeType {
        guard let state = state else {
            return Node<UIView> { _, _, _ in
                
            }
        }
        
        let cactusImage = Node<UIView>(identifier: "empty-state-image") { view, layout, _ in
            view.backgroundColor = .clear
            
            layout.alignSelf = .center
            layout.width = state.oniPad ? 202 : 161
            layout.height = state.oniPad ? 125 : 100
            
            if !(state.oniPad) {
                layout.marginTop = 30
                layout.marginBottom = 12
            }
            
            let animationView = LOTAnimationView(name: "FeedEmptyState")
            animationView.loopAnimation = true
            animationView.frame.size = CGSize(width: state.oniPad ? 202 : 161, height: state.oniPad ? 125 : 100)
            animationView.contentMode = .scaleAspectFill
            animationView.backgroundColor = .clear
            
            view.addSubview(animationView)
            
            animationView.play(completion: { _ in
                
            })
        }
        
        let title = Node<UILabel>(identifier: "empty-state-title") { label, layout, _ in
            layout.flexShrink = 1
            layout.marginBottom = 12
            layout.alignSelf = state.oniPad ? .flexStart : .center
            
            label.text = (state.errorType == .emptyFeed) ? "Oops, Feed masih kosong" : "Oops!"
            label.font = UIFont.boldSystemFont(ofSize: 16.0)
            label.textColor = UIColor.tpSecondaryBlackText()
            label.textAlignment = .center
            label.numberOfLines = 0
        }
        
        let desc = Node<UILabel>(identifier: "empty-state-desc") { label, layout, _ in
            layout.flexShrink = 1
            layout.marginBottom = 25
            layout.alignSelf = state.oniPad ? .flexStart : .center
            
            if !(state.oniPad) {
                layout.maxWidth = 262
            }
            
            label.text = (state.errorType == .emptyFeed) ? "Segera favoritkan toko yang Anda sukai untuk mendapatkan update produk terbaru di sini." : "Mohon maaf terjadi kendala pada server.\nSilakan coba lagi."
            label.font = .largeTheme()
            label.textColor = UIColor.tpDisabledBlackText()
            label.textAlignment = state.oniPad ? .left : .center
            label.numberOfLines = 0
        }
        
        let button = Node<UIButton>(identifier: "action-button") { button, layout, _ in
            button.setTitle((state.errorType == .emptyFeed) ? "Cari Toko" : "Coba Lagi", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = .smallThemeSemibold()
            button.backgroundColor = .tpGreen()
            button.cornerRadius = 3
            button.isEnabled = !(state.refreshButtonIsLoading)
            
            button.rx.tap
                .subscribe(onNext: {
                    self.onButtonPressed(state.errorType)
                })
                .disposed(by: self.rx_disposeBag)
            
            layout.height = 40.0
            layout.width = 233.0
            layout.alignSelf = state.oniPad ? .flexStart : .center
            layout.flexDirection = .row
            
            if !(state.oniPad) {
                layout.marginBottom = 25
            }
        }.add(child: state.refreshButtonIsLoading ? Node<UIActivityIndicatorView> { view, layout, _ in
            view.activityIndicatorViewStyle = .white
            view.startAnimating()
            
            layout.marginLeft = 15
        } : NilNode())
        
        let emptySpace = Node<UIView>(identifier: "blank-space") { view, layout, size in
            layout.height = 15
            layout.width = size.width
            view.backgroundColor = .tpBackground()
        }
        
        let iPadLayout = Node<UIView> { _, layout, _ in
            layout.flexDirection = .column
            layout.width = 560
        }.add(children: [
            Node<UIView> { view, layout, size in
                layout.flexDirection = .row
                layout.justifyContent = .center
                layout.alignItems = .center
                layout.width = size.width
                layout.height = 200
                
                view.backgroundColor = .tpBackground()
            }.add(children: [
                cactusImage,
                Node<UIView> { _, layout, _ in
                    layout.flexDirection = .column
                    layout.justifyContent = .center
                    layout.flexShrink = 1
                }.add(children: [
                    title,
                    desc,
                    button
                ])
            ]),
            emptySpace
        ])
        
        let iPhoneLayout = Node<UIView> { view, layout, size in
            layout.flexDirection = .column
            layout.width = size.width
            layout.justifyContent = .center
            
            view.backgroundColor = .tpBackground()
        }
        .add(children: [
            cactusImage,
            title,
            desc,
            button,
            emptySpace
        ])
        
        return state.oniPad ? iPadLayout : iPhoneLayout
    }
}
