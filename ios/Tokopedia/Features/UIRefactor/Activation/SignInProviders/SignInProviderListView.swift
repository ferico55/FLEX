//
//  SignInProviderListView.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 7/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class SignInProviderListView: UIView {
    var onWebViewProviderSelected: ((SignInProvider) -> Void)?
    var onFacebookSelected: ((SignInProvider) -> Void)?
    var onGoogleSelected: ((SignInProvider) -> Void)?
    var onTouchIdSelected: ((SignInProvider) -> Void)?
    var onPhoneNumberSelected: ((SignInProvider) -> Void)?
    var buttons: [UIButton] = []
    
    //    MARK: - Lifecycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(providers: [SignInProvider], isRegister: Bool) {
        super.init(frame: CGRect.zero)
        self.buttons = self.setProviders(providers: providers, isRegister: isRegister)
        self.updateViewWithButtons()
    }
    
    //    MARK: - Public
    func setSignInProviders(isRegister: Bool) {
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
    
    func attachToView(_ container: UIView) {
        container.addSubview(self)
        self.mas_makeConstraints { make in
            make?.left.equalTo()(container.mas_left)
            make?.top.equalTo()(container.mas_top)
            make?.right.equalTo()(container.mas_right)
            make?.bottom.equalTo()(container.mas_bottom)
        }
    }
    
    //    MARK: - Private
    private func setProviders(providers: [SignInProvider], isRegister: Bool) -> [UIButton] {
        let buttons: [UIButton] = providers.map { provider in
            let button = UIButton(type: .custom)
            button.isAccessibilityElement = true
            button.accessibilityLabel = "\(provider.name)"
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.layer.cornerRadius = 3
            button.adjustsImageWhenHighlighted = false
            button.setTitle(isRegister ? "Daftar dengan \(provider.name)" : "Masuk dengan \(provider.name)", for: .normal)
            button.backgroundColor = UIColor.fromHexString(provider.color)
            
            if let color = button.backgroundColor {
                button.setTitleColor(textColorForBackground(color), for: .normal)
            } else {
                button.setTitleColor(.white, for: .normal)
            }
            
            if provider.id == "gplus" || provider.id == "touchid" || provider.id == "phoneNumber" {
                button.borderWidth = 1
                button.borderColor = UIColor(red: 231.0 / 255.0, green: 231.0 / 255.0, blue: 231.0 / 255.0, alpha: 1)
            }
            
            if let url = URL(string: provider.imageUrl) {
                let request = URLRequest(url: url)
                button.imageView?.setImageWith(request,
                                               placeholderImage: nil,
                                               success: { _, _, image in
                                                   button.setImage(image?.resizedImage(to: CGSize(width: 20, height: 20)), for: .normal)
                                               },
                                               failure: { _, _, error in
                                                   debugPrint(error ?? "error not determined")
                })
            } else if provider.id == "touchid" {
                if provider.name == "Touch ID" {
                    button.setImage(UIImage(named: "touchId")?.resizedImage(to: CGSize(width: 20, height: 20)), for: .normal)
                } else {
                    button.setImage(UIImage(named: "faceID")?.resizedImage(to: CGSize(width: 20, height: 20)), for: .normal)
                }
                
            } else if provider.id == "phoneNumber" {
                button.setImage(UIImage(named: "tokoCashPhone")?.resizedImage(to: CGSize(width: 11.5, height: 18)), for: .normal)
            }
            
            button.bk_addEventHandler({ [unowned self] _ in
                switch provider.id {
                case "facebook": self.onFacebookSelected?(provider)
                case "gplus": self.onGoogleSelected?(provider)
                case "touchid": self.onTouchIdSelected?(provider)
                case "yahoo": self.onWebViewProviderSelected?(provider)
                case "phoneNumber": self.onPhoneNumberSelected?(provider)
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
    fileprivate func textColorForBackground(_ color: UIColor) -> UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let value = (299 * red * 255 + 587 * green * 255 + 114 * blue * 255) / 1000
        let gray: CGFloat = value >= 128 ? 0 : 1
        return UIColor(white: gray, alpha: 1)
    }
}
