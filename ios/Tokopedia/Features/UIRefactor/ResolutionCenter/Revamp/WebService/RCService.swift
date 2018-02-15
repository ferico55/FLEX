//
//  RCService.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 16/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Moya
import UIKit

internal enum RCService {
    case getStep1(orderId: String)
    case getSolutions(orderId: String, rcStep1Data: RCCreateStep1ResponseData)
    case cacheKeyToCreateComplaint(orderId: String, rcStep1Data: RCCreateStep1ResponseData)
    case createComplaint(orderId: String, cacheKey: String, imageObjects: [ImageResult])
    case getInboxBuyer(limit: String, startId: String, sortBy: String, asc: String, filter: String, startTime: String, endTime: String)
    case getInboxSeller(limit: String, startId: String, sortBy: String, asc: String, filter: String, startTime: String, endTime: String)
}

extension RCService: TargetType {
    internal var parameterEncoding: ParameterEncoding {
        switch self {
        case .getInboxBuyer, .getInboxSeller:
            return URLEncoding.queryString
        default:
            return JSONEncoding.default
        }
    }    
    internal var parameters: [String : Any]? {
        switch self {
        case .getStep1:
            return [:]
        case .getSolutions(_,let rcStep1Data):
            return self.bodyJsonForSolutions(rcStep1Data: rcStep1Data)
        case .cacheKeyToCreateComplaint(_,let rcStep1Data):
            return self.bodyJsonForCacheKeyToCreateComplaint(rcStep1Data: rcStep1Data)
        case let .createComplaint(_, cache, imageObjects):
            return self.bodyJsonToCreateComplaint(cacheKey: cache, images: imageObjects)
        case let .getInboxBuyer(limit, startId, sortBy, asc, filter, startTime, endTime):
            return [
                "limit": limit,
                "startID": startId,
                "sortBy": sortBy,
                "asc": asc,
                "filter": filter,
                "startTime": startTime,
                "endTime": endTime
            ]
        case let .getInboxSeller(limit, startId, sortBy, asc, filter, startTime, endTime):
            return [
                "limit": limit,
                "startID": startId,
                "sortBy": sortBy,
                "asc": asc,
                "filter": filter,
                "startTime": startTime,
                "endTime": endTime
            ]
        }
    }
    internal var baseURL: URL {
        return URL(string: NSString.tokopediaUrl())!
    }
    internal var path: String {
        switch self {
        case let .getStep1(orderId):
            return "/resolution/v2/create/" + orderId + "/step1"
        case let .getSolutions(orderId,_):
                return "/resolution/v2/create/" + orderId + "/step2_3"
        case let .cacheKeyToCreateComplaint(orderId,_):
            return "/resolution/v2/create/" + orderId
        case let .createComplaint(orderId,_,_):
            return "/resolution/v2/create/" + orderId
        case .getInboxBuyer:
            return "resolution/v2/inbox/buyer"
        case .getInboxSeller:
            return "resolution/v2/inbox/seller"
        }
    }
    internal var method: Moya.Method {
        switch self {
        case .getStep1, .getInboxBuyer, .getInboxSeller:
            return .get
        case .getSolutions, .cacheKeyToCreateComplaint, .createComplaint:
            return .post
        }
    }
    internal var task: Task {
        switch self {
        case .getStep1, .getSolutions, .cacheKeyToCreateComplaint, .createComplaint, .getInboxBuyer, .getInboxSeller:
            return .request
        }
    }
    internal var headers: [String : String] {
        return [:]
    }
    internal var sampleData: Data { return "{ \"data\": 123 }".data(using: .utf8)! }
//    MARK:- Helpers
    internal func bodyJsonToCreateComplaint(cacheKey: String, images: [ImageResult])->[String:Any] {
        let imageList = images.filter(){!$0.isVideo}
        let videoList = images.filter(){$0.isVideo}
        let list1: [String] = imageList.map {$0.pic_obj}
        let list2: [String] = videoList.map {$0.pic_obj}
        var body: [String:Any] = ["pictures":list1]
        body["videos"] = list2
        body["cacheKey"] = cacheKey
        return body
    }
    internal func bodyJsonForCacheKeyToCreateComplaint(rcStep1Data: RCCreateStep1ResponseData)->[String:Any] {
        let selectedProblems = rcStep1Data.selectedProblemItem
        var list: [[String:Any]] = []
        for item in selectedProblems {
            var temp:[String:Any] = [:]
            temp["type"] = item.problem.type
            temp["trouble"] = item.selectedStatus?.selectedTrouble?.id ?? 0
            if item.order != nil {
                temp["quantity"] = item.goodsCount
                temp["order"] = ["detail": ["id": item.order?.detail.id]]
                temp["remark"] = item.remark ?? ""
            }
            list.append(temp)
        }
        var body: [String:Any] = ["problem":list]
        body["solution"] = rcStep1Data.solutionData?.selectedSolution?.id
        if rcStep1Data.isProofSubmissionRequired {
            if let photos = rcStep1Data.selectedPhotos {
                body["attachmentCount"] = photos.count
            }
            let remark = ["remark":rcStep1Data.attchmentMessage]
            body["message"] = remark
        }
        if let expected = rcStep1Data.solutionData?.selectedSolution?.returnExpected {
            body["refundAmount"] = expected
        }
        return body
    }
    internal func bodyJsonForSolutions(rcStep1Data: RCCreateStep1ResponseData)->[String:Any] {
        let selectedProblems = rcStep1Data.selectedProblemItem
        var list: [[String:Any]] = []
        for item in selectedProblems {
            var temp:[String:Any] = [:]
            temp["type"] = item.problem.type
            temp["trouble"] = item.selectedStatus?.selectedTrouble?.id ?? 0
            if item.order != nil {
                temp["quantity"] = item.goodsCount
                temp["order"] = ["detail": ["id": item.order?.detail.id]]
            }
            list.append(temp)
        }
        return ["problem":list]
    }
}
