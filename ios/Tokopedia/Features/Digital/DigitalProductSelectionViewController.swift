//
//  DigitalProductSelectionViewController.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 3/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Render
import NSAttributedString_DDHTML

class DigitalProductView: ComponentView<DigitalProduct> {
    override func construct(state: DigitalProduct?, size: CGSize) -> NodeType {
        let product = state!
        
        return Node(identifier: "data") { _, layout, size in
            layout.alignItems = .stretch
            layout.padding = 10
            layout.width = size.width
            
        }.add(children: [
            
            Node(identifier: "title row") { _, layout, _ in
                layout.flexDirection = .row
            }.add(children: [
                Node<UILabel>(identifier: "title") { label, _, _ in
                    label.text = product.name
                    label.font = .microThemeMedium()
                    label.textColor = product.status == .outOfStock ? .tpDisabledBlackText() : .tpPrimaryBlackText()
                    label.numberOfLines = 0
                },
                Node<UILabel>() { view, layout, size in
                    layout.flexGrow = 1
                },
                product.status == .outOfStock ? Node<UILabel>() { label, layout, _ in
                    label.text = "Stok Habis"
                    label.font = .microTheme()
                    label.textColor = .white
                    label.backgroundColor = .tpGray()
                    label.textAlignment = .center
                    
                    label.layer.cornerRadius = 4
                    label.layer.masksToBounds = true
                    
                    layout.paddingVertical = 2
                    layout.paddingHorizontal = 4
                    
                } as NodeType : NilNode()
            ]),
            Node<UILabel>(identifier: "tag") { label, layout, _ in
                layout.marginTop = 5
                
                label.text = product.promoTag
                label.textColor = product.status == .outOfStock ? .tpDisabledBlackText() : .tpOrange()
                label.font = .microThemeMedium()
            },
            
            product.detail.isEmpty ? NilNode() : Node<UILabel>(identifier: "description") { label, layout, _ in
                label.text = NSAttributedString(fromHTML: product.detail).string
                label.font = .microTheme()
                label.textColor = product.status == .outOfStock ? .tpDisabledBlackText() : .tpSecondaryBlackText()
                label.numberOfLines = 0
                
                layout.paddingVertical = 8
            },
            
            Node(identifier: "footer") { _, layout, _ in
                layout.flexDirection = .row
                layout.paddingTop = 5
                layout.paddingBottom = 5
            }.add(children: [
                Node(identifier: "price container") { _, layout, _ in
                    layout.flexDirection = .row
                    layout.flexGrow = 1
                }.add(children: [
                    Node<UILabel>(identifier: "old price") { label, _, _ in
                        label.text = product.priceText
                        label.font = .largeThemeSemibold()
                        label.textColor = product.status == .outOfStock ? .tpDisabledBlackText() : .tpPrimaryBlackText()
                        
                        if product.hasDiscount {
                            label.font = .microTheme()
                            let attributedString = { () -> NSMutableAttributedString in
                                let string = NSMutableAttributedString(string: product.priceText)
                                string.addAttribute(
                                    NSStrikethroughStyleAttributeName,
                                    value: 2,
                                    range: NSMakeRange(0, product.priceText.characters.count)
                                )
                                
                                return string
                            }()
                            
                            label.attributedText = attributedString
                        }
                    },
                    {
                        guard product.hasDiscount else { return NilNode() }
                        
                        return Node<UILabel>(identifier: "new price") { label, layout, _ in
                            layout.marginLeft = 8
                            label.text = product.promoPriceText
                            label.font = .largeThemeSemibold()
                            label.textColor = product.status == .outOfStock ? .tpDisabledBlackText() : .tpOrange()
                        }
                    }()
                ])
            ])
        ])
        
    }
}

@objc(DigitalProductSelectionViewController)
class DigitalProductSelectionViewController: UIViewController {
    
    var onProductSelected = PublishSubject<DigitalProduct>()
    
    private let products: [DigitalProduct]
    
    init(products: [DigitalProduct]) {
        self.products = products
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Pilih Nominal"
        let tableView = UITableView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView()
        
        Observable.from(optional: products)
            .bindTo(tableView.rx.items) { tableView, _, product in
                let cell = ComponentTableViewCell<DigitalProductView>()
                cell.selectionStyle = .gray
                cell.mountComponentIfNecessary(DigitalProductView())
                cell.state = product
                cell.isUserInteractionEnabled = product.status != .outOfStock
                cell.render(in: tableView.frame.size)
                cell.preservesSuperviewLayoutMargins = false
                cell.separatorInset = UIEdgeInsets.zero
                cell.layoutMargins = UIEdgeInsets.zero
                return cell
            }
            .disposed(by: rx_disposeBag)
        
        tableView.rx.itemSelected.map { [unowned self] in self.products[$0.row] }
            .do(onNext: { [unowned self] _ in
                _ = self.navigationController?.popViewController(animated: true)
            })
            .bindTo(onProductSelected)
            .disposed(by: rx_disposeBag)
        
        self.view = tableView
        view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AnalyticsManager.trackScreenName("Recharge Product Page")
    }
}
