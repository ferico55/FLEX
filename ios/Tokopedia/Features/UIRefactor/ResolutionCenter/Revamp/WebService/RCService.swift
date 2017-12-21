//
//  RCService.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 16/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Moya

enum RCService {
    case getStep1(orderId: String)
    case getSolutions(orderId: String, rcStep1Data: RCCreateStep1ResponseData)
    case cacheKeyToCreateComplaint(orderId: String, rcStep1Data: RCCreateStep1ResponseData)
    case createComplaint(orderId: String, cacheKey: String, imageObjects: [ImageResult])
}

extension RCService: TargetType {
    var parameterEncoding: ParameterEncoding {
        return JSONEncoding.default
    }    
    var parameters: [String : Any]? {
        switch self {
        case .getStep1:
            return [:]
        case .getSolutions(_,let rcStep1Data):
            return self.bodyJsonForSolutions(rcStep1Data: rcStep1Data)
        case .cacheKeyToCreateComplaint(_,let rcStep1Data):
            return self.bodyJsonForCacheKeyToCreateComplaint(rcStep1Data: rcStep1Data)
        case .createComplaint(_,let cache, let imageObjects):
            return self.bodyJsonToCreateComplaint(cacheKey: cache, images: imageObjects)
        }
    }
    var baseURL: URL {
        return URL(string: NSString.tokopediaUrl())!
    }
    var path: String {
        switch self {
        case let .getStep1(orderId):
            return "/resolution/v2/create/" + orderId + "/step1"
        case let .getSolutions(orderId,_):
                return "/resolution/v2/create/" + orderId + "/step2_3"
        case let .cacheKeyToCreateComplaint(orderId,_):
            return "/resolution/v2/create/" + orderId
        case let .createComplaint(orderId,_,_):
            return "/resolution/v2/create/" + orderId
        }
    }
    var method: Moya.Method {
        switch self {
        case .getStep1:
            return .get
        case .getSolutions, .cacheKeyToCreateComplaint, .createComplaint:
            return .post
        }
    }
    var task: Task {
        switch self {
        case .getStep1, .getSolutions, .cacheKeyToCreateComplaint, .createComplaint:
            return .request
        }
    }
    var headers: [String : String] {
        return [:]
    }
    var sampleData: Data { return "{ \"data\": 123 }".data(using: .utf8)! }
//    MARK:- Helpers
    func bodyJsonToCreateComplaint(cacheKey: String, images: [ImageResult])->[String:Any] {
        let list: [String] = images.map { (item) in
            item.pic_obj
        }
        var body: [String:Any] = ["pictures":list]
        body["cacheKey"] = cacheKey
        return body
    }
    func bodyJsonForCacheKeyToCreateComplaint(rcStep1Data: RCCreateStep1ResponseData)->[String:Any] {
        let selectedProblems = rcStep1Data.selectedProblemItem
        let list: [[String:Any]] = selectedProblems.map { (item) in
            [
                "type": item.problem.type,
                "trouble": item.selectedStatus?.selectedTrouble?.id ?? 0,
                "quantity": item.goodsCount,
                "order": ["detail": ["id": item.order.detail.id]],
                "remark": item.remark ?? ""
            ]
        }
        var body: [String:Any] = ["problem":list]
        body["solution"] = rcStep1Data.solutionData?.selectedSolution?.id
        if let solutionData = rcStep1Data.solutionData  {
            if solutionData.require.attachment {
                if let photos = rcStep1Data.selectedPhotos {
                    body["attachmentCount"] = photos.count
                }
                let remark = ["remark":rcStep1Data.attchmentMessage]
                body["message"] = remark
            }
        }
        if let expected = rcStep1Data.solutionData?.selectedSolution?.returnExpected {
            body["refundAmount"] = expected
        }
        debugPrint(body)
        return body
    }
    func bodyJsonForSolutions(rcStep1Data: RCCreateStep1ResponseData)->[String:Any] {
        let selectedProblems = rcStep1Data.selectedProblemItem
        let list: [[String:Any]] = selectedProblems.map { (item) in
            [
                "type": item.problem.type,
                "trouble": item.selectedStatus?.selectedTrouble?.id ?? 0,
                "quantity": item.goodsCount,
                "order": ["detail": ["id": item.order.detail.id]]
            ]
        }
        debugPrint(["problem":list])
        return ["problem":list]
    }
}
