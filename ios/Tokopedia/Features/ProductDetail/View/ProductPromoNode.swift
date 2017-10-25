//
//  ProductPromoNode.swift
//  Tokopedia
//
//  Created by Valentina Widiyanti Amanda on 10/5/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render
import RxSwift

class ProductPromoNode: ContainerNode {
    fileprivate var state: ProductDetailState
    fileprivate let didTapPromo: (String?) -> Void
    fileprivate let didTapDescription: (String?) -> Void
    
    fileprivate var scrollView: UIScrollView?
    
    init(identifier: String, state: ProductDetailState, promoDetail: PromoDetail?, didTapPromo: @escaping (String?) -> Void, didTapDescription: @escaping (String?) -> Void) {
        self.state = state
        self.didTapPromo = didTapPromo
        self.didTapDescription = didTapDescription
        super.init(identifier: identifier)
        if let detail = promoDetail {
            node.add(children: [
                container().add(children: [
                    GlobalRenderComponent.horizontalLine(identifier: "Promo-Line-1", marginLeft: 0),
                    promoBoxView(detail: detail),
                    promoButtonView(promoDetail: detail),
                    GlobalRenderComponent.horizontalLine(identifier: "Promo-Line-2", marginLeft: 0)
                    ])
                ])
        }
    }
    
    private func container() -> NodeType {
        return Node<UIView> { view, layout, size in
            layout.width = size.width
            layout.flexDirection = .column
            layout.marginTop = 10
            view.backgroundColor = .white
            view.isUserInteractionEnabled = true
        }
    }
    
    private func promoBoxView(detail: PromoDetail?) -> NodeType {
        return Node(identifier: "promoBoxView") { _, layout, _ in
            layout.flexDirection = .row
            layout.marginTop = 10
            layout.marginLeft = 14
            layout.alignItems = .center
            }.add(children: [
                Node<UIImageView>() { view, layout, _ in
                    layout.marginRight = 8
                    layout.width = 29
                    layout.height = 25
                    view.image = UIImage(named: "icon_megaphone")
                },
                promoInfoBoxView(promoDetail: detail)
                ])
    }
    
    private func megaphone() -> NodeType {
        return Node<UIImageView>() { view, layout, _ in
            layout.marginRight = 8
            layout.width = 29
            layout.height = 25
            view.image = UIImage(named: "icon_megaphone")
        }
    }
    
    private func promoInfoBoxView(promoDetail: PromoDetail?) -> NodeType {
        var shortDesc = ""
        var shortCond = ""
        if let detail = promoDetail {
            shortDesc = (detail.shortDescHTML)
            shortCond = (detail.shortCondHTML)
        }
        
        return Node { _, layout, _ in
            layout.flexDirection = .column
            layout.alignItems = .flexStart
            layout.marginRight = 8
            layout.flexGrow = 1
            layout.flexShrink = 1
            }.add(children: [
                Node<UIButton>() { [weak self] view, layout, _ in
                    view.setAttributedTitle(NSAttributedString(fromHTML: shortDesc, normalFont: .largeThemeMedium(), boldFont: .smallTheme(), italicFont: .smallTheme()), for: .normal)
                    view.contentHorizontalAlignment = .left
                    view.titleLabel?.numberOfLines = 0
                    view.rx.tap.subscribe(onNext: { _ in
                        self?.didTapDescription(promoDetail?.targetURL)
                    }).disposed(by: (self?.rx_disposeBag)!)
                },
                Node<UILabel>() { view, layout, _ in
                    layout.marginTop = 3
                    view.attributedText = NSAttributedString(fromHTML:shortCond)
                    view.font = .microTheme()
                    view.numberOfLines = 0
                    view.textColor = .tpPrimaryBlackText()
                }
                ])
    }
    
    private func promoButtonView(promoDetail: PromoDetail?) -> NodeType {
        var code = ""
        if let detail = promoDetail {
            code = (detail.codeHTML)
        }
        return Node { _, layout, _ in
            layout.flexDirection = .row
            layout.alignItems = .center
            layout.marginTop = 10
            layout.alignSelf = .center
            layout.marginBottom = 10
            }.add(children: [
                Node<UILabel>() { view, layout, _ in
                    layout.height = 32
                    layout.width = 166
                    view.attributedText = NSAttributedString(fromHTML:code)
                    view.textAlignment = .center
                    view.font = .smallTheme()
                    view.textColor = .tpOrange()
                    view.backgroundColor = .tpBackground()
                    view.borderWidth = 1
                    view.borderColor = .tpLine()
                },
                Node<UIButton>() { [weak self] view, layout, size in
                    layout.height = 32
                    layout.width = 105
                    view.titleLabel?.font = .smallTheme()
                    view.titleLabel?.lineBreakMode = .byTruncatingMiddle
                    view.setTitle("Salin Kode", for: .normal)
                    view.setTitleColor(.tpDisabledBlackText(), for: .normal)
                    view.borderWidth = 1
                    view.borderColor = .tpLine()
                    view.rx.tap.subscribe(onNext: { _ in
                        self?.didTapPromo(promoDetail?.code)
                        view.setTitle("Kode Tersalin", for: .normal)
                        view.setTitleColor(.tpGreen(), for: .normal)
                    }).disposed(by: (self?.rx_disposeBag)!)
                }
                ])
    }
}
