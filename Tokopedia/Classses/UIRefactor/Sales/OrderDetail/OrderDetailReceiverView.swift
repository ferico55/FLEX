//
//  OrderDetailReceiverView.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 11/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class OrderDetailReceiverView: UIView {

    @IBOutlet private var receiverPhone: LabelCopyable!
    @IBOutlet private var receiverName: LabelCopyable!
    @IBOutlet private var receiverAddress: LabelCopyable!
    @IBOutlet private var partialOrder: LabelCopyable!
    @IBOutlet private var courierAgent: LabelCopyable!
    @IBOutlet private var iDropCodeButton: UIButton!
    
    private var order = OrderTransaction(){
        didSet{
            let orderReceiver = order.order_destination
            
            receiverName.text = orderReceiver.receiver_name
            receiverName.onCopy = { text in
                UIPasteboard.generalPasteboard().string = text
            }
            receiverAddress.text = "\(orderReceiver.address_street)\n\(orderReceiver.address_district)\n\(orderReceiver.address_city)\n\(orderReceiver.address_province), \(orderReceiver.address_country), \(orderReceiver.address_postal)"
            receiverAddress.onCopy = { text in
                UIPasteboard.generalPasteboard().string = text
            }
            receiverPhone.text = orderReceiver.receiver_phone
            receiverPhone.onCopy = { text in
                UIPasteboard.generalPasteboard().string = text
            }
            courierAgent.text = "\(order.order_shipment.shipment_name) (\(order.order_shipment.shipment_product))"
            courierAgent.onCopy = { text in
                UIPasteboard.generalPasteboard().string = text
            }
            partialOrder.text = order.order_detail.partialString
            partialOrder.onCopy = { text in
                UIPasteboard.generalPasteboard().string = text
            }
        }
    }
    
    var iDropCode = String(){
        didSet{
            var text : NSAttributedString!
            
            if iDropCode == "try again" {
                text = NSAttributedString(string: "Kode sedang dipronses...", attributes: [NSForegroundColorAttributeName:UIColor.blackColor()])
                
                iDropCodeButton.setImage(UIImage(named: "icon_pesan_ulang.png"), forState: .Normal)
                iDropCodeButton.hidden = false
            } else {
                text = NSAttributedString(string: iDropCode, attributes: [NSForegroundColorAttributeName:UIColor.redColor()])
                
                iDropCodeButton.hidden = true
            }
            
            let kurir = NSMutableAttributedString(string: courierAgent.text!)
            kurir.appendAttributedString(NSAttributedString(string:"-"))
            kurir.appendAttributedString(text)
            
            courierAgent.attributedText = kurir;
        }
    }
    
    var onTapGetIDropCode:(() -> Void)?
    var shouldRequestIDropCode : Bool = false
    
    static func newView(order: OrderTransaction)-> UIView {
        let views:Array = NSBundle.mainBundle().loadNibNamed("OrderDetailReceiverView", owner: nil, options: nil)!
        let view = views.first as! OrderDetailReceiverView
        
        view.order = order
        
        return view
    }
    
    @IBAction private func getIDropCode(sender: AnyObject){
        
        guard shouldRequestIDropCode else { return }

        let kurir = NSMutableAttributedString(string: courierAgent.text!)
        kurir.appendAttributedString(NSAttributedString(string:"-"))
        kurir.appendAttributedString(NSAttributedString(string:"Loading..."))
        courierAgent.attributedText = kurir;
        iDropCodeButton.hidden = true
            
        onTapGetIDropCode?()
        
    }
    
}
