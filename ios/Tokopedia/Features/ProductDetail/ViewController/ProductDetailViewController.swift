//
//  ProductDetailViewController.swift
//  Tokopedia
//
//  Created by Setiady Wiguna on 4/18/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Moya
import MoyaUnbox
import Render
import ReSwift
import RxSwift
import SwiftyJSON
import TTTAttributedLabel
import UIKit
import Unbox

internal class ProductDetailViewController: UIViewController, EtalaseViewControllerDelegate, GalleryViewControllerDelegate, NoResultDelegate, UIGestureRecognizerDelegate, TTTAttributedLabelDelegate {

    fileprivate var store: Store<ProductDetailState>!
    fileprivate var product: ProductUnbox?
    fileprivate var promo: PromoDetail?
    fileprivate var productView: ProductDetailViewComponent!
    fileprivate var initialData: [String: String]?
    fileprivate var isReplacementMode: Bool!
    fileprivate var campaignTimer = Timer()
    fileprivate var campaignEndDate: Date?

    fileprivate lazy var safeAreaView: UIView = {
        let view = UIView(frame: CGRect.zero)

        view.backgroundColor = .clear

        return view
    }()

    override internal var canBecomeFirstResponder: Bool { return true }
    override internal var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }

    // MARK: - Lifecycle
    required internal init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override internal init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.productDetailDidModified(notification:)), name: Notification.Name(ADD_PRODUCT_POST_NOTIFICATION_NAME), object: nil)
    }

    convenience internal init(productID: String = "", name: String = "", price: String = "", imageURL: String = "", shopName: String = "", isReplacementMode: Bool = false) {
        self.init(nibName: nil, bundle: nil)

        self.isReplacementMode = isReplacementMode
        self.initialData = ["id": productID,
                            "name": name,
                            "price": price,
                            "imageURL": imageURL,
                            "shopName": shopName]
    }

    override internal func viewDidLoad() {
        super.viewDidLoad()
        let state = ProductDetailState()

        store = Store<ProductDetailState>(reducer: ProductDetailReducer(),
                                          state: state)

        guard let initialData = self.initialData else {
            return
        }

        self.productView = ProductDetailViewComponent(store: self.store, viewController: self)
        self.productView.delegate = self

        self.view.addSubview(self.safeAreaView)

        self.safeAreaView.addSubview(self.productView)

        self.safeAreaView.translatesAutoresizingMaskIntoConstraints = false

        // Hacking for iOS 11 except iPhone X
        var topAnchor: NSLayoutYAxisAnchor = self.view.topAnchor
        var topConstant: CGFloat = 0

        if #available(iOS 11, *) {
            if UIDevice.current.modelName.caseInsensitiveCompare("iPhone X") == ComparisonResult.orderedSame {
                topAnchor = self.view.safeAreaTopAnchor
                topConstant = 0
            } else {
                topAnchor = self.view.topAnchor
                topConstant = -UIApplication.shared.statusBarFrame.size.height
            }
        }

        NSLayoutConstraint.activate([
            self.safeAreaView.topAnchor.constraint(equalTo: topAnchor, constant: topConstant),
            self.safeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaBottomAnchor, constant: 0),
            self.safeAreaView.rightAnchor.constraint(equalTo: self.view.safeAreaRightAnchor, constant: 0),
            self.safeAreaView.leftAnchor.constraint(equalTo: self.view.safeAreaLeftAnchor, constant: 0)
            ])

        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

        self.store.dispatch(ProductDetailAction.begin(initialData))
        self.loadProductDetail(data: initialData)
    }

    override internal func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        AnalyticsManager.trackScreenName("Product Information")

        self.navigationController?.isNavigationBarHidden = true

        if let campaignEndDate = campaignEndDate,
            campaignEndDate > Date() {
            self.campaignTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ProductDetailViewController.campaignScheduledProcess), userInfo: nil, repeats: true)
        }
    }

    override internal func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.campaignTimer.invalidate()
    }

    override internal func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override internal func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.productView.render(in: self.safeAreaView.bounds.size)
        self.store.subscribe(self.productView)
    }

    deinit {
        campaignTimer.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Analytic
    private func trackScreenWithProduct(product: ProductUnbox) {
        guard !product.categories.isEmpty else { return }

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

        AnalyticsManager.trackScreenName("Product Detail Page Finished Load", customDataLayer: customLayer)

        AnalyticsManager.moEngageTrackEvent(withName: "Product_Page_Opened",
                                            attributes: self.moengageAttributes(product: product))
        AnalyticsManager.trackProductView(product: product)
    }

    private func moengageAttributes(product: ProductUnbox) -> [String: Any] {
        var attributes = ["product_name": product.name,
                          "product_url": product.url,
                          "product_id": product.id,
                          "product_image_url": product.images.first?.normalURL ?? "",
                          "product_price": product.info.priceUnformatted,
                          "shop_id": product.shop.id,
                          "is_official_store": product.shop.isOfficial,
                          "shop_name": product.shop.name,
                          "category": product.categories.first?.name ?? "",
                          "category_id": product.categories.first?.id ?? ""] as [String: Any]

        if product.categories.count > 1 {
            attributes["subcategory"] = product.categories[1].name
            attributes["subcategory_id"] = product.categories[1].id
        }

        return attributes
    }

    // MARK: - Data
    private func loadProductDetail(data: [String: String]) {
        let provider = NetworkProvider<V4Target>(plugins: [NetworkLoggerPlugin()])
        provider.request(.getProductDetail(withProductId: data["id"], productName: data["name"], shopName: data["shopName"]))
            .do(onError: { error in

                var errorMessages: [String]
                switch (error as NSError).code {
                case NSURLErrorBadServerResponse, NSURLErrorCancelled:
                    errorMessages = ["Terjadi kendala pada server. Mohon coba beberapa saat lagi."]
                case NSURLErrorNotConnectedToInternet:
                    errorMessages = ["Tidak ada koneksi internet"]
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
                    self.store.dispatch(ProductDetailAction.updateWishlist((self.product?.isWishlisted)!))

                    self.loadOtherProduct(product: product)
                    self.loadPromo()
                    if product.shop.isGoldMerchant {
                        self.loadProductVideos(product: product)
                    }

                    self.loadProductMostHelpfulReview(product: product)
                    self.loadProductLatestDiscussion(product: product)
                    self.loadProductStock(product: product)

                    if let _ = product.campaign {
                        self.setupCampaignTimer()
                    }

                    if product.info.hasVariant {
                        self.store.dispatch(ProductDetailAction.productNeedLoadVariant(true))
                        self.loadProductVariant(product: product)
                    } else {
                        self.store.dispatch(ProductDetailAction.productNeedLoadVariant(false))
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

    fileprivate func checkProductAndDispatch(product: ProductUnbox) {
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
            } else if product.shop.status == .open && product.info.status != .active {
                self.store.dispatch(ProductDetailAction.receive(product, .outOfStock))
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

    private func loadProductMostHelpfulReview(product: ProductUnbox) {
        let provider = NetworkProvider<ReputationTarget>()
        provider.request(.getMostHelpfulReview(withProductID: product.id))
            .map(to: ProductReviews.self)
            .subscribe({ event in
                switch event {
                case let .next(productReviews) :
                    self.product?.mostHelpfulReviews = productReviews.reviews
                    self.store.dispatch(ProductDetailAction.receive(self.product!, nil))

                case let .error(error) :
                    print("\(error.localizedDescription)")
                default:
                    break
                }
            })
            .disposed(by: self.rx_disposeBag)
    }
    
    private func loadProductStock(product: ProductUnbox) {
        let provider = NetworkProvider<V4Target>()
        provider.request(.getStockProduct(withProductId: product.id))
            .map(to: ProductStock.self)
            .subscribe({ event in
                switch event {
                case let .next(stock) :
                    if stock.stockString != "" {
                        self.product?.stockProduct = stock
                    }
                    
                    if let product = self.product {
                        self.store.dispatch(ProductDetailAction.receive(product, nil))
                    }
                    
                case let .error(error) :
                    if let product = self.product {
                        self.store.dispatch(ProductDetailAction.receive(product, nil))
                    }
                default:
                    break
                }
            })
            .disposed(by: self.rx_disposeBag)
    }

    private func loadProductLatestDiscussion(product: ProductUnbox) {
        let provider = NetworkProvider<TalkTarget>()
        provider.request(.getLatestTalk(withProductID: product.id))
            .map(to: ProductTalks.self)
            .subscribe({ event in
                switch event {
                case let .next(productTalks) :
                    if !productTalks.talks.isEmpty {
                        self.product?.latestDiscussion = productTalks.talks[0]
                        if let talkID = self.product?.latestDiscussion?.talkID {
                            self.loadProductDiscussionComment(talkID: talkID)
                        } else {
                            self.store.dispatch(ProductDetailAction.receive(self.product!, nil))
                        }
                    }
                case let .error(error) :
                    print("\(error.localizedDescription)")
                default:
                    break
                }
            })
            .disposed(by: self.rx_disposeBag)
    }

    private func loadProductDiscussionComment(talkID: String) {
        let provider = NetworkProvider<TalkTarget>()
        provider.request(.getTalkComment(withTalkID: talkID))
            .map(to: ProductTalkComments.self)
            .subscribe({ event in
                switch event {
                case let .next(productTalkComments) :
                    if !productTalkComments.comments.isEmpty {
                        self.product?.latestDiscussion?.comments = productTalkComments.comments
                    }
                    self.store.dispatch(ProductDetailAction.receive(self.product!, nil))
                case let .error(error) :
                    self.store.dispatch(ProductDetailAction.receive(self.product!, nil))
                    print("\(error.localizedDescription)")
                default:
                    break
                }
            })
            .disposed(by: self.rx_disposeBag)
    }

    private func loadProductVariant(product: ProductUnbox) {
        let provider = NetworkProvider<V4Target>()

        provider.request(
            .getVariantProduct(withProductId: product.id))
            .subscribe(onNext: { [weak self] response in
                guard let `self` = self else { return }

                if response.statusCode == 200 {
                    self.store.dispatch(ProductDetailAction.productNeedLoadVariant(false))
                    let result = JSON(response.data)
                    let productVariant = ProductVariant(json: result["data"])
                    self.product?.variantProduct = productVariant

                    Array(Set(productVariant.possibilityChildrens.map {
                        return $0.originalPicture
                    })).forEach {
                        if !$0.isEmpty || $0 != "" {
                            self.product?.fullImages.append(ProductImage(normalURL: $0))
                        }
                    }

                    self.store.dispatch(ProductDetailAction.receive(self.product!, nil))
                } else {
                    UIViewController.showNotificationWithMessage("Terjadi kesalahan saat memproses permintaan Anda.", type: NotificationType.error.rawValue, duration: 50, buttonTitle: "Coba Lagi", dismissable: false, action: { [weak self] in
                        guard let `self` = self else { return }
                        self.loadProductVariant(product: product)
                    })
                }

                }, onError: { [weak self] error in
                    guard let `self` = self else { return }
                    self.store.dispatch(ProductDetailAction.productNeedLoadVariant(false))
                    guard let moyaError = (error as? MoyaError), let _ = moyaError.response else {
                        StickyAlertView.showErrorMessage([error.localizedDescription])
                        return
                    }
                    StickyAlertView.showErrorMessage(["Terjadi kesalahan saat memproses permintaan Anda."])
            })
            .disposed(by: self.rx_disposeBag)
    }

    @objc
    private func campaignScheduledProcess() {
        if let campaignEndDate = campaignEndDate,
            campaignEndDate < Date() {
            self.campaignTimer.invalidate()
            self.campaignEndDate = nil
            self.product?.campaign = nil
        }

        self.store.dispatch(ProductDetailAction.receive(self.product!, nil))
    }

    // MARK: - EtalaseViewController Delegate
    internal func didSelectEtalase(_ selectedEtalase: EtalaseList!) {
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
    internal func numberOfPhotos(forPhotoGallery gallery: GalleryViewController!) -> Int32 {
        guard let images = store.state.productDetail?.fullImages,
            !images.isEmpty else {
                return 0
        }
        return Int32(images.count)
    }

    internal func photoGallery(_ index: UInt) -> UIImage! {
        return nil
    }

    internal func photoGallery(_ gallery: GalleryViewController!, captionForPhotoAt index: UInt) -> String! {
        guard let images = store.state.productDetail?.fullImages,
            images.count > Int(index) else {
                return ""
        }

        return images[Int(index)].imageDescription
    }

    internal func photoGallery(_ gallery: GalleryViewController!, urlFor size: GalleryPhotoSize, at index: UInt) -> String! {
        guard let images = store.state.productDetail?.fullImages,
            images.count > Int(index) else {
                return ""
        }

        return images[Int(index)].normalURL
    }

    // MARK: - NoResultView Delegate
    internal func buttonDidTapped(_ sender: Any!) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - GestureRecognizer Delegate
    internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    override internal func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        var result = false

        if action == #selector(ProductDetailViewController.copy(_:)) {
            result = true
        } else {
            return super.canPerformAction(action, withSender: sender)
        }

        return result
    }

    @objc
    override internal func copy(_ sender: Any?) {
        guard let description = store.state.productDetail?.info.descriptionHtml() else {
            return
        }
        UIPasteboard.general.string = description
    }

    // MARK: - TTTAttributedLabel Delegate
    internal func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        TPRoutes.routeURL(url.TKPMeUrl())
    }

    // MARK: - NotificationHandler
    @objc
    internal func productDetailDidModified(notification: NSNotification) {
        if let initialData = self.initialData {
            self.loadProductDetail(data: initialData)
        }
    }

    // MARK: - PromoWidget
    internal func loadPromo() {
        let provider = NetworkProvider<GaladrielTarget>()
        provider.request(.getPromoWidget(shopType: (self.product?.shop.isOfficial ?? false) ? "os" : "merchant"))
            .map(to: PromoUnbox.self)
            .subscribe(onNext: { (promoUnbox) in
                guard let data = promoUnbox.list.first else {
                    return
                }
                self.store.dispatch(ProductDetailAction.receivePromo(data))
            })
            .disposed(by: self.rx_disposeBag)
    }

    // MARK: - Private Function
    fileprivate func setupCampaignTimer() {
        guard let productDetail = self.product, let campaign = productDetail.campaign else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"

        if let endPromoDate = formatter.date(from: campaign.endDate),
            endPromoDate > Date(),
            endPromoDate.timeIntervalSinceNow < 24 * 60 * 60 {
            self.campaignEndDate = endPromoDate
            self.campaignTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ProductDetailViewController.campaignScheduledProcess), userInfo: nil, repeats: true)
        }
    }
}

extension ProductDetailViewController: ProductDetailComponentDelegate {
    internal func productDetailDidModified(productDetail: ProductUnbox) {
        self.product = productDetail

        self.checkProductAndDispatch(product: productDetail)
        self.store.dispatch(ProductDetailAction.updateWishlist(productDetail.isWishlisted))

        self.campaignEndDate = nil
        self.campaignTimer.invalidate()
        self.setupCampaignTimer()
    }
}
