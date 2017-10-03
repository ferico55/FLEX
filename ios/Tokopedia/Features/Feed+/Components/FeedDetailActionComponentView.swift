//
//  FeedDetailActionComponentView.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 4/18/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render
import RxSwift
import RxCocoa

class FeedDetailActionComponentView: ComponentView<FeedDetailState> {
    private var disposeBag = DisposeBag()
    
    override func construct(state: FeedDetailState?, size _: CGSize) -> NodeType {
        guard let state = state else { return NilNode() }
        
        let shareButton = Node<UIButton>(identifier: "share") { button, layout, _ in
            button.setTitle("Bagikan", for: .normal)
            button.backgroundColor = .white
            button.titleLabel?.font = .largeThemeSemibold()
            button.setTitleColor(UIColor.tpSecondaryBlackText(), for: .normal)
            
            button.rx.tap
                .subscribe(onNext: { [weak self] in
                    AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: GA_EVENT_ACTION_CLICK, label: "Share - Product List")
                    if let textURL = ReferralManager().getShortUrlFor(shopState: state.source.shopState) {
                        let title = state.source.shopState.shareDescription
                        let controller = UIActivityViewController.shareDialog(withTitle: title, url: URL(string: textURL), anchor: button)
                        UIApplication.topViewController()?.present(controller!, animated: true, completion: nil)
                    }
                })
                .disposed(by: self.rx_disposeBag)
            
            layout.height = 51.0
            layout.flexGrow = 1
            layout.flexBasis = 10
        }
        
        return Node<UIView>() { _, layout, _ in
            layout.flexDirection = .row
            layout.height = 51.0
            layout.width = UIScreen.main.bounds.width
            layout.flexGrow = 1
            layout.flexShrink = 1
            layout.position = .absolute
            layout.bottom = 0
        }.add(children: [
            shareButton,
            Node<UIView>() { view, layout, _ in
                layout.width = 1
                
                view.backgroundColor = UIColor.fromHexString("#e0e0e0")
            },
            Node<UIButton>(identifier: "visit-shop") { button, layout, _ in
                button.setTitle("Kunjungi Toko", for: .normal)
                button.backgroundColor = .tpGreen()
                button.titleLabel?.font = .largeThemeSemibold()
                button.setTitleColor(.white, for: .normal)
                button.rx.tap
                    .subscribe(onNext: { [weak self] in
                        AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: GA_EVENT_ACTION_CLICK, label: "Kunjungi Toko - Shop")
                        TPRoutes.routeURL(URL(string: state.source.shopState.shopURL)!)
                    })
                    .disposed(by: self.disposeBag)
                
                layout.height = 51.0
                layout.flexGrow = 1
                layout.flexBasis = 10
            }
        ])
    }
}
