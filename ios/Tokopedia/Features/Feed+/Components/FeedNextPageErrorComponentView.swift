//
//  FeedNextPageErrorComponentView.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 10/31/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render
import RxSwift

class FeedNextPageErrorComponentView: ComponentView<FeedCardState> {
    private let onReloadNextPagePressed: (() -> Void)
    
    init(onReloadNextPagePressed: @escaping (() -> Void)) {
        self.onReloadNextPagePressed = onReloadNextPagePressed
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func construct(state: FeedCardState?, size: CGSize) -> NodeType {
        guard let state = state else { return NilNode() }
        
        let desc = Node<UILabel>(identifier: "empty-state-desc") { label, layout, _ in
            layout.flexShrink = 1
            layout.marginTop = 26
            layout.marginBottom = 16
            layout.alignSelf = .center
            
            label.text = "Mohon maaf terjadi kendala, silakan coba lagi."
            label.font = .largeTheme()
            label.textColor = UIColor.tpDisabledBlackText()
            label.textAlignment = .center
            label.numberOfLines = 0
        }
        
        let button = Node<UIButton>(identifier: "action-button") { button, layout, _ in
            button.setTitle("Coba Lagi", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = .smallThemeSemibold()
            button.backgroundColor = .tpGreen()
            button.cornerRadius = 3
            button.isEnabled = true
            
            button.rx.tap
                .subscribe(onNext: {
                    button.isEnabled = false
                    self.onReloadNextPagePressed()
                })
                .disposed(by: self.rx_disposeBag)
            
            layout.height = 40.0
            layout.width = 200.0
            layout.alignSelf = .center
            layout.flexDirection = .row
            
            if !(state.oniPad) {
                layout.marginBottom = 25
            }
        }.add(child: state.nextPageReloadIsLoading ? Node<UIActivityIndicatorView> { view, layout, _ in
            view.activityIndicatorViewStyle = .white
            view.startAnimating()
            
            layout.marginLeft = 15
        } : NilNode())
        
        let emptySpace = Node<UIView>(identifier: "blank-space") { view, layout, size in
            layout.height = 15
            layout.width = size.width
            view.backgroundColor = .tpBackground()
        }
        
        let container = Node<UIView> { view, layout, size in
            layout.flexDirection = .column
            layout.width = size.width
            layout.justifyContent = .center
            
            view.backgroundColor = .tpBackground()
        }
        .add(children: [
            desc,
            button,
            emptySpace
        ])
        
        return container
    }
}
