//
//  FormProductValidation.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 8/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class FormError:Error{
    let message:String
    init(message:String) {
        self.message = message
    }
}

enum FormType:Int{
    case addProduct = 1
    case editProduct = 2
    case copyProduct = 3
}

enum PriceCurrencyType:String{
    case IDR = "1"
    case USD = "2"
}

enum WeightUnitType:String{
    case Gram       = "1"
    case Kilogram   = "2"
}

class FormProductValidation: NSObject {
    
    fileprivate var errorMessages : [String] = []
    fileprivate var type : FormType = FormType.addProduct
    
    func isValidFormFirstStep(_ form: ProductEditResult?, type:Int, productNameBeforeCopy: String) -> Bool {
        
        guard let form = form else {
            return false
        }
        
        self.type = FormType(rawValue: type)!
        
        do{
            try self.imageValidation(form.product_images)
        } catch let error as FormError {
            self.errorMessages.append(error.message)
        } catch {
            //other error
        }
        
        do{
            try self.categoryValidation(form.product.product_category)
        } catch let error as FormError {
            self.errorMessages.append(error.message)
        } catch {
            //other error
        }
        
        do{
            try self.nameValidation(form.product.product_name, nameBeforeCopy: productNameBeforeCopy)
        } catch let error as FormError {
            self.errorMessages.append(error.message)
        } catch {
            //other error
        }
        
        do{
            try self.minimalOrderValidation(form.product.product_min_order)
        } catch let error as FormError {
            self.errorMessages.append(error.message)
        } catch {
            //other error
        }
        
        do{
            try self.priceValidation(form.product.product_price, currency: form.product.product_currency_id)
        } catch let error as FormError {
            self.errorMessages.append(error.message)
        } catch {
            //other error
        }
        
        do{
            try self.weightValidation(form.product.product_weight, unit: form.product.product_weight_unit)
        } catch let error as FormError {
            self.errorMessages.append(error.message)
        } catch {
            //other error
        }
        
        if errorMessages.count > 0 {
            StickyAlertView.showErrorMessage(errorMessages)
        }
        
        return errorMessages.count == 0
    }

    func isValidFormSecondStep(_ form: ProductEditResult, type:Int) -> Bool {
        do{
            try self.etalaseValidation(form.product.product_etalase_id, etalaseName: form.product.product_etalase)
        } catch let error as FormError {
            self.errorMessages.append(error.message)
        } catch {
            //other error
        }
        
        if errorMessages.count > 0 {
            StickyAlertView.showErrorMessage(errorMessages)
        }
        
        return errorMessages.count == 0
    }
    
    func isValidFormProductWholesale(_ wholesales: [WholesalePrice], product: ProductEditDetail) -> Bool {
        do{
            try self.wholesaleValidation(wholesales, product: product)
        } catch let error as FormError {
            self.errorMessages.append(error.message)
        } catch {
            //other error
        }
        
        if errorMessages.count > 0 {
            StickyAlertView.showErrorMessage(errorMessages)
        }
        
        return errorMessages.count == 0
    }
    
    fileprivate func imageValidation(_ selectedImages: [ProductEditImages]) throws {
        
        guard selectedImages.count > 0 else {
            throw FormError(message: "Gambar harus tersedia")
        }
    }
    
    fileprivate func nameValidation(_ name: String, nameBeforeCopy: String) throws {
        
        guard name != "" else {
            throw FormError(message: "Nama produk harus diisi.")
        }
        
        if type == .copyProduct {
            guard name != nameBeforeCopy else {
                throw FormError(message: "Tidak dapat menyalin dengan Nama Produk yang sama.")
            }
        }
    }
    
    fileprivate func categoryValidation(_ category: ListOption) throws {
        
        guard let _ = category.categoryId else {
            throw FormError(message: "Kategori tidak benar")
        }
    }
    
    fileprivate func minimalOrderValidation(_ minimalOrder: String) throws {
        
        guard Int(minimalOrder) > 0 else {
            throw FormError(message: "Minimal pemesanan harus lebih dari 1")
        }
        
        guard Int(minimalOrder) <= ProductDetail.maximumPurchaseQuantity() else {
            throw FormError(message: "Maksimal minimum pembelian untuk 1 produk adalah \(ProductDetail.maximumPurchaseQuantity())")
        }
    }
    
    fileprivate func priceValidation(_ price: String?, currency:String) throws {
        
        guard price != "" && price != nil else {
            throw FormError(message: "Harga harus diisi.")
        }
        
        if currency == PriceCurrencyType.IDR.rawValue {
            guard Float(price!) >= 100 && Float(price!) <= 50000000 else {
                throw FormError(message: "Rentang Harga 100 - 50000000")
            }
        }
        
        if currency == PriceCurrencyType.USD.rawValue {
            guard Float(price!) >= 1 && Float(price!) <= 4000 else {
                throw FormError(message: "Rentang Harga 1 - 4000")
            }
        }
    }
    
