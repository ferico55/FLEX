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

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buttonSeeAll.isAccessibilityElement = true
        buttonSeeAll.accessibilityIdentifier = "seeAllOfficialStore"
        var modIndex: Int!
        modIndex = shops.count
        if UIDevice.current.userInterfaceIdiom == .pad || shops.count < 4 {
            secondImageContainerHeight.constant = 0
            baseViewHeight.constant = 209
            separator2ToTop.constant = -15
            separator2.backgroundColor = .clear
        }
        if UIDevice.current.userInterfaceIdiom == .phone {
            modIndex = 3
        }

        shops.enumerated().forEach { index, shop in
            let view = UIView()
            view.backgroundColor = .white
            let height = (UIDevice.current.userInterfaceIdiom == .pad ? 150 : 75)
            view.mas_makeConstraints { make in
                make?.height.equalTo()(height)
            }

            if index % modIndex != 0 {
                let separatorView = UIView()
                separatorView.backgroundColor = .tpLine()
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
            imageView.isAccessibilityElement = true
            imageView.accessibilityIdentifier = "officialStore" + "\(index)"
            view.addSubview(imageView)

            imageView.mas_makeConstraints { make in
                make?.top.left().equalTo()(view)?.offset()(5)
                make?.bottom.right().equalTo()(view)?.offset()(-5)
            }

            imageView.setImageWith(NSURL(string: shop.imageUrl)! as URL!)

            if UIDevice.current.userInterfaceIdiom == .phone && index > 2 {
                secondRowImageContainer.addArrangedSubview(view)
            } else {
                imageContainer.addArrangedSubview(view)
            }

            view.bk_(whenTapped: { [unowned self] in
                self.openShopWithItem(shop)
            })
            
            buttonSeeAll.bk_(whenTapped: { [unowned self] in
                AnalyticsManager.trackEventName(GA_EVENT_NAME_USER_INTERACTION_HOMEPAGE, category: GA_EVENT_CATEGORY_HOMEPAGE_OFFICIAL_STORE_WIDGET, action: GA_EVENT_ACTION_CLICK_VIEW_ALL, label: "")
                let controller = OfficialStoreBrandsViewController()
                self.navigationController?.pushViewController(controller, animated: true)
            })

            if shop.isNew {
                let holder = UIView()
                holder.backgroundColor = .tpRed()
                holder.cornerRadius = 2
                view.addSubview(holder)
                
                holder.mas_makeConstraints { make in
                    make?.left.top().equalTo()(view)?.offset()(5)
                    make?.width.equalTo()(36)
                    make?.height.equalTo()(15)
                }
                
                let newText = UILabel()
                newText.isUserInteractionEnabled = false
                newText.text = "BARU"
                newText.textColor = .white
                newText.font = UIFont.superMicroTheme()
                holder.addSubview(newText)

                newText.mas_makeConstraints { make in
                    make?.left.equalTo()(holder)?.offset()(5)
                    make?.top.equalTo()(holder)?.offset()(2.5)
                }
            }
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
        let loginState = authenticationManager.isLogin ? "Login" : "Non Login"

        AnalyticsManager.trackEventName(
            "clickOfficialStore",
            category: GA_EVENT_CATEGORY_HOMEPAGE,
            action: GA_EVENT_ACTION_CLICK,
            label: "Official Store Visit Microsite - \(loginState)")

        let webViewVC = WebViewController()
        webViewVC.strURL = authenticationManager.webViewUrl(fromUrl: urlString)
        webViewVC.strTitle = "Official Store"
        webViewVC.shouldAuthorizeRequest = authenticationManager.isLogin
        navigationController?.pushViewController(webViewVC, animated: true)
    }
}
