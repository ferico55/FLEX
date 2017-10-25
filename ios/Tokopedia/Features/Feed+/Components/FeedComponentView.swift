//
//  FeedComponentView.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 4/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render
import RxSwift
import Lottie

class FeedComponentView: ComponentView<FeedCardState> {
    
    private weak var viewController: UIViewController?
    private var onTopAdsStateChanged: ((TopAdsFeedPlusState) -> Void)
    private var onEmptyStateButtonPressed: ((FeedErrorType) -> Void)
    private var onReloadNextPagePressed: (() -> Void)
    private var pageIndex = Variable(Int())
    private var scrollViewPageIndex = 0
    
    init(viewController: UIViewController, onTopAdsStateChanged: @escaping ((TopAdsFeedPlusState) -> Void), onEmptyStateButtonPressed: @escaping ((FeedErrorType) -> Void), onReloadNextPagePressed: @escaping (() -> Void)) {
        self.viewController = viewController
        self.onTopAdsStateChanged = onTopAdsStateChanged
        self.onEmptyStateButtonPressed = onEmptyStateButtonPressed
        self.onReloadNextPagePressed = onReloadNextPagePressed
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
        
        let topAdsComponent = TopAdsFeedPlusComponentView(favoriteCallback: { state in
            self.onTopAdsStateChanged(state)
        })
        
        if state.isEmptyState {
            return self.emptyState(state: state, size: size)
        }
        
        if state.isNextPageError {
            return self.nextPageError(state: state, size: size)
        }
        
        if let inspiration = state.inspiration {
            return FeedInspirationComponentView().construct(state: inspiration, size: size)
        }
        
        if state.content.officialStore != nil {
            return FeedOfficialStoreComponentView().construct(state: state.content, size: size)
        }
        
        if state.content.toppicks != nil {
            return FeedToppicksComponentView().construct(state: state.content, size: size)
        }
        
        return (state.topads != nil) ? topAdsComponent.construct(state: state.topads, size: size) : self.feedCard(state: state, size: size)
    }
    
