//
//  ProductDetailViewController.swift
//  Tokopedia
//
//  Created by Setiady Wiguna on 4/18/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render
import Moya
import Unbox
import MoyaUnbox
import RxSwift
import ReSwift
import TTTAttributedLabel

class ProductDetailViewController: UIViewController, EtalaseViewControllerDelegate, GalleryViewControllerDelegate, NoResultDelegate, UIGestureRecognizerDelegate, TTTAttributedLabelDelegate {
    
    fileprivate var store: Store<ProductDetailState>!
    fileprivate var product: ProductUnbox?
    fileprivate var productView: ProductDetailViewComponent!
    fileprivate var initialData: [String: String]?
    fileprivate var isReplacementMode: Bool!
    
    override var canBecomeFirstResponder: Bool { return true }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    // MARK: - Lifecycle
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.productDetailDidModified(notification:)), name: Notification.Name(ADD_PRODUCT_POST_NOTIFICATION_NAME), object: nil)
    }
    
    convenience init(productID: String) {
        self.init(productID: productID, name: "", price: "", imageURL: "", shopName: "")
    }
    
    convenience init(productID: String, name: String, price: String, imageURL: String, shopName: String) {
        self.init(productID: productID, name: name, price: price, imageURL: imageURL, shopName: shopName, isReplacementMode: false)
    }
    
    convenience init(productID: String, name: String, price: String, imageURL: String, shopName: String, isReplacementMode: Bool) {
        self.init(nibName: nil, bundle: nil)
        self.isReplacementMode = isReplacementMode
        self.initialData = ["id": productID,
                            "name": name,
                            "price": price,
                            "imageURL": imageURL,
                            "shopName": shopName]
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let state = ProductDetailState()
        
        store = Store<ProductDetailState>(
            reducer: ProductDetailReducer(),
            state: state
        )
        
        guard let initialData = self.initialData else {
            return
        }
        
        self.productView = ProductDetailViewComponent(store: self.store, viewController: self)
        
        self.view.addSubview(self.productView)
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        self.store.dispatch(ProductDetailAction.begin(initialData))
        self.loadProductDetail(data: initialData)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        UIApplication.shared.statusBarStyle = .lightContent
        
        // return navigation bar style to default
        self.navigationController?.navigationBar.barTintColor = .tpNavigationBar()
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.productView.render(in: self.view.bounds.size)
        self.store.subscribe(self.productView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Data
    private func loadProductDetail(data: [String: String]) {
        let provider = NetworkProvider<V4Target>(plugins: [NetworkLoggerPlugin()])
        provider.request(.getProductDetail(withProductId: data["id"], productName: data["name"], shopName: data["shopName"]))
            .do(onError: { error in
                    
                var errorMessages: [String]
                switch (error as NSError).code {
                case NSURLErrorBadServerResponse:
                    errorMessages = ["Mohon maaf, terjadi kendala pada server kami. Mohon kirimkan screenshot halaman ini ke ios[dot]feedback@tokopedia[dot]com untuk kami investigasi lebih lanjut."]
                case NSURLErrorNotConnectedToInternet:
                    errorMessages = ["Tidak ada koneksi internet"]
                case NSURLErrorCancelled:
                    errorMessages = ["Terjadi kendala pada koneksi internet"]
                default:
                    errorMessages = [error.localizedDescription]
                }
                StickyAlertView.showErrorMessage(errorMessages)
            })
            .map(to: ProductUnbox.self)
            .subscribe({ event in
                switch event {
                case let .next(product) :
                    self.trackScreenWithProduct(product: product)
                    self.product = product
                    self.loadOtherProduct(product: product)
                    if product.shop.isGoldMerchant {
                        self.loadProductVideos(product: product)
                    }
                    self.checkProductAndDispatch(product: product)
                    
                case let .error(error) :
                    if let moyaError = error as? MoyaError,
                        let _ = moyaError.response {
                        self.store.dispatch(ProductDetailAction.updateActivity(.noResult))
                    }
                    
                default:
                    break
                }
            })
            .disposed(by: self.rx_disposeBag)
        
    }
    
    private func trackScreenWithProduct(product: ProductUnbox) {
        let shopID = product.shop.id
        var shopType = "regular"
        
        if product.shop.isGoldMerchant {
            shopType = "gold_merchant"
        }
        
        if product.shop.isOfficial {
            shopType = "official_store"
        }
        
        let customLayer = ["shopId": shopID,
                           "shopType": shopType]
        
        AnalyticsManager.trackScreenName("Product Detail Page", customDataLayer: customLayer)
    }
    
    private func checkProductAndDispatch(product: ProductUnbox) {
        if product.info.status == .deleted {
            self.store.dispatch(ProductDetailAction.receive(product, .noResult))
            return
        }
        
        let userAuthenticationManager = UserAuthentificationManager()
        if userAuthenticationManager.isLogin &&
            userAuthenticationManager.isMyShop(withShopId: product.shop.id) {
            if product.shop.status == .open && product.info.status == .active {
                self.store.dispatch(ProductDetailAction.receive(product, .seller))
                return
            }
            self.store.dispatch(ProductDetailAction.receive(product, .sellerInactive))
        } else {
            if product.shop.status == .open && product.info.status == .active {
                if self.isReplacementMode {
                    self.store.dispatch(ProductDetailAction.receive(product, .replacement))
                    return
                }
                self.store.dispatch(ProductDetailAction.receive(product, .normal))
            } else {
                self.store.dispatch(ProductDetailAction.receive(product, .inactive))
            }
        }
    }
    
    private func loadProductVideos(product: ProductUnbox) {
        let provider = NetworkProvider<GoldMerchantTarget>()
        provider.request(.getProductVideos(withProductID: product.id))
            .do(onError: { error in
                print(error)
            })
            .map(to: ProductVideos.self)
            .subscribe({ event in
                switch event {
                case let .next(productVideo) :
                    self.product?.videos = productVideo.videos
                    self.store.dispatch(ProductDetailAction.receive(self.product!, nil))
                    
                case let .error(error) :
                    print("\(error.localizedDescription)")
                default:
                    break
                }
            })
            .disposed(by: self.rx_disposeBag)
    }
    
    private func loadOtherProduct(product: ProductUnbox) {
        let provider = NetworkProvider<AceTarget>(plugins: [NetworkLoggerPlugin()])
        provider.request(.getOtherProduct(withProductID: product.id, shopID: product.shop.id))
            .do(onError: { _ in
                
            })
            .map(to: OtherProducts.self)
            .subscribe({ event in
                switch event {
                case let .next(other) :
                    self.product?.otherProducts = other.products
                    self.store.dispatch(ProductDetailAction.receive(self.product!, nil))
                case let .error(error) :
                    print("\(error.localizedDescription)")
                default:
                    break
                }
            })
            .disposed(by: self.rx_disposeBag)
        
    }
    
    // MARK: - EtalaseViewController Delegate
    func didSelectEtalase(_ selectedEtalase: EtalaseList!) {
        guard var productDetail = store.state.productDetail else {
            return
        }
        
        let provider = NetworkProvider<V4Target>()
        
        provider.request(.moveToEtalase(withProductId: productDetail.id, etalaseId: selectedEtalase.etalase_id, etalaseName: selectedEtalase.etalase_name))
            .subscribe(onNext: { _ in
                productDetail.info.status = .active
                productDetail.info.etalaseId = selectedEtalase.etalase_id
                productDetail.info.etalaseName = selectedEtalase.etalase_name
                if productDetail.shop.status == .open && productDetail.info.status == .active {
                    self.store.dispatch(ProductDetailAction.receive(productDetail, .seller))
                } else {
                    self.store.dispatch(ProductDetailAction.receive(productDetail, .sellerInactive))
                }
                
            },
            onError: { _ in
                print("error")
            })
            .disposed(by: self.rx_disposeBag)
    }
    
    // MARK: - GalleryViewController Delegate
    func numberOfPhotos(forPhotoGallery gallery: GalleryViewController!) -> Int32 {
        guard let images = store.state.productDetail?.images else {
            return 0
        }
        return Int32(images.count)
    }
    
    func photoGallery(_ index: UInt) -> UIImage! {
        return nil
    }
    
    func photoGallery(_ gallery: GalleryViewController!, captionForPhotoAt index: UInt) -> String! {
        guard let images = store.state.productDetail?.images else {
            return ""
        }
        
        return images[Int(index)].imageDescription
    }
    
    func photoGallery(_ gallery: GalleryViewController!, urlFor size: GalleryPhotoSize, at index: UInt) -> String! {
        guard let images = store.state.productDetail?.images else {
            return ""
        }
        
        return images[Int(index)].normalURL
    }
    
    // MARK: - NoResultView Delegate
    func buttonDidTapped(_ sender: Any!) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - GestureRecognizer Delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        var result = false
        
        if action == #selector(ProductDetailViewController.copy(_:)) {
            result = true
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
        
        return result
    }
    
    @objc
    override func copy(_ sender: Any?) {
        guard let description = store.state.productDetail?.info.descriptionHtml() else {
            return
        }
        UIPasteboard.general.string = description
    }
    
    // MARK: - TTTAttributedLabel Delegate
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        var trueURL = "https://tkp.me/r?url=" + url.absoluteString.replacingOccurrences(of: "*", with: ".")
        if url.host == "www.tokopedia.com" {
            trueURL = url.absoluteString
        }
        
        let vc = WebViewController()
        vc.strURL = trueURL
        vc.strTitle = "Mengarahkan..."
        vc.onTapLinkWithUrl = { [weak self] url in
            if url?.absoluteString == "https://www.tokopedia.com/" {
                self?.navigationController?.popViewController(animated: true)
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - NotificationHandler
    @objc
    func productDetailDidModified(notification: NSNotification) {
        if let initialData = self.initialData {
            self.loadProductDetail(data: initialData)
        }
    }
}
