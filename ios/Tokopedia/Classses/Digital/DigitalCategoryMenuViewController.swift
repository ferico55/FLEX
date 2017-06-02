import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import BEMCheckBox
import Masonry
import Render
import ReSwift
import BlocksKit
import MMNumberKeyboard
import SwiftOverlays
import TPKeyboardAvoiding

import Moya

extension Array where Element: DigitalOperator {
    func appropriateOperator(for text: String) -> DigitalOperator? {
        return self.first { (digitalOperator) -> Bool in
            return digitalOperator.hasPrefix(for: text)
        }
    }
}

extension Reactive where Base: UIImageView {
    public var imageUrl: UIBindingObserver<Base, URL?> {
        return UIBindingObserver(UIElement: base) { imageView, url in
            imageView.setImageWith(url)
        }
    }
}

extension ObservableType where E: ReSwift.Action {
    public func dispatch<State: ReSwift.StateType>(to store: Store<State>) -> Disposable {
        let disposable = self.subscribe(onNext: { action in
            store.dispatch(action)
        })
        return disposable
    }
}

import Unbox
import MoyaUnbox

// MARK: UI

class DigitalCategoryMenuViewController: UIViewController {
    fileprivate var store: Store<DigitalState>!
    
    fileprivate var widgetView: DigitalWidgetView!
    fileprivate let provider = DigitalProvider()
    
    fileprivate let categoryId: String
    
    required init(categoryId: String) {
        self.categoryId = categoryId
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }
    
    convenience init() {
        self.init(categoryId: "3")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not used")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let barButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-option"), style: .plain, target: nil, action: nil)
        
        barButton.rx.tap.subscribe(onNext: { [unowned self] in
            let openWebView = { (_ urlString: String) -> () in
                let webViewController = WKWebViewController(urlString: urlString)
                
                self.navigationController?.pushViewController(webViewController, animated: true)
            }
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Daftar Produk", style: .default) { _ in
                openWebView("\(NSString.pulsaUrl())/products/")
            })
            
            alertController.addAction(UIAlertAction(title: "Daftar Transaksi", style: .default) { _ in
                openWebView("\(NSString.pulsaUrl())/order-list/")
            })
            
            alertController.addAction(UIAlertAction(title: "Langganan", style: .default) { _ in
                openWebView("\(NSString.pulsaUrl())/subscribe/")
            })
            
            alertController.addAction(UIAlertAction(title: "Batal", style: .cancel) { _ in
                
            })
            
            alertController.popoverPresentationController?.barButtonItem = barButton
            
            self.present(alertController, animated: true, completion: nil)
        })
            .disposed(by: rx_disposeBag)
        
        self.navigationItem.rightBarButtonItem = barButton
        
        let state = DigitalState()
        
        store = Store<DigitalState>(
            reducer: DigitalWidgetReducer(),
            state: state
        )
        
        widgetView = DigitalWidgetView(store: store, categoryId: categoryId, viewController: self)
        
        self.view.addSubview(widgetView)
        
        widgetView.state = state
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AnalyticsManager.trackScreenName("Recharge Category Page")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        widgetView.render(in: self.view.bounds.size)
        store.subscribe(widgetView) //subscribe after rendering for the first time
    }
    
    deinit {
        store.unsubscribe(widgetView)
    }
}

class DigitalWidgetView: ComponentView<DigitalState>, StoreSubscriber, BEMCheckBoxDelegate {
    fileprivate var disposeBag = DisposeBag()
    fileprivate let store: Store<DigitalState>
    
    fileprivate let phoneBookService = PhoneBookService()
    fileprivate weak var viewController: UIViewController?
    
    fileprivate let categoryId: String
    
