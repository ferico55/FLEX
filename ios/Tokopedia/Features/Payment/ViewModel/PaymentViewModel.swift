//
//  PaymentViewModel.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 8/4/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import RxSwift
import Moya
import MoyaUnbox
import RxDataSources

enum MultipleSectionModel {
    case oneClick(title: String, items: [SectionItem])
    case creditCard(title: String, items: [SectionItem])
    case empty()
}

enum SectionItem {
    case oneClick(userData: OneClickData)
    case oneClickRegister()
    case creditCard(userData: CreditCardData)
    case emptyCreditCard()
    case errorFetchData()
    case errorInternetConnection()
    case empty()
}

extension MultipleSectionModel: SectionModelType {

    typealias sectionItems = SectionItem

    var items: [SectionItem] {
        switch self {
        case .oneClick(title: _, items: let items):
            return items
        case .creditCard(title: _, items: let items):
            return items
        case .empty():
            return []
        }
    }

    init(original: MultipleSectionModel, items: [SectionItem]) {
        switch original {
        case let .oneClick(title: title, items: _):
            self = .oneClick(title: title, items: items)
        case let .creditCard(title: title, items: _):
            self = .creditCard(title: title, items: items)
        case .empty():
            self = .empty()
        }
    }
}

extension MultipleSectionModel {
    var title: String {
        switch self {
        case .oneClick(title: let title, items: _):
            return title
        case .creditCard(title: let title, items: _):
            return title
        default: return ""
        }
    }
}

class PaymentViewModel: NSObject {

    private var provider: NetworkProvider<ScroogeTarget>!

    let listActivityIndicator = ActivityIndicator()
    let actionActivityIndicator = ActivityIndicator()

    var listItems: Observable<[MultipleSectionModel]>?

    private var deletedCreditCardData = Variable(CreditCardData())
    private var registeredOneClickData = Variable(OneClickData())
    private var editedOneClickData = Variable(OneClickData())
    private var deletedOneClickData = Variable(OneClickData())

    init(provider: NetworkProvider<ScroogeTarget>, doRefresh: Observable<Void>) {

        self.provider = provider

        super.init()

        let request = self.refreshPage()

        let refresh = doRefresh.flatMap { _ -> Observable<[MultipleSectionModel]> in
            return self.refreshPage()
        }

        let doDeleteCreditCard = deletedCreditCardData.asObservable()
            .filter({ data -> Bool in
                data.tokenID != ""
            }).distinctUntilChanged({ (current, last) -> Bool in
                current.tokenID == last.tokenID
            }).flatMap({ data in
                self.deleteCreditCard(data.tokenID)
            }).flatMap({ response -> Observable<[MultipleSectionModel]> in
                if response.success {
                    StickyAlertView.showSuccessMessage([response.message ?? "Berhasil menghapus kartu kredit"])
                    return self.refreshPage()
                } else {
                    StickyAlertView.showErrorMessage([response.message ?? "Gagal menghapus kartu kredit"])
                    self.deletedCreditCardData.value = CreditCardData()
                    return refresh
                }

            }).shareReplay(1)

        let doRegisterOneClick = registeredOneClickData.asObservable()
            .filter({ data -> Bool in
                data.tokenID != ""
            }).distinctUntilChanged({ current, last -> Bool in
                current.tokenID == last.tokenID
            }).flatMap({ data in
                self.registerUser(data)
            }).flatMap({ response -> Observable<[MultipleSectionModel]> in
                if response.success {
                    StickyAlertView.showSuccessMessage([response.message ?? "Berhasil mendaftarkan data oneklik"])
                    return self.refreshPage()
                } else {
                    StickyAlertView.showErrorMessage([response.message ?? "Gagal mendaftarkan data oneklik"])
                    self.registeredOneClickData.value = OneClickData()
                    return refresh
                }
            }).shareReplay(1)

        let doEditOneClick = editedOneClickData.asObservable()
            .filter({ data -> Bool in
                data.tokenID != ""
            }).distinctUntilChanged({ current, last -> Bool in
                current.tokenID == last.tokenID
            }).flatMap({ data in
                self.editOneClick(data)
            }).flatMap({ response -> Observable<[MultipleSectionModel]> in
                if response.success {
                    StickyAlertView.showSuccessMessage([response.message ?? "Berhasil mengubah data oneklik"])
                    return self.refreshPage()
                } else {
                    StickyAlertView.showErrorMessage([response.message ?? "Gagal mengubah data oneklik"])
                    self.registeredOneClickData.value = OneClickData()
                    return refresh
                }
            }).shareReplay(1)

        let doDeleteOneClick = deletedOneClickData.asObservable()
            .filter({ data -> Bool in
                data.tokenID != ""
            }).distinctUntilChanged({ (current, last) -> Bool in
                current.tokenID == last.tokenID
            }).flatMap({ data in
                self.deleteOneClick(data.tokenID)
            }).flatMap({ response -> Observable<[MultipleSectionModel]> in
                if response.success {
                    StickyAlertView.showSuccessMessage([response.message ?? "Berhasil menghapus OneKlik"])
                    return self.refreshPage()
                } else {
                    StickyAlertView.showErrorMessage([response.message ?? "Gagal menghapus Oneklik"])
                    self.deletedOneClickData.value = OneClickData()
                    return refresh
                }

            }).shareReplay(1)
        
        let actions = Observable.of(doDeleteOneClick,
                                    doRegisterOneClick,
                                    doEditOneClick,
                                    doDeleteCreditCard)
            .merge()
            .catchError({ error -> Observable<[MultipleSectionModel]> in
                if let moyaError = error as? MoyaError,
                    case let .underlying(responseError) = moyaError,
                    responseError._code == NSURLErrorNotConnectedToInternet {
                    StickyAlertView.showErrorMessage(["Tidak ada koneksi internet."])
                    
                } else {
                    StickyAlertView.showErrorMessage(["Terjadi kendala pada server. Silahkan coba beberapa saat lagi."])
                    
                }
                return self.refreshPage()
        })

        listItems = Observable.of(refresh,
                                  request,
                                  actions)
            .merge()
            .shareReplay(1)
    }
    
