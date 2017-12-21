//
//  RCCreateStep1ResponseData.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 24/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON
import DKImagePickerController
final class RCCreateStep1ResponseData: NSObject {
    var createInfo: [RCProblemItem] = []
//    MARK:- User computation
    var postageIssueProblem: RCProblemItem? {
        for item in createInfo {
            if item.problem.type == 1 {
                return item
            }
        }
        return nil
    }
    var selectedProblemItem: [RCProblemItem] {
        var selected: [RCProblemItem] = []
        for item in self.createInfo {
            if item.isSelected {
                selected.append(item)
            }
        }
        return selected
    }
    var solutionData: RCCreateSolutionData?
    var selectedPhotos: [DKAsset]?
    var attchmentMessage: String?
    var isItemsAdded: Bool {
        return self.selectedProblemItem.count > 0
    }
    var isSolutionAdded: Bool {
        if let solution = self.solutionData?.selectedSolution {
            if solution.amount != nil {
                if solution.returnExpected != nil {
                    return true
                }
            } else {
                return true
            }
        }
        return false
    }
    var isProofAdded: Bool {
        guard let solution = RCManager.shared.rcCreateStep1Data?.solutionData  else {return false}
        return (!solution.require.attachment || (solution.require.attachment && self.attchmentMessage != nil && self.selectedPhotos != nil))
    }
    var titleForItemsAdded: String {
        var count = self.selectedProblemItem.count
        if count > 0 {
            var subtitle = ""
            if let postageIssue = self.postageIssueProblem {
                if postageIssue.isSelected {
                    subtitle += "Selisih Ongkos Kirim "
                    count -= 1
                }
                if count > 0 && postageIssue.isSelected {
                    subtitle += "& "
                }
            }
            if count > 0 {
                subtitle +=   "\(count) Barang Bermasalah"
            }
            return subtitle
        } else {
            return "Pilih Barang & Masalah"
        }
    }
    var titleForSolution: String {
        if let solution = self.solutionData?.selectedSolution {
            if solution.amount != nil {
                if let expected = solution.returnExpected {
                    return solution.nameCustom.replacingOccurrences(of: "$amount", with: "\(expected)")
                }
            } else {
                return solution.name
            }
        }
        return "Pilih Solusi"
    }
    var titleForProofSubmission: String {
        if self.isProofAdded {
            return "Bukti & Keterangan Sudah Diunggah"
        } else {
            return "Upload Bukti & Keterangan"
        }
    }
//    MARK:- Mapping
    override init(){}
    init(json:[String:JSON]) {
        if let list = json["createInfo"]?.array {
            for item in list {
                let problemItem = RCProblemItem(json: item)
                self.createInfo.append(problemItem)
            }
        }
    }
}