    init(store: Store<DigitalState>, categoryId: String, viewController: UIViewController) {
        self.store = store
        self.categoryId = categoryId
        self.viewController = viewController
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func textInputNode(for textInput: DigitalTextInput, with textInputState: DigitalTextInputState) -> NodeType {
        unowned let `self` = self
        
        return Node(identifier: textInput.id) { view, layout, size in
            layout.marginBottom = 10
            layout.marginTop = 15
            }.add(children:[
                Node<UILabel>(identifier: "title") { label, layout, size in
                    label.text = textInput.title
                    label.font = .smallTheme()
                    label.textColor = UIColor.black.withAlphaComponent(0.38)
                    layout.marginBottom = 5
                },
                Node(identifier: "content") { (view, layout, size) in
                    layout.flexDirection = .row
                    layout.alignItems = .center
                    }.add(children: [
                        Node(identifier: "text-container") { view, layout, size in
                            layout.flexDirection = .column
                            layout.flexGrow = 1
                            layout.flexShrink = 1
                            layout.marginBottom = 5
                            }.add(children: [
                                Node<UITextField>(
                                    identifier: "textfield",
                                    create: {
                                        let textField = UITextField()
                                        textField.textColor = UIColor.black.withAlphaComponent(0.54)
                                        return textField
                                    }
                                ) { [unowned self] (view, layout, size) in
                                    layout.height = 25
                                    layout.marginBottom = 5
                                    
                                    view.font = .largeTheme()
                                    view.text = textInputState.text
                                    view.placeholder = textInput.placeholder
                                    view.clearButtonMode = .always
                                    
                                    if textInput.type == .number || textInput.type == .phone {
                                        let keyboard = MMNumberKeyboard()
                                        keyboard.allowsDecimalPoint = false
                                        
                                        view.inputView = keyboard
                                    }
                                    
                                    view
                                        .rx.text.orEmpty.changed
                                        .map { DigitalWidgetAction.changePhoneNumber(textInput: textInput, text: $0) }
                                        .dispatch(to: self.store)
                                        .disposed(by: self.disposeBag)
                                    }.add(child: Node<UIImageView>(identifier: "icon")
                                        {[unowned self] (imageView, layout, size) in
                                            layout.width = 35
                                            layout.height = 35
                                            layout.right = 30
                                            layout.top = -5
                                            layout.position = .absolute

                                            imageView.contentMode = .scaleAspectFit
                                            imageView.setImageWith(URL(string: self.state!.selectedOperator?.imageUrl ?? ""))
                                    }) ,
                                Node() { view, layout, size in
                                    layout.height = 1
                                    
                                    view.backgroundColor = .fromHexString("#d8d8d8")
                                },
                                ]),
                        {
                            if textInput.type != .phone {
                                return NilNode()
                            }
                            
                            return Node<UIButton> { [unowned self] (button, layout, size) in
                                layout.width = 25
                                layout.height = 25
                                layout.marginLeft = 5
                                
                                button.setImage(#imageLiteral(resourceName: "icon_phonebook"), for: .normal)
                                
                                
                                //FIXME: the number of callback increases as the number of tap increases
                                button.rx.tap
                                    .flatMap { () -> Observable<String> in
                                        self.phoneBookService.findContact(from: self.viewController!)
                                        return self.phoneBookService.phoneNumberSelected.asObservable()
                                    }
                                    .map { text in
                                        return DigitalWidgetAction.changePhoneNumber(textInput: textInput, text: text)
                                    }
                                    .dispatch(to: self.store)
                                    .disposed(by: self.rx_disposeBag)
                            }
                        }(),
                        ]),
                Node<UILabel> { label, layout, size in
                    label.font = .smallTheme()
                    label.textColor = .red
                    
                    label.text = self.state!.showErrors ? textInput.errorMessage(
                        for: textInputState.text,
                        operators: self.state!.form!.operators
                    ) : nil
                },
                ])
    }
    
    func mainContent(state: DigitalState?, size: CGSize) -> NodeType {
        unowned let `self` = self
        
        let operatorSelector = { () -> NodeType in
            switch state!.form!.operatorSelectonStyle {
            case let .prefixChecking(textInput):
                let textInputState = state!.textInputStates[textInput.id] ?? DigitalTextInputState(text: "", failedValidation: nil)
                
                return textInputNode(for: textInput, with: textInputState)
                
            case .choice: return
                Node() { view, layout, size in
                    layout.paddingVertical = 5
                    layout.marginBottom = 10
                    layout.marginTop = 15
                    }.add(children: [
                        Node<UILabel>() { label, layout, size in
                            label.text = "Pilih Produk \(state!.form!.name)"
                            label.font = .smallTheme()
                            label.textColor = UIColor.black.withAlphaComponent(0.38)
                            layout.marginBottom = 5
                        },
                        Node<UIButton> { [unowned self] button, layout, size in
                            layout.height = 25
                            layout.marginBottom = 5
                            button.setTitle(state?.selectedOperator?.name ?? "- Pilih -", for: .normal)
                            button.contentHorizontalAlignment = .left
                            button.setTitleColor(UIColor.black.withAlphaComponent(0.54), for: .normal)
                            button.titleLabel?.font = .title2Theme()
                            
                            button.rx.tap
                                .flatMap { () -> Observable<DigitalOperator> in
                                    let viewController = DigitalOperatorSelectionViewController(operators: state!.form!.operators)
                                    
                                    self.viewController?.navigationController?.pushViewController(viewController, animated: true)
                                    
                                    return viewController.onOperatorSelected
                                }
                                .do(onNext: { selectedOperator in
                                    AnalyticsManager.trackRechargeEvent(event: .homepage, category: self.state?.form, operators: selectedOperator, product: self.state?.selectedProduct, action:"Select Operator")
                                })
                                .map { DigitalWidgetAction.selectOperator($0) }
                                .dispatch(to: self.store)
                                .disposed(by: self.rx_disposeBag)
                            }.add(child: Node<UIImageView> { view, layout, size in
                                layout.width = 14
                                layout.height = 14
                                layout.position = .absolute
                                layout.right = 0
                                layout.top = 5.5
                                
                                view.image = #imageLiteral(resourceName: "icon_arrow_down_grey")
                            }),
                        Node() { view, layout, size in
                            layout.height = 1
                            
                            view.backgroundColor = .fromHexString("#d8d8d8")
                        }
                        ])
                
            case .implicit:
                return NilNode()
            }
        }()
        
        let shouldShowProductButton = state?.selectedOperator?.shouldShowProductSelection ?? false
        
        let productButton = Node(identifier: "product button") { view, layout, size in
            layout.paddingVertical = 5
            layout.marginBottom = 10
            layout.marginTop = 15
            }.add(children: [
                Node<UILabel>() { label, layout, size in
                    label.text = state?.selectedOperator?.productSelectionTitle
                    label.font = .smallTheme()
                    label.textColor = UIColor.black.withAlphaComponent(0.38)
                    layout.marginBottom = 5
                },
                Node<UIButton> { [unowned self] button, layout, size in
                    layout.height = 25
                    
                    button.setTitle(state?.selectedProduct?.name ?? "- Pilih -", for: .normal)
                    button.contentHorizontalAlignment = .left
                    button.setTitleColor(UIColor.black.withAlphaComponent(0.54), for: .normal)
                    button.titleLabel?.font = .title2Theme()
                    
                    guard let state = state,
                        let viewController = self.viewController,
                        let selectedOperator = state.selectedOperator else { return }
                    
                    button
                        .rx.tap
                        .flatMap { () -> Observable<DigitalProduct> in
                            let productSelectionViewController = DigitalProductSelectionViewController(products: selectedOperator.products)
                            
                            viewController.navigationController?.pushViewController(productSelectionViewController, animated: true)
                            
                            return productSelectionViewController.onProductSelected
                        }
                        .do(onNext: { selectedProduct in
                            AnalyticsManager.trackRechargeEvent(event: .homepage, category: self.state?.form, operators: self.state?.selectedOperator, product: selectedProduct, action:"Select Product")
                        })
                        .map { DigitalWidgetAction.selectProduct($0) }
                        .dispatch(to: self.store)
                        .disposed(by: self.rx_disposeBag)
                    
                    }.add(child: Node<UIImageView> { view, layout, size in
                        layout.width = 14
                        layout.height = 14
                        layout.position = .absolute
                        layout.right = 0
                        layout.top = 5.5
                        
                        view.image = #imageLiteral(resourceName: "icon_arrow_down_grey")
                    }),
                Node() { view, layout, size in
                    layout.height = 1
                    
                    view.backgroundColor = .fromHexString("#d8d8d8")
                },
                Node<UILabel>() { label, layout, size in
                    label.font = .smallTheme()
                    label.textColor = .red
                    label.text = state!.showErrors && state!.selectedProduct == nil ? "Pilih terlebih dahulu" : nil
                    
                }
                ])
        
        let operatorInputs = state?.selectedOperator?.textInputs.map { textInput in
            return textInputNode(for: textInput, with: state!.textInputStates[textInput.id] ?? DigitalTextInputState(text: "", failedValidation: nil))
        }
        
        return Node<UIView>(identifier: "widget") { (view, layout, size) in
            view.backgroundColor = .white
            layout.padding = 15
            }.add(children: [
                operatorSelector,
                
                Node(identifier: "operator_\(state?.selectedOperator?.name ?? "empty")")
                    .add(children: operatorInputs ?? [Node()]),
                
                shouldShowProductButton ? productButton as NodeType : NilNode(),
                
                {
                    guard state!.form!.isInstantPaymentAvailable else { return NilNode() }
                    
                    return Node() { view, layout, size in
                        layout.flexDirection = .row
                        layout.paddingVertical = 5
                        layout.alignItems = .center
                        layout.marginTop = 10
                        }.add(children:[
                            Node<BEMCheckBox>() { checkbox, layout, size in
                                layout.width = 18
                                layout.height = 18
                                
                                checkbox.delegate = self
                                checkbox.on = state!.isInstantPaymentEnabled
                                checkbox.boxType = .square
                                checkbox.lineWidth = 1
                                checkbox.onTintColor = .white
                                checkbox.onCheckColor = .white
                                checkbox.onFillColor = .tpGreen()
                                checkbox.animationDuration = 0
                            },
                            Node<UIButton>() { button, layout, size in
                                layout.marginLeft = 5
                                button.titleLabel?.font = .largeTheme()
                                button.setTitle("Bayar Instan", for: .normal)
                                button.setTitleColor(UIColor.black.withAlphaComponent(0.54), for: .normal)
                                
                                button.rx.tap
                                    .map { DigitalWidgetAction.toggleInstantPayment }
                                    .dispatch(to: self.store)
                                    .disposed(by: self.disposeBag)
                            }
                            ])
                }(),
                
                Node<UIButton>(
                    identifier: "buy",
                    create: {
                        let button = UIButton(type:. system)
                        button.setTitleColor(.white, for: .normal)
                        button.backgroundColor = .tpOrange()
                        button.titleLabel?.font = .largeTheme()
                        button.layer.cornerRadius = 3
                        
                        return button
                    }
                ) { button, layout, size in
                    let addToCartProgress = state!.addToCartProgress
                    
                    let title = addToCartProgress == .idle ? "Beli" : "Sedang proses..."
                    
                    button.setTitle(title, for: .normal)
                    
                    button.isEnabled = addToCartProgress != .onProgress && state!.canAddToCart
                    
                    layout.height = 52
                    layout.flexDirection = .row
                    layout.marginBottom = 40
                    layout.marginTop = 20
                    button.rx.tap
                        .subscribe(onNext: {
                            guard state!.passesTextValidations && state!.selectedProduct != nil else {
                                self.store.dispatch(DigitalWidgetAction.buyButtonTap)
                                return
                            }
                            
                            self.store.dispatch(DigitalWidgetAction.addToCart)
                            
                            let productId = state!.selectedProduct?.id
                            let textInputs = state!.textInputStates.map { key, value in
                                return [key, value.text]
                                }
                                .reduce([String: String]()) { result, item in
                                    var newResult = result
                                    newResult[item[0]] = item[1]
                                    return newResult
                            }
                            
                            guard productId != nil else { return }
                            if (self.state!.isInstantPaymentEnabled) {
                                AnalyticsManager.trackRechargeEvent(event: .homepage, category: self.state?.form, operators: self.state?.selectedOperator, product: self.state?.selectedProduct, action:"Click Beli with Instant Saldo")
                            } else {
                                AnalyticsManager.trackRechargeEvent(event: .homepage, category: self.state?.form, operators: self.state?.selectedOperator, product: self.state?.selectedProduct, action:"Click Beli")
                            }
                            let cache = PulsaCache()
                           let lastOrder = DigitalLastOrder(categoryId: self.categoryId, operatorId: self.state?.selectedOperator?.id, productId: productId, clientNumber: textInputs["client_number"])
                            cache.storeLastOrder(lastOrder: lastOrder)
                            
                            DigitalService()
                                .purchase(
                                    from: self.viewController!,
                                    withProductId: productId!,
                                    categoryId: self.categoryId,
                                    inputFields: textInputs,
                                    instantPaymentEnabled: state!.isInstantPaymentEnabled,
                                    onNavigateToCart: { [weak self] in
                                        self?.store.dispatch(DigitalWidgetAction.navigateToCart)
                                    },
                                    onNeedLoading: { [weak self] in
                                        self?.store.dispatch(DigitalWidgetAction.addToCart)
                                    })
                                .subscribe(
                                    onError: { error in
                                        let errorMessage = error as? String ?? "Kendala koneksi internet, silakan coba kembali"
                                        AnalyticsManager.trackRechargeEvent(event: .homepage, category: self.state?.form, operators: self.state?.selectedOperator, product: self.state?.selectedProduct, action:"Homepage Error - \(errorMessage)")
                                        self.store.dispatch(DigitalWidgetAction.showError(errorMessage))
                                    }
                                )
                                .disposed(by: self.rx_disposeBag)
                        })
                        .disposed(by: self.disposeBag)
                    }.add(child: state!.addToCartProgress == .onProgress ? Node<UIActivityIndicatorView>() { indicator, layout, size in
                        indicator.activityIndicatorViewStyle = .white
                        indicator.startAnimating()
                        
                        layout.marginLeft = 15
                    } : NilNode())
                ])
    }
    
    override func construct(state: DigitalState?, size: CGSize) -> NodeType {
        disposeBag = DisposeBag()
        
        unowned let `self` = self
        
        if state!.isLoadingFailed {
            //can't use no result view, button not responding
            return Node<UIView>(identifier: "no result") { view, layout, size in
                view.backgroundColor = .white
                layout.width = size.width
                layout.height = size.height
                layout.justifyContent = .flexStart
                layout.alignItems = .center
                layout.paddingTop = 100
            }.add(children: [
                Node<UIImageView>(create: { UIImageView(image: #imageLiteral(resourceName: "icon_retry_grey")) }),
                Node<UILabel>() { label, layout, size in
                    layout.marginTop = 20
                    label.text = "Kendala koneksi internet"
                    label.font = .title1ThemeMedium()
                },
                Node<UILabel>() { label, layout, size in
                    layout.marginVertical = 20
                    label.text = "Silakan mencoba kembali"
                    label.font = .largeThemeMedium()
                },
                Node<UIButton>() { button, layout, size in
                    layout.height = 40
                    layout.minWidth = 200
                    
                    button.setTitle("Coba kembali", for: .normal)
                    button.backgroundColor = .tpGreen()
                    button.layer.cornerRadius = 3
                    
                    button.rx.tap
                        .map { DigitalWidgetAction.loadForm }
                        .do(onNext: { action in
                            self.loadForm()
                        })
                        .dispatch(to: self.store)
                        .disposed(by: self.disposeBag)
                }
            ])
        }
        
        guard let form = state?.form else {
            return Node(identifier: "loader") { view, layout, size in
                view.backgroundColor = .white
                layout.width = size.width
                layout.height = size.height
                layout.justifyContent = .center
                layout.alignItems = .center
            }.add(children: [
                Node<UIActivityIndicatorView>(
                    create: { UIActivityIndicatorView(activityIndicatorStyle: .gray) },
                    configure: { view, layout, size in
                        view.startAnimating()
                    }
                )
            ])
        }
        
        return Node<TPKeyboardAvoidingScrollView>() { view, layout, size in
            layout.width = size.width
            layout.height = size.height
            
            view.backgroundColor = .tpBackground()
        }.add(children: [
            mainContent(state: state, size: size),
            promo()
        ])
    }
    
    private func promo() -> NodeType {
        unowned let `self` = self
        
        guard let form = state?.form, !form.banners.isEmpty else { return NilNode() }
        
        return Node(identifier: "promo") { view, layout, size in
            layout.paddingHorizontal = 7
            layout.marginVertical = 15
            layout.marginTop = 30
        }.add(children:
            [
                Node<UILabel>(identifier: "header") { label, layout, size in
                    label.font = .title2Theme()
                    label.textColor = UIColor.black.withAlphaComponent(0.54)
                    label.text = "Promo \(form.name)"
                    layout.marginBottom = 10
                }
            ]
            + form.banners.map { banner in
                return Node(
                    identifier: "promo_\(banner.id)",
                    create: {
                        let view = UIView()
                        
                        let gestureRecognizer = UITapGestureRecognizer()
                        gestureRecognizer.rx.event
                            .subscribe(onNext: { _ in
                                let webViewController = WKWebViewController(urlString: banner.url)
                                
                                self.viewController?.navigationController?.pushViewController(webViewController, animated: true)
                            })
                            .disposed(by: self.rx_disposeBag)
                        
                        view.addGestureRecognizer(gestureRecognizer)
                        
                        return view
                    }
                ) { view, layout, size in
                    view.backgroundColor = .white
                    
                    layout.padding = 14
                    layout.marginVertical = 5
                    }.add(children:[
                        Node<UILabel>(identifier: "detail") { label, layout, size in
                            label.text = banner.detail
                            label.numberOfLines = 0
                            label.font = .smallTheme()
                            label.textColor = UIColor.black.withAlphaComponent(0.54)
                        },
                        banner.voucherCode == "" ? NilNode() : (Node(identifier: "voucher container") { view, layout, size in
                            layout.flexDirection = .row
                            layout.alignItems = .center
                            layout.marginTop = 5
                            } as NodeType).add(children: [
                                Node<UILabel>(identifier: "label") { label, layout, size in
                                    label.text = "Kode Promo: "
                                    label.font = .microTheme()
                                    label.textColor = UIColor.black.withAlphaComponent(0.54)
                                },
                                Node<UIButton>(identifier: "button") { button, layout, size in
                                    layout.flexDirection = .row
                                    button.rx.tap
                                        .subscribe(onNext: {
                                            UIPasteboard.general.string = banner.voucherCode
                                            
                                            self.store.dispatch(DigitalWidgetAction.alert("Kode promo tersalin"))
                                        })
                                        .disposed(by: self.disposeBag)
                                    }.add(children: [
                                        Node<UILabel>(identifier: "label") { label, layout, size in
                                            label.text = banner.voucherCode
                                            label.font = .microTheme()
                                            label.textColor = .tpGreen()
                                        },
                                        Node<UILabel>(identifier: "salin") { label, layout, size in
                                            layout.marginLeft = 8
                                            
                                            let color = UIColor.black.withAlphaComponent(0.54)
                                            
                                            label.text = "SALIN"
                                            label.textColor = color
                                            label.font = .systemFont(ofSize: 9)
                                            label.layer.borderColor = color.cgColor
                                            label.layer.borderWidth = 1
                                            label.layer.cornerRadius = 2
                                            label.textAlignment = .center
                                            layout.padding = 3
                                        }
                                    ])
                                ])
                        ])
            }
        )
    }
    
    private func verifyOtp(_ needOtp: Bool, cartId: String) -> Observable<Void> {
        guard needOtp else {
            return Observable.create { observer in
                observer.onNext()
                
                return Disposables.create()
            }
        }
        
        return Observable.create { [weak self] observer in
            let auth = UserAuthentificationManager()
            let userId = auth.getUserId()!
            let deviceId = auth.getMyDeviceToken()
            let dict = auth.getUserLoginData()!
            let userName = dict["full_name"] as! String
            
            let oAuthToken = OAuthToken()
            oAuthToken.tokenType = dict["oAuthToken.tokenType"] as! String
            oAuthToken.accessToken = dict["oAuthToken.accessToken"] as! String
            
            let sqObject = SecurityQuestionObjects()
            sqObject.userID = userId
            sqObject.deviceID = deviceId
            sqObject.token = oAuthToken
            
            let viewController = SecurityQuestionViewController(securityQuestionObject: sqObject)
            viewController.questionType1 = "0"
            viewController.questionType2 = "2"
            viewController.successAnswerCallback =  { _ in
                observer.onNext()
                observer.onCompleted()
            }
            
            self?.viewController?.navigationController?.pushViewController(viewController, animated: true)
            
            return Disposables.create()
        }.flatMap { () -> Observable<Void> in
            return DigitalProvider()
                .request(.otpSuccess(cartId))
                .map { _ in return }
        }
    }
    
    override func didRender() {
        guard let state = self.state else { return }
        
        viewController?.navigationItem.title = state.form?.title
        
        if case let DigitalErrorState.notShowing(errorMessage) = state.errorMessageState {
            StickyAlertView(errorMessages: [errorMessage], delegate: viewController).show()
            
            self.store.dispatch(DigitalWidgetAction.resetErrorState)
        }
        
        if case let DigitalAlertState.message(message) = state.alertState {
            StickyAlertView(successMessages: [message], delegate: viewController).show()
            
            self.store.dispatch(DigitalWidgetAction.resetAlert)
        }
        
        if !state.isLoadingForm && !state.isLoadingFailed && state.form == nil {
            self.store.dispatch(DigitalWidgetAction.loadForm)
            
            loadForm()
        }
    }
    
    private func loadForm() {
        let form = DigitalProvider()
            .request(.category(categoryId))
            .do(onError: { [weak self] error in
                self?.store.dispatch(DigitalWidgetAction.loadFailed)
            })
            .map(to: DigitalForm.self)
        
        let lastOrder = DigitalService()
            .lastOrder(categoryId: categoryId)
        
        Observable.zip(form, lastOrder) {form,lastOrder in
                return (form, lastOrder)
            }.subscribe(onNext: { [weak self] form, lastOrder in
                self?.store.dispatch(DigitalWidgetAction.receiveForm(form, lastOrder))
            })
    }
    
    func newState(state: DigitalState) {
        self.state = state
        self.render(in: self.bounds.size)
    }
    
    func didTap(_ checkBox: BEMCheckBox) {
        self.store.dispatch(DigitalWidgetAction.toggleInstantPayment)
        if (checkBox.on) {
            AnalyticsManager.trackRechargeEvent(event: .homepage, category: self.state?.form, operators: self.state?.selectedOperator, product: self.state?.selectedProduct, action:"Check Instant Saldo")
        } else {
            AnalyticsManager.trackRechargeEvent(event: .homepage, category: self.state?.form, operators: self.state?.selectedOperator, product: self.state?.selectedProduct, action:"Uncheck Instant Saldo")
        }
    }
}

// MARK: address book

import ContactsUI
import AddressBookUI

class PhoneBookService: NSObject {
    
    var phoneNumberSelected = PublishSubject<String>()
    
    func findContact(from viewController: UIViewController) {
        if #available(iOS 9.0, *) {
            let contactPicker = CNContactPickerViewController()
            
            contactPicker.delegate = self
            contactPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
            
            viewController.present(contactPicker, animated: true, completion: nil)
        } else {
            let contactPicker = ABPeoplePickerNavigationController()
            contactPicker.peoplePickerDelegate = self
            contactPicker.displayedProperties = [NSNumber(value: kABPersonPhoneProperty as Int32)]
            viewController.present(contactPicker, animated: true, completion: nil)
        }
    }
}

extension PhoneBookService: CNContactPickerDelegate {
    @available(iOS 9.0, *)
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        if contactProperty.key == CNContactPhoneNumbersKey {
            guard let phoneNumber = contactProperty.value else { return }
            
            let phone = phoneNumber as! CNPhoneNumber
            self.phoneNumberSelected.onNext(phone.stringValue)
        }
    }
}

extension PhoneBookService: ABPeoplePickerNavigationControllerDelegate {
    func peoplePickerNavigationController(
        _ peoplePicker: ABPeoplePickerNavigationController,
        didSelectPerson person: ABRecord,
        property: ABPropertyID,
        identifier: ABMultiValueIdentifier) {
        
        let phones: ABMultiValue = ABRecordCopyValue(person, kABPersonPhoneProperty).takeRetainedValue()
        AnalyticsManager.trackEventName("clickPulsa", category: GA_EVENT_CATEGORY_PULSA, action: GA_EVENT_ACTION_CLICK, label: "Select Contact on Phonebook")
        
        if ABMultiValueGetCount(phones) > 0 {
            let index = Int(identifier) as CFIndex
            let phoneNumber = ABMultiValueCopyValueAtIndex(phones, index).takeRetainedValue() as! String
            
            self.phoneNumberSelected.onNext(phoneNumber)
        }
    }
}

extension String: Swift.Error {
    var localizedDescription: String {
        return self
    }
}