    func deleteCreditCardData(_ data: CreditCardData) {
        self.deletedCreditCardData.value = data
    }
    
    func deleteOneClickData(_ data: OneClickData) {
        self.deletedOneClickData.value = data
    }
    
    func editOneClickData(_ data: OneClickData) {
        self.editedOneClickData.value = data
    }
    
    func registerOneClickData(_ data: OneClickData) {
        self.registeredOneClickData.value = data
    }

    private func refreshPage() -> Observable<[MultipleSectionModel]> {
        let creditCardData = getListCreditCardData()
        let oneClickData = getListOneClickData()
        return Observable.combineLatest(creditCardData, oneClickData, resultSelector: { creditCard, oneClick in
            [creditCard, oneClick]
        }).observeOn(MainScheduler.instance)
        .trackActivity(listActivityIndicator)
        .retry(3)
        .shareReplay(1)
    }

    private func getListOneClickData() -> Observable<MultipleSectionModel> {
        return provider
            .request(.getListOneClick())
            .map(to: OneClickResponse.self)
            .map({ data in
                data.list
            }).map({ items in

                guard let items = items else {
                    return .empty()
                }

                var sectionItems: [SectionItem] = []
                items.forEach({ data in
                    sectionItems.append(.oneClick(userData: data))
                })

                if sectionItems.count < 3 {
                    sectionItems.append(.oneClickRegister())
                }
                return .oneClick(title: "Pembayaran Cepat", items: sectionItems)
            }).catchErrorJustReturn(.empty())
    }

    private func getListCreditCardData() -> Observable<MultipleSectionModel> {
        return provider
            .request(.getListCreditCard())
            .map(to: CreditCardResponse.self)
            .map({ data in
                data.list
            }).map({ items in

                guard let items = items else {
                    return .empty()
                }

                var sectionItems: [SectionItem] = []
                items.forEach({ data in
                    sectionItems.append(.creditCard(userData: data))
                })

                if sectionItems.count == 0 {
                    sectionItems.append(.emptyCreditCard())
                }

                return .creditCard(title: "Kartu Kredit", items: sectionItems)
            }).catchError({ error -> Observable<MultipleSectionModel> in
                if let moyaError = error as? MoyaError,
                    case let .underlying(responseError) = moyaError,
                    responseError._code == NSURLErrorNotConnectedToInternet {
                    return Observable.just(.creditCard(title: "",
                                                       items: [.errorInternetConnection()]))
                } else {
                    return Observable.just(.creditCard(title: "",
                                                       items: [.errorFetchData()]))
                }
            })
    }

    func getToken() -> Observable<OneClickAuth> {
        return provider
            .request(.getOneClickAccessToken())
            .map(to: OneClickAuth.self)
            .observeOn(MainScheduler.instance)
            .trackActivity(actionActivityIndicator)
            .retry(3)
            .shareReplay(1)
            .catchError({ error -> Observable<OneClickAuth> in
                if let moyaError = error as? MoyaError,
                    case let .underlying(responseError) = moyaError,
                    responseError._code == NSURLErrorNotConnectedToInternet {
                    StickyAlertView.showErrorMessage(["Tidak ada koneksi internet."])
                    
                } else {
                    StickyAlertView.showErrorMessage(["Terjadi kendala pada server. Silahkan coba beberapa saat lagi."])
                    
                }
                return Observable.just(OneClickAuth())
            })
    }

    private func registerUser(_ userData: OneClickData) -> Observable<PaymentActionResponse> {
        return provider
            .request(.registerOneClick(userData))
            .map(to: PaymentActionResponse.self)
            .observeOn(MainScheduler.instance)
            .trackActivity(actionActivityIndicator)
            .retry(3)
    }

    private func deleteCreditCard(_ tokenID: String) -> Observable<PaymentActionResponse> {
        return provider
            .request(.deleteCreditCard(tokenID))
            .map(to: PaymentActionResponse.self)
            .observeOn(MainScheduler.instance)
            .trackActivity(actionActivityIndicator)
            .retry(3)
    }

    private func editOneClick(_ data: OneClickData) -> Observable<PaymentActionResponse> {
        return provider
            .request(.editOneClick(data))
            .map(to: PaymentActionResponse.self)
            .observeOn(MainScheduler.instance)
            .trackActivity(actionActivityIndicator)
            .retry(3)
    }

    private func deleteOneClick(_ tokenID: String) -> Observable<PaymentActionResponse> {
        return provider
            .request(.deleteOneClick(tokenID))
            .map(to: PaymentActionResponse.self)
            .observeOn(MainScheduler.instance)
            .trackActivity(actionActivityIndicator)
            .retry(3)
    }
}
