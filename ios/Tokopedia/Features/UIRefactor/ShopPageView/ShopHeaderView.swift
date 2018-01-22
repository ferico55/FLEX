//
//  ShopHeaderView.swift
//  Tokopedia
//
//  Created by Hans Arijanto on 29/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

struct ShopHeaderViewModel {
    var shop: DetailShopResult?         = nil
    var ownShop: Bool                   = false
    var favoriteRequestInProgress: Bool = false
}

class ShopHeaderView: UIView, CMPopTipViewDelegate {
    
    var onTapMessageButton   : (() -> Void)? = nil
    var onTapSettingsButton  : (() -> Void)? = nil
    var onTapAddProductButton: (() -> Void)? = nil
    var onTapFavoriteButton  : (() -> Void)? = nil

    @IBOutlet private weak var activityContainer  : UIView!
    @IBOutlet private weak var activityTitle      : UILabel!
    @IBOutlet private weak var activityReason     : UILabel!
    @IBOutlet private(set) weak var mainStackView : UIStackView!
    @IBOutlet private weak var shopBanner         : UIImageView!
    @IBOutlet private weak var shopAvatar         : UIImageView!
    @IBOutlet private weak var shopNameLabel      : UILabel!
    @IBOutlet private weak var medalContainer     : UIStackView!
    @IBOutlet private weak var shopBadgeIcon      : UIImageView!
    @IBOutlet private weak var chatButton         : ActionButton!
    @IBOutlet private weak var tambahProdukButton : ActionButton!
    @IBOutlet private weak var aturTokoButton     : ActionButton!
    @IBOutlet private weak var favoriteButton     : FavoriteButton!
    @IBOutlet private weak var favoriteContainer  : UIView!
    
    var viewModel: ShopHeaderViewModel? = nil {
        didSet {
            self.updateUI()
        }
    }
    
    class func instanceFromNib() -> ShopHeaderView {
        let header = UINib(nibName: "ShopHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ShopHeaderView
        
        // setting custom font
        header.shopNameLabel.font  = UIFont.title1ThemeMedium()
        header.activityTitle.font  = UIFont.smallThemeMedium()
        header.activityReason.font = UIFont.smallTheme()
        header.activityReason.numberOfLines = 0
        
        return header
    }
    
    // called when the view model is updated
    private func updateUI() {
        if let vm = self.viewModel, let shop = vm.shop {
            self.shopBanner.setImageWith(URL(string:shop.info.isOfficial || shop.info.hasGoldBadge ? shop.info.shop_cover:""))
            self.shopAvatar.setImageWith(URL(string:shop.info.shop_avatar))
            self.setupMedals(shop: shop)
            
            self.shopNameLabel.text = shop.info.shop_name
            
            var badgeImage : UIImage? = nil
            if shop.info.isOfficial {
                badgeImage = #imageLiteral(resourceName: "badge_official")
            } else if shop.info.hasGoldBadge {
                badgeImage = #imageLiteral(resourceName: "Badges_gold_merchant")
            }
            self.shopBadgeIcon.image = badgeImage
            
            self.aturTokoButton.isHidden     = !vm.ownShop
            self.tambahProdukButton.isHidden = !vm.ownShop
            self.chatButton.isHidden         = vm.ownShop
            self.favoriteContainer.isHidden  = vm.ownShop
            
            self.favoriteButton.isFavorite = shop.info.isFavorite
            self.favoriteButton.isHidden   = vm.favoriteRequestInProgress
            
            let activity = shop.activity
            if activity == .open {
                self.activityContainer.isHidden = true
            } else {
                self.activityContainer.isHidden = false
                self.activityTitle.text         = activity == .other ? shop.info.shop_status_title.strippingHTML() : "Toko akan tutup sampai : " + shop.closed_info.until
                self.activityReason.text        = NSAttributedString(fromHTML: shop.info.shop_status_message).string
            }
        }
    }
    
    // creates the medal icons based on shop data
    private func setupMedals(shop: DetailShopResult) {
        
        if shop.info.isOfficial {
            self.medalContainer.isHidden = true
            return
        }
        
        self.medalContainer.removeAllSubviews()
        self.medalContainer.isHidden = false
        
        var medalImage = #imageLiteral(resourceName: "icon_medal14")
        if let set = Int(shop.stats.shop_badge_level.set), let level = set == 0 ? 1 : Int(shop.stats.shop_badge_level.level) {
            switch (set) {
                case 1:
                    medalImage = #imageLiteral(resourceName: "icon_medal_bronze14")
                case 2:
                    medalImage = #imageLiteral(resourceName: "icon_medal_silver14")
                case 3:
                    medalImage = #imageLiteral(resourceName: "icon_medal_gold14")
                case 4:
                    medalImage = #imageLiteral(resourceName: "icon_medal_diamond_one14")
                default:
                    break;
            }
            
            for _ in 0..<level {
                let imgView = UIImageView(image: medalImage)
                self.medalContainer.addArrangedSubview(imgView)
            }
        }
    }
    
    // MARK: Callbacks from xib
    @IBAction func didTapChatButton(_ sender: UIButton) {
        self.onTapMessageButton?()
    }
    
    @IBAction func didTapTambahProdukButton(_ sender: UIButton) {
        self.onTapAddProductButton?()
    }
    
    @IBAction func didTapAturTokoButton(_ sender: UIButton) {
        self.onTapSettingsButton?()
    }
    
    @IBAction func didTapFavoriteButton(_ sender: UIButton) {
        self.onTapFavoriteButton?()
    }
    
    // show tip view when medal is tapped
    @IBAction func didTapMedal(_ sender: UITapGestureRecognizer) {
        if let vm = self.viewModel, let shop = vm.shop, let tipView = CMPopTipView(message: shop.stats.pointsText) {
            tipView.textFont           = UIFont.boldSystemFont(ofSize: 13.0)
            tipView.textColor          = .white
            tipView.delegate           = self
            tipView.backgroundColor    = .black
            tipView.animation          = .slide
            tipView.dismissTapAnywhere = true
            
            tipView.presentPointing(at: sender.view, in: self, animated: true)
        }
    }
    
    // MARK: cmPopTipViewDelegate Callbacks
    func popTipViewWasDismissed(byUser popTipView: CMPopTipView!) {
    }
}
