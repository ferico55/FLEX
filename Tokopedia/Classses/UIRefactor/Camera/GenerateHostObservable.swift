//
//  GenerateHostObservable.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 9/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift

class GenerateHostObservable: NSObject {
    
    class func getGeneratedHost() -> Observable<GeneratedHost> {
        return Observable.create({ (observer) -> Disposable in
            
            let auth : UserAuthentificationManager = UserAuthentificationManager()
            let param : [String : String] = [
                "user_id"          : auth.getUserId(),
                "new_add"          : "1",
                "upload_version"   : "2"
            ]
            
            let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
            networkManager.isUsingHmac = true
            
            networkManager.requestWithBaseUrl(NSString.v4Url(),
                path: "/v4/action/generate-host/generate_host.pl",
                method: .GET,
                parameter: param,
                mapping: GenerateHost.mapping() ,
                onSuccess: { (mappingResult, operation) in
                    
                    let result : Dictionary = mappingResult.dictionary() as Dictionary
                    let response : GenerateHost = result[""] as! GenerateHost
                    
                    observer.onNext(response.data.generated_host)
                    observer.onCompleted()
                    
            }) { (error) in
                observer.onError(RequestError.networkError)
                StickyAlertView.showErrorMessage(["Error"])
            }
            
            return NopDisposable.instance
        })
    }

}
