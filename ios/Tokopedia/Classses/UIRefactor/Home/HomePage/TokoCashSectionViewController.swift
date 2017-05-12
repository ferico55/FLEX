//
//  TokoCashSectionViewController.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 4/25/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc (TokoCashSectionViewController)
class TokoCashSectionViewController: UIViewController {

    @IBOutlet private var icon: UIImageView!
    @IBOutlet private var lblBalance: UILabel!
    @IBOutlet private var btnTopUp: UIButton!
    @IBOutlet private var lblTitle: UILabel!
    
    fileprivate let wallet:WalletStore
    fileprivate let userManager = UserAuthentificationManager()
    
    init(wallet:WalletStore) {
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
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapResponse))
        gestureRecognizer.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(gestureRecognizer)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didTap(_ sender: Any) {
        TPRoutes.routeURL(URL(string: (wallet.data?.action?.applinks)!)!)
    }

    func tapResponse(_ sender: UITapGestureRecognizer) {
        if (!wallet.shouldShowActivation()) {
            let controller = WKWebViewController(urlString: self.userManager.webViewUrl(fromUrl: wallet.walletFullUrl()), shouldAuthorizeRequest:true)
            controller.title = wallet.data?.text
            
            controller.didTapBack = { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: false)
        }
        
    }

}
