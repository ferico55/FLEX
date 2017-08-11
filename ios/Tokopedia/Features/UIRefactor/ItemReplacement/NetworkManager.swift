//
//  NetworkLogger.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 4/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Moya
import enum Result.Result
import Alamofire

class DefaultAlamofireManager: Alamofire.SessionManager {
    static let sharedManager: DefaultAlamofireManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 15 // as seconds, you can set your request timeout
        configuration.timeoutIntervalForResource = 15 // as seconds, you can set your resource timeout
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return DefaultAlamofireManager(configuration: configuration)
    }()
}

final class NetworkPlugin: PluginType {
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let response):
            if response.statusCode != 200 {
                StickyAlertView.showErrorMessage(["Mohon maaf, terjadi kendala pada server kami. Mohon kirimkan screenshot halaman ini ke ios[dot]feedback@tokopedia[dot]com untuk kami investigasi lebih lanjut."])
            }
        case .failure( _):
            StickyAlertView.showErrorMessage(["Tidak ada koneksi internet"])
        }
    }
}
