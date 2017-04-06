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

class DigitalProductView: ComponentView<DigitalProduct>  {
    override func construct(state: DigitalProduct?, size: CGSize) -> NodeType {
        let product = state!
        
        return Node(identifier: "data") { view, layout, size in
            layout.alignItems = .stretch
            layout.padding = 10
            layout.width = size.width
            
            }.add(children: [
                
                Node(identifier: "title row") { view, layout, size in
                    layout.flexDirection = .row
                    }.add(children: [
                        Node<UILabel>(identifier: "title") { label, layout, size in
                            label.text = product.name
                            label.font = .largeTheme()
                            label.numberOfLines = 0
                        },
                        Node<UILabel>(identifier: "tag") { label, layout, size in
                            layout.marginLeft = 8
                            
                            label.text = product.promoTag
                            label.textColor = .fromHexString("ff5722")
                            label.font = .smallTheme()
                        }
                        ]),
                
                Node<UILabel>(identifier: "description") { label, layout, size in
                    label.text = NSAttributedString(fromHTML: product.detail).string
                    label.font = .smallTheme()
                    label.textColor = .fromHexString("AAAAAA")
                    label.numberOfLines = 0
                    
                    layout.paddingVertical = 8
                },
                
                Node(identifier: "footer") { view, layout, size in
                    layout.flexDirection = . row
                    }.add(children:[
                        Node(identifier: "price container") { view, layout, size in
                            layout.flexDirection = .row
                            layout.flexGrow = 1
                            
                            }.add(children: [
                                Node<UILabel>(identifier: "old price") { label, layout, size in
                                    label.text = product.priceText
                                    label.font = .largeThemeMedium()
                                    
                                    if product.hasDiscount {
                                        let attributedString = { () -> NSMutableAttributedString in
                                            let string =  NSMutableAttributedString(string: product.priceText)
                                            string.addAttribute(
                                                NSStrikethroughStyleAttributeName,
                                                value: 2,
                                                range: NSMakeRange(0, product.priceText.characters.count))
                                            
                                            return string
                                        }()
                                        
                                        label.attributedText = attributedString
                                    }
                                },
                                {
                                    guard product.hasDiscount else { return NilNode() }
                                    
                                    return Node<UILabel>(identifier: "new price") { label, layout, size in
                                        layout.marginLeft = 8
                                        label.text = product.promoPriceText
                                        label.font = .largeTheme()
                                        label.textColor = .fromHexString("ff5722")
                                    }
                                }()
                                ]),
                        product.status == .outOfStock ? Node<UILabel>() { label, layout, size in
                            label.text = "Kosong"
                            label.font = .smallTheme()
                            label.textColor = .white
                            label.backgroundColor = .lightGray
                            label.textAlignment = .center
                            
                            label.layer.cornerRadius = 4
                            label.layer.masksToBounds = true
                            
                            layout.paddingVertical = 3
                            layout.paddingHorizontal = 5
                            } as NodeType : NilNode()
                        
                        ]),
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
        
        let tableView = UITableView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        Observable.from(optional: products)
            .bindTo(tableView.rx.items) { (tableView, row, product) in
                let cell = ComponentTableViewCell<DigitalProductView>()
                cell.selectionStyle = .gray
                cell.mountComponentIfNecessary(DigitalProductView())
                cell.state = product
                cell.isUserInteractionEnabled = product.status != .outOfStock
                cell.render(in: tableView.frame.size)
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
