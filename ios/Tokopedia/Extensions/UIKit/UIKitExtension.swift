//
//  UIKitHelper.swift
//  Tokopedia
//
//  Created by Setiady Wiguna on 3/31/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import RxSwift
import UIKit

extension UISearchBar {
    
    private func getViewElement<T>(type: T.Type) -> T? {
        
        let allSubviews = subviews.flatMap { $0.subviews }
        guard let element = (allSubviews.filter { $0 is T }).first as? T else { return nil }
        return element
    }
    
    public func getSearchBarTextField() -> UITextField? {
        
        return getViewElement(type: UITextField.self)
    }
    
    public func setTextColor(color: UIColor) {
        
        if let textField = getSearchBarTextField() {
            textField.textColor = color
        }
    }
    
    public func setTextFieldColor(color: UIColor) {
        
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
    
    public func setPlaceholderTextColor(color: UIColor) {
        
        if let textField = getSearchBarTextField() {
            textField.attributedPlaceholder = NSAttributedString(string: placeholder != nil ? placeholder! : "", attributes: [NSForegroundColorAttributeName: color])
        }
    }
    
    public func setTextFieldClearButtonColor(color: UIColor) {
        
        if let textField = getSearchBarTextField() {
            
            let button = textField.value(forKey: "clearButton") as! UIButton
            if let image = button.imageView?.image {
                button.setImage(image.transform(withNewColor: color), for: .normal)
            }
        }
    }
    
    public func setSearchImageColor(color: UIColor) {
        
        if let imageView = getSearchBarTextField()?.leftView as? UIImageView {
            imageView.image = imageView.image?.transform(withNewColor: color)
        }
    }
}

public protocol PropertyStoring {
    
    associatedtype T
    
    func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: T) -> T
}

extension PropertyStoring {
    public func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: T) -> T {
        guard let value = objc_getAssociatedObject(self, key) as? T else {
            return defaultValue
        }
        return value
    }
}

extension UISearchController: PropertyStoring {
    
    public typealias T = SearchBarWrapperView?
    
    private struct CustomProperties {
        static var wrapperView: SearchBarWrapperView?
    }
    
    public var wrapperView: SearchBarWrapperView? {
        get {
            return getAssociatedObject(&CustomProperties.wrapperView, defaultValue: nil)
        }
        set(newValue) {
            return objc_setAssociatedObject(self, &CustomProperties.wrapperView, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    public func setSearchBarToTop(viewController: UIViewController, title: String) {
        
        delegate = viewController as? UISearchControllerDelegate
        searchResultsUpdater = viewController as? UISearchResultsUpdating
        searchBar.placeholder = "Cari Produk atau Toko"
        searchBar.barTintColor = .tpGreen()
        searchBar.setTextFieldColor(color: #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1))
        searchBar.setTextColor(color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.7))
        searchBar.backgroundImage = UIImage()
        
        hidesNavigationBarDuringPresentation = false
        dimsBackgroundDuringPresentation = false
        
        // if initialized from HomeTabViewController and the title is set, somehow searching doesn't work
        if !title.isEmpty {
            searchBar.text = title
        }
        
        searchBar.sizeToFit()
        
        wrapperView = SearchBarWrapperView(customSearchBar: searchBar)
        let screenWidth = UIScreen.main.bounds.width
        wrapperView?.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 44)
        wrapperView?.autoresizingMask = [.flexibleWidth]
        wrapperView?.sizeToFit()
        
        viewController.navigationItem.titleView = wrapperView
    }
    
    public func setSearchBarToTop(viewController: UIViewController) {
        setSearchBarToTop(viewController: viewController, title: "")
    }
    
    public func getSearchWrapperView() -> SearchBarWrapperView? {
        return wrapperView
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

@objc extension UIApplication {
    public class func getAppVersionStringWithoutDot() -> String {
        guard let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return ""
        }
        var appVersionWithoutDot = appVersion.replacingOccurrences(of: ".", with: "")
        return appVersionWithoutDot
    }
    
    public class func getAppVersionString() -> String {
        let appVersion: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        return appVersion
    }
    
    public class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
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
    
    public class func topViewController() -> UIViewController? {
        return topViewController(UIApplication.shared.keyWindow?.rootViewController)
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
    
    public func sizeOfString(string: String, constrainedToWidth width: Double) -> CGSize {
        return sizeOfString(string: string, constrainedToWidth: width, andHeight: Double.greatestFiniteMagnitude)
    }
    
    public func sizeOfString(string: String, constrainedToWidth width: Double, andHeight height: Double) -> CGSize {
        return (string as NSString).boundingRect(with: CGSize(width: width, height: height),
                                                 options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                 attributes: [NSFontAttributeName: self],
                                                 context: nil).size
    }
}

@IBDesignable
public class DesignableView: UIView {
}

@IBDesignable
public class DesignableButton: UIButton {
}

@IBDesignable
public class DesignableLabel: UILabel {
}

@IBDesignable
extension UIView {
    
    @IBInspectable public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        } set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable public var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
    @IBInspectable public var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        } set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable public var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        } set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable public var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        } set {
            layer.shadowOffset = newValue
        }
    }

    @IBInspectable public var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        } set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable public var borderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor!)
        } set {
            // FIXME: this hack needs to be done because React also
            // has borderColor method which receives a CGColor
            // to fix this, this method either needs to be renamed or removed
            let newColor: Any = newValue
            
            if !newValue.responds(to: #selector(getter: UIColor.cgColor)) {
                layer.borderColor = (newColor as! CGColor)
            } else {
                layer.borderColor = newValue.cgColor
            }
        }
    }
    
    public func removeAllSubviews() {
        subviews.forEach({ view in
            view.removeFromSuperview()
        })
    }
    
    public func addDashedLine(color: UIColor, lineWidth: CGFloat) {
        backgroundColor = .clear
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.name = "DashedTopLine"
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.lineDashPattern = [4, 4]
        
        let path = CGMutablePath()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: frame.width, y: 0))
        shapeLayer.path = path
        
        layer.addSublayer(shapeLayer)
    }
}

