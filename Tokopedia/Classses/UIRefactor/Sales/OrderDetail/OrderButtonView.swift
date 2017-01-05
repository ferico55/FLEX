//
//  OrderButtonView.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 11/25/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import OAStackView

class OrderButtonView: UIView {
    
    private var onTapAccept:(() -> Void)?
    private var onTapReject:(() -> Void)?
    private var onTapCancel:(() -> Void)?
    private var onTapPickup:(() -> Void)?
    private var onTapChangeCourier:(() -> Void)?
    private var onTapConfirm:(() -> Void)?
    private var onTapTrack:(() -> Void)?
    private var onTapChangeResi:(() -> Void)?
    private var onTapAskBuyer:(() -> Void)?
    
    private var stackView : OAStackView!
    
    func addAcceptButton(onTap:(() -> Void)?) {
        onTapAccept = onTap
        self.addButtonWithTitle("Terima", imageName:"icon_order_check", action:#selector(self.tapAccept(_:)))
    }
    
    func addRejectButton(onTap:(() -> Void)?) {
        onTapReject = onTap
        self.addButtonWithTitle("Tolak", imageName:"icon_order_cancel", action:#selector(self.tapReject(_:)))
    }
    
    func addCancelButton(onTap:(() -> Void)?) {
        onTapCancel = onTap
        self.addButtonWithTitle("Batal", imageName:"icon_order_cancel", action:#selector(self.tapCancel(_:)))
    }
    
    func addPickupButton(onTap:(() -> Void)?) {
        onTapPickup = onTap
        self.addButtonWithTitle("Pickup", imageName:"icon_order_check", action:#selector(self.tapPickup(_:)))
    }
    
    func addChangeCourierButton(onTap:(() -> Void)?) {
        onTapChangeCourier = onTap
        self.addButtonWithTitle("Ubah Kurir", imageName:"icon_truck", action:#selector(self.tapChangeCourier(_:)))
    }
    
    func addConfirmButton(onTap:(() -> Void)?) {
        onTapConfirm = onTap
        self.addButtonWithTitle("Konfirmasi", imageName:"icon_order_check", action:#selector(self.tapConfirm(_:)))
    }
    
    func addTrackButton(onTap:(() -> Void)?) {
        onTapTrack = onTap
        self.addButtonWithTitle("Lacak", imageName:"icon_track_grey", action:#selector(self.tapTrack(_:)))
    }
    
    func addChangeResiButton(onTap:(() -> Void)?) {
        onTapChangeResi = onTap
        self.addButtonWithTitle("Ubah Resi", imageName:"icon_edit_grey", action:#selector(self.tapChangeResi(_:)))
    }
    
    func addAskBuyerButton(onTap:(() -> Void)?) {
        onTapAskBuyer = onTap
        self.addButtonWithTitle("Tanya Pembeli", imageName:"icon_order_message_grey", action:#selector(self.tapAskBuyer(_:)))
    }
    
    
    func removeAllButtons(){
        guard let _ = stackView else {
            return
        }
        stackView.subviews.forEach { $0.removeFromSuperview()}
    }
    
    
    @objc private func tapAccept(sender:UIButton){
        onTapAccept?()
    }
    
    @objc private func tapReject(sender:UIButton){
        onTapReject?()
    }
    
    @objc private func tapCancel(sender:UIButton){
        onTapCancel?()
    }
    
    @objc private func tapPickup(sender:UIButton){
        onTapPickup?()
    }
    
    @objc private func tapChangeCourier(sender:UIButton){
        onTapChangeCourier?()
    }
    
    @objc private func tapConfirm(sender:UIButton){
        onTapConfirm?()
    }
    
    @objc private func tapTrack(sender:UIButton){
        onTapTrack?()
    }
    
    @objc private func tapChangeResi(sender:UIButton){
        onTapChangeResi?()
    }
    
    @objc private func tapAskBuyer(sender:UIButton){
        onTapAskBuyer?()
    }
    
    private func buttonsStackView() -> OAStackView{
        if stackView == nil{
            stackView = OAStackView()
            stackView.axis = .Horizontal;
            stackView.alignment = .Fill;
            stackView.distribution = .FillEqually;
            
            self.addSubview(stackView)
            stackView.mas_makeConstraints({ (make) in
                make.edges.mas_equalTo()(self)
            })
        }
        return stackView
    }
    
    private func addButtonWithTitle(title:String, imageName:String, action:Selector){
        
        let button = UIButton(type: UIButtonType.Custom) as UIButton
        button.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
        button.setTitleColor(UIColor(red:98.0/255.0, green:98.0/255.0, blue:98.0/255.0, alpha:1), forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(10)
        button.titleLabel?.numberOfLines = 0;
        button.backgroundColor = UIColor.clearColor()
        button.setTitle(title, forState: UIControlState.Normal)
        button.addTarget(self, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        button.titleEdgeInsets.left = 6;
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor(red:188.0/255.0, green:187.0/255.0, blue:193.0/255.0, alpha:0.5).CGColor
        
        self.buttonsStackView().addArrangedSubview(button)
        
        button.mas_makeConstraints({ (make) in
            make.height.mas_equalTo()(40)
        })
    }
    
}
