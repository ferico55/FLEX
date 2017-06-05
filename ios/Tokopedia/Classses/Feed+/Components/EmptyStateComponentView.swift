//
//  EmptyStateComponentView.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 4/25/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render
import Lottie
import RxSwift
import RxCocoa
import ReSwift

class EmptyStateComponentView: ComponentView<FeedState> {
    
    private let onButtonTapped: (() -> Void)
    private weak var viewController: UIViewController?
    private var onTopAdsStateChanged: ((TopAdsFeedPlusState) -> Void)
    
    init(viewController: UIViewController, onButtonTapped: @escaping (() -> Void), onTopAdsStateChanged: @escaping ((TopAdsFeedPlusState) -> Void)) {
        self.viewController = viewController
        self.onButtonTapped = onButtonTapped
        self.onTopAdsStateChanged = onTopAdsStateChanged
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func construct(state: FeedState?, size: CGSize) -> NodeType {
        return self.scrollViewComponent(state: state, size: size)
    }
    
    private func scrollViewComponent(state: FeedState?, size: CGSize) -> NodeType {
        let topAdsComponent = TopAdsFeedPlusComponentView(favoriteCallback: { state in
            self.onTopAdsStateChanged(state)
        })
        
        return Node<UIScrollView>(identifier: "scroll-view") { _, layout, size in
            layout.width = size.width
            layout.height = size.height
        }.add(children: [
            Node<UIRefreshControl>() { view, layout, _ in
                view.endRefreshing()
                view.bk_addEventHandler({ _ in
                    self.onButtonTapped()
                }, for: .valueChanged)
                
                layout.height = 0
            },
            self.emptyState(state: state, size: size),
            topAdsComponent.construct(state: state?.topads, size: size)
        ])
    }
    
    private func emptyState(state: FeedState?, size: CGSize) -> NodeType {
        return Node<UIView>(identifier: "empty-state") { view, layout, size in
            layout.flexDirection = .column
            layout.width = size.width
            layout.justifyContent = .center
            
            view.backgroundColor = .white
        }
        .add(
            children: [
                Node<UIView>(identifier: "empty-state-image") { view, layout, _ in
                    layout.height = 177
                    layout.width = 274
                    layout.marginTop = 30
                    layout.marginBottom = 12
                    layout.alignSelf = .center
                    
                    let animationView = LOTAnimationView(name: "FeedEmptyState")
                    animationView?.loopAnimation = true
                    animationView?.frame.size = CGSize(width: 274, height: 177)
                    animationView?.contentMode = .scaleAspectFill
                    
                    view.addSubview(animationView!)
                    
                    animationView!.play(completion: { _ in
                        
                    })
                },
                Node<UILabel>(identifier: "empty-state-title") { label, layout, _ in
                    layout.flexShrink = 1
                    layout.marginBottom = 12
                    
                    label.text = (state?.errorType == .emptyFeed) ? "Oops, feed masih kosong" : "Oops, terjadi kendala pada server"
                    label.font = UIFont.boldSystemFont(ofSize: 16.0)
                    label.textColor = UIColor.black.withAlphaComponent(0.54)
                    label.textAlignment = .center
                    label.numberOfLines = 0
                },
                Node<UILabel>(identifier: "empty-state-desc") { label, layout, _ in
                    layout.flexShrink = 1
                    layout.marginBottom = 25
                    layout.width = 303
                    layout.alignSelf = .center
                    
                    label.text = (state?.errorType == .emptyFeed) ? "Segera favoritkan toko yang Anda sukai untuk mendapatkan update produk terbaru di sini." : "Terjadi kendala dalam memuat halaman ini. Silakan coba lagi."
                    label.font = .largeTheme()
                    label.textColor = UIColor.black.withAlphaComponent(0.38)
                    label.textAlignment = .center
                    label.numberOfLines = 0
                },
                Node<UIButton>(identifier: "action-button") { button, layout, _ in
                    button.setTitle((state?.errorType == .emptyFeed) ? "Cari Toko" : "Coba Lagi", for: .normal)
                    button.setTitleColor(.white, for: .normal)
                    button.titleLabel?.font = .smallThemeSemibold()
                    button.backgroundColor = .tpGreen()
                    button.cornerRadius = 3
                    
                    button.rx.tap
                        .subscribe(onNext: {
                            if state?.errorType == .emptyFeed {
                                NotificationCenter.default.post(name: Notification.Name("didSwipeHomePage"), object: self, userInfo: ["page": 5])
                            } else {
                                self.onButtonTapped()
                            }
                        })
                        .disposed(by: self.rx_disposeBag)
                    
                    layout.height = 40.0
                    layout.width = 233.0
                    layout.alignSelf = .center
                    layout.marginBottom = 40
                }
            ]
        )
    }
}