extension UIView {
    public class func loadFirstFromNib<T>(name: String, type: T.Type, owner: Any?, options: [AnyHashable : Any]? = nil) -> T? {
        guard let views = Bundle.main.loadNibNamed(name, owner: owner, options: options), let view = views[0] as? T else { return nil }
        return view
    }
}

extension UISplitViewController {
    public func replaceDetailViewController(_ viewController: UIViewController) {
        let masterViewController = viewControllers.first!
        viewControllers = [masterViewController, viewController]
    }
    
    public func getDetailViewController() -> UIViewController {
        let detailViewController = viewControllers.last!
        return detailViewController
    }
}

extension UIScrollView {
    public func scrollToBottomAnimated(_ animated: Bool) {
        if contentSize.height > bounds.size.height {
            let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height)
            setContentOffset(bottomOffset, animated: animated)
        }
    }
    
    public func scrollToTop() {
        let inset = self.contentInset
        self.setContentOffset(CGPoint(x: -inset.left, y: -inset.top), animated: true)
    }
}

extension UIImage {
    internal convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage!)!)
    }
    
    public func transform(withNewColor color: UIColor) -> UIImage {
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
    public func fixOrientation() -> UIImage {
        
        if self.imageOrientation == UIImageOrientation.up {
            return self
        }
        
        var transform = CGAffineTransform.identity
        
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            
        case .up, .upMirrored:
            break
        }
        
        switch self.imageOrientation {
            
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        default:
            break
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        guard let cgImage = self.cgImage else {
            return self
        }
        guard let colorSpace = cgImage.colorSpace else {
            return self
        }
        guard let context = CGContext(
            data: nil,
            width: Int(self.size.width),
            height: Int(self.size.height),
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: UInt32(cgImage.bitmapInfo.rawValue)
        ) else {
            return self
        }
        
        context.concatenate(transform)
        
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
        default:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        }
        
        // And now we just create a new UIImage from the drawing context
        guard let newCGImage = context.makeImage() else {
            return self
        }
        let image = UIImage(cgImage: newCGImage)
        
        return image
        
    }
    
    public func compressImageData(maxSizeInMB: Int) -> Data? {
        let image = self.fixOrientation()
        let sizeInBytes = maxSizeInMB * 1024 * 1024
        var needCompress: Bool = true
        var imgData: Data?
        var compressingValue: CGFloat = 1.0
        while needCompress && compressingValue > 0.0 {
            if let data: Data = UIImageJPEGRepresentation(image, compressingValue) {
                if data.count < sizeInBytes {
                    needCompress = false
                    imgData = data
                } else {
                    compressingValue -= 0.1
                }
            }
        }
        
        if let data = imgData {
            if data.count < sizeInBytes {
                return data
            }
        }
        return UIImageJPEGRepresentation(image, 1)
    }
}

extension UIDevice {
    
    internal var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1": return "iPod Touch 5"
        case "iPod7,1": return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3": return "iPhone 4"
        case "iPhone4,1": return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2": return "iPhone 5"
        case "iPhone5,3", "iPhone5,4": return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2": return "iPhone 5s"
        case "iPhone7,2": return "iPhone 6"
        case "iPhone7,1": return "iPhone 6 Plus"
        case "iPhone8,1": return "iPhone 6s"
        case "iPhone8,2": return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3": return "iPhone 7"
        case "iPhone9,2", "iPhone9,4": return "iPhone 7 Plus"
        case "iPhone8,4": return "iPhone SE"
        case "iPhone10,1", "iPhone10,4": return "iPhone 8"
        case "iPhone10,2", "iPhone10,5": return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6": return "iPhone X"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3": return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6": return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3": return "iPad Air"
        case "iPad5,3", "iPad5,4": return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7": return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6": return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9": return "iPad Mini 3"
        case "iPad5,1", "iPad5,2": return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3": return "Apple TV"
        case "i386", "x86_64": return "Simulator"
        default: return identifier
        }
    }
}

extension UINavigationController {
    public func replaceTopViewController(viewController: UIViewController) {
        if self.viewControllers.count > 0 {
            self.viewControllers[self.viewControllers.count - 1] = viewController
        }
    }
}

extension UIScrollView {
    public var rx_reachedBottom: Observable<Void> {
        return rx.contentOffset
            .debounce(0.025, scheduler: MainScheduler.instance)
            .flatMap { [weak self] contentOffset -> Observable<Void> in
                guard let scrollView = self else {
                    return Observable.empty()
                }
                
                let visibleHeight = scrollView.frame.height - scrollView.contentInset.top - scrollView.contentInset.bottom
                let y = contentOffset.y + scrollView.contentInset.top
                let threshold = max(0.0, scrollView.contentSize.height - visibleHeight)
                
                return y >= threshold ? Observable.just() : Observable.empty()
            }
        
    }
}
