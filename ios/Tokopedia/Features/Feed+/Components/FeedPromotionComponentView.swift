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

class FeedPromotionComponentView: ComponentView<FeedCardPromotionState> {
    private var disposeBag = DisposeBag()
    
    override func construct(state: FeedCardPromotionState?, size: CGSize) -> NodeType {
        return self.promotionCell(state: state, size: size)
    }
    
    private func promotionCell(state: FeedCardPromotionState?, size: CGSize) -> NodeType {
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
        }.add(children: [self.promotionBanner(state: state, size: size)] + ((state?.oniPad)! ? [self.iPadLayout(state: state, size: size)] : [self.iPhoneLayout(state: state, size: size)])))
        
    }
    
    private func iPadLayout(state: FeedCardPromotionState?, size: CGSize) -> NodeType {
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
                (state?.hasNoCode)! ? NilNode() : self.kode(),
                self.promoCode(state: state, size: size)
            ])
        ])
    }
    
    private func iPhoneLayout(state: FeedCardPromotionState?, size: CGSize) -> NodeType {
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
                (state?.hasNoCode)! ? NilNode() : self.kode(),
                self.promoCode(state: state, size: size)
            ])
        ])
    }
    
    private func promotionBanner(state: FeedCardPromotionState?, size: CGSize) -> NodeType {
        let thumbnailURL = (state?.oniPad)! ? state?.banneriPad : state?.banneriPhone
        
        return Node<UIButton>() { button, _, _ in
            button.bk_(whenTapped: {
                let eventLabel = "Promotion - \((state?.promoName)!)"
                AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: GA_EVENT_ACTION_CLICK, label: eventLabel)
                TPRoutes.routeURL(URL(string: (state?.promoURL)!)!)
            })
        }.add(child: Node<UIImageView>(identifier: "banner") { imageView, layout, size in
            layout.flexGrow = 1
            layout.aspectRatio = (state?.oniPad)! ? 2.8 : 1.8
            layout.width = size.width
            
            imageView.setImageWith(URL(string: thumbnailURL!), placeholderImage: #imageLiteral(resourceName: "grey-bg"))
        })
    }
    
    private func promotionDescription(state: FeedCardPromotionState?, size _: CGSize) -> NodeType {
        let description = NSString.convertHTML((state?.desc)!)
        
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
        let date = state?.period
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
                label.text = (date == "") ? "-" : date
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
        return Node<UIView>(identifier: "code-container") { _, layout, _ in
            layout.flexDirection = .row
            layout.flexGrow = 1
            layout.flexShrink = 1
            layout.justifyContent = (state?.hasNoCode)! ? .flexEnd : .flexStart
        }.add(children: [
            (state?.hasNoCode)! ? NilNode() : Node<UIView>(identifier: "promo-code-view") { view, layout, _ in
                layout.alignItems = .center
                layout.justifyContent = .center
                layout.flexGrow = 1
                layout.flexShrink = 1
                layout.height = 40
                
                view.borderWidth = 1.0
                view.borderColor = UIColor.fromHexString("#e0e0e0")
                
            }.add(child: Node<UILabel>(identifier: "code-label") { label, layout, _ in
                label.text = state?.voucherCode
                label.font = .largeThemeMedium()
                label.textColor = UIColor.black.withAlphaComponent(0.7)
                
                layout.alignSelf = .center
            }),
            (state?.hasNoCode)! ? NilNode() : Node<UIButton>(identifier: "copy-button") { button, layout, _ in
                button.setTitle("Salin", for: .normal)
                button.backgroundColor = .tpGreen()
                button.cornerRadius = 2.0
                button.titleLabel?.font = .smallThemeMedium()
                button.setTitleColor(.white, for: .normal)
                button.rx.tap
                    .subscribe(onNext: {
                        let eventLabel = "Promotion - \((state?.promoName)!)"
                        AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: "Copy Code", label: eventLabel)
                        UIPasteboard.general.string = state?.voucherCode
                        
                        StickyAlertView.showSuccessMessage(["Kode promo tersalin"])
                    })
                    .disposed(by: self.disposeBag)
                
                layout.height = 40
                layout.width = 70
                layout.marginLeft = 5
            },
            (state?.hasNoCode)! ? Node<UIButton>(identifier: "detail-button") { button, layout, _ in
                button.setTitle("Lihat Promo", for: .normal)
                button.backgroundColor = .tpGreen()
                button.cornerRadius = 2.0
                button.titleLabel?.font = .smallThemeMedium()
                button.setTitleColor(.white, for: .normal)
                
                layout.height = 40
                layout.width = 92
                
                button.rx.tap
                    .subscribe(onNext: {
                        TPRoutes.routeURL(URL(string: (state?.promoURL)!)!)
                    })
                    .disposed(by: self.disposeBag)
                
            } : NilNode()
        ])
    }
}
