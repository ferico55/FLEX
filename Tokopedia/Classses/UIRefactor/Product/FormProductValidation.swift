//
//  FormProductValidation.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 8/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

enum Errors:ErrorType{
    case errorMessage(String)
}

enum FormType:Int{
    case AddProduct = 1
    case EditProduct = 2
    case CopyProduct = 3
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
    
    private var errorMessages : [String] = []
    private var type : FormType = FormType.AddProduct
    
    func isValidFormFirstStep(form: ProductEditResult, type:Int, productNameBeforeCopy: String) -> Bool {
        
        self.type = FormType.init(rawValue: type)!
        
        do{
            try self.imageValidation(form.product_images)
        } catch Errors.errorMessage(let message) {
            self.errorMessages.append(message)
        } catch {
            //other error
        }
        
        do{
            try self.categoryValidation(form.product.product_category)
        } catch Errors.errorMessage(let message) {
            self.errorMessages.append(message)
        } catch {
            //other error
        }
        
        do{
            try self.nameValidation(form.product.product_name, nameBeforeCopy: productNameBeforeCopy)
        } catch Errors.errorMessage(let message) {
            self.errorMessages.append(message)
        } catch {
            //other error
        }
        
        do{
            try self.minimalOrderValidation(form.product.product_min_order)
        } catch Errors.errorMessage(let message) {
            self.errorMessages.append(message)
        } catch {
            //other error
        }
        
        do{
            try self.priceValidation(form.product.product_price, currency: form.product.product_currency_id)
        } catch Errors.errorMessage(let message) {
            self.errorMessages.append(message)
        } catch {
            //other error
        }
        
        do{
            try self.weightValidation(form.product.product_weight, unit: form.product.product_weight_unit)
        } catch Errors.errorMessage(let message) {
            self.errorMessages.append(message)
        } catch {
            //other error
        }
        
        if errorMessages.count > 0 {
            StickyAlertView.showErrorMessage(errorMessages)
        }
        
        return errorMessages.count == 0
    }
    
    func isValidFormSecondStep(form: ProductEditResult, type:Int) -> Bool {
        do{
            try self.etalaseValidation(form.product.product_etalase_id, etalaseName: form.product.product_etalase)
        } catch Errors.errorMessage(let message) {
            self.errorMessages.append(message)
        } catch {
            //other error
        }
        
        if errorMessages.count > 0 {
            StickyAlertView.showErrorMessage(errorMessages)
        }
        
        return errorMessages.count == 0
    }
    
    func isValidFormProductWholesale(wholesales: [WholesalePrice], product: ProductEditDetail) -> Bool {
        do{
            try self.wholesaleValidation(wholesales, product: product)
        } catch Errors.errorMessage(let message) {
            self.errorMessages.append(message)
        } catch {
            //other error
        }
        
        if errorMessages.count > 0 {
            StickyAlertView.showErrorMessage(errorMessages)
        }
        
        return errorMessages.count == 0
    }
    
    private func imageValidation(selectedImages: [ProductEditImages]) throws {
        
        guard selectedImages.count > 0 else {
            throw Errors.errorMessage("Gambar harus tersedia")
        }
    }
    
    private func nameValidation(name: String, nameBeforeCopy: String) throws {
        
        guard name != "" else {
            throw Errors.errorMessage("Nama produk harus diisi.")
        }
        
        if type == .CopyProduct {
            guard name != nameBeforeCopy else {
                throw Errors.errorMessage("Tidak dapat menyalin dengan Nama Produk yang sama.")
            }
        }
    }
    
    private func categoryValidation(category: CategoryDetail) throws {
        
        guard category.categoryId != "" else {
            throw Errors.errorMessage("Kategori tidak benar")
        }
    }
    
    private func minimalOrderValidation(minimalOrder: String) throws {
        
        guard Int(minimalOrder) <= 1000 else {
            throw Errors.errorMessage("Maksimal minimum pembelian untuk 1 produk adalah 999")
        }
    }
    
    private func priceValidation(price: String?, currency:String) throws {
        
        guard price != "" && price != nil else {
            throw Errors.errorMessage("Harga harus diisi.")
        }
        
        if currency == PriceCurrencyType.IDR.rawValue {
            guard Int(price!) >= 100 && Int(price!) <= 50000000 else {
                throw Errors.errorMessage("Rentang Harga 100 - 50000000")
            }
        }
        
        if currency == PriceCurrencyType.USD.rawValue {
            guard Float(price!) >= 1 && Float(price!) <= 4000 else {
                throw Errors.errorMessage("Rentang Harga 1 - 4000")
            }
        }
    }
    
