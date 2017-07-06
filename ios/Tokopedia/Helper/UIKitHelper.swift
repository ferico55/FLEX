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

extension UIFont {
    
    func sizeOfString (string: String, constrainedToWidth width: Double) -> CGSize {
        return sizeOfString (string: string, constrainedToWidth: width, andHeight: Double.greatestFiniteMagnitude)
    }
    
    func sizeOfString (string: String, constrainedToWidth width: Double, andHeight height: Double) -> CGSize {
        return (string as NSString).boundingRect(with: CGSize(width: width, height: height),
                                                 options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                 attributes: [NSFontAttributeName: self],
                                                 context: nil).size
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

extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
}

extension UINavigationController {
    func replaceTopViewController(viewController: UIViewController) {
        if self.viewControllers.count > 0  {
            self.viewControllers[self.viewControllers.count - 1] = viewController
        }
    }
}
