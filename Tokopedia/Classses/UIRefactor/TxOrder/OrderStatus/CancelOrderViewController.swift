//
//  CancelOrderViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 11/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc(CancelOrderViewController) class CancelOrderViewController: UIViewController {

    @IBOutlet private weak var reasonTextView: RSKPlaceholderTextView!
    
    var order : TxOrderStatusList = TxOrderStatusList()
    private var barButtonDone : UIBarButtonItem = UIBarButtonItem()
    var didRequestCancelOrder: (TxOrderStatusList) -> Void = {_ in }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Ajukan Pembatalan"
        self.adjustBarButtonIsLoading(false)
        self.reasonTextView.placeholder = "Jelaskan Alasan Pembatalan"
    }
    
    private func adjustBarButtonIsLoading(isLoading:Bool){
        if isLoading {
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
            indicator.startAnimating()
            barButtonDone = UIBarButtonItem(customView: indicator)
        } else {
            barButtonDone = UIBarButtonItem(title: "Ajukan", style: .Plain, target: self, action: #selector(requestCancelOrder))
        }
        self.navigationItem.rightBarButtonItem = barButtonDone
    }
    
    @objc private func requestCancelOrder(){
        self.adjustBarButtonIsLoading(true)
        
        RequestOrderAction.fetchRequestCancelOrderID(order.order_detail.detail_order_id, reason: reasonTextView.text, onSuccess: { [weak self] in
            
            if let wself = self {
                wself.adjustBarButtonIsLoading(false)
                wself.didRequestCancelOrder(wself.order)
                
                wself.navigationController?.popViewControllerAnimated(true)
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
