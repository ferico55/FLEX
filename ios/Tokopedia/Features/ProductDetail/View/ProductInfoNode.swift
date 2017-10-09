//
//  ProductInfoNode.swift
//  Tokopedia
//
//  Created by Setiady Wiguna on 7/5/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render

class ProductInfoNode: ContainerNode {
    fileprivate let state: ProductDetailState
    fileprivate let didTapCategory: (ProductCategory) -> Void
    fileprivate let didTapStorefront: (ProductUnbox) -> Void
    fileprivate let didTapReturnInfo: (String) -> Void
    
    init(identifier: String, state: ProductDetailState, didTapCategory: @escaping (ProductCategory) -> Void, didTapStorefront: @escaping (ProductUnbox) -> Void, didTapReturnInfo: @escaping (String) -> Void) {
        self.state = state
        self.didTapCategory = didTapCategory
        self.didTapStorefront = didTapStorefront
        self.didTapReturnInfo = didTapReturnInfo
        
        super.init(identifier: identifier)
        guard let preorder = state.productDetail?.preorderDetail else { return }
        
        node.add(children: [
            container().add(children: [
                GlobalRenderComponent.horizontalLine(identifier: "Info-Line-1", marginLeft: 0),
                titleLabel(),
                productInfoBoxView(),
                productInfoNoticeView(),
                preorder.isPreorder ? GlobalRenderComponent.horizontalLine(identifier: "Info-Line-2", marginLeft: 15) : NilNode(),
                preorder.isPreorder ? productPreorderView() : NilNode(),
                GlobalRenderComponent.horizontalLine(identifier: "Info-Line-3", marginLeft: 15),
                productConditionView(),
                GlobalRenderComponent.horizontalLine(identifier: "Info-Line-4", marginLeft: 15),
                productMinOrderView(),
                GlobalRenderComponent.horizontalLine(identifier: "Info-Line-5", marginLeft: 15),
                productCategoryView(),
                GlobalRenderComponent.horizontalLine(identifier: "Info-Line-6", marginLeft: 15),
                productStorefrontView(),
                GlobalRenderComponent.horizontalLine(identifier: "Info-Line-7", marginLeft: 0)
                ])
            ])
    }
    
    private func container() -> NodeType {
        return Node<UIView>() { view, layout, size in
            layout.width = size.width
            layout.flexDirection = .column
            layout.marginTop = 10
            view.backgroundColor = .white
            view.isUserInteractionEnabled = true
        }
    }
    
    private func titleLabel() -> NodeType {
        return Node<UILabel>() { view, layout, _ in
            layout.marginLeft = 15
            layout.marginTop = 22
            layout.marginBottom = 22
            view.text = "Informasi Produk"
            view.textColor = .tpPrimaryBlackText()
            view.font = .largeThemeMedium()
        }
    }
    
    private func infoBoxView(iconImage: UIImage?, title: String, subtitle: String) -> NodeType {
        return Node { _, layout, _ in
            layout.flexDirection = .column
            layout.alignItems = .center
            layout.flexGrow = 1
            layout.flexShrink = 1
            layout.flexBasis = 10
            }.add(children: [
                Node<UIImageView>() { view, layout, _ in
                    layout.width = 32
                    layout.height = 32
                    view.image = iconImage ?? UIImage(named: "")
                },
                Node<UILabel>() { view, layout, _ in
                    layout.marginTop = 2
                    layout.marginBottom = 2
                    view.text = title
                    view.font = .microTheme()
                    view.textColor = .tpDisabledBlackText()
                },
                Node<UILabel>() { view, _, _ in
                    view.text = subtitle
                    view.font = .microTheme()
                    view.textColor = .tpPrimaryBlackText()
                }
                ])
    }
    
