//
//  ResolutionValidation.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 9/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class ResolutionValidation: NSObject {
    
    fileprivate var errorMessages : [String] = []
    
    func isValidInputProblem(_ postObject: ReplayConversationPostData) -> Bool {
        
        if postObject.category_trouble_id == "1"{
            do{
                try self.validateProductRelatedProblem(postObject)
            } catch let error as FormError {
                self.errorMessages.append(error.message)
            } catch {
                //other error
            }
        } else {
            do{
                try self.validateNonProductRelatedProblem(postObject)
            } catch let error as FormError {
                self.errorMessages.append(error.message)
            } catch {
                //other error
            }
        }
        
        if errorMessages.count > 0 {
            StickyAlertView.showErrorMessage(errorMessages)
        }
        
        return errorMessages.count == 0
    }
    
    func isValidSubmitEditResolution(_ postObject : ReplayConversationPostData) -> Bool{
        do{
            try self.validateSolution(postObject)
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
    
    fileprivate func validateSolution(_ postObject : ReplayConversationPostData) throws {
        
        guard Int(postObject.refundAmount)! <= Int(postObject.maxRefundAmount)! else {
            throw FormError(message: "Nominal maksimal pengembalian dana sebesar \(postObject.maxRefundAmountIDR) .")
        }
        
        guard postObject.replyMessage != "" else {
            throw FormError(message: "Alasan mengubah solusi belum diisi.")
        }
    }
    
    fileprivate func validateProductRelatedProblem(_ postObject: ReplayConversationPostData) throws {
        guard postObject.selectedProducts.count > 0 else{
            throw FormError(message: "Pilih produk yang bermasalah.")
        }
        
        try postObject.selectedProducts.forEach { (product) in
            guard product.pt_last_selected_quantity != "" && Int(product.pt_last_selected_quantity)! > 0 else {
                throw FormError(message: "Jumlah produk \(product.pt_product_name) belum diisi")
            }
            
            guard product.pt_trouble_id != "" else {
                throw FormError(message: "Masalah pada produk \(product.pt_product_name) belum dipilih")
            }
            guard product.pt_solution_remark != "" else {
                throw FormError(message: "Keterangan Masalah pada produk \(product.pt_product_name) belum diisi")
            }
        }
    }
    
    fileprivate func validateNonProductRelatedProblem(_ postObject: ReplayConversationPostData) throws {
        guard postObject.troubleType != "" && Int(postObject.troubleType) != 0 else {
            throw FormError(message: "Pilih detail masalah")
        }
    }

}
