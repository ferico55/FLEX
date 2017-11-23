//
//  CCAuthenticationViewModel.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 02/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import RxSwift
import Moya
import MoyaUnbox
import RxDataSources

enum CCAuthenticationError: Swift.Error {
    case networkError
    case notSupported
    case noInternetConnection
}

struct ErrorState {

    var title = "Oops"
    var description = ""
    var buttonTitle = "Coba Lagi"
    var buttonColor = UIColor.tpGreen()
    var action = Action.refresh
    var showError = false

    enum Action {
        case dismiss
        case refresh
    }

    mutating func setErrorMessage(error: CCAuthenticationError) {
        showError = true
        switch error {
        case .networkError:
            description = "Mohon maaf terjadi kendala pada server.\nSilakan ulangi beberapa saat lagi."
        case .noInternetConnection:
            title = "Oops, Tidak ada koneksi internet"
            description = "Mohon cek kembali jaringan Anda"
        case .notSupported:
            description = "Maaf, Layanan Belum Tersedia"
            buttonTitle = "Kembali"
            buttonColor = UIColor.tpOrange()
            action = Action.dismiss
        }
    }
}

struct CCItemState {
    var name = ""
    var value = 0
    var isSelected = false
}

class CCAuthenticationViewModel: NSObject {

    var items: Observable<[SectionModel<String, CCItemState>]>?
    var selectedItem = Variable(CCItemState())
    var showErrorState = Variable(ErrorState())
    private let provider = ScroogeProvider()
    let statusActivityIndicator = ActivityIndicator()
    let actionActivityIndicator = ActivityIndicator()

    let headerTitles = [
        "PILIH METODE AUTENTIKASI",
        "",
    ]

    let footerTitles = [
        "Anda hanya akan diminta memasukkan CVV untuk setiap transaksi. Verifikasi via SMS/sidik jari akan diperlukan untuk transaksi kasus tertentu.",
        "Anda akan diminta memasukkan CVV dan verifikasi via SMS/sidik jari untuk setiap transaksi.",
    ]

    init(doRefresh: Observable<Void>) {
        super.init()

        let request = self.getStatus().catchError { (error) -> Observable<CCAuthenticationStatus> in
            self.handleError(error: error)
            return .empty()
        }

        let refresh = doRefresh.flatMap { _ -> Observable<CCAuthenticationStatus> in
            return request.catchError { (error) -> Observable<CCAuthenticationStatus> in
                self.handleError(error: error)
                return .empty()
            }
        }

        let updateStatus = selectedItem.asObservable().filter({ (item) -> Bool in
            item.name != ""
        }).distinctUntilChanged({ (status, lastStatus) -> Bool in
            status.value == lastStatus.value
        }).flatMap({ (status) -> Observable<CCAuthenticationStatus> in
            self.updateStatus(status.value)
                .catchError { (error) -> Observable<CCAuthenticationStatus> in
                    self.handleError(error: error)
                    return .empty()
                }
        })

        items = Observable.of(refresh, request, updateStatus)
            .merge()
            .flatMap({ status -> Observable<[SectionModel<String, CCItemState>]> in
                .just([
                    SectionModel(model: "single auth",
                                 items: [CCItemState(name: "Autentikasi Tunggal",
                                                   value: 1,
                                                   isSelected: status.state == 1)]),
                    SectionModel(model: "double auth",
                                 items: [CCItemState(name: "Autentikasi Ganda",
                                                   value: 0,
                                                   isSelected: status.state == 0)]),
                ])
            })
    }

    private func handleError(error: Swift.Error) {
        var state = ErrorState()
        if let moyaError = error as? MoyaError,
            case let .underlying(responseError) = moyaError,
            responseError._code == NSURLErrorNotConnectedToInternet {
            state.setErrorMessage(error: CCAuthenticationError.noInternetConnection)
        } else if let ccAuthError = error as? CCAuthenticationError {
            state.setErrorMessage(error: ccAuthError)
        } else {
            state.setErrorMessage(error: CCAuthenticationError.networkError)
        }
        showErrorState.value = state
    }

    private func getStatus() -> Observable<CCAuthenticationStatus> {
        return provider
            .request(.getCCAuthenticationStatus())
            .map(to: CCAuthenticationStatus.self)
            .trackActivity(statusActivityIndicator)
            .flatMap({ (status) -> Observable<CCAuthenticationStatus> in
                if status.statusCode == 501 {
                    return .error(CCAuthenticationError.notSupported)
                } else if status.statusCode != 200 {
                    return .error(CCAuthenticationError.networkError)
                } else {
                    return .just(status)
                }
            })
    }

    func updateStatus(_ status: Int) -> Observable<CCAuthenticationStatus> {
        return provider
            .request(.updateCCAuthenticationStatus(status))
            .map(to: CCAuthenticationStatus.self)
            .trackActivity(actionActivityIndicator)
            .flatMap({ (status) -> Observable<CCAuthenticationStatus> in
                if status.statusCode == 501 {
                    return .error(CCAuthenticationError.notSupported)
                } else if status.statusCode != 200 {
                    return .error(CCAuthenticationError.networkError)
                } else {
                    return .just(status)
                }
            })
    }
}
