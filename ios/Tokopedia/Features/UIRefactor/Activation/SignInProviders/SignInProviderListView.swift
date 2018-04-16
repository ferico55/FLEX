//
//  SignInProviderListView.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 7/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

public class SignInProviderListView: UIView {
    public var onWebViewProviderSelected: ((SignInProvider) -> Void)?
    public var onFacebookSelected: ((SignInProvider) -> Void)?
    public var onGoogleSelected: ((SignInProvider) -> Void)?
    public var onTouchIdSelected: ((SignInProvider) -> Void)?
    public var onPhoneNumberSelected: ((SignInProvider) -> Void)?
    public var onRegPhoneNumberSelected: ((SignInProvider) -> Void)?
    public var onRegEmailSelected: ((SignInProvider) -> Void)?
    public var buttons: [SignInProviderButton] = []
    
    //    MARK: - Lifecycle
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public init(providers: [SignInProvider], isRegister: Bool) {
        super.init(frame: CGRect.zero)
        self.buttons = self.setProviders(providers: providers, isRegister: isRegister)
        self.updateViewWithButtons()
    }
    
    //    MARK: - Public
    public func setSignInProviders(isRegister: Bool) {
        var providers = SignInProvider.defaultProviders(useFor: .login)
        let isAvailable = TouchIDHelper.sharedInstance.isTouchIDAvailable()
        let connectedAccounts = TouchIDHelper.sharedInstance.numberOfConnectedAccounts()
        if isAvailable == true && connectedAccounts > 0 {
            let touchIdProvider = SignInProvider.touchIdProvider()
            providers.insert(touchIdProvider, at: 0)
        }
        
        self.buttons = self.setProviders(providers: providers, isRegister: isRegister)
        self.updateViewWithButtons()
    }
    
    public func attachToView(_ container: UIView) {
        container.addSubview(self)
        self.mas_makeConstraints { make in
            make?.left.equalTo()(container.mas_left)
            make?.top.equalTo()(container.mas_top)
            make?.right.equalTo()(container.mas_right)
            make?.bottom.equalTo()(container.mas_bottom)
        }
    }
    
    //    MARK: - Private
    private func setProviders(providers: [SignInProvider], isRegister: Bool) -> [SignInProviderButton] {
        let buttons: [SignInProviderButton] = providers.map { provider in
            let button = SignInProviderButton.instanceFromNib()
            button.providerButton.setTitle(isRegister ? "\(provider.name)" : "Masuk dengan \(provider.name)", for: .normal)
            
            if let url = URL(string: provider.imageUrl) {
                let request = URLRequest(url: url)
                button.providerImageView?.setImageWith(request,
                                                       placeholderImage: nil,
                                                       success: { _, _, image in
                                                           button.providerImageView.setImage(image, animated: true)
                                                       },
                                                       failure: { _, _, error in
                                                           debugPrint(error ?? "error not determined")
                })
            } else if provider.id == "touchid" {
                if provider.name == "Touch ID" {
                    button.providerImageView.setImage(#imageLiteral(resourceName: "touchId"), animated: true)
                } else {
                    button.providerImageView.setImage(#imageLiteral(resourceName: "faceID"), animated: true)
                }
                
            } else if provider.id == "phoneNumber" {
                button.providerImageView.setImage(#imageLiteral(resourceName: "tokoCashPhone"), animated: true)
            } else if provider.id == "regemail" {
                button.providerImageView.setImage(#imageLiteral(resourceName: "icon_email"), animated: true)
            }
            
            button.providerButton.bk_addEventHandler({ [unowned self] _ in
                switch provider.id {
                case "facebook": self.onFacebookSelected?(provider)
                case "gplus": self.onGoogleSelected?(provider)
                case "touchid": self.onTouchIdSelected?(provider)
                case "yahoo": self.onWebViewProviderSelected?(provider)
                case "phoneNumber": self.onPhoneNumberSelected?(provider)
                case "phonenumber": self.onRegPhoneNumberSelected?(provider)
                case "regemail": self.onRegEmailSelected?(provider)
                default: return
                }
            }, for: .touchUpInside)
            return button
        }
        return buttons
    }
    private func updateViewWithButtons() {
        self.removeAllSubviews()
        self.buttons.enumerated().forEach({ index, button in
            self.addSubview(button)
            let height = 44
            button.mas_makeConstraints { make in
                if let superview = button.superview {
                    make?.left.equalTo()(superview.mas_left)
                    make?.right.equalTo()(superview.mas_right)
                    make?.height.mas_equalTo()(height)
                    make?.top.equalTo()(superview)?.with().offset()(CGFloat((height + 10) * index))
                }
                
            }
        })
        
        guard let button = buttons.last else {
            return
        }
        
        button.mas_makeConstraints { make in
            if let superview = button.superview {
                make?.bottom.equalTo()(superview.mas_bottom)
            }
        }
    }
}
