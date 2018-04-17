//
//  ShakeTarget.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 21/03/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Moya
import UIKit

internal enum ShakeTarget {
    case verifyShake(url: URL?, isAudio: Bool)
}
extension ShakeTarget: TargetType {
    internal var baseURL: URL {
        return URL(string: NSString.bookingUrl())! 
    }
    internal var path:String {
        switch self {
        case .verifyShake(_, _):
            return "/trigger/v1/api/campaign/av/verify"
        }
    }
    internal var method: Moya.Method {
        switch self {
        case let .verifyShake(_, isAudio):
            if isAudio {
                return .post
            } else {
                return .post
            }
        }
    }
    internal var parameters: [String : Any]? {
        var screen = AnalyticsManager().dataLayer.get("screenName") as? String ?? ""
        screen = screen.replacingOccurrences(of: " ", with: "")
        switch self {
        case let .verifyShake(_, isAudio):
            if isAudio {
                return [:]
            } else {
                return ["is_audio":false,"source":screen]
            }
        }
    }
    internal var parameterEncoding: ParameterEncoding {
        switch self {
        case let .verifyShake(_, isAudio):
            if isAudio {
                return URLEncoding.queryString
            } else {
                return JSONEncoding.default
            }
        }
    }
    internal var task: Task {
        switch self {
        case let .verifyShake(url, isAudio):
            if isAudio {
                var dataList: [MultipartFormData] = []
                if let fileUrl = url, isAudio == true {
                    let multipartData = MultipartFormData(provider: .file(fileUrl), name: "tkp_file", fileName: "campaign.wav", mimeType:"audio/wav")
                    dataList.append(multipartData)
                }
                if let isAudioData = "\(isAudio)".data(using: .utf8) {
                    let multipartData = MultipartFormData(provider: .data(isAudioData), name: "is_audio")
                    dataList.append(multipartData)
                }
                return .upload(.multipart(dataList))
            } else {
                return .request
            }
        }
    }
    internal var sampleData: Data {
        return Data()
    }
}

