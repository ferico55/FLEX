//
//  DigitalCategoriesComponentView.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 7/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import UIKit
import Render
import RxSwift

struct DigitalCategoryState: StateType {
    var categories: [HomePageCategoryLayoutRow]
}

class DigitalCategoriesComponentView: ComponentView<DigitalCategoryState> {
    let numberOfColumns = 4.0
    
    override init() {
        super.init()
    }
    
    convenience init(categories: [HomePageCategoryLayoutRow]) {
        self.init()
        let theState = DigitalCategoryState(categories: categories)
        self.state = theState
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func construct(state: DigitalCategoryState?, size: CGSize) -> NodeType {
        guard let state = state, state.categories.count > 0 else {
            return Node<UIView> {
                _, _, _ in
            }
        }
        
        let mainWrapper = Node<UIScrollView> {
            view, layout, size in
            view.backgroundColor = .tpBackground()
            layout.width = size.width
            layout.height = size.height - 60
            layout.top = 60
            view.contentInset.top = 10
        }
        
        func digitalCategoryView(category: HomePageCategoryLayoutRow?) -> NodeType {
            let digitalCategoryView = Node<UIView>(
                create: {
                    let tapGesture = UITapGestureRecognizer()
                    tapGesture.rx.event
                        .subscribe(onNext: { _ in
                            if let stringUrl = category?.url, let url = URL(string: stringUrl) {
                                AnalyticsManager.trackRechargeEvent(event: .homepage, category: (category?.name)!, action: "Click Icon on All Categories")
                                
                                guard let categoryId = category?.category_id, categoryId != "103"  else { TPRoutes.routeURL(url); return  }
                                
                                WalletService.getBalance(userId: UserAuthentificationManager().getUserId())
                                    .subscribe(onNext: { wallet in
                                        
                                        if wallet.shouldShowActivation {
                                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                            let controller = storyboard.instantiateViewController(withIdentifier: "TokoCashActivationViewController")
                                            controller.hidesBottomBarWhenPushed = true
                                            UIApplication.topViewController()?
                                                .navigationController?
                                                .pushViewController(controller, animated: true)
                                        }else {
                                            TPRoutes.routeURL(url)
                                        }
                                    }, onError: { error in
                                        StickyAlertView.showErrorMessage([error.localizedDescription])
                                    })
                                    .disposed(by: self.rx_disposeBag)
                                
                            }
                        }).addDisposableTo(self.rx_disposeBag)
                    
                    let view = UIView()
                    view.addGestureRecognizer(tapGesture)
                    return view
            }) {
                view, layout, size in
                view.clipsToBounds = true
                view.backgroundColor = .white
                view.layer.borderWidth = 0.5
                view.layer.borderColor = UIColor.tpBackground().cgColor
                layout.alignItems = .center
                layout.flexDirection = .column
                layout.width = size.width / CGFloat(self.numberOfColumns)
                layout.height = 110
                
            }
            
            let digitalCategoryLabel = Node<UILabel> {
                view, layout, _ in
                if let name = category?.name {
                    view.text = name
                } else {
                    view.text = ""
                }
                view.font = UIFont.microTheme()
                view.textColor = UIColor.tpSecondaryBlackText()
                view.numberOfLines = 0
                view.lineBreakMode = .byClipping
                view.textAlignment = .center
                layout.margin = 10
            }
            
            let digitalCategoryImageView = Node<UIImageView> {
                view, layout, _ in
                if let url = category?.image_url {
                    view.setImageWith(URL(string: url))
                }
                view.contentMode = .scaleAspectFit
                layout.width = 30
                layout.height = 30
                layout.marginTop = 20
                layout.marginBottom = 10
            }
            
            return digitalCategoryView.add(children: [digitalCategoryImageView, digitalCategoryLabel])
        }
        
        func digitalCategoryRow(rowData: [HomePageCategoryLayoutRow]) -> NodeType {
            let digitalCategoryRow = Node<UIView> {
                view, layout, size in
                view.backgroundColor = .clear
                layout.alignItems = .center
                layout.flexDirection = .row
                layout.width = size.width
            }
            
            for index in 0...3 {
                if rowData.indices.contains(index) {
                    digitalCategoryRow.add(child: digitalCategoryView(category: rowData[index]))
                } else {
                    digitalCategoryRow.add(child: digitalCategoryView(category: nil))
                }
            }
            return digitalCategoryRow
        }
        
        func digitalCategoryContainer(data: [HomePageCategoryLayoutRow]) -> NodeType {
            let digitalCategoryContainer = Node<UIView> {
                view, layout, size in
                view.backgroundColor = .clear
                layout.alignItems = .center
                layout.flexDirection = .column
                layout.width = size.width
            }
            
            let totalRow = Double(data.count) / numberOfColumns
            var maxRow = 0
            if totalRow.truncatingRemainder(dividingBy: 1) == 0 {
                maxRow = Int(floor(totalRow))
            } else {
                maxRow = Int(floor(totalRow)) + 1
            }
            
            for rowCount in 1...maxRow {
                let startIndex = Int(numberOfColumns) * (rowCount - 1)
                var endIndex = Int(numberOfColumns) * rowCount - 1
                if endIndex > data.count - 1 {
                    endIndex = data.count - 1
                }
                let selectedData = Array(data[startIndex...endIndex])
                digitalCategoryContainer.add(child: digitalCategoryRow(rowData: selectedData))
            }
            return digitalCategoryContainer
        }
        
        return mainWrapper.add(child: digitalCategoryContainer(data: state.categories))
    }
}

class DigitalCategoriesHeaderComponentView: ComponentView<DigitalCategoryState> {
    let numberOfColumns = 3
    override init() {
        super.init()
    }
    
