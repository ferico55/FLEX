//
//  CancelOrderShipmentViewController.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 12/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding
import MMNumberKeyboard
import RSKGrowingTextView

@objc(CancelOrderShipmentViewController) class CancelOrderShipmentViewController: UIViewController, RSKGrowingTextViewDelegate, UITextViewDelegate {
    
    var onFinishRequestCancel: ((Bool) -> Void)!
    
    fileprivate let orderTransaction: OrderTransaction
    
    @IBOutlet fileprivate var tickerView: UIView!
    @IBOutlet fileprivate var messageLabel: UILabel!
    @IBOutlet fileprivate var tickerCTAButton: UIButton!
    
    @IBOutlet fileprivate var horizontalLine: UIView!
    @IBOutlet fileprivate var formView: UIView!
    @IBOutlet fileprivate var invoiceButton: UIButton!
    @IBOutlet fileprivate var buyerName: UILabel!
    @IBOutlet fileprivate var cancelInfoTitleLabel: UILabel!
    @IBOutlet fileprivate var cancelInfoTextView: RSKGrowingTextView!
    @IBOutlet fileprivate var minimalCharacterLabel: UILabel!
    @IBOutlet fileprivate var scrollView: TPKeyboardAvoidingScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Batalkan Pesanan"
        AnalyticsManager.trackScreenName("Cancel Order Shipment Page")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Kembali",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(didTapCancelButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Kirim",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapSubmitButton))
        
        setupForm()
        setupTicker()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    init(orderTransaction: OrderTransaction) {
        self.orderTransaction = orderTransaction
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Init View    
    fileprivate func setupForm() {
        cancelInfoTextView.delegate = self
        invoiceButton.setTitle(orderTransaction.order_detail.detail_invoice, for: .normal)
        buyerName.text = orderTransaction.order_customer.customer_name
        
        cancelInfoTitleLabel.isHidden = true
        minimalCharacterLabel.isHidden = true
    }
    
    fileprivate func setupTicker() {
        if tickerMessageLabel() == "" {
            tickerView.mas_updateConstraints({ (make) in
                make?.height.equalTo()(0)
            })
            
            return
        }
        
        messageLabel.text = tickerMessageLabel()
        tickerCTAButton.setTitle(tickerButtonLabel(), for: UIControlState())
    }
    
    //MARK: Init Ticker
    fileprivate func tickerMessageLabel() -> String {
        return "Mulai hari Senin, 7 November 2016, Tokopedia telah menetapkan sistem penalti reputasi toko untuk seller yang membatalkan pesanan.\n" +
        "Pembatalan pengiriman akan mendapatkan pengurangan reputasi sebesar 3 poin."
    }
    
    fileprivate func tickerButtonLabel() -> String {
        return "Pelajari Sistem Penalti"
    }
    
    fileprivate func tickerButtonURLString() -> String {
        let userManager = UserAuthentificationManager()
        return userManager.webViewUrl(fromUrl: "https://www.tokopedia.com/bantuan/penalti-reputasi/definisi-penalti-reputasi?flag_app=1&utm_source=ios")
    }
    
    //MARK: Button Action
    @objc fileprivate func didTapCancelButton() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func didTapSubmitButton() {
        if onFinishRequestCancel == nil {
            return
        }
        
        if cancelInfoTextView.text.characters.count < 10 {
            StickyAlertView.showErrorMessage(["Alasan pembatalan minimal 10 karakter"])
            return
        }
        
        AnalyticsManager.trackEventName("clickShipping", category: GA_EVENT_CATEGORY_SHIPPING, action: GA_EVENT_ACTION_CLICK, label: "Reject Shipment")
        doRequest()
    }
    
    @IBAction fileprivate func didTapTickerButton() {
        let controller = WebViewController()
        controller.strURL = tickerButtonURLString()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction fileprivate func didTapInvoice() {
        let invoiceURL = orderTransaction.order_detail.detail_pdf_uri
        if invoiceURL == "" {
            return
        }
        
        NavigateViewController.navigateToInvoice(from: self, withInvoiceURL: invoiceURL)
    }
    
    //MARK: UITextView Delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        cancelInfoTitleLabel.isHidden = false
        minimalCharacterLabel.isHidden = false
        horizontalLine.backgroundColor = UIColor.fromHexString("#42B549")
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            cancelInfoTitleLabel.isHidden = true
            minimalCharacterLabel.isHidden = true
        }
        horizontalLine.backgroundColor = UIColor.fromHexString("#9E9E9E")
    }
    
    //MARK: Methods
    fileprivate func doRequest() {
        showRequestIsOnProgress(true)
        let object: ProceedShippingObjectRequest = ProceedShippingObjectRequest()
        object.type = .reject
        object.orderID = orderTransaction.order_detail.detail_order_id
        object.reason = cancelInfoTextView.text
        
        ShipmentRequest.fetchProceedShipping(object, onSuccess: { [weak self] in
            guard let `self` = self else { return }
            self.onFinishRequestCancel?(true)
            self.navigationController?.dismiss(animated: true, completion: nil)
            }, onFailure: { [weak self] in
                guard let `self` = self else { return }
                self.onFinishRequestCancel?(false)
                self.showRequestIsOnProgress(false)
        })
    }
    
    fileprivate func showRequestIsOnProgress(_ isLoading: Bool) {
        if isLoading {
            let activityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            activityIndicatorView.color = UIColor.white
            activityIndicatorView.startAnimating()
            navigationItem.rightBarButtonItem?.customView = activityIndicatorView
        } else {
            navigationItem.rightBarButtonItem?.customView = nil
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Kirim",
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(didTapSubmitButton))
        }
    }
}
