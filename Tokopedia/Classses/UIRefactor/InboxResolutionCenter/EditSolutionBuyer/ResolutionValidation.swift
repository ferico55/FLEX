//
//  ResolutionValidation.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 9/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class ResolutionValidation: NSObject {
    
    private var errorMessages : [String] = []
    
    func isValidInputProblem(postObject: ReplayConversationPostData) -> Bool {
        
        if postObject.category_trouble_id == "1"{
            do{
                try self.validateProductRelatedProblem(postObject)
            } catch Errors.errorMessage(let message) {
                self.errorMessages.append(message)
            } catch {
                //other error
            }
        } else {
            do{
                try self.validateNonProductRelatedProblem(postObject)
            } catch Errors.errorMessage(let message) {
                self.errorMessages.append(message)
            } catch {
                //other error
            }
        }
        
        if errorMessages.count > 0 {
            StickyAlertView.showErrorMessage(errorMessages)
        }
        
        return errorMessages.count == 0
    }
    
    func isValidSubmitEditResolution(postObject : ReplayConversationPostData) -> Bool{
        if postObject.solution == "1"{
            do{
                try self.validateRefundSolution(postObject)
            } catch Errors.errorMessage(let message) {
                self.errorMessages.append(message)
            } catch {
                //other error
            }
        }
        
        do{
            try self.validateSolution(postObject)
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
    
    private func validateRefundSolution(postObject: ReplayConversationPostData) throws{
        guard postObject.refundAmount != "" else {
            throw Errors.errorMessage("Jumlah pengembalian dana belum diisi.")
        }
        
        guard Int(postObject.refundAmount) < Int(postObject.maxRefundAmount) else {
            throw Errors.errorMessage("Jumlah refund tidak valid.")
        }
    }
    
    private func validateSolution(postObject : ReplayConversationPostData) throws {
        guard postObject.replyMessage != "" else {
            throw Errors.errorMessage("Alasan merubah solusi belum diisi.")
        }
    }
    
    private func validateProductRelatedProblem(postObject: ReplayConversationPostData) throws {
        guard postObject.selectedProducts.count > 0 else{
            throw Errors.errorMessage("Pilih produk yang bermasalah.")
        }
        
        try postObject.selectedProducts.forEach { (product) in
            guard product.pt_trouble_id != "" else {
                throw Errors.errorMessage("Masalah pada produk \(product.pt_product_name) belum dipilih")
            }
            guard product.pt_solution_remark != "" else {
                throw Errors.errorMessage("Keterangan Masalah pada produk \(product.pt_product_name) belum diisi")
            }
        }
    }
    
    private func validateNonProductRelatedProblem(postObject: ReplayConversationPostData) throws {
        guard postObject.troubleType != "" else {
            throw Errors.errorMessage("Pilih detail masalah")
        }
    }

}