    convenience init(categories: [HomePageCategoryLayoutRow]) {
        self.init()
        let theState = DigitalCategoryState(categories: categories)
        self.state = theState
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func construct(state: DigitalCategoryState?, size: CGSize) -> NodeType {
        guard let state = state, state.categories.count > 0 else {
            return Node<UIView> {
                _, _, _ in
            }
        }
        
        let mainWrapper = Node<UIView> {
            view, layout, size in
            view.backgroundColor = .white
            layout.width = size.width
            layout.height = 60
            layout.alignItems = .center
            layout.flexDirection = .row
            view.isUserInteractionEnabled = true
        }
        
        func history() -> NodeType {
            let view = Node<UIView>(
                create: {
                    let tapGesture = UITapGestureRecognizer()
                    tapGesture.rx.event
                        .subscribe(onNext: { _ in
                            TPRoutes.routeURL(URL(string: "tokopedia://webview?url=\(NSString.pulsaUrl())/order-list")!)
                        }).addDisposableTo(self.rx_disposeBag)
                    
                    let v = UIView()
                    v.addGestureRecognizer(tapGesture)
                    return v
            }) {
                view, layout, size in
                view.clipsToBounds = true
                view.backgroundColor = .white
                view.layer.borderWidth = 0.5
                view.layer.borderColor = UIColor.tpBackground().cgColor
                layout.alignItems = .center
                layout.flexDirection = .column
                layout.width = size.width / CGFloat(self.numberOfColumns)
                layout.height = 60
            }
            
            let icon = Node<UIImageView> {
                view, layout, _ in
                layout.marginTop = 10
                layout.marginBottom = 10
                view.image = UIImage(named: "icon_transaksi_saya")
            }
            
            let label = Node<UILabel> {
                view, _, _ in
                view.font = UIFont.microTheme()
                view.textColor = UIColor.tpSecondaryBlackText()
                view.numberOfLines = 0
                view.lineBreakMode = .byClipping
                view.textAlignment = .center
                view.text = "Transaksi Saya"
            }
            
            return view.add(children: [icon, label])
        }
        
        func subscribe() -> NodeType {
            let view = Node<UIView>(
                create: {
                    let tapGesture = UITapGestureRecognizer()
                    tapGesture.rx.event
                        .subscribe(onNext: { _ in
                            TPRoutes.routeURL(URL(string: "tokopedia://webview?url=\(NSString.pulsaUrl())/subscribe")!)
                        }).addDisposableTo(self.rx_disposeBag)
                    
                    let view = UIView()
                    view.addGestureRecognizer(tapGesture)
                    return view
            }) {
                view, layout, size in
                view.clipsToBounds = true
                view.backgroundColor = .white
                view.layer.borderWidth = 0.5
                view.layer.borderColor = UIColor.tpBackground().cgColor
                layout.alignItems = .center
                layout.flexDirection = .column
                layout.width = size.width / CGFloat(self.numberOfColumns)
                layout.height = 60
            }
            
            let icon = Node<UIImageView> {
                view, layout, _ in
                layout.marginTop = 10
                layout.marginBottom = 10
                view.image = UIImage(named: "icon_langganan")
            }
            
            let label = Node<UILabel> {
                view, _, _ in
                view.font = UIFont.microTheme()
                view.textColor = UIColor.tpSecondaryBlackText()
                view.numberOfLines = 0
                view.lineBreakMode = .byClipping
                view.textAlignment = .center
                view.text = "Langganan"
            }
            
            return view.add(children: [icon, label])
        }
        
        func favourite() -> NodeType {
            let view = Node<UIView>(
                create: {
                    let tapGesture = UITapGestureRecognizer()
                    tapGesture.rx.event
                        .subscribe(onNext: { _ in
                            TPRoutes.routeURL(URL(string: "tokopedia://webview?url=\(NSString.pulsaUrl())/favorite-list")!)
                        }).addDisposableTo(self.rx_disposeBag)
                    
                    let view = UIView()
                    view.addGestureRecognizer(tapGesture)
                    return view
            }) {
                view, layout, size in
                view.clipsToBounds = true
                view.backgroundColor = .white
                view.layer.borderWidth = 0.5
                view.layer.borderColor = UIColor.tpBackground().cgColor
                layout.alignItems = .center
                layout.flexDirection = .column
                layout.width = size.width / CGFloat(self.numberOfColumns)
                layout.height = 60
            }
            
            let icon = Node<UIImageView> {
                view, layout, _ in
                layout.marginTop = 10
                layout.marginBottom = 10
                view.image = UIImage(named: "icon_nomor_favorit")
            }
            
            let label = Node<UILabel> {
                view, _, _ in
                view.font = UIFont.microTheme()
                view.textColor = UIColor.tpSecondaryBlackText()
                view.numberOfLines = 0
                view.lineBreakMode = .byClipping
                view.textAlignment = .center
                view.text = "Nomor Favorit"
            }
            
            return view.add(children: [icon, label])
        }
        
        return mainWrapper.add(children: [history(), subscribe(), favourite()])
    }
}
