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

@objc(OfficialStoreSectionViewController)
class OfficialStoreSectionViewController: UIViewController {
    
    fileprivate var separatorGrayColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.12)
    fileprivate var newRedColor = UIColor(red: 234.0/255, green: 33.0/255, blue: 45.0/255, alpha: 1.0)

    private let shops: [OfficialStoreHomeItem]
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var separator2: UIView!
    @IBOutlet weak var buttonSeeAll: UIButton!
    @IBOutlet weak var separator2ToTop: NSLayoutConstraint!
    @IBOutlet weak var baseViewHeight: NSLayoutConstraint!
    @IBOutlet weak var secondImageContainerHeight: NSLayoutConstraint!
    
    @IBOutlet private var imageContainer: OAStackView!
    @IBOutlet private var secondRowImageContainer: OAStackView!

    init(shops: [OfficialStoreHomeItem]) {
        self.shops = shops
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shops.enumerated().forEach { (index, shop) in
            let view = UIView()
            view.backgroundColor = .white
            view.mas_makeConstraints { make in
                if (UIDevice.current.userInterfaceIdiom == .pad) {
                    make?.height.equalTo()(150)
                } else {
                    make?.height.equalTo()(75)
                }
            }
            
            var modIndex:Int!
            if UIDevice.current.userInterfaceIdiom == .pad {
                modIndex = 6
            } else {
                modIndex = 3
            }
            if index % modIndex != 0 {
                let separatorView = UIView()
                separatorView.backgroundColor = separatorGrayColor
                view.addSubview(separatorView)
                separatorView.mas_makeConstraints { make in
                    make?.width.equalTo()(1)
                    make?.left.equalTo()(0)?.offset()(-5)
                    make?.bottom.equalTo()(0)
                    make?.top.equalTo()(0)
                }
            }
            
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            view.addSubview(imageView)
            
            imageView.mas_makeConstraints { make in
                make?.top.left().equalTo()(view)?.offset()(5)
                make?.bottom.right().equalTo()(view)?.offset()(-5)
            }

            imageView.setImageWith(NSURL(string: shop.imageUrl)! as URL!)
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                if index > 2 {
                    secondRowImageContainer.addArrangedSubview(view)
                }
                else {
                    imageContainer.addArrangedSubview(view)
                }
                if shops.count < 4 {
                    secondImageContainerHeight.constant = 0
                    baseViewHeight.constant = 209
                    separator2ToTop.constant = -15;
                    separator2.backgroundColor = .clear
                }
            } else {
                imageContainer.addArrangedSubview(view)
                secondImageContainerHeight.constant = 0
                baseViewHeight.constant = 209
                separator2ToTop.constant = -15;
                separator2.backgroundColor = .clear
            }
        
            view.bk_(whenTapped: { [unowned self] in
                self.openShopWithItem(shop)
            })

            if shop.isNew {
                let newText = UITextView()
                newText.text = "BARU"
                newText.textColor = .white
                newText.font = UIFont.superMicroTheme()
                newText.backgroundColor = newRedColor
                newText.textContainerInset = UIEdgeInsetsMake(2, 0, 2, 0)
                newText.cornerRadius = 2
                view.addSubview(newText)
                
                newText.mas_makeConstraints{ make in
                    make?.left.top().equalTo()(view)?.offset()(5)
                    make?.width.equalTo()(36)
                    make?.height.equalTo()(15)
                }
            }
        }
        
        buttonSeeAll.bk_(whenTapped: { [unowned self] in
            self.goToWebView("\(NSString.mobileSiteUrl())/official-store/mobile")
        })
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
        let loginState = authenticationManager.isLogin ? "Login" : "Non Login"
        
        AnalyticsManager.trackEventName(
            "clickOfficialStore",
            category: GA_EVENT_CATEGORY_HOMEPAGE,
            action: GA_EVENT_ACTION_CLICK,
            label: "Official Store Visit Microsite - \(loginState)")
        
        let webViewVC = WebViewController()
        webViewVC.strURL = authenticationManager.webViewUrl(fromUrl: urlString)
        webViewVC.strTitle = "Official Store";
        webViewVC.shouldAuthorizeRequest = authenticationManager.isLogin
        self.navigationController?.pushViewController(webViewVC, animated: true)
    }
}
