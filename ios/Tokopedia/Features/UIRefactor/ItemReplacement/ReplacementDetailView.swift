//
//  ReplacementDetailView.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 6/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Render
import RxSwift
import NSObject_Rx

struct ReplacementState: StateType {
    
    var deadline : String = ""
    var backgroundColorHexString : String = ""
    var cashback : String = ""
    var destination : String = ""
    var shipper : String = ""
    var productImageUrlString : String = ""
    var productName : String = ""
    var productNote : String = ""
    var totalPrice : String = ""
    var quantity : String = ""
}

class ReplacementNestedDetailView: ComponentView<ReplacementState> {
    
    private var viewModel : ReplacementDetailViewModel!
    
    init(viewModel: ReplacementDetailViewModel) {
        super.init()
        self.viewModel = viewModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported")
    }
    
    override func construct(state: ReplacementState?, size: CGSize = CGSize.undefined) -> NodeType {
        
        guard let state = state else {
            return NilNode()
        }
        
        func horizontalLine() -> NodeType {
            return Node<UIView>(identifier: "line") { view, layout, _ in
                layout.height = 1
                view.backgroundColor = .tpLine()
            }
        }
        
        func deadlineView(deadline: String) -> NodeType {
            
            let deadlineContainer = Node<UIView> { _, layout, _ in
                layout.height = 50
                layout.flexDirection = .row
            }
            
            let deadlineTitleLabel = Node<UILabel> { view, layout, size in
                view.text = "Batas Respon :"
                view.textColor = .tpDisabledBlackText()
                view.font = .microThemeSemibold()
                layout.flexGrow = 1
                layout.alignSelf = .stretch
            }
            
            let deadlineLabelContainer = Node<UIView> { view, layout, size in
                view.backgroundColor = UIColor.fromHexString(state.backgroundColorHexString)
                view.cornerRadius = 2
                layout.height = 20
                layout.flexGrow = 1
                layout.flexBasis = 1
                layout.alignSelf = .center
                layout.alignItems = .center
                layout.alignContent = .center
            }
            
            let deadlineTextLabel = Node<UILabel> { view, layout, size in
                view.text = deadline
                view.textColor = .white
                view.backgroundColor = UIColor.fromHexString(state.backgroundColorHexString)
                view.font = .microThemeSemibold()
                view.textAlignment = .right
                layout.marginRight = 8
                layout.marginLeft = 8
                layout.alignContent = .center
                layout.flexGrow = 1
            }

            let deadlineLabel = deadlineLabelContainer.add(child: deadlineTextLabel)
            
            return deadlineContainer.add(children: [
                deadlineTitleLabel,
                deadlineLabel,
            ])
        }
        
        func defaultCellHeaderView(title: String, detail: String) -> NodeType {
            
            let container = Node<UIView> { _, layout, _ in
                layout.height = 50
                layout.flexDirection = .row
            }
            
            let titleLabel = Node<UILabel> { view, layout, size in
                view.text = title
                view.textColor = .tpDisabledBlackText()
                view.font = .microThemeSemibold()
                layout.flexGrow = 1
                layout.alignSelf = .stretch
            }
            
            let detailLabel = Node<UILabel> { view, layout, size in
                view.text = detail
                view.textColor = .tpSecondaryBlackText()
                view.font = .largeThemeMedium()
                view.textAlignment = .right
                layout.flexGrow = 1
                layout.alignSelf = .stretch
            }
            
            return container.add(children: [
                titleLabel,
                detailLabel,
                ])
        }
        
        func headerView() -> NodeType {
            let container =  Node<UIView>() { view, layout, size in
                view.backgroundColor = .white
            }
            
            let headerView =  Node<UIView>() { view, layout, size in
                    layout.marginLeft = 10
                    layout.marginRight = 10
                }
                .add(children: [
                    deadlineView(deadline: state.deadline),
                    horizontalLine(),
                    defaultCellHeaderView(title: "Cashback :", detail: state.cashback),
                    horizontalLine(),
                    defaultCellHeaderView(title: "Kota Tujuan :", detail: state.destination),
                    horizontalLine(),
                    defaultCellHeaderView(title: "Pengiriman :", detail: state.shipper),
                ])
            
            return container.add(children: [
                    headerView,
                    horizontalLine()
                ])
        }
        
        func productView() -> NodeType {
            
            let container =  Node<UIView>() { view, layout, size in
                view.backgroundColor = .white
                view.borderColor = .tpLine()
                view.borderWidth = 1
                view.cornerRadius = 3
                layout.marginRight = 10
                layout.marginLeft = 10
                layout.marginTop = 10
                layout.marginBottom = 15
            }
            
            let thumbnail = Node<UIImageView> { view, layout, size in
                view.setImageWith(URL(string: state.productImageUrlString), placeholderImage: #imageLiteral(resourceName: "grey-bg"))
                layout.marginRight = 10
                (layout.width, layout.height) = (52, 52)
            }
            
            let productNameLabel = Node<UILabel> { view, layout, size in
                view.textColor = .tpSecondaryBlackText()
                view.font = .largeThemeMedium()
                view.text = state.productName
                view.numberOfLines = 0
                layout.flexGrow = 2
                layout.flexBasis = 1
                layout.alignSelf = .center
            }
            
            let titleQuantityLabel = Node<UILabel> { view, layout, size in
                view.text = "Jumlah :"
                view.textColor = .tpSecondaryBlackText()
                view.font = .microTheme()
                view.textAlignment = .right
                layout.flexGrow = 1
                layout.flexBasis = 1
            }
            
            let quantityLabel = Node<UILabel> { view, layout, size in
                view.text = state.quantity
                view.textColor = .tpDisabledBlackText()
                view.font = .microTheme()
                view.textAlignment = .right
                layout.flexGrow = 1
                layout.flexBasis = 1
                layout.marginLeft = 10
                layout.marginBottom = 10
            }
            
            let containerQuantity = Node<UIView> { _, layout, _ in
                layout.height = 50
            }.add(children: [
                titleQuantityLabel,
                quantityLabel,
            ])
        
            let productContainer =  Node<UIView>() { view, layout, size in
                    layout.flexDirection = .row
                    layout.marginRight = 10
                    layout.marginLeft = 10
                    layout.marginBottom = 15
                    layout.marginTop = 15
                    layout.alignSelf = .stretch
                }
                .add(children: [
                    thumbnail,
                    productNameLabel,
                    containerQuantity
            ])
            
            let productNoteLabel = Node<UILabel> { view, layout, size in
                view.textColor = .tpSecondaryBlackText()
                view.font = .largeThemeMedium()
                view.text = state.productNote
                view.numberOfLines = 0
                layout.flexGrow = 1
                layout.alignSelf = .stretch
                layout.marginRight = 10
                layout.marginLeft = 10
                layout.marginBottom = 10
                layout.marginTop = 10
            }
            
            let seeProductButton = Node<UIButton>() { button, layout, size in
                button.setTitle("Lihat Produk", for: .normal)
                button.backgroundColor = .white
                button.titleLabel?.font = .microThemeMedium()
                button.setTitleColor(.tpGreen(), for: .normal)
                button.rx.tap
                    .bindTo(self.viewModel.seeProduct)
                    .disposed(by: self.rx_disposeBag)
                layout.alignSelf = .stretch
            }
            
            let arrow = Node<UIImageView>() { view, layout, _ in
                view.image = #imageLiteral(resourceName: "icon_forward")
                view.tintColor = .tpGreen()
                layout.height = 9
                layout.width = 6
                layout.alignSelf = .center
                layout.marginLeft = 10
            }
            
            let seeProductView = Node<UIView>() { view, layout, size in
                    layout.flexDirection = .rowReverse
                    layout.height = 50
                    layout.marginRight = 10
                }.add(children: [
                    arrow,
                    seeProductButton
                ])
            
            return container.add(children: [
                    productContainer,
                    horizontalLine(),
                    productNoteLabel,
                    horizontalLine(),
                    seeProductView
                ])
        }
        
        func totalPriceView() -> NodeType {
            
            let container = Node<UIView> {
                view, layout, size in
                view.backgroundColor = .white
                layout.height = 50
            }
            
            let titleLabel = Node<UILabel> {
                view, layout, size in
                view.text = "Total Pesanan :"
                view.textColor = .tpPrimaryBlackText()
                view.font = .largeThemeMedium()
                layout.flexGrow = 1
                layout.marginLeft = 10
                layout.alignSelf = .stretch
            }
            
            let detailLabel = Node<UILabel> {
                view, layout, size in
                view.text = state.totalPrice
                view.textColor = .tpOrange()
                view.font = .largeThemeMedium()
                view.textAlignment = .right
                layout.flexGrow = 1
                layout.alignSelf = .stretch
                layout.marginRight = 10
            }
            
            return container.add(children: [
                    horizontalLine(),
                    Node<UIView>() { view, layout, size in
                        layout.height = 50
                        layout.flexDirection = .row
                        layout.alignSelf = .stretch
                    }
                    .add(children: [
                        titleLabel,
                        detailLabel
                    ]),
                    horizontalLine()
                ])

        }
        
        func buttonView() -> NodeType {
            let container = Node<UIView> {
                view, layout, size in
            }
            
            let takeOpportunityButton = Node<UIButton>() { button, layout, size in
                button.setTitle("Ambil Peluang", for: .normal)
                button.backgroundColor = .tpGreen()
                button.titleLabel?.font = .microThemeSemibold()
                button.setTitleColor(.white, for: .normal)
                button.rx
                    .tap
                    .bindTo(self.viewModel.takeReplacement)
                    .disposed(by: self.rx_disposeBag)
                self.viewModel.loading
                    .asDriver()
                    .map{ !$0 }
                    .drive(button.rx.isEnabled)
                    .disposed(by: self.rx_disposeBag)
                self.viewModel.canTakeOpportunity
                    .asDriver()
                    .map{ !$0 }
                    .drive(button.rx.isHidden)
                    .disposed(by: self.rx_disposeBag)
                layout.alignSelf = .stretch
                layout.marginTop = 15
                layout.marginLeft = 10
                layout.marginRight = 10
                layout.marginBottom = 10
                layout.height = 50
            }
            
            return container.add(children: [
                    takeOpportunityButton
                ])
            
        }
        
        return Node<UIView>() { view, layout, size in
                layout.width = size.width
            }.add(children: [
                headerView(),
                productView(),
                totalPriceView(),
                buttonView()
            ])
    }
    
    func showAlertConfirmationTakeReplacement(button:UIButton) {
        let alert = UIAlertController(title: "", message: "Dengan klik \"Setuju\", anda menyetujui barang yang akan dikirim sudah sesuai pesanan pembeli. \nPembatalan akan dikenakan penalti reputasi: -10", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Setuju", style: .default, handler: { (action) in
            
        }))
        alert.addAction(UIAlertAction(title: "Kembali", style: .default, handler: nil))
    }
}

