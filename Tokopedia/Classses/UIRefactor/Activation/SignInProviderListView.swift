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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(providers: [SignInProvider]) {
        super.init(frame: CGRect.zero)
        
        let buttons: [UIButton] = providers.map { provider in
            let button = UIButton(type: .custom)
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.layer.cornerRadius = 3
            button.adjustsImageWhenHighlighted = false
            
            button.setTitle("Masuk dengan \(provider.name)", for: .normal)
            button.backgroundColor = UIColor.fromHexString(provider.color)
            
            button.setTitleColor(textColorForBackground(button.backgroundColor!), for: .normal)
            
            let request = NSMutableURLRequest(url: NSURL(string: provider.imageUrl) as! URL)
            
            let imageView = UIImageView()
            imageView.setImageWith(request as URLRequest,
                placeholderImage: nil,
                success: {request, response, image in
                    button.setImage(image?.resizedImage(to: CGSize(width: 20, height: 20)), for: .normal)
                },
                failure: nil)
            
            button.bk_addEventHandler({[unowned self] button in
                switch provider.id {
                    case "facebook": self.onFacebookSelected?(provider)
                    case "gplus": self.onGoogleSelected?(provider)
                default: self.onWebViewProviderSelected?(provider)
                }
            }, for: .touchUpInside)
            return button
        }
        
        buttons.enumerated().forEach({index, button in
            self.addSubview(button)
            
            let height = 44
            
            button.mas_makeConstraints { make in
                make?.left.equalTo()(button.superview!.mas_left)
                make?.right.equalTo()(button.superview!.mas_right)
                make?.height.mas_equalTo()(height)
                make?.top.equalTo()(button.superview!)?.with().offset()(CGFloat((height + 10) * index))
            }
        })
        
        buttons.last!.mas_makeConstraints { make in
            make?.bottom.equalTo()(self.mas_bottom)
        }
    }
    
    func attachToView(_ container: UIView) {
        container.addSubview(self)
        
        self.mas_makeConstraints {make in
            make?.left.equalTo()(container.mas_left)
            make?.top.equalTo()(container.mas_top)
            make?.right.equalTo()(container.mas_right)
            make?.bottom.equalTo()(container.mas_bottom)
        }
    }
    
    fileprivate func textColorForBackground(_ color: UIColor) -> UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let value = (299 * red * 255 + 587 * green * 255 + 114 * blue * 255)/1000
        let gray: CGFloat = value >= 128 ? 0: 1
        return UIColor(white: gray, alpha: 1)
    }
}
