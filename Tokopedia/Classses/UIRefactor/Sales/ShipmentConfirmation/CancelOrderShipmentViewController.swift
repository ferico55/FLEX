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

@objc(CancelOrderShipmentViewController) class CancelOrderShipmentViewController: UIViewController, RSKGrowingTextViewDelegate, UITextViewDelegate {
    
    var onFinishRequestCancel: ((Bool) -> Void)!
    
    private let orderTransaction: OrderTransaction
    
    @IBOutlet private var tickerView: UIView!
    @IBOutlet private var messageLabel: UILabel!
    @IBOutlet private var tickerCTAButton: UIButton!
    
    @IBOutlet private var horizontalLine: UIView!
    @IBOutlet private var formView: UIView!
    @IBOutlet private var invoiceButton: UIButton!
    @IBOutlet private var buyerName: UILabel!
    @IBOutlet private var cancelInfoTitleLabel: UILabel!
    @IBOutlet private var cancelInfoTextView: RSKGrowingTextView!
    @IBOutlet private var minimalCharacterLabel: UILabel!
    @IBOutlet private var scrollView: TPKeyboardAvoidingScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Batalkan Pesanan"
        AnalyticsManager.trackScreenName("Cancel Order Shipment Page")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Kembali",
                                                           style: .Plain,
                                                           target: self,
                                                           action: #selector(didTapCancelButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Kirim",
                                                            style: .Plain,
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
    private func setupForm() {
        cancelInfoTextView.delegate = self
        invoiceButton.setTitle(orderTransaction.order_detail.detail_invoice, forState: .Normal)
        buyerName.text = orderTransaction.order_customer.customer_name
        
        cancelInfoTitleLabel.hidden = true
        minimalCharacterLabel.hidden = true
    }
    
    private func setupTicker() {
        if tickerMessageLabel() == "" {
            tickerView.mas_updateConstraints({ (make) in
                make.height.equalTo()(0)
            })
            
            return
        }
        
        messageLabel.text = tickerMessageLabel()
        tickerCTAButton.setTitle(tickerButtonLabel(), forState: .Normal)
    }
    
    //MARK: Init Ticker
    private func tickerMessageLabel() -> String {
        return "Mulai hari Senin, 7 November 2016, Tokopedia telah menetapkan sistem penalti reputasi toko untuk seller yang membatalkan pesanan.\n" +
        "Pembatalan pengiriman akan mendapatkan pengurangan reputasi sebesar 3 poin."
    }
    
    private func tickerButtonLabel() -> String {
        return "Pelajari Sistem Penalti"
    }
    
    private func tickerButtonURLString() -> String {
        let userManager = UserAuthentificationManager()
        return userManager.webViewUrlFromUrl("https://www.tokopedia.com/bantuan/penalti-reputasi/definisi-penalti-reputasi?flag_app=1&utm_source=ios")
    }
    
    //MARK: Button Action
    @objc private func didTapCancelButton() {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @objc private func didTapSubmitButton() {
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
    
    @IBAction private func didTapTickerButton() {
        let controller = WebViewController()
        controller.strURL = tickerButtonURLString()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction private func didTapInvoice() {
        let invoiceURL = orderTransaction.order_detail.detail_pdf_uri
        if invoiceURL == "" {
            return
        }
        
        NavigateViewController.navigateToInvoiceFromViewController(self, withInvoiceURL: invoiceURL)
    }
    
    //MARK: UITextView Delegate
    func textViewDidBeginEditing(textView: UITextView) {
        cancelInfoTitleLabel.hidden = false
        minimalCharacterLabel.hidden = false
        horizontalLine.backgroundColor = UIColor.fromHexString("#42B549")
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            cancelInfoTitleLabel.hidden = true
            minimalCharacterLabel.hidden = true
        }
        horizontalLine.backgroundColor = UIColor.fromHexString("#9E9E9E")
    }
    
    //MARK: Methods
    private func doRequest() {
        showRequestIsOnProgress(true)
        let object: ProceedShippingObjectRequest = ProceedShippingObjectRequest()
        object.type = .Reject
        object.orderID = orderTransaction.order_detail.detail_order_id
        object.reason = cancelInfoTextView.text
        
        ShipmentRequest.fetchProceedShipping(object, onSuccess: { [weak self] in
            guard let `self` = self else { return }
            self.onFinishRequestCancel?(true)
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            }, onFailure: { [weak self] in
                guard let `self` = self else { return }
                self.onFinishRequestCancel?(false)
                self.showRequestIsOnProgress(false)
        })
    }
    
    private func showRequestIsOnProgress(isLoading: Bool) {
        if isLoading {
            let activityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 30, 30))
            activityIndicatorView.color = UIColor.whiteColor()
            activityIndicatorView.startAnimating()
            navigationItem.rightBarButtonItem?.customView = activityIndicatorView
        } else {
            navigationItem.rightBarButtonItem?.customView = nil
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Kirim",
                                                                style: .Plain,
                                                                target: self,
                                                                action: #selector(didTapSubmitButton))
        }
    }
}
