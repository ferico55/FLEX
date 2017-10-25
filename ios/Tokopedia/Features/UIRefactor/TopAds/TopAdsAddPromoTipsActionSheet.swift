//
//  TopAdsAddPromoTipsActionSheet.swift
//  Tokopedia
//
//  Created by Dhio Etanasti on 10/9/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import CFAlertViewController
import WebKit

class TopAdsAddPromoTipsActionSheet: CFAlertViewController {
    
    var owningViewController: UIViewController?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let bundle = Bundle(for: CFAlertViewController.self)
        super.init(nibName: "CFAlertViewController", bundle: bundle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        // height is the only thing that matters
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: UIScreen.main.applicationFrame.size.height <= 568 ? 140 : 130))
        headerView.backgroundColor = .white
        self.init(title: "",
                  titleColor: .black,
                  message: "",
                  messageColor: .black,
                  textAlignment: .center,
                  preferredStyle: UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet,
                  headerView: headerView,
                  footerView: nil,
                  didDismissAlertHandler: { _ in })
        
        let titleLabel = UILabel()
        titleLabel.text = "Tips"
        titleLabel.textColor = .tpPrimaryBlackText()
        titleLabel.font = .title1ThemeSemibold()
        headerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(headerView).offset(25)
            make.left.equalTo(headerView).offset(16)
        }
        
        if (UIScreen.main.applicationFrame.size.height <= 568) {
            let infoLabel = UILabel()
            infoLabel.text = "Kelompokkan produk-produk dengan kategori yang serupa dalam satu grup promo, untuk memudahkan Anda dalam mengatur Promo."
            infoLabel.textColor = .tpSecondaryBlackText()
            infoLabel.font = .largeTheme()
            infoLabel.numberOfLines = 0
            headerView.addSubview(infoLabel)
            infoLabel.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(10)
                make.left.equalTo(headerView).offset(16)
                make.right.equalTo(headerView).offset(-16)
            }
        } else {
            let lampImageView = UIImageView()
            lampImageView.image = UIImage(named: "lamp")
            lampImageView.contentMode = .scaleAspectFit
            headerView.addSubview(lampImageView)
            lampImageView.snp.makeConstraints { make in
                make.top.equalTo(headerView).offset(5)
                make.width.equalTo(110)
                make.height.equalTo(90)
                make.right.equalTo(headerView).offset(-5)
            }
            
            let infoLabel = UILabel()
            infoLabel.text = "Kelompokkan produk-produk dengan kategori yang serupa dalam satu grup promo, untuk memudahkan Anda dalam mengatur Promo."
            infoLabel.textColor = .tpSecondaryBlackText()
            infoLabel.font = .largeTheme()
            infoLabel.numberOfLines = 0
            headerView.addSubview(infoLabel)
            infoLabel.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(10)
                make.left.equalTo(headerView).offset(16)
                make.right.equalTo(lampImageView.snp.right).offset(-70)
            }
        }
        
        let closeButton = CFAlertAction.action(title: "Tutup", style: .Default, alignment: .justified, backgroundColor: .tpGreen(), textColor: .white, handler: nil)
        self.addAction(closeButton)
    }
    
    func show() {
        if let vc = UIApplication.topViewController() {
            owningViewController = vc
            vc.present(self, animated: true, completion: nil)
        }
    }
}

