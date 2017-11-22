//
//  FeedPromotionComponentView.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 5/5/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render
import RxSwift

class FeedPromotionComponentView: ComponentView<FeedCardState> {
    private var disposeBag = DisposeBag()
    private weak var viewController: UIViewController?
    private var pageIndex = Variable(Int())
    private var scrollViewPageIndex = 0
    
    init(viewController: UIViewController) {
        self.viewController = viewController
        super.init()
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func construct(state: FeedCardState?, size: CGSize) -> NodeType {
        return self.promotionCard(state: state, size: size)
    }
    
    private func promotionCard(state: FeedCardState?, size: CGSize) -> NodeType {
        guard let state = state, let vc = self.viewController else {
            return Node<UIView>() { _, _, _ in
                
            }
        }
        
        let feedContent = self.promotionLayout(promotions: state.content.promotion, size: size)
        
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
            state.content.promotion.count > 1 ? self.promotionPageControl(state: state) : NilNode()
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
    
    private func promotionLayout(promotions: [FeedCardPromotionState], size: CGSize) -> NodeType {
        var mainContent: NodeType
        let amount = promotions.count
        
        if amount == 1 {
            mainContent = self.promotionCell(state: promotions[0], size: size)
        } else {
            var promotionArray: [NodeType] = []
            promotions.forEach({ promotionState in
                promotionArray.append(self.promotionCell(state: promotionState, size: size))
            })
            
            mainContent = Node<UIScrollView>(identifier: "scroll-view") { [weak self] view, layout, size in
                guard let `self` = self else {
                    return
                }
                
                view.backgroundColor = .white
                view.showsHorizontalScrollIndicator = false
                view.alwaysBounceVertical = false
                view.isPagingEnabled = true
                view.contentSize = CGSize(width: size.width * CGFloat(promotions.count), height: size.height)
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
    
    private func promotionPageControl(state: FeedCardState) -> NodeType {
        return Node<UIView>() { _, layout, _ in
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
    
    private func promotionCell(state: FeedCardPromotionState?, size: CGSize) -> NodeType {
        guard let state = state else {
            return Node<UIView> { _, _, _ in
                
            }
        }
        
        return Node<UIView>(identifier: "cell-container") { _, layout, size in
            layout.padding = 8
            layout.width = size.width
        }.add(child: Node<UIView>(identifier: "promotion-cell") { view, layout, _ in
            layout.flexDirection = .column
            
            view.cornerRadius = 2.0
            view.shadowRadius = 1.0
            view.borderColor = UIColor.fromHexString("#e0e0e0")
            view.borderWidth = 0.5
            view.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
            view.layer.shadowOpacity = 0.1
            view.layer.shadowOffset = CGSize.zero
            view.layer.shadowRadius = 2
        }.add(children: [self.promotionBanner(state: state, size: size)] + (state.oniPad ? [self.iPadLayout(state: state, size: size)] : [self.iPhoneLayout(state: state, size: size)])))
        
    }
    
    private func iPadLayout(state: FeedCardPromotionState?, size: CGSize) -> NodeType {
        guard let state = state else {
            return Node<UIView> { _, _, _ in
                
            }
        }
        
        return Node<UIView>(identifier: "ipad") { _, layout, _ in
            layout.flexDirection = .row
            layout.padding = 10
        }.add(children: [
            Node<UIView>(identifier: "desc-period") { _, layout, _ in
                layout.flexDirection = .column
                layout.flexBasis = 5
                layout.flexGrow = 5
            }.add(children: [
                self.promotionDescription(state: state, size: size),
                self.promotionPeriod(state: state, size: size)
            ]),
            Node<UIView>(identifier: "blank-space") { _, layout, _ in
                layout.flexBasis = 1
                layout.flexGrow = 1
            },
            Node<UIView>(identifier: "kode-promo-ipad") { _, layout, _ in
                layout.flexDirection = .column
                layout.flexBasis = 4
                layout.flexGrow = 4
            }.add(children: [
                state.hasNoCode ? NilNode() : self.kode(),
                self.promoCode(state: state, size: size)
            ])
        ])
    }
    
    private func iPhoneLayout(state: FeedCardPromotionState?, size: CGSize) -> NodeType {
        guard let state = state else {
            return Node<UIView> { _, _, _ in
                
            }
        }
        
        return Node<UIView>(identifier: "iphone") { _, layout, _ in
            layout.flexDirection = .column
            layout.padding = 10
        }.add(children: [
            self.promotionDescription(state: state, size: size),
            self.promotionPeriod(state: state, size: size),
            Node<UIView>(identifier: "kode-promo-iphone") { _, layout, _ in
                layout.flexDirection = .row
                layout.alignItems = .center
                layout.flexGrow = 1
                layout.flexShrink = 1
                layout.marginTop = 8
                layout.marginBottom = 8
            }.add(children: [
                state.hasNoCode ? NilNode() : self.kode(),
                self.promoCode(state: state, size: size)
            ])
        ])
    }
    
    private func promotionBanner(state: FeedCardPromotionState?, size: CGSize) -> NodeType {
        guard let state = state else {
            return Node<UIView> { _, _, _ in
                
            }
        }
        
        let thumbnailURL = state.oniPad ? state.banneriPad : state.banneriPhone
        
        return Node<UIButton>() { button, _, _ in
            button.bk_(whenTapped: {
                let eventLabel = "\(state.page).\(state.row) Promotion - \(state.promoName)"
                AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: GA_EVENT_ACTION_CLICK, label: eventLabel)
                TPRoutes.routeURL(URL(string: state.promoURL)!)
            })
        }.add(child: Node<UIImageView>(identifier: "banner") { imageView, layout, size in
            layout.flexGrow = 1
            layout.aspectRatio = state.oniPad ? 2.8 : 1.8
            layout.width = size.width
            
            imageView.setImageWith(URL(string: thumbnailURL), placeholderImage: #imageLiteral(resourceName: "grey-bg"))
        })
    }
    
    private func promotionDescription(state: FeedCardPromotionState?, size _: CGSize) -> NodeType {
        guard let state = state else {
            return Node<UIView> { _, _, _ in
                
            }
        }
        
        let description = NSString.convertHTML(state.desc)
        
        return Node<UIView>(identifier: "name-container") { _, _, _ in
            
        }.add(child: Node<UILabel>(identifier: "description") { label, layout, _ in
            layout.flexGrow = 1
            layout.flexShrink = 1
            layout.marginBottom = 5
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            
            let attrString = NSMutableAttributedString(string: description)
            attrString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
            
            label.attributedText = attrString
            label.numberOfLines = 2
            label.font = .smallTheme()
            label.textColor = UIColor.black.withAlphaComponent(0.7)
        })
        
    }
    
    private func promotionPeriod(state: FeedCardPromotionState?, size _: CGSize) -> NodeType {
        guard let state = state else {
            return Node<UIView> { _, _, _ in
                
            }
        }
        
        return Node<UIView>(identifier: "period") { _, layout, _ in
            layout.flexGrow = 1
            layout.flexDirection = .row
            layout.marginBottom = 8.0
        }.add(children: [
            Node<UILabel>(identifier: "periode") { label, _, _ in
                label.text = "Periode: "
                label.font = .smallTheme()
                label.textColor = .black
                label.alpha = 0.38
            },
            Node<UILabel>(identifier: "date") { label, layout, _ in
                label.text = (state.period == "") ? "-" : state.period
                label.font = .smallTheme()
                label.textColor = UIColor.black.withAlphaComponent(0.7)
                
                layout.flexShrink = 1
            }
        ])
    }
    
    private func kode() -> NodeType {
        return Node<UILabel>(identifier: "kode") { label, layout, _ in
            label.text = "Kode:"
            label.font = .smallTheme()
            label.textColor = .black
            label.alpha = 0.38
            
            layout.marginRight = 8
        }
    }
    
    private func promoCode(state: FeedCardPromotionState?, size _: CGSize) -> NodeType {
        guard let state = state else {
            return Node<UIView> { _, _, _ in
                
            }
        }
        
        return Node<UIView>(identifier: "code-container") { _, layout, _ in
            layout.flexDirection = .row
            layout.flexGrow = 1
            layout.flexShrink = 1
            layout.justifyContent = state.hasNoCode ? .flexEnd : .flexStart
        }.add(children: [
            state.hasNoCode ? NilNode() : Node<UIView>(identifier: "promo-code-view") { view, layout, _ in
                layout.alignItems = .center
                layout.justifyContent = .center
                layout.flexGrow = 1
                layout.flexShrink = 1
                layout.height = 40
                
                view.borderWidth = 1.0
                view.borderColor = UIColor.fromHexString("#e0e0e0")
                
            }.add(child: Node<UILabel>(identifier: "code-label") { label, layout, _ in
                label.text = state.voucherCode
                label.font = .largeThemeMedium()
                label.textColor = UIColor.black.withAlphaComponent(0.7)
                
                layout.alignSelf = .center
            }),
            state.hasNoCode ? NilNode() : Node<UIButton>(identifier: "copy-button") { button, layout, _ in
                button.setTitle("Salin", for: .normal)
                button.backgroundColor = .tpGreen()
                button.cornerRadius = 2.0
                button.titleLabel?.font = .smallThemeMedium()
                button.setTitleColor(.white, for: .normal)
                button.rx.tap
                    .subscribe(onNext: {
                        let eventLabel = "\(state.page).\(state.row) Promotion - \(state.promoName)"
                        AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: "Copy Code", label: eventLabel)
                        UIPasteboard.general.string = state.voucherCode
                        
                        StickyAlertView.showSuccessMessage(["Kode promo tersalin"])
                    })
                    .disposed(by: self.disposeBag)
                
                layout.height = 40
                layout.width = 70
                layout.marginLeft = 5
            },
            state.hasNoCode ? Node<UIButton>(identifier: "detail-button") { button, layout, _ in
                button.setTitle("Lihat Promo", for: .normal)
                button.backgroundColor = .tpGreen()
                button.cornerRadius = 2.0
                button.titleLabel?.font = .smallThemeMedium()
                button.setTitleColor(.white, for: .normal)
                
                layout.height = 40
                layout.width = 92
                
                button.rx.tap
                    .subscribe(onNext: {
                        TPRoutes.routeURL(URL(string: state.promoURL)!)
                    })
                    .disposed(by: self.disposeBag)
                
            } : NilNode()
        ])
    }
}