    fileprivate func weightValidation(_ weight: String, unit: String) throws {
        
        guard weight != "" else {
            throw FormError(message: "Berat produk harus diisi .")
        }
        
        if unit == WeightUnitType.Gram.rawValue {
            guard Int(weight) >= 1 && Int(weight) <= 35000 else {
                throw FormError(message: "Berat harus diisi antara 1 - 35000")
            }
        }
        
        if unit == WeightUnitType.Kilogram.rawValue {
            guard Int(weight) >= 1 && Int(weight) <= 35 else {
                throw FormError(message: "Berat harus diisi antara 1 - 35")
            }
        }
    }
    
    fileprivate func etalaseValidation(_ etalaseID: String ,etalaseName: String) throws {
        guard etalaseID != "" else {
            throw FormError(message: "Etalase belum dipilih")
        }
    }
    
    
    //MARK: - Wholesale
    fileprivate func wholesaleValidation(_ wholesales: [WholesalePrice], product:ProductEditDetail) throws {
        
        wholesales.forEach({ (wholesale) in
            do{
                try self.wholesalePriceValidation(wholesale.wholesale_price, product: product)
            } catch let error as FormError {
                self.errorMessages.append(error.message)
            } catch {
                //other error
            }
            
            do{
                try self.wholesaleQuantityValidation(wholesale.wholesale_min, quantityMax: wholesale.wholesale_max, product: product)
            } catch let error as FormError {
                self.errorMessages.append(error.message)
            } catch {
                //other error
            }
        })
        
        if wholesales.count >= 2 {
            do{
                try self.lastWholesaleValidation(wholesales[wholesales.count-2], newWholesale: wholesales.last!)
            } catch let error as FormError {
                self.errorMessages.append(error.message)
            } catch {
                //other error
            }
        }
        
    }
    
    fileprivate func wholesaleQuantityValidation(_ quantityMin:String, quantityMax:String, product:ProductEditDetail) throws {
        
        do{
            try self.wholesaleQuantityMinValidation(quantityMin, product: product)
        } catch let error as FormError {
            self.errorMessages.append(error.message)
        } catch {
            //other error
        }
        
        do{
            try self.wholesaleQuantityMaxValidation(quantityMax, product: product)
            guard Int(quantityMax) > Int(quantityMin) else {
                throw FormError(message: "Jumlah maksimum harus lebih besar dari jumlah minimum")
            }
        } catch let error as FormError {
            self.errorMessages.append(error.message)
        } catch {
            //other error
        }
    }
    
    fileprivate func wholesaleQuantityMinValidation(_ quantityMin:String, product:ProductEditDetail) throws {
        guard quantityMin != "" else {
            throw FormError(message: "Jumlah minimum harus diisi")
        }
        
        guard Int(quantityMin) > Int(product.product_min_order) else {
            throw FormError(message: "Jumlah barang grosir harus lebih besar dari minimum pemesanan")
        }
    }
    
    fileprivate func wholesaleQuantityMaxValidation(_ quantityMax:String, product:ProductEditDetail) throws {
        guard quantityMax != "" else {
            throw FormError(message: "Jumlah maksimum harus diisi")
        }
        
        guard Int(quantityMax) > Int(product.product_min_order) else {
            throw FormError(message: "Jumlah barang grosir harus lebih besar dari minimum pemesanan")
        }
    }
    
    fileprivate func wholesalePriceValidation(_ price: String?, product: ProductEditDetail) throws {
        guard price != "" && price != nil else {
            throw FormError(message: "Harga harus diisi")
        }
        
        guard Float(price!) < Float(product.product_price) else {
            throw FormError(message: "Harga grosir harus lebih murah dari harga pas")
        }
        
        do{
            try self.priceValidation(price, currency: product.product_currency_id)
        } catch let error as FormError {
            self.errorMessages.append(error.message)
        } catch {
            //other error
        }
    }
    
    fileprivate func lastWholesaleValidation(_ lastWholesale: WholesalePrice, newWholesale: WholesalePrice) throws {
        
        guard Int(newWholesale.wholesale_min) > Int(lastWholesale.wholesale_min) else {
            throw FormError(message: "Total produk tidak valid")
        }
        
        guard Int(newWholesale.wholesale_max) > Int(lastWholesale.wholesale_max) else {
            throw FormError(message: "Total produk tidak valid")
        }
        
        guard Float(newWholesale.wholesale_price) < Float(lastWholesale.wholesale_price) else {
            throw FormError(message: "Harga harus lebih murah dari harga grosir sebelumnya")
        }
    }
    
}
