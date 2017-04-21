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
import RestKit

@objc
class OfficialStoreHomeItem: NSObject {
    var shopId: String = ""
    var imageUrl: String = ""
    var shopName: String = ""
    
    static func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(for: OfficialStoreHomeItem.self)
        
        mapping?.addAttributeMappings(from: [
            "shop_id": "shopId",
            "logo_url": "imageUrl",
            "shop_name": "shopName"
        ])
        return mapping!
    }
}

@objc(OfficialStoreSectionViewController)
class OfficialStoreSectionViewController: UIViewController {
    
    fileprivate var separatorGrayColor = UIColor(red: 241.0/255, green: 241.0/255, blue: 241.0/255, alpha: 1.0)

    private let shops: [OfficialStoreHomeItem]
    
    @IBOutlet weak var buttonSeeAll: UIButton!
    
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
            view.backgroundColor = .white
            view.layer.borderColor = separatorGrayColor.cgColor
            view.layer.cornerRadius = 2
            view.layer.borderWidth = 1
            view.mas_makeConstraints { make in
                make?.width.equalTo()(view.mas_height)
                make?.width.greaterThanOrEqualTo()(1)
            }
            
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            view.addSubview(imageView)
            
            imageView.mas_makeConstraints { make in
                make?.top.left().equalTo()(view)?.offset()(5)
                make?.bottom.right().equalTo()(view)?.offset()(-5)
            }

            imageView.setImageWith(NSURL(string: shop.imageUrl)! as URL!)
            
            imageContainer.addArrangedSubview(view)
            
            view.bk_(whenTapped: { [unowned self] in
                self.openShopWithItem(shop)
            })
            
            buttonSeeAll.bk_(whenTapped: { [unowned self] in
                self.goToWebView("\(NSString.mobileSiteUrl())/official-store/mobile")
            })
        }
        
        for _ in stride(from: 0, to: 4-shops.count, by: 1) {
            let stretchView = UIView()
            stretchView.backgroundColor = .clear
            
            imageContainer.addArrangedSubview(stretchView)
        }
    }

    private func openShopWithItem(_ shop: OfficialStoreHomeItem) {
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
    
    fileprivate func goToWebView(_ urlString: String) {
        let authenticationManager = UserAuthentificationManager()
        
        let webViewVC = WebViewController()
        webViewVC.strURL = authenticationManager.webViewUrl(fromUrl: urlString)
        webViewVC.shouldAuthorizeRequest = authenticationManager.isLogin
        self.navigationController?.pushViewController(webViewVC, animated: true)
    }
}
