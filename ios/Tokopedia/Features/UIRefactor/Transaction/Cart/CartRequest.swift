//
//  CartRequest.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 5/4/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import NSObject_Rx
import RxSwift
import UIKit

public enum InsuranceType: String {
    case noInsurace = "1"
    case optionalInsurace = "2"
    case mustInsurance = "3"
}

public class CartRequest: NSObject {

    public func fetchCartData(_ onSuccess: @escaping ((TransactionCartResult) -> Void), onFailure: @escaping ((Error) -> Void)) {

        var cartResult: TransactionCartResult!

        self.fetchListCart()
            .flatMap { (data) -> Observable<[TransactionCartList]> in
                cartResult = data
                guard let token = data.keroToken else { return Observable.just(data.list) }
                guard let ut = data.ut else { return Observable.just(data.list) }
                return self.fetchRates(data.list, token: token, ut: ut)
            }
            .subscribe(onNext: { carts in
                let grandTotal = carts
                    .filter {
                        guard let errors = $0.errors else { return true }
                        return errors.count == 0
                    }
                    .flatMap { (Int($0.cart_total_amount) ?? 0) }
                    .reduce(0, +)
                cartResult.grand_total = "\(grandTotal - (Int(cartResult.lp_amount ?? "0") ?? 0))"
                cartResult.grand_total_without_lp = "\(grandTotal)"
                cartResult.list = carts
                onSuccess(cartResult)
            }, onError: { error in
                onFailure(error)
            })
            .disposed(by: rx_disposeBag)

    }

    private func fetchListCart() -> Observable<TransactionCartResult> {

        return Observable.create({ (observer) -> Disposable in
            let networkManager: TokopediaNetworkManager = TokopediaNetworkManager()
            networkManager.isUsingHmac = true

            networkManager.request(withBaseUrl: NSString.v4Url(),
                                   path: "/v4/tx.pl",
                                   method: .GET,
                                   parameter: [:],
                                   mapping: V4Response<TransactionCartResult>.mapping(withData: TransactionCartResult.mapping()),
                                   onSuccess: { mappingResult, _ in

                                       let result: Dictionary = mappingResult.dictionary() as Dictionary
                                       let response: V4Response<TransactionCartResult> = result[""] as! V4Response<TransactionCartResult>
                                       if let messageError = response.message_error, !messageError.isEmpty {
                                           StickyAlertView.showErrorMessage(response.message_error)
                                           observer.onError(RequestError.networkError as Error)
                                       } else {
                                           if let messageStatus = response.message_status, !messageStatus.isEmpty {
                                               StickyAlertView.showSuccessMessage(response.message_status)
                                           }
                                           observer.onNext(response.data)
                                       }

                                   }, onFailure: { _ in
                                       observer.onError(RequestError.networkError as Error)
                                       StickyAlertView.showErrorMessage(["Kendala koneksi internet"])
            })

            return Disposables.create()
        })
    }

    private func fetchRates(_ carts: [TransactionCartList], token: String, ut: String) -> Observable<[TransactionCartList]> {
        return Observable.from(carts)
            .flatMap({ cart -> Observable<TransactionCartList> in
                guard cart.errors == nil else { return Observable.just(cart) }
                return self.fetchRate(cart, token: token, ut: ut)
            })
            .toArray()
    }

