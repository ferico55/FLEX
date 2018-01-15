//
//  ProductWishlistCell.swift
//  Tokopedia
//
//  Created by Tonito Acen on 3/11/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation
import OAStackView
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class ProductWishlistCell : UICollectionViewCell {
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productTrashButton: UIImageView!
    @IBOutlet weak var productBuyButton: UIButton!
    @IBOutlet weak var productShopName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var badgesView: OAStackView!
    @IBOutlet weak var labelsView: OAStackView!
    
    var imageDownloader = QueueImageDownloader()
    
    @IBOutlet weak var preorderPositionConstraint: NSLayoutConstraint!
    
    var tappedBuyButton: ((ProductWishlistCell) -> Void)?
    var tappedTrashButton: ((ProductWishlistCell) -> Void)?
    
    func setViewModel(_ viewModel : ProductModelView) {
        self.accessibilityLabel = "wishlistCell"
        productName.text = viewModel.productName
        productName.accessibilityLabel = viewModel.productName
        productPrice.text = viewModel.productPrice
        productShopName.text = viewModel.productShop
        
        locationLabel.text = viewModel.shopLocation
        
        if let urlString = viewModel.productThumbUrl, let url = URL(string: urlString) {
            productImage.setImageWithUrl(url, placeHolderImage: #imageLiteral(resourceName: "grey-bg"))
        } else {
            productImage.setImage(#imageLiteral(resourceName: "grey-bg"), animated: false)
        }
        
        let trashGesture = UITapGestureRecognizer(target: self, action: #selector(ProductWishlistCell.tapTrashButton))
        productTrashButton.addGestureRecognizer(trashGesture)
        productTrashButton.isUserInteractionEnabled = true
        
        if(viewModel.isProductBuyAble) {
            productBuyButton.backgroundColor = .tpOrange()
            productBuyButton.setTitle("Beli", for: .normal)
            productBuyButton.isUserInteractionEnabled = true
            productBuyButton.setTitleColor(.white, for: .normal)
        } else {
            productBuyButton.backgroundColor = UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 0.65)
            productBuyButton.setTitle("Stok Kosong", for: .normal)
            productBuyButton.setTitleColor(UIColor.lightGray, for: .normal)
            productBuyButton.layer.borderColor = UIColor.lightGray.cgColor
            productBuyButton.isUserInteractionEnabled = false
        }
        setBadges(viewModel.badges as [AnyObject]?)
        setLabels(viewModel.labels as [AnyObject]?)
        
    }
    
    internal func setLabels(_ labels: [AnyObject]?) {
        labelsView.arrangedSubviews.forEach { (subview) in
            labelsView .removeArrangedSubview(subview)
        }
        
        labelsView.alignment = .fill
        labelsView.spacing = 2
        labelsView.axis = .horizontal
        labelsView.distribution = .equalSpacing
        
        if(labels?.count > 0) {
            labels!.forEach { (productLabel) in
                let productObject = productLabel as! ProductLabel
                
                let label = UILabel(frame: CGRect.zero)
                label.text = "\(productObject.title) "
                label.backgroundColor = UIColor.fromHexString(productObject.color)
                label.textAlignment = .center
                label.layer.cornerRadius = 3
                label.layer.masksToBounds = true
                label.layer.borderWidth = 1.0
                label.layer.borderColor = (productObject.color == "#ffffff") ? UIColor.tpGray().cgColor : UIColor.fromHexString(productObject.color).cgColor
                label.textColor = (productObject.color == "#ffffff") ? .tpDisabledBlackText() : UIColor.white
                label.font = UIFont.superMicroTheme()
                
                self.labelsView .addArrangedSubview(label)
                
            }
        }
        
    }
    
    internal func setBadges(_ badges: [AnyObject]?) {
        badgesView.arrangedSubviews.forEach { (subview) in
            badgesView .removeArrangedSubview(subview)
        }
        
        badgesView.alignment = .fill
        badgesView.spacing = 2
        badgesView.axis = .horizontal
        badgesView.distribution = .fillEqually
        badgesView.alignment = .center
        
        if(badges?.count > 0) {
            var urls = [String]()
            badges!.forEach({ badge in
                let badgeObject = badge as! ProductBadge
                urls.append(badgeObject.image_url)
            })
            
            imageDownloader.downloadImages(withUrls: urls) { [weak self](images) in
                guard let `self` = self else { return }
                
                images?.forEach({ (image) in
                    if(image.size.width > 1) {
                        let imageView = UIImageView(frame: CGRect.zero)
                        imageView.image = image
                        
                        self.badgesView .addArrangedSubview(imageView)
                        
                        imageView.mas_makeConstraints({ (make) in
                            make?.width.equalTo()(self.badgesView.mas_height)
                            make?.height.equalTo()(self.badgesView.mas_height)
                        })

                    }
                })
            }
            
            locationLabel.mas_makeConstraints({ (make) in
                make?.trailing.equalTo()(self.badgesView.mas_leading)
            })

        }
        
    }
    
    @IBAction func tapBuyButton(_ sender: AnyObject) {
        tappedBuyButton?(self)
    }
    
    func tapTrashButton() {
        tappedTrashButton?(self)
    }

}
