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
        if wallet.shouldShowActivation {
            openActivationPage()
        }else {
            guard let data = wallet.data,
                let action = data.action,
                let url = URL (string : action.applinks) else { return }
            TPRoutes.routeURL(url)
        }
    }
    
    func tapResponse(_ sender: UITapGestureRecognizer) {
        if wallet.shouldShowActivation {
            if (wallet.data?.hasPendingCashback)! {
                let closeButton = CFAlertAction.action(title: "Tutup", style: .Cancel, alignment: .justified, backgroundColor: .lightGray, textColor: .lightGray, handler: nil)
                let cashbackButton = CFAlertAction.action(title: "Dapatkan Cashback Sekarang", style: .Default, alignment: .justified, backgroundColor: UIColor.tpGreen(), textColor: .white) { [weak self] _ in
                    TPRoutes.routeURL(URL(string: (self?.wallet.data?.action?.applinks)!)!)
                }
                
                let actionSheet = TooltipAlert.createAlert(title: "Bonus Cashback", subtitle: "Anda mendapatkan cashback Tokocash sebesar \((wallet.data?.balance)!)", image: UIImage(named: "icon_cashback")!, buttons:[cashbackButton, closeButton])
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

    func openActivationPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "TokoCashActivationViewController")
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
}