    private func weightValidation(weight: String, unit: String) throws {
        
        guard weight != "" else {
            throw Errors.errorMessage("Berat produk harus diisi .")
        }
        
        if unit == WeightUnitType.Gram.rawValue {
            guard Int(weight) >= 1 && Int(weight) <= 35000 else {
                throw Errors.errorMessage("Berat harus diisi antara 1 - 35000")
            }
        }
        
        if unit == WeightUnitType.Kilogram.rawValue {
            guard Int(weight) >= 1 && Int(weight) <= 35 else {
                throw Errors.errorMessage("Berat harus diisi antara 1 - 35")
            }
        }
    }
    
    private func etalaseValidation(etalaseID: String ,etalaseName: String) throws {
        guard etalaseID != "" else {
            throw Errors.errorMessage("Etalase belum dipilih")
        }
    }
    
    
    //MARK: - Wholesale
    private func wholesaleValidation(wholesales: [WholesalePrice], product:ProductEditDetail) throws {
        
        wholesales.forEach({ (wholesale) in
            do{
                try self.wholesalePriceValidation(wholesale.wholesale_price, product: product)
            } catch Errors.errorMessage(let message) {
                self.errorMessages.append(message)
            } catch {
                //other error
            }
            
            do{
                try self.wholesaleQuantityValidation(wholesale.wholesale_min, quantityMax: wholesale.wholesale_max, product: product)
            } catch Errors.errorMessage(let message) {
                self.errorMessages.append(message)
            } catch {
                //other error
            }
        })
        
        if wholesales.count >= 2 {
            do{
                try self.lastWholesaleValidation(wholesales[wholesales.count-2], newWholesale: wholesales.last!)
            } catch Errors.errorMessage(let message) {
                self.errorMessages.append(message)
            } catch {
                //other error
            }
        }
        
    }
    
    private func wholesaleQuantityValidation(quantityMin:String, quantityMax:String, product:ProductEditDetail) throws {
        
        do{
            try self.wholesaleQuantityMinValidation(quantityMin, product: product)
        } catch Errors.errorMessage(let message) {
            self.errorMessages.append(message)
        } catch {
            //other error
        }
        
        do{
            try self.wholesaleQuantityMaxValidation(quantityMax, product: product)
            guard Int(quantityMax) > Int(quantityMin) else {
                throw Errors.errorMessage("Jumlah maksimum harus lebih besar dari jumlah minimum")
            }
        } catch Errors.errorMessage(let message) {
            self.errorMessages.append(message)
        } catch {
            //other error
        }
    }
    
    private func wholesaleQuantityMinValidation(quantityMin:String, product:ProductEditDetail) throws {
        guard quantityMin != "" else {
            throw Errors.errorMessage("Jumlah minimum harus diisi")
        }
        
        guard Int(quantityMin) > Int(product.product_min_order) else {
            throw Errors.errorMessage("Jumlah barang grosir harus lebih besar dari minimum pemesanan")
        }
    }
    
    private func wholesaleQuantityMaxValidation(quantityMax:String, product:ProductEditDetail) throws {
        guard quantityMax != "" else {
            throw Errors.errorMessage("Jumlah maksimum harus diisi")
        }
        
        guard Int(quantityMax) > Int(product.product_min_order) else {
            throw Errors.errorMessage("Jumlah barang grosir harus lebih besar dari minimum pemesanan")
        }
    }
    
    private func wholesalePriceValidation(price: String?, product: ProductEditDetail) throws {
        guard price != "" && price != nil else {
            throw Errors.errorMessage("Harga harus diisi")
        }
        
        guard Int(price!) < Int(product.product_price) else {
            throw Errors.errorMessage("Harga grosir harus lebih murah dari harga pas")
        }
        
        do{
            try self.priceValidation(price, currency: product.product_currency_id)
        } catch Errors.errorMessage(let message) {
            self.errorMessages.append(message)
        } catch {
            //other error
        }
    }
    
    private func lastWholesaleValidation(lastWholesale: WholesalePrice, newWholesale: WholesalePrice) throws {
        
        guard Int(newWholesale.wholesale_min) > Int(lastWholesale.wholesale_min) else {
            throw Errors.errorMessage("Total produk tidak valid")
        }
        
        guard Int(newWholesale.wholesale_max) > Int(lastWholesale.wholesale_max) else {
            throw Errors.errorMessage("Total produk tidak valid")
        }
        
        guard Float(newWholesale.wholesale_price) < Float(lastWholesale.wholesale_price) else {
            throw Errors.errorMessage("Harga harus lebih murah dari harga grosir sebelumnya")
        }
    }
    
}