    func nextPageError(state: FeedCardState?, size: CGSize) -> NodeType {
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
    
    func emptyState(state: FeedCardState?, size: CGSize) -> NodeType {
        guard let state = state else { return NilNode() }
        
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
            
            label.text = (state.errorType == .emptyFeed) ? "Oops, feed masih kosong" : "Oops!"
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
                    self.onEmptyStateButtonPressed(state.errorType)
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
    
    func feedCard(state: FeedCardState?, size: CGSize) -> NodeType {
        guard let state = state else { return NilNode() }
        
        var feedContent: NodeType = NilNode()
        
        if state.content.type == .newProduct || state.content.type == .editProduct {
            feedContent = self.productCellLayout(withProductAmount: state.content.product.count, size: size)
        } else if state.content.type == .promotion {
            feedContent = self.promotionLayout(withPromotionAmount: state.content.promotion.count, size: size)
        }
        
        var promotionPageControl: NodeType = NilNode()
        
        if state.content.type == .promotion && state.content.promotion.count > 1 {
            promotionPageControl = Node<UIView>() { _, layout, _ in
                layout.flexDirection = .column
            }.add(children: [
                Node<UIView>(identifier: "see-more-container") { view, layout, size in
                    layout.width = size.width
                    layout.height = 30
                    layout.flexDirection = .row
                    layout.justifyContent = .spaceBetween
                    view.backgroundColor = .white
                }.add(children: [
                    Node<UIPageControl>(identifier: "page-control") { [weak self] view, layout, _ in
                        guard let `self` = self else { return }
                        view.numberOfPages = state.content.promotion.count
                        view.currentPage = 0
                        view.currentPageIndicatorTintColor = .tpGreen()
                        view.pageIndicatorTintColor = .tpLine()
                        
                        self.pageIndex.asObservable()
                            .bindTo(view.rx.currentPage)
                            .addDisposableTo(self.rx_disposeBag)
                        
                        layout.width = 36
                        layout.marginLeft = 16
                    },
                    Node<UIView>(identifier: "see-more-button-container") { _, layout, _ in
                        layout.flexDirection = .row
                        layout.alignItems = .center
                        layout.width = 135
                        layout.marginRight = 16
                    }.add(children: [
                        Node<UIButton>(identifier: "see-more") { [weak self] button, layout, _ in
                            button.setTitle("Lihat Semua Promo", for: .normal)
                            button.backgroundColor = .white
                            button.titleLabel?.font = .microThemeMedium()
                            button.setTitleColor(.tpGreen(), for: .normal)
                            
                            guard let `self` = self else { return }
                            
                            button.rx.tap
                                .subscribe(onNext: {
                                    AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: GA_EVENT_ACTION_CLICK, label: "\(state.page).\(state.row) Promotion - Promo Page Lihat Promo Lainnya")
                                    NotificationCenter.default.post(name: Notification.Name("didSwipeHomePage"), object: self, userInfo: ["page": 3])
                                })
                                .disposed(by: self.rx_disposeBag)
                            
                            layout.width = 121
                        },
                        Node<UIImageView>(identifier: "arrow") { view, layout, _ in
                            view.image = #imageLiteral(resourceName: "icon_forward")
                            view.tintColor = .tpGreen()
                            
                            layout.height = 9
                            layout.width = 6
                        }
                    ])
                ]),
                Node<UIView>() { view, layout, _ in
                    layout.height = 5
                    view.backgroundColor = .white
                }
            ])
        }
        
        guard let vc = self.viewController else {
            return Node<UIView> { _, _, _ in
            
            }
        }
        
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
            promotionPageControl,
            state.oniPad || (state.content.type == .promotion) ? NilNode() : self.shareButton(withSize: size)
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
    
    func horizontalLine(withSize size: CGSize) -> NodeType {
        return Node<UIView>(identifier: "line") { view, layout, _ in
            layout.height = 1
            
            view.backgroundColor = UIColor.fromHexString("#e0e0e0")
        }
    }
    
    func verticalLine(withSize size: CGSize) -> NodeType {
        return Node<UIView>(identifier: "line") { view, layout, _ in
            layout.width = 1
            
            view.backgroundColor = UIColor.fromHexString("#e0e0e0")
        }
    }
    
    func promotionLayout(withPromotionAmount amount: Int, size: CGSize) -> NodeType {
        guard let state = state else { return NilNode() }
        
        var mainContent: NodeType
        
        if amount == 1 {
            mainContent = FeedPromotionComponentView().construct(state: state.content.promotion[0], size: size)
        } else {
            var promotionArray: [NodeType] = []
            state.content.promotion.forEach({ promotionState in
                promotionArray.append(FeedPromotionComponentView().construct(state: promotionState, size: size))
            })
            
            mainContent = Node<UIScrollView>(identifier: "scroll-view") { [weak self] view, layout, size in
                guard let `self` = self, let state = self.state else {
                    return
                }
                
                    view.backgroundColor = .white
                    view.showsHorizontalScrollIndicator = false
                    view.alwaysBounceVertical = false
                    view.isPagingEnabled = true
                    view.contentSize = (state.content.promotion.count > 1) ? CGSize(width: size.width * CGFloat(state.content.promotion.count), height: size.height) : CGSize(width: size.width, height: size.height)
                    view.rx.contentOffset.bindNext({ _ in
                        self.scrollViewPageIndex = Int(floor((view.contentOffset.x - size.width / 2) / size.width) + 1.0)
                        self.pageIndex.value = self.scrollViewPageIndex
                    }).disposed(by: self.rx_disposeBag)
                    
                    layout.width = size.width
                    layout.flexDirection = .row
                    layout.alignItems = .center
                
            }.add(children: promotionArray)
        }
        
        return mainContent
    }
    
    func productCellLayout(withProductAmount amount: Int, size: CGSize) -> NodeType {
        guard let state = state, amount > 0 else { return NilNode() }
        
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
    
    func shareButton(withSize size: CGSize) -> NodeType {
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
                        if let textURL = ReferralManager().getShortUrlFor(shopState: state.source.shopState) {
                            let title = state.source.shopState.shareDescription
                            
                            guard let controller = UIActivityViewController.shareDialog(withTitle: title, url: URL(string: textURL), anchor: button) else {
                                return
                            }
                            
                            self?.viewController?.present(controller, animated: true, completion: nil)
                        }
                    })
                    .disposed(by: self.rx_disposeBag)
                
                layout.height = 52.0
            }
        ])
    }
}
