//
//  PaymentService.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 9/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Moya
import MoyaUnbox
import SwiftyJSON
import enum Result.Result

class PaymentService: NSObject {
    
    func getPaymentStatus(paymentID: String, onSuccess: @escaping ((String) -> Void), onFailure:@escaping ((String)->Void)) {
        NetworkProvider<PaymentTarget>()
            .request(.getPaymentStatus(paymentID))
            .mapJSON()
            .subscribe(onNext: { response in
                let result = JSON(response)
                if result.dictionaryValue["success"]?.stringValue == "200" {
                    let message = result.dictionaryValue["data"]?.dictionaryValue["message"]?.stringValue ?? "Batalkan Transaksi?"
                        onSuccess(message)
                } else {
                    onFailure("Terjadi kendala pada server. Silahkan coba beberapa saat lagi.")
                }
            }, onError: { error in
                if let moyaError = error as? MoyaError,
                    case let .underlying(responseError) = moyaError,
                    responseError._code == NSURLErrorNotConnectedToInternet {
                    onFailure("Tidak ada koneksi internet.")
                } else {
                    onFailure("Terjadi kendala pada server. Silahkan coba beberapa saat lagi.")
                    
                }
            }).disposed(by: rx_disposeBag)
    }
    
    func cancelPayment(paymentID: String, onSuccess: @escaping ((String) -> Void), onFailure:@escaping ((String, _ shouldRefreshList: Bool)->Void)) {
        NetworkProvider<PaymentTarget>()
            .request(.cancelPayment(paymentID))
            .mapJSON()
            .subscribe(onNext: { response in
                let result = JSON(response)
                if result.dictionaryValue["success"]?.stringValue == "200",
                    let message = result.dictionaryValue["message"]?.stringValue {
                    onSuccess(message)
                } else {
                    let message = result.dictionaryValue["message"]?.stringValue ?? "Gagal membatalkan pesanan"
                    let shouldRefresh = result.dictionaryValue["success"]?.stringValue == "404003" || result.dictionaryValue["success"]?.stringValue == "404004"
                    onFailure(message, shouldRefresh)
                }
            }, onError: { error in
                if let moyaError = error as? MoyaError,
                    case let .underlying(responseError) = moyaError,
                    responseError._code == NSURLErrorNotConnectedToInternet {
                    onFailure("Tidak ada koneksi internet.", false)
                } else {
                    onFailure("Terjadi kendala pada server. Silahkan coba beberapa saat lagi.", false)
                    
                }
            }).disposed(by: rx_disposeBag)
    }

}
