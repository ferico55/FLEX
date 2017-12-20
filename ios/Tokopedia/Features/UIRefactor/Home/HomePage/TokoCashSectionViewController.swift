//
//  TokoCashSectionViewController.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 4/25/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import CFAlertViewController

enum TokoCashSectionViewType {
    case compact
    case normal
}

class TokoCashSectionViewController: UIViewController {
    
    @IBOutlet private var btnTopUp: UIButton!
    @IBOutlet private var lblTitle: UILabel!
    @IBOutlet weak var lblBalance: UILabel!
    @IBOutlet weak var imgInfo: UIImageView!
    
    fileprivate var wallet: WalletStore
    fileprivate let userManager = UserAuthentificationManager()
    
    init(wallet: WalletStore, viewType: TokoCashSectionViewType = .normal) {
        self.wallet = wallet
        
        switch viewType {
        case .normal:
            super.init(nibName: "TokoCashSectionViewController", bundle: nil)
            break
        case .compact:
            super.init(nibName: "TokoCashSmallSectionViewController", bundle: nil)
            break
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapResponse))
        gestureRecognizer.numberOfTapsRequired = 1
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(gestureRecognizer)
        
        arrangeDisplay()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setWallet(wallet: WalletStore) {
        self.wallet = wallet
        
        arrangeDisplay()
    }
    
    func arrangeDisplay() {
        guard let data = wallet.data else {
            return
        }
        
        btnTopUp.setTitle(data.action?.text, for: .normal)
        lblBalance.setText(data.balance, animated: false)
        lblTitle.setText(data.text, animated: false)
        
        if data.hasPendingCashback {
            imgInfo.isHidden = false
            lblBalance.textColor = UIColor(white: 0, alpha: 0.38)
            btnTopUp.isHidden = true    // btn aktivasi
        }
        else if data.link == 1 {
            btnTopUp.isHidden = true    // btn aktivasi
        }
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
                    self?.openActivationPage()
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
        navigationController?.pushViewController(controller, animated: true)
    }

    func openActivationPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "TokoCashActivationViewController")
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
}
