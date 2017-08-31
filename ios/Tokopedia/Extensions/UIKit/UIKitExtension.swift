//
//  UIKitHelper.swift
//  Tokopedia
//
//  Created by Setiady Wiguna on 3/31/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift

extension UISearchBar {
    
    private func getViewElement<T>(type: T.Type) -> T? {
        
        let allSubviews = subviews.flatMap { $0.subviews }
        guard let element = (allSubviews.filter { $0 is T }).first as? T else { return nil }
        return element
    }
    
    func getSearchBarTextField() -> UITextField? {
        
        return getViewElement(type: UITextField.self)
    }
    
    func setTextColor(color: UIColor) {
        
        if let textField = getSearchBarTextField() {
            textField.textColor = color
        }
    }
    
    func setTextFieldColor(color: UIColor) {
        
        if let textField = getViewElement(type: UITextField.self) {
            switch searchBarStyle {
            case .minimal:
                textField.layer.backgroundColor = color.cgColor
                textField.layer.cornerRadius = 6
                
            case .prominent, .default:
                textField.backgroundColor = color
            }
        }
    }
    
    func setPlaceholderTextColor(color: UIColor) {
        
        if let textField = getSearchBarTextField() {
            textField.attributedPlaceholder = NSAttributedString(string: self.placeholder != nil ? self.placeholder! : "", attributes: [NSForegroundColorAttributeName: color])
        }
    }
    
    func setTextFieldClearButtonColor(color: UIColor) {
        
        if let textField = getSearchBarTextField() {
            
            let button = textField.value(forKey: "clearButton") as! UIButton
            if let image = button.imageView?.image {
                button.setImage(image.transform(withNewColor: color), for: .normal)
            }
        }
    }
    
    func setSearchImageColor(color: UIColor) {
        
        if let imageView = getSearchBarTextField()?.leftView as? UIImageView {
            imageView.image = imageView.image?.transform(withNewColor: color)
        }
    }
}

extension UISearchController {
    
    func setSearchBarToTop(viewController: UIViewController, title: String) {
        
        delegate = self
        searchResultsUpdater = self
        searchBar.placeholder = "Cari Produk atau Toko"
        searchBar.barTintColor = .white
        searchBar.setTextFieldColor(color: UIColor.fromHexString("E5E5E5"))
        searchBar.setTextColor(color: UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.7))
        searchBar.layer.borderColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0).cgColor
        hidesNavigationBarDuringPresentation = false
        dimsBackgroundDuringPresentation = false
        searchBar.text = title
        searchBar.sizeToFit()
        let searchWrapper = UIView(frame: self.searchBar.bounds)
        searchWrapper.addSubview(self.searchBar)
        searchWrapper.backgroundColor = .clear
        searchBar.layer.borderWidth = 1
        searchBar.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(searchWrapper)
        }
        viewController.navigationItem.titleView = searchWrapper
        
    }
}

extension UISearchController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        DispatchQueue.main.async {
            searchController.searchResultsController?.view.isHidden = false
        }
    }
}

extension UISearchController: UISearchControllerDelegate {
    public func willPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {
            searchController.searchResultsController?.view.isHidden = false
        }
    }
    
    public func didPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {
            searchController.searchResultsController?.view.isHidden = false
        }
    }
}

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
    convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage!)!)
    }
    
    func transform(withNewColor color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.clip(to: rect, mask: cgImage!)
        
        color.setFill()
        context.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    // MARK: - UIImage+Resize
    func compressImageData(maxSizeInMB:Int) -> Data? {
        let sizeInBytes = maxSizeInMB * 1024 * 1024
        var needCompress:Bool = true
        var imgData:Data?
        var compressingValue:CGFloat = 1.0
        while (needCompress && compressingValue > 0.0) {
            if let data:Data = UIImageJPEGRepresentation(self, compressingValue) {
                if data.count < sizeInBytes {
                    needCompress = false
                    imgData = data
                } else {
                    compressingValue -= 0.1
                }
            }
        }
        
        if let data = imgData {
            if (data.count < sizeInBytes) {
                return data
            }
        }
        return UIImageJPEGRepresentation(self, 1)
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
    
    func setGreen() {
        self.navigationBar.setBackgroundImage(UIImage(color: UIColor.tpGreen()), for: .default)
        self.navigationBar.shadowOpacity = 0
        self.navigationBar.tintColor = .white
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        self.navigationBar.isTranslucent = false;
        self.navigationBar.shadowImage = UIImage(color: UIColor.tpGreen(), size: CGSize(width: 1, height: 0.3))
        
        let barButtonAttributes = [NSForegroundColorAttributeName: UIColor.white]
        UIBarButtonItem.appearance().setTitleTextAttributes(barButtonAttributes as? [String:AnyObject], for: UIControlState.normal)
        
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func setWhite() {
        self.navigationBar.setBackgroundImage(UIImage(color: .white), for: .default)
        self.navigationBar.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)]
        self.navigationBar.isTranslucent = false;
        self.navigationBar.shadowImage = UIImage(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.12), size: CGSize(width: 1, height: 0.3))

        let barButtonAttributes = [NSForegroundColorAttributeName: UIColor.tpPrimaryBlackText()]
        UIBarButtonItem.appearance().setTitleTextAttributes(barButtonAttributes as? [String:AnyObject], for: UIControlState.normal)
        
        
        
        UIApplication.shared.statusBarStyle = .default
        
    }
}

extension UIScrollView {
    var rx_reachedBottom: Observable<Void> {
        return rx.contentOffset
            .debounce(0.025, scheduler: MainScheduler.instance)
            .flatMap { [weak self] contentOffset -> Observable<Void> in
                guard let scrollView = self else {
                    return Observable.empty()
                }
                
                let visibleHeight = scrollView.frame.height - scrollView.contentInset.top - scrollView.contentInset.bottom
                let y = contentOffset.y + scrollView.contentInset.top
                let threshold = max(0.0, scrollView.contentSize.height - visibleHeight)
                
                return y > threshold ? Observable.just() : Observable.empty()
        }
        
    }
}