    private func productInfoBoxView() -> NodeType {
        guard
            let sold = state.productDetail?.soldCount,
            let view = state.productDetail?.viewCount,
            let weight = state.productDetail?.info.weight,
            let insurance = state.productDetail?.info.insurance
            else { return NilNode() }
        
        return Node(identifier: "info-box-\(sold)") { _, layout, _ in
            layout.flexDirection = .row
            layout.marginBottom = 22
            
            }.add(children: [
                infoBoxView(iconImage: UIImage(named: "icon_sold_basket"), title: "Terjual", subtitle: sold),
                infoBoxView(iconImage: UIImage(named: "icon_view_product"), title: "Dilihat", subtitle: view),
                infoBoxView(iconImage: UIImage(named: "icon_insurance"), title: "Asuransi", subtitle: insurance),
                infoBoxView(iconImage: UIImage(named: "icon_weight"), title: "Berat", subtitle: weight)
                ])
    }
    
    private func productInfoNoticeView() -> NodeType {
        guard let productInfo = state.productDetail?.info else { return NilNode() }
        
        if productInfo.returnInfo.info == "" { return NilNode() }
        
        return Node<UIView>(identifier: "return-info-\(productInfo.returnInfo.info)") { view, layout, _ in
            layout.marginBottom = 22
            layout.marginLeft = 15
            layout.marginRight = 15
            layout.padding = 12
            layout.flexDirection = .row
            view.backgroundColor = productInfo.returnInfo.colorRGB()
            view.layer.cornerRadius = 4
            view.layer.masksToBounds = true
            view.accessibilityLabel = "freeReturnView"
            }.add(children: [
                Node<UIImageView>() { view, layout, _ in
                    view.setImageWith(URL(string: productInfo.returnInfo.iconImage))
                    layout.height = 32
                    layout.width = 32
                    layout.alignSelf = .center
                },
                Node<UILabel>() { view, layout, _ in
                    layout.marginLeft = 12
                    layout.marginRight = 12
                    view.font = .microTheme()
                    view.textColor = .tpDisabledBlackText()
                    view.numberOfLines = 0
                    view.isUserInteractionEnabled = true
                    
                    let returnInfo = NSString(replaceAhrefWithUrl: productInfo.returnInfo.info) as String
                    view.text = returnInfo
                    
                    guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
                        return
                    }
                    
                    let matches = detector.matches(in: returnInfo, options: [], range: NSRange(location: 0, length: returnInfo.utf16.count))
                    for match in matches {
                        let url = (returnInfo as NSString).substring(with: match.range)
                        
                        var replaceString = "Pelajari lebih lanjut."
                        if productInfo.returnable == "2" {
                            replaceString = ""
                        }
                        
                        let formattedReturnInfo = returnInfo.replacingOccurrences(of: url, with: replaceString)
                        let attributedString = NSMutableAttributedString(string: formattedReturnInfo)
                        attributedString.setColorForText(replaceString, with: UIColor.tpGreen(), with: view.font)
                        view.attributedText = attributedString
                        
                        let tapGestureRecognizer = UITapGestureRecognizer()
                        _ = tapGestureRecognizer.rx.event.subscribe(onNext: { [unowned self] _ in
                            self.didTapReturnInfo(url)
                        })
                        view.addGestureRecognizer(tapGestureRecognizer)
                        
                        break
                    }
                }
                ])
    }
    
    private func productPreorderView() -> NodeType {
        guard let preorder = state.productDetail?.preorderDetail else { return NilNode() }
        
        return Node { _, layout, _ in
            layout.marginLeft = 15
            layout.marginRight = 15
            layout.marginTop = 22
            layout.marginBottom = 22
            layout.justifyContent = .spaceBetween
            layout.flexDirection = .row
            }.add(children: [
                Node<UILabel>() { view, _, _ in
                    view.text = "Waktu Preorder"
                    view.font = .title1Theme()
                    view.textColor = .tpSecondaryBlackText()
                    view.accessibilityLabel = "preorderView"
                },
                Node<UILabel>() { view, _, _ in
                    view.text = "\(preorder.preorderTime) \(preorder.preorderTimeType)"
                    view.font = .title1Theme()
                    view.textColor = .tpOrange()
                }
                ])
    }
    
    private func productConditionView() -> NodeType {
        guard let info = state.productDetail?.info else { return NilNode() }
        
        return Node { _, layout, _ in
            layout.marginLeft = 15
            layout.marginRight = 15
            layout.marginTop = 22
            layout.marginBottom = 22
            layout.justifyContent = .spaceBetween
            layout.flexDirection = .row
            }.add(children: [
                Node<UILabel>() { view, _, _ in
                    view.text = "Kondisi"
                    view.font = .title1Theme()
                    view.textColor = .tpSecondaryBlackText()
                    view.accessibilityLabel = "conditionView"
                },
                Node<UILabel>() { view, _, _ in
                    view.text = info.condition
                    view.font = .title1Theme()
                    view.textColor = .tpPrimaryBlackText()
                }
                ])
    }
    
    private func productMinOrderView() -> NodeType {
        guard let info = state.productDetail?.info else { return NilNode() }
        
        return Node { _, layout, _ in
            layout.marginLeft = 15
            layout.marginRight = 15
            layout.marginTop = 22
            layout.marginBottom = 22
            layout.justifyContent = .spaceBetween
            layout.flexDirection = .row
            }.add(children: [
                Node<UILabel>() { view, _, _ in
                    view.text = "Min Pemesanan"
                    view.font = .title1Theme()
                    view.textColor = .tpSecondaryBlackText()
                    view.accessibilityLabel = "minimumBuyView"
                },
                Node<UILabel>() { view, _, _ in
                    view.text = info.minimumOrder
                    view.font = .title1Theme()
                    view.textColor = .tpPrimaryBlackText()
                }
                ])
    }
    
    private func productCategoryView() -> NodeType {
        guard let category = state.productDetail?.categories.last else { return NilNode() }
        
        return Node { _, layout, _ in
            layout.marginLeft = 15
            layout.marginRight = 12
            layout.marginTop = 22
            layout.marginBottom = 22
            layout.justifyContent = .spaceBetween
            layout.flexDirection = .row
            }.add(children: [
                Node<UILabel>() { view, _, _ in
                    view.text = "Kategori"
                    view.font = .title1Theme()
                    view.textColor = .tpSecondaryBlackText()
                },
                Node<UIButton>() { view, layout, size in
                    view.titleLabel?.font = .title1Theme()
                    view.titleLabel?.lineBreakMode = .byTruncatingMiddle
                    view.setTitle(category.name, for: .normal)
                    view.setTitleColor(.tpGreen(), for: .normal)
                    view.setTitleColor(.tpLightGreen(), for: .highlighted)
                    _ = view.rx.tap.subscribe(onNext: { [unowned self] _ in
                        self.didTapCategory(category)
                    })
                    
                    let categoryNameSize = UIFont.title1Theme().sizeOfString(string: category.name,
                                                                             constrainedToWidth: Double(size.width * 0.6),
                                                                             andHeight: 24)
                    layout.width = categoryNameSize.width + 10
                    view.accessibilityLabel = "productCategory"
                }
                ])
    }
    
    private func productStorefrontView() -> NodeType {
        guard let productDetail = state.productDetail else { return NilNode() }
        
        return Node { _, layout, _ in
            layout.marginLeft = 15
            layout.marginRight = 12
            layout.marginTop = 22
            layout.marginBottom = 22
            layout.justifyContent = .spaceBetween
            layout.flexDirection = .row
            }.add(children: [
                Node<UILabel>() { view, _, _ in
                    view.text = "Etalase"
                    view.font = .title1Theme()
                    view.textColor = .tpSecondaryBlackText()
                    
                },
                Node<UIButton>() { view, layout, size in
                    view.titleLabel?.font = .title1Theme()
                    view.setTitle(productDetail.info.etalaseName, for: .normal)
                    view.titleLabel?.lineBreakMode = .byTruncatingMiddle
                    view.setTitleColor(.tpGreen(), for: .normal)
                    view.setTitleColor(.tpLightGreen(), for: .highlighted)
                    _ = view.rx.tap.subscribe(onNext: { [unowned self] _ in
                        self.didTapStorefront(productDetail)
                    })
                    
                    let etalaseNameSize = UIFont.title1Theme().sizeOfString(string: productDetail.info.etalaseName,
                                                                            constrainedToWidth: Double(size.width * 0.6),
                                                                            andHeight: 24)
                    layout.width = etalaseNameSize.width + 10
                    view.accessibilityLabel = "productEtalase"
                    
                }
                ])
    }
}
