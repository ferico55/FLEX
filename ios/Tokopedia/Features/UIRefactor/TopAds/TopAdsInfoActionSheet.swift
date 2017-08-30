//
//  TopAdsInfoActionSheet.swift
//  Tokopedia
//
//  Created by Dhio Etanasti on 7/5/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import CFAlertViewController
import WebKit

class TopAdsInfoActionSheet: CFAlertViewController {
    
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
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: UIScreen.main.applicationFrame.size.height <= 568 ? 140 : 110))
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
        titleLabel.text = "Promoted"
        titleLabel.textColor = .tpPrimaryBlackText()
        titleLabel.font = .title1ThemeSemibold()
        headerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(headerView).offset(25)
            make.left.equalTo(headerView).offset(16)
        }
        
        let infoLabel = UILabel()
        infoLabel.text = "Promosi oleh TopAds yang muncul berdasarkan minat Anda."
        infoLabel.textColor = .tpSecondaryBlackText()
        infoLabel.font = .largeTheme()
        infoLabel.numberOfLines = 0
        headerView.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.equalTo(headerView).offset(16)
        }
        
        let speakerImageView = UIImageView()
        speakerImageView.image = UIImage(named: "speaker")
        headerView.addSubview(speakerImageView)
        speakerImageView.snp.makeConstraints { make in
            make.width.equalTo(102)
            make.height.equalTo(65)
            make.centerY.equalTo(infoLabel.snp.centerY)
            make.left.equalTo(infoLabel.snp.right)
            make.right.equalTo(headerView).offset(-12)
        }
        
        let learnMoreButton = UIButton()
        learnMoreButton.setTitle("Pelajari Selengkapnya", for: .normal)
        learnMoreButton.setTitleColor(.tpGreen(), for: .normal)
        learnMoreButton.titleLabel!.font = .largeTheme()
        headerView.addSubview(learnMoreButton)
        learnMoreButton.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(11)
            make.left.equalTo(headerView).offset(16)
        }
        learnMoreButton.bk_(whenTapped: { [weak self] _ in
            self?.dismissAlert(withAnimation: true, completion: { _ in
                let urlString = "https://www.tokopedia.com/iklan?source=tooltip&medium=ios"
                
                if let vc = self?.owningViewController, let navCon = vc.navigationController {
                    let webViewController = WKWebViewController(urlString: urlString)
                    navCon.pushViewController(webViewController, animated: true)
                } else {
                    UIApplication.shared.openURL(URL(string: urlString)!)
                }
            })
        })
        
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
