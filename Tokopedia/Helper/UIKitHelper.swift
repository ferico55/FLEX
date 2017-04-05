//
//  UIKitHelper.swift
//  Tokopedia
//
//  Created by Setiady Wiguna on 3/31/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

extension UIApplication {
    class func getAppVersionStringWithoutDot() -> String {
        var appVersion: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        appVersion = appVersion.replacingOccurrences(of: ".", with: "")
        return appVersion
    }
    
    class func getAppVersionString() -> String {
        let appVersion: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        return appVersion
    }
    
    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let search = base as? UISearchController {
            return search.presentingViewController
        }
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}

extension UIScreen {
    /**
     Returns the height of the device screen.
     
     - returns: The device screen height.
     */
    public static func height() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    /**
     Returns the width of the device screen.
     
     - returns: The device screen width.
     */
    public static func width() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    
    /**
     Returns the size of the device screen.
     
     - returns: The device screen size.
     */
    public static func size() -> CGSize {
        return UIScreen.main.bounds.size
    }
    
    /**
     Returns the bounds of the device screen.
     
     - returns: The bounds of device screen.
     */
    public static func bounds() -> CGRect {
        return UIScreen.main.bounds
    }
}

@IBDesignable
extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        } set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var shadowColor : UIColor {
        get {
            return UIColor.clear
        } set {
            layer.shadowColor = newValue.cgColor
        }
    }
    
    @IBInspectable var shadowOpacity : Float {
        get {
            return layer.shadowOpacity
        } set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable var shadowRadius : CGFloat {
        get {
            return layer.shadowRadius
        } set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable var borderWidth : CGFloat {
        get {
            return layer.borderWidth
        } set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor : UIColor {
        get {
            return UIColor(cgColor: layer.borderColor!)
        } set {
            layer.borderColor = newValue.cgColor
        }
    }
    
    func removeAllSubviews() {
        subviews.forEach({view in
            view.removeFromSuperview();
        });
    }
}

@IBDesignable
extension UIButton {
    
    @IBInspectable override var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        } set {
            layer.cornerRadius = newValue
        }
    }
}

extension UISplitViewController {
    func replaceDetailViewController(_ viewController: UIViewController) {
        let masterViewController = viewControllers.first!
        viewControllers = [masterViewController, viewController]
    }
    
    func getDetailViewController()->UIViewController {
        let detailViewController = viewControllers.last!
        return detailViewController;
    }
}

extension UIScrollView {
    func scrollToBottomAnimated(_ animated: Bool) {
        if contentSize.height > bounds.size.height {
            let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height);
            setContentOffset(bottomOffset, animated: animated);
        }
    }
    
    func scrollToTop() {
        let inset = self.contentInset
        self.setContentOffset(CGPoint(x:-inset.left, y:-inset.top), animated:true)
    }
}

extension UIImage {
    func resizedImage() -> (UIImage){
        var actualHeight = self.size.height
        var actualWidth = self.size.width
        var imgRatio = actualWidth/actualHeight
        let maxImageSize = CGSize(width: 600, height: 600)
        let widthView = maxImageSize.width;
        let heightView = maxImageSize.height;
        let maxRatio = widthView/heightView;
        
        if (imgRatio != maxRatio){
            if (imgRatio < maxRatio){
                imgRatio = heightView / actualHeight
                actualHeight = heightView
                actualWidth = imgRatio * actualWidth
            } else {
                imgRatio = widthView / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = widthView
            }
        }
        
        let rect = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight);
        UIGraphicsBeginImageContext(rect.size)
        self.draw(in: rect)
        let resized : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return resized
    }
}