    private func fetchRate(_ cart: TransactionCartList, token: String, ut: String) -> Observable<TransactionCartList> {

        return Observable.create({ (observer) -> Disposable in
            let networkManager: TokopediaNetworkManager = TokopediaNetworkManager()
            networkManager.isUsingDefaultError = false
            networkManager.isUsingHmac = true

            var productInsurance = "0"
            if cart.cart_products.filter({ product -> Bool in
                (product.product_must_insurance == "1")
            }).count > 0 {
                productInsurance = "1"
            }

            let param: [String: String] = [
                "names": cart.cart_shipments.shipmentCode,
                "origin": "\(cart.cart_shop.addressID!)|\(cart.cart_shop.postalCode!)|\(cart.cart_shop.latitude!),\(cart.cart_shop.longitude!)",
                "destination": "\(cart.cart_destination.address_district_id!)|\(cart.cart_destination.postal_code!)|\(cart.cart_destination.latitude!),\(cart.cart_destination.longitude!)",
                "weight": cart.cart_total_weight,
                "token": token,
                "nocache": "1",
                "cat_id": cart.categoryID,
                "order_value": cart.cart_total_product_price,
                "insurance": "1",
                "product_insurance": productInsurance,
                "ut": ut
            ]

            networkManager.request(withBaseUrl: NSString.keroUrl(),
                                   path: "/rates/v1",
                                   method: .GET,
                                   parameter: param,
                                   mapping: RateResponse.mapping(),
                                   onSuccess: { mappingResult, _ in

                                       let result: Dictionary = mappingResult.dictionary() as Dictionary
                                       let response: RateResponse = result[""] as! RateResponse

                                       response.data.attributes.first?.products.forEach({ productRate in
                                           if productRate.shipper_product_id == cart.cart_shipments.shipment_package_id {
                                               self.adjustCart(cart, productRate: productRate)
                                           }
                                       })

                                       observer.onNext(cart)
                                       observer.onCompleted()

                                   }, onFailure: { _ in
                                       self.adjustCart(cart, productRate: nil)
                                       let errors = Errors(name: "", title: "Tidak dapat mengirim ke tujuan, silahkan periksa kembali kurir atau alamat yang digunakan")
                                       cart.errors = [errors]
                                       observer.onNext(cart)
                                       observer.onCompleted()
            })

            return Disposables.create()
        })
    }

    private func adjustCart(_ cart: TransactionCartList, productRate: RateProduct?) {

        guard let rate = productRate else { return }

        let package = ShippingInfoShipmentPackage(price: rate.price, packageID: rate.shipper_product_id, name: rate.shipper_product_name)
        cart.cart_shipments.selected_shipment_package = package

        cart.cart_shipping_rate = rate.price
        cart.cart_shipping_rate_idr = rate.formatted_price

        let insurancePrice = calculateInsurancePrice(cart, productRate: productRate)
        cart.cart_insurance_price = insurancePrice

        cart.cart_total_amount = "\(Int(cart.cart_shipping_rate)! + Int(cart.cart_total_product_price)! + Int(cart.cart_insurance_price)! + Int(cart.cart_logistic_fee)!)"

        if let totalInsurance = Int(cart.cart_insurance_price) {
            cart.cart_insurance_price_idr = NumberFormatter.idr().string(from: NSNumber(value: totalInsurance))
        }

        if let totalAmount = Int(cart.cart_total_amount) {
            cart.cart_total_amount_idr = NumberFormatter.idr().string(from: NSNumber(value: totalAmount))
        }

        cart.rateValue = "\(rate.price ?? "")|\(cart.cart_total_weight!)|\(rate.ut ?? "")|\(productRate?.check_sum ?? "")"

        cart.insuranceUsedType = rate.insuranceUsedType
        cart.insuranceUsedDefault = rate.insuranceUsedDefault
        cart.insuranceUsedInfo = rate.insuranceUsedInfo
        cart.insuranceType = rate.insuranceType
        cart.insuranceTypeInfo = rate.insuranceTypeInfo
        cart.insurancePrice = insurancePrice
    }

    private func calculateInsurancePrice(_ cart: TransactionCartList, productRate: RateProduct?) -> String {
        var insurancePrice = "0"
        if let price = productRate?.insurancePrice,
            cart.cart_force_insurance == "1" ||
            cart.cart_insurance_prod == "1" ||
            cart.cart_products.filter({ product -> Bool in
                (product.product_must_insurance == "1" ||
                    product.product_use_insurance == "1")
            }).count > 1 {
            insurancePrice = price
        }
        return insurancePrice
    }

    public func cancelVoucher() {
        NetworkProvider<VoucherTarget>().request(.cancelVoucher()).subscribe(onNext: { response in
            print(response)
        }, onError: { error in
            print(error)
        }).disposed(by: rx_disposeBag)
    }
}
