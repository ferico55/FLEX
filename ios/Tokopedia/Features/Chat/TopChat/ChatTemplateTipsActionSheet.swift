//
//  ChatTemplateTipsActionSheet.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 13/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import CFAlertViewController

class ChatTemplateTipsActionSheet: CFAlertViewController {
    
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
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 130))
        headerView.backgroundColor = .white
        self.init(title: "",
                  titleColor: .black,
                  message: "",
                  messageColor: .black,
                  textAlignment: .center,
                  preferredStyle: .actionSheet,
                  headerView: headerView,
                  footerView: nil,
                  didDismissAlertHandler: { _ in })
        
        let titleLabel = UILabel()
        titleLabel.text = "Kelola Template Pesan"
        titleLabel.textColor = .tpPrimaryBlackText()
        titleLabel.font = .title1ThemeSemibold()
        headerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(headerView).offset(25)
            make.left.equalTo(headerView).offset(16)
        }
        
        let ImageView = UIImageView()
        ImageView.image = UIImage(named: "infoDragEdit")
        ImageView.contentMode = .scaleAspectFit
        headerView.addSubview(ImageView)
        ImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.width.equalTo(86)
            make.height.equalTo(67)
            make.right.equalTo(headerView).offset(-9)
        }
        
        let infoLabel = UILabel()
        infoLabel.text = "Ubah dengan tekan tombol edit, atau atur urutan dengan tahan dan geser tombol drag."
        infoLabel.textColor = .tpSecondaryBlackText()
        infoLabel.font = .largeTheme()
        infoLabel.numberOfLines = 0
        headerView.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalTo(headerView).offset(16)
            make.right.equalTo(ImageView.snp.left).offset(-9)
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
