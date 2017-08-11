//
//  CancelOrderViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 11/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RSKPlaceholderTextView

@objc(CancelOrderViewController) class CancelOrderViewController: UIViewController {

    @IBOutlet fileprivate weak var reasonTextView: RSKPlaceholderTextView!
    
    var order : TxOrderStatusList = TxOrderStatusList()
    fileprivate var barButtonDone : UIBarButtonItem = UIBarButtonItem()
    var didRequestCancelOrder: (TxOrderStatusList) -> Void = {_ in }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Ajukan Pembatalan"
        self.adjustBarButtonIsLoading(false)
        self.reasonTextView.placeholder = "Jelaskan Alasan Pembatalan"
    }
    
    fileprivate func adjustBarButtonIsLoading(_ isLoading:Bool){
        if isLoading {
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
            indicator.startAnimating()
            barButtonDone = UIBarButtonItem(customView: indicator)
        } else {
            barButtonDone = UIBarButtonItem(title: "Ajukan", style: .plain, target: self, action: #selector(requestCancelOrder))
        }
        self.navigationItem.rightBarButtonItem = barButtonDone
    }
    
    @objc fileprivate func requestCancelOrder(){
        self.adjustBarButtonIsLoading(true)
        
        RequestOrderAction.fetchRequestCancelOrderID(order.order_detail.detail_order_id, reason: reasonTextView.text, onSuccess: { [weak self] in
            
            if let wself = self {
                wself.adjustBarButtonIsLoading(false)
                wself.didRequestCancelOrder(wself.order)
                
                wself.navigationController?.popViewController(animated: true)
            }

        }) {  [weak self] in
            if let wself = self {
                wself.adjustBarButtonIsLoading(false)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
