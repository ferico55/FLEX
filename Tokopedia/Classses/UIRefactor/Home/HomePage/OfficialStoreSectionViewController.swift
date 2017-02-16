//
//  OfficialStoreSectionViewController.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 1/24/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import OAStackView
import Masonry
import BlocksKit

@objc
class OfficialStoreHomeItem: NSObject {
    var shopId: String = ""
    var imageUrl: String = ""
    var shopName: String = ""
    
    static func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: OfficialStoreHomeItem.self)
        
        mapping.addAttributeMappingsFromDictionary([
            "shop_id": "shopId",
            "logo_url": "imageUrl",
            "shop_name": "shopName"
        ])
        return mapping
    }
}

@objc(OfficialStoreSectionViewController)
class OfficialStoreSectionViewController: UIViewController {

    private let shops: [OfficialStoreHomeItem]
    
    @IBOutlet private var imageContainer: OAStackView!

    init(shops: [OfficialStoreHomeItem]) {
        self.shops = shops
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shops.forEach { shop in
            let view = UIView()
            view.backgroundColor = .whiteColor()
            view.mas_makeConstraints { make in
                make.width.equalTo()(view.mas_height)
                make.width.greaterThanOrEqualTo()(1)
            }
            
            let imageView = UIImageView()
            imageView.contentMode = .ScaleAspectFit
            view.addSubview(imageView)
            
            imageView.mas_makeConstraints { make in
                make.top.left().equalTo()(view).offset()(5)
                make.bottom.right().equalTo()(view).offset()(-5)
            }

            imageView.setImageWithURL(NSURL(string: shop.imageUrl)!)
            
            imageContainer.addArrangedSubview(view)
            
            view.bk_whenTapped { [unowned self] in
                self.openShopWithItem(shop)
            }
        }
        
        for _ in 0.stride(to: 4-shops.count, by: 1) {
            let stretchView = UIView()
            stretchView.backgroundColor = .clearColor()
            
            imageContainer.addArrangedSubview(stretchView)
        }
    }

    private func openShopWithItem(shop: OfficialStoreHomeItem) {
        AnalyticsManager.trackEventName(
            "clickOfficialStore",
            category: GA_EVENT_CATEGORY_HOMEPAGE,
            action: GA_EVENT_ACTION_CLICK,
            label: "Official Store - \(shop.shopName)")
        
        let viewController = ShopViewController()
        viewController.data = [
            "shop_id": shop.shopId
        ]
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}
