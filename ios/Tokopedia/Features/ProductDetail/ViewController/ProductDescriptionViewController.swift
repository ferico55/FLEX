//
//  ProductDescriptionViewController.swift
//  Tokopedia
//
//  Created by Setiady Wiguna on 7/13/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Render
import UIKit

internal class ProductDescriptionViewController: UIViewController, UIGestureRecognizerDelegate, TTTAttributedLabelDelegate {
    
    private var productInfo: ProductInfo
    private var productDescriptionComponent: ProductDescriptionComponentView!
    
    internal override var canBecomeFirstResponder: Bool { return true }
    
    // MARK: - Lifecycle
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal init(productInfo: ProductInfo) {
        self.productInfo = productInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Deskripsi Produk"
        productDescriptionComponent = ProductDescriptionComponentView(viewController: self)
        view.addSubview(productDescriptionComponent)
        productDescriptionComponent.state = ProductDescriptionState(productInfo: productInfo)
    }
    
    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        AnalyticsManager.trackScreenName("Product Detail - Description Page")
    }
    
    internal override func viewDidLayoutSubviews() {
        productDescriptionComponent.render(in: view.bounds.size)
    }
    
    // MARK: - GestureRecognizer Delegate
    internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    internal override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        var result = false
        
        if action == #selector(ProductDetailViewController.copy(_:)) {
            result = true
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
        
        return result
    }
    
    @objc
    internal override func copy(_ sender: Any?) {
        UIPasteboard.general.string = productInfo.descriptionHtml()
    }
    
    // MARK: - TTTAttributedLabel Delegate
    internal func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        TPRoutes.routeURL(url.TKPMeUrl())
    }
}

// MARK: - ProductShipmentComponentView

internal struct ProductDescriptionState: StateType {
    internal let productInfo: ProductInfo
    
    internal init(productInfo: ProductInfo) {
        self.productInfo = productInfo
    }
}

internal class ProductDescriptionComponentView: ComponentView<ProductDescriptionState> {
    
    private let viewController: ProductDescriptionViewController
    
    internal init(viewController: ProductDescriptionViewController) {
        self.viewController = viewController
        super.init()
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func construct(state: ProductDescriptionState?, size: CGSize = CGSize.undefined) -> NodeType {
        
        func descriptionView() -> NodeType {
            guard let productInfo = state?.productInfo else {
                return NilNode()
            }
            
            return Node<TTTAttributedLabel> { view, layout, _ in
                layout.marginLeft = 24
                layout.marginRight = 24
                layout.marginTop = 14
                layout.marginBottom = 14
                view.numberOfLines = 0
                view.font = .title1Theme()
                view.textColor = .tpSecondaryBlackText()
                view.isUserInteractionEnabled = true
                view.delegate = self.viewController
                
                var description = productInfo.descriptionHtml()
                description = description.kv_decodeHTMLCharacterEntities()
                let fullString = NSString.extracTKPMEUrl(description) as String
                
                let descriptionSize = view.font.sizeOfString(string: fullString, constrainedToWidth: Double(size.width - 48))
                layout.height = descriptionSize.height + 50
                
                view.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
                guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
                    return
                }
                let matches = detector.matches(in: fullString, options: [], range: NSRange(location: 0, length: fullString.utf16.count))
                
                for match in matches {
                    view.addLink(to: match.url, with: match.range)
                }
                
                let longPressGestureRecognizer = UILongPressGestureRecognizer()
                longPressGestureRecognizer.minimumPressDuration = 1.0
                _ = longPressGestureRecognizer.rx.event
                    .filter { event in
                        event.state == .began
                    }
                    .subscribe(onNext: { [unowned self] _ in
                        self.didLongPressDescription(view)
                    })
                view.addGestureRecognizer(longPressGestureRecognizer)
                
                view.text = fullString
            }
        }
        
        return Node<UIScrollView>() { view, layout, size in
            layout.width = size.width
            layout.height = size.height
            view.backgroundColor = .white
        }.add(children: [
            descriptionView(),
        ])
    }
    
    private func didLongPressDescription(_ view: UILabel) {
        view.becomeFirstResponder()
        let menuController = UIMenuController.shared
        let centerRect = CGRect(x: 0, y: view.frame.height * 1 / 3, width: view.frame.width, height: view.frame.height)
        menuController.setTargetRect(centerRect, in: view)
        menuController.setMenuVisible(true, animated: true)
    }
}
