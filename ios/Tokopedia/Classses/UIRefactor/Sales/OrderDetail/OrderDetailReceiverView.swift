//
//  OrderDetailReceiverView.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 11/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class OrderDetailReceiverView: UIView {

    @IBOutlet fileprivate var receiverPhone: LabelCopyable!
    @IBOutlet fileprivate var receiverName: LabelCopyable!
    @IBOutlet fileprivate var receiverAddress: LabelCopyable!
    @IBOutlet fileprivate var partialOrder: LabelCopyable!
    @IBOutlet fileprivate var courierAgent: LabelCopyable!
    @IBOutlet fileprivate var iDropCodeButton: UIButton!
    
    fileprivate var order = OrderTransaction(){
        didSet{
            let orderReceiver = order.order_destination
            
            receiverName.text = orderReceiver.receiver_name
            receiverName.onCopy = { text in
                UIPasteboard.general.string = text
            }
            receiverAddress.text = "\(orderReceiver.address_street)\n\(orderReceiver.address_district)\n\(orderReceiver.address_city)\n\(orderReceiver.address_province), \(orderReceiver.address_country), \(orderReceiver.address_postal)"
            receiverAddress.onCopy = { text in
                UIPasteboard.general.string = text
            }
            receiverPhone.text = orderReceiver.receiver_phone
            receiverPhone.onCopy = { text in
                UIPasteboard.general.string = text
            }
            courierAgent.text = "\(order.order_shipment.shipment_name) (\(order.order_shipment.shipment_product))"
            courierAgent.onCopy = { text in
                UIPasteboard.general.string = text
            }
            partialOrder.text = order.order_detail.partialString
            partialOrder.onCopy = { text in
                UIPasteboard.general.string = text
            }
        }
    }
    
    var iDropCode = String(){
        didSet{
            var text : NSAttributedString!
            
            if iDropCode == "try again" {
                text = NSAttributedString(string: "Kode sedang dipronses...", attributes: [NSForegroundColorAttributeName:UIColor.black])
                
                iDropCodeButton.setImage(UIImage(named: "icon_pesan_ulang.png"), for: UIControlState())
                iDropCodeButton.isHidden = false
            } else {
                text = NSAttributedString(string: iDropCode, attributes: [NSForegroundColorAttributeName:UIColor.red])
                
                iDropCodeButton.isHidden = true
            }
            
            let kurir = NSMutableAttributedString(string: courierAgent.text!)
            kurir.append(NSAttributedString(string:"-"))
            kurir.append(text)
            
            courierAgent.attributedText = kurir;
        }
    }
    
    var onTapGetIDropCode:(() -> Void)?
    var shouldRequestIDropCode : Bool = false
    
    static func newView(_ order: OrderTransaction)-> UIView {
        let views:Array = Bundle.main.loadNibNamed("OrderDetailReceiverView", owner: nil, options: nil)!
        let view = views.first as! OrderDetailReceiverView
        
        view.order = order
        
        return view
    }
    
    @IBAction fileprivate func getIDropCode(_ sender: AnyObject){
        
        guard shouldRequestIDropCode else { return }

        let kurir = NSMutableAttributedString(string: courierAgent.text!)
        kurir.append(NSAttributedString(string:"-"))
        kurir.append(NSAttributedString(string:"Loading..."))
        courierAgent.attributedText = kurir;
        iDropCodeButton.isHidden = true
            
        onTapGetIDropCode?()
        
    }
    
}
