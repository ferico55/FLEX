//
//  ProductShipmentViewController.swift
//  Tokopedia
//
//  Created by Setiady Wiguna on 6/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render

class ProductShipmentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    fileprivate var shipments: [ProductShipment]
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(shipments: [ProductShipment]) {
        self.shipments = shipments
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setWhite()
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
        
        self.title = "Kurir"
        
        AnalyticsManager.trackScreenName("Product Detail - Shipment Page")
    }
    
    // MARK: - UITableView Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shipments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ??
            ComponentTableViewCell<ProductShipmentComponentView>()
        if let cell = cell as? ComponentTableViewCell<ProductShipmentComponentView> {
            cell.mountComponentIfNecessary(ProductShipmentComponentView())
            cell.state = ProductShipmentState(shipment: self.shipments[indexPath.row])
            cell.render(in: cell.bounds.size)
        }
        return cell
    }
}

// MARK: - ProductShipmentComponentView

struct ProductShipmentState: StateType {
    let shipment: ProductShipment
    
    init(shipment: ProductShipment) {
        self.shipment = shipment
    }
}

class ProductShipmentComponentView: ComponentView<ProductShipmentState> {
    
    override func construct(state: ProductShipmentState?, size: CGSize = CGSize.undefined) -> NodeType {
        func iconView() -> NodeType {
            guard let shipment = state?.shipment else {
                return NilNode()
            }
            
            return Node<UIImageView>() { view, layout, _ in
                layout.width = 40
                layout.height = 40
                layout.marginLeft = 15
                layout.marginRight = 15
                layout.alignSelf = .center
                
                view.backgroundColor = .white
                view.contentMode = .scaleAspectFit
                view.clipsToBounds = true
                view.setImageWith(URL(string: shipment.logo))
            }
        }
        
        func titleView() -> NodeType {
            guard let shipment = state?.shipment else {
                return NilNode()
            }
            
            return Node<UILabel> { view, layout, _ in
                layout.marginBottom = 4
                view.font = .title1Theme()
                view.textColor = .tpPrimaryBlackText()
                view.text = shipment.name
            }
        }
        
        func packageView(packageName: String) -> NodeType {
            return Node { _, layout, _ in
                layout.flexDirection = .row
                layout.marginRight = 10
            }.add(children: [
                Node<UIImageView>() { view, layout, _ in
                    layout.width = 16
                    layout.height = 16
                    layout.marginRight = 4
                    view.image = UIImage(named: "icon_tick_grey")
                },
                Node<UILabel> { view, _, _ in
                    view.font = .microTheme()
                    view.textColor = .tpSecondaryBlackText()
                    view.text = packageName
                }
            ])
        }
        
        func packageContentView() -> NodeType {
            guard let packages = state?.shipment.packages.map({ (package) -> NodeType in
                packageView(packageName: package)
            }) else {
                return NilNode()
            }
            
            if state?.shipment.packages.count == 0 {
                return NilNode()
            }
            
            return Node { _, layout, _ in
                layout.flexDirection = .row
                layout.flexWrap = .wrap
            }.add(children: packages)
        }
        
        func contentView() -> NodeType {
            return Node { _, layout, _ in
                layout.flexDirection = .column
            }.add(children: [
                titleView(),
                packageContentView()
            ])
        }
        
        return Node<UIView>() { _, layout, size in
            layout.paddingLeft = 8
            layout.paddingRight = 8
            layout.paddingTop = 14
            layout.paddingBottom = 14
            
            layout.width = size.width
            layout.flexDirection = .row
        }.add(children: [
            iconView(),
            contentView()
        ])
    }
    
}
