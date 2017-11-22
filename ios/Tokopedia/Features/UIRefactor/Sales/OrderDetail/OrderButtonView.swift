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
    
    fileprivate var onTapAccept:(() -> Void)?
    fileprivate var onTapReject:(() -> Void)?
    fileprivate var onTapCancel:(() -> Void)?
    fileprivate var onTapPickup:(() -> Void)?
    fileprivate var onTapChangeCourier:(() -> Void)?
    fileprivate var onTapConfirm:(() -> Void)?
    fileprivate var onTapTrack:(() -> Void)?
    fileprivate var onTapRetry:(() -> Void)?
    fileprivate var onTapChangeResi:(() -> Void)?
    fileprivate var onTapAskBuyer:(() -> Void)?
    
    fileprivate var stackView : OAStackView!
    
    func addAcceptButton(_ onTap:(() -> Void)?) {
        onTapAccept = onTap
        self.addButtonWithTitle("Terima", imageName:"icon_order_check", action:#selector(self.tapAccept(_:)))
    }
    
    func addRejectButton(_ onTap:(() -> Void)?) {
        onTapReject = onTap
        self.addButtonWithTitle("Tolak", imageName:"icon_order_cancel", action:#selector(self.tapReject(_:)))
    }
    
    func addCancelButton(_ onTap:(() -> Void)?) {
        onTapCancel = onTap
        self.addButtonWithTitle("Batal", imageName:"icon_order_cancel", action:#selector(self.tapCancel(_:)))
    }
    
    func addPickupButton(_ onTap:(() -> Void)?) {
        onTapPickup = onTap
        self.addButtonWithTitle("Pickup", imageName:"icon_order_check", action:#selector(self.tapPickup(_:)))
    }
    
    func addChangeCourierButton(_ onTap:(() -> Void)?) {
        onTapChangeCourier = onTap
        self.addButtonWithTitle("Ganti Kurir", imageName:"icon_truck", action:#selector(self.tapChangeCourier(_:)))
    }
    
    func addConfirmButton(_ onTap:(() -> Void)?) {
        onTapConfirm = onTap
        self.addButtonWithTitle("Konfirmasi", imageName:"icon_order_check", action:#selector(self.tapConfirm(_:)))
    }
    
    func addTrackButton(_ onTap:(() -> Void)?) {
        onTapTrack = onTap
        self.addButtonWithTitle("Lacak", imageName:"icon_track_grey", action:#selector(self.tapTrack(_:)))
    }
    
    func addRetryButton(_ onTap:(() -> Void)?) {
        onTapRetry = onTap
        self.addButtonWithTitle(title: "Retry Pickup", imageName:"", action:#selector(self.tapRetry(_:)), color:UIColor(red: 66/255, green: 181/255, blue: 73/255, alpha: 1.0), textColor:UIColor.white)
    }
    
    func addChangeResiButton(_ onTap:(() -> Void)?) {
        onTapChangeResi = onTap
        self.addButtonWithTitle("Ubah Resi", imageName:"icon_edit_grey", action:#selector(self.tapChangeResi(_:)))
    }
    
    func addAskBuyerButton(_ onTap:(() -> Void)?) {
        onTapAskBuyer = onTap
        self.addButtonWithTitle("Tanya Pembeli", imageName:"icon_order_message_grey", action:#selector(self.tapAskBuyer(_:)))
    }
    
    func removeAllButtons(){
        guard let _ = stackView else {
            return
        }
        stackView.subviews.forEach { $0.removeFromSuperview()}
    }
    
    @objc fileprivate func tapAccept(_ sender:UIButton){
        onTapAccept?()
    }
    
    @objc fileprivate func tapReject(_ sender:UIButton){
        onTapReject?()
    }
    
    @objc fileprivate func tapCancel(_ sender:UIButton){
        onTapCancel?()
    }
    
    @objc fileprivate func tapPickup(_ sender:UIButton){
        onTapPickup?()
    }
    
    @objc fileprivate func tapChangeCourier(_ sender:UIButton){
        onTapChangeCourier?()
    }
    
    @objc fileprivate func tapConfirm(_ sender:UIButton){
        onTapConfirm?()
    }
    
    @objc fileprivate func tapTrack(_ sender:UIButton){
        onTapTrack?()
    }
    
    @objc private func tapRetry(_ sender:UIButton){
        onTapRetry?()
    }
    
    @objc private func tapChangeResi(_ sender:UIButton){
        onTapChangeResi?()
    }
    
    @objc fileprivate func tapAskBuyer(_ sender:UIButton){
        onTapAskBuyer?()
    }
    
    fileprivate func buttonsStackView() -> OAStackView{
        if stackView == nil{
            stackView = OAStackView()
            stackView.axis = .horizontal;
            stackView.alignment = .fill;
            stackView.distribution = .fillEqually;
            
            self.addSubview(stackView)
            stackView.mas_makeConstraints({ (make) in
                make?.edges.mas_equalTo()(self)
            })
        }
        return stackView
    }
    
    fileprivate func addButtonWithTitle(_ title:String, imageName:String, action:Selector){
        
        let button = UIButton(type: UIButtonType.custom) as UIButton
        button.setImage(UIImage(named: imageName), for: UIControlState())
        button.setTitleColor(UIColor(red:98.0/255.0, green:98.0/255.0, blue:98.0/255.0, alpha:1), for: UIControlState())
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        button.titleLabel?.numberOfLines = 0;
        button.backgroundColor = UIColor.clear
        button.setTitle(title, for: UIControlState())
        button.addTarget(self, action: action, for: UIControlEvents.touchUpInside)
        button.titleEdgeInsets.left = 6;
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor(red:188.0/255.0, green:187.0/255.0, blue:193.0/255.0, alpha:0.5).cgColor
        
        self.buttonsStackView().addArrangedSubview(button)
        
        button.mas_makeConstraints({ (make) in
            make?.height.mas_equalTo()(40)
        })
    }
    
    private func addButtonWithTitle(title:String, imageName:String, action:Selector, color:UIColor, textColor:UIColor){
        
        let button = UIButton(type: UIButtonType.custom)
        button.setImage(UIImage(named: imageName), for: UIControlState.normal)
        button.setTitleColor(textColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        button.titleLabel?.numberOfLines = 0;
        button.backgroundColor = color;
        button.setTitle(title, for: UIControlState.normal)
        button.addTarget(self, action: action, for: UIControlEvents.touchUpInside)
        button.titleEdgeInsets.left = 6;
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor(red:188.0/255.0, green:187.0/255.0, blue:193.0/255.0, alpha:0.5).cgColor
        
        self.buttonsStackView().addArrangedSubview(button)
        
        button.mas_makeConstraints({ (make) in
            make?.height.mas_equalTo()(40)
        })
    }
    
}
