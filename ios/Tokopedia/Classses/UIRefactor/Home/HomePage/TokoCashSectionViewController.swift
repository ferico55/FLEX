//
//  TokoCashSectionViewController.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 4/25/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import CFAlertViewController
import SnapKit

@objc(TokoCashSectionViewController)
class TokoCashSectionViewController: UIViewController {
    
    @IBOutlet private var icon: UIImageView!
    @IBOutlet private var lblBalance: UILabel!
    @IBOutlet private var btnTopUp: UIButton!
    @IBOutlet private var lblTitle: UILabel!
    @IBOutlet private var lblPending: UILabel!
    @IBOutlet private var iconPending: UIImageView!
    
    fileprivate let wallet: WalletStore
    fileprivate let userManager = UserAuthentificationManager()
    
    init(wallet: WalletStore) {
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnTopUp.setTitle(wallet.data?.action?.text, for: .normal)
        lblBalance.setText(wallet.data?.balance, animated: false)
        lblTitle.setText(wallet.data?.text, animated: false)
        if (wallet.data?.hasPendingCashback)! {
            lblPending.isHidden = false
            iconPending.isHidden = false
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapResponse))
        gestureRecognizer.numberOfTapsRequired = 1
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(gestureRecognizer)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didTap(_ sender: Any) {
        TPRoutes.routeURL(URL(string: (wallet.data?.action?.applinks)!)!)
    }
    
    func tapResponse(_ sender: UITapGestureRecognizer) {
        if wallet.shouldShowActivation {
            if (wallet.data?.hasPendingCashback)! {
                var style = CFAlertViewController.CFAlertControllerStyle.actionSheet
                if UIDevice.current.userInterfaceIdiom == .pad {
                    style = CFAlertViewController.CFAlertControllerStyle.alert
                }
                
                let actionSheet = CFAlertViewController.alertController(title: nil, message: nil, textAlignment: .center, preferredStyle: style, didDismissAlertHandler: nil)
                
                actionSheet.headerView = createHeaderView()
                
                let cashbackButton = CFAlertAction.action(title: "Dapatkan Cashback Sekarang", style: .Default, alignment: .justified, backgroundColor: UIColor.tpGreen(), textColor: .white) { [weak self] _ in
                    TPRoutes.routeURL(URL(string: (self?.wallet.data?.action?.applinks)!)!)
                }
                
                let closeButton = CFAlertAction.action(title: "Tutup", style: .Cancel, alignment: .justified, backgroundColor: .lightGray, textColor: .lightGray) { _ in
                    actionSheet.dismiss(animated: false, completion: nil)
                }
                
                actionSheet.addAction(cashbackButton)
                actionSheet.addAction(closeButton)
                present(actionSheet, animated: true, completion: nil)
            }
        } else {
            openWebView()
        }
    }
    
    func openWebView() {
        let controller = WKWebViewController(urlString: userManager.webViewUrl(fromUrl: wallet.walletFullUrl()), shouldAuthorizeRequest: true)
        controller.title = wallet.data?.text
        
        controller.didTapBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: false)
    }
    
    func createHeaderView() -> UIView {
        let headerView = UIView()
        let image = UIImage(named: "icon_cashback")
        let imageView = UIImageView(image: image)
        let title = UILabel()
        title.font = UIFont.title1ThemeSemibold()
        title.text = "Bonus Cashback"
        
        let message = UILabel()
        message.font = UIFont.largeTheme()
        message.numberOfLines = 0
        message.text = "Anda mendapatkan cashback Tokocash sebesar \((wallet.data?.balance)!)"
        message.lineBreakMode = .byWordWrapping
        message.sizeToFit()
        
        headerView.addSubview(title)
        headerView.addSubview(message)
        headerView.addSubview(imageView)
        
        title.snp.makeConstraints({ make in
            make.top.equalTo(headerView.snp.top).inset(20)
            make.left.equalTo(headerView.snp.left).inset(20)
            make.right.equalTo(message.snp.right)
        })
        
        message.snp.makeConstraints({ make in
            make.left.equalTo(title.snp.left)
            make.right.equalTo(imageView.snp.left)
            make.top.equalTo(title.snp.bottom).offset(10)
        })
        
        imageView.snp.makeConstraints({ make in
            make.top.equalTo(title.snp.top)
            make.right.equalTo(headerView.snp.right).inset(20)
            make.height.equalTo((image?.size.height)!)
            make.width.equalTo((image?.size.width)!)
            make.bottom.equalTo(headerView.snp.bottom).inset(10)
        })
        
        imageView.contentMode = .scaleAspectFit
        
        let size = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        headerView.frame = CGRect(x: headerView.frame.origin.x, y: headerView.frame.origin.y, width: headerView.frame.width, height: size.height)
        headerView.setNeedsLayout()
        
        return headerView
    }
}