class ReplacementDetailView: ComponentView<ReplacementState> {
    
    private var viewModel : ReplacementDetailViewModel!
    
    init(viewModel: ReplacementDetailViewModel) {
        super.init()
        self.viewModel = viewModel
        let replacement = viewModel.rxReplacement.value
        self.state = ReplacementState(
            deadline:replacement.deadline.processText,
            backgroundColorHexString:replacement.deadline.backgroundColorHex,
            cashback: replacement.cashback,
            destination: replacement.destination.province,
            shipper: "\(replacement.shipper.name!) - \(replacement.shipper.product!)",
            productImageUrlString: replacement.products.first!.thumbnailUrlString,
            productName: replacement.products.first!.name,
            productNote: replacement.products.first!.note ?? "-",
            totalPrice: replacement.detail.totalPriceIdr,
            quantity: "\(replacement.products.first!.deliverQuantity!) barang"
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func construct(state: ReplacementState?, size: CGSize = CGSize.undefined) -> NodeType {
        guard let state = state else {
            return NilNode()
        }
        return Node<UIScrollView>(identifier: String(describing: ReplacementDetailView.self)) {
            (view, layout, size) in
                layout.width = size.width
                layout.height = size.height
            }.add(child:
                ReplacementNestedDetailView(viewModel:viewModel).construct(state: state)
            )
    }
    
}
