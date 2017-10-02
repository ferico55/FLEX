//
//  ProductWholesaleViewController.swift
//  Tokopedia
//
//  Created by Setiady Wiguna on 6/13/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render

class ProductWholesaleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    fileprivate var wholesales: [ProductWholesale]
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(wholesales: [ProductWholesale]) {
        self.wholesales = wholesales
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        super.loadView()
        
        var navigationBarHeight: CGFloat = 0
        if let navigationController = self.navigationController {
            navigationBarHeight = navigationController.navigationBar.bounds.height + 20
        }
        let tableViewFrame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - navigationBarHeight)
        let tableView = UITableView(frame: tableViewFrame, style: .plain)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        self.view.addSubview(tableView)
        
        self.title = "Harga Grosir"
        
        AnalyticsManager.trackScreenName("Product Detail - Wholesale Page")
    }
    
    // MARK: - UITableView Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.wholesales.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ??
            ComponentTableViewCell<ProductWholesaleComponentView>()
        if let cell = cell as? ComponentTableViewCell<ProductWholesaleComponentView> {
            cell.mountComponentIfNecessary(ProductWholesaleComponentView())
            cell.state = ProductWholesaleState(wholesale: self.wholesales[indexPath.row])
            cell.render(in: cell.bounds.size)
        }
        return cell
    }
}

// MARK: - ProductShipmentComponentView

struct ProductWholesaleState: StateType {
    let wholesale: ProductWholesale
    
    init(wholesale: ProductWholesale) {
        self.wholesale = wholesale
    }
}

class ProductWholesaleComponentView: ComponentView<ProductWholesaleState> {
    
    override func construct(state: ProductWholesaleState?, size: CGSize = CGSize.undefined) -> NodeType {
        
        func titleView() -> NodeType {
            guard let wholesale = state?.wholesale else {
                return NilNode()
            }
            
            return Node<UILabel> { view, layout, _ in
                layout.marginBottom = 2
                view.font = .title1Theme()
                view.textColor = .tpPrimaryBlackText()
                view.text = "Rp \(wholesale.price)"
            }
        }
        
        func descriptionView() -> NodeType {
            guard let wholesale = state?.wholesale else {
                return NilNode()
            }
            
            return Node<UILabel> { view, layout, _ in
                layout.marginBottom = 2
                view.font = .microTheme()
                view.textColor = .tpSecondaryBlackText()
                view.text = "Kisaran jumlah > \(wholesale.minQuantity) produk"
            }
        }
        
        return Node<UIView>() { _, layout, size in
            layout.paddingLeft = 24
            layout.paddingRight = 24
            layout.paddingTop = 14
            layout.paddingBottom = 14
            layout.width = size.width
        }.add(children: [
            titleView(),
            descriptionView(),
        ])
    }
}
