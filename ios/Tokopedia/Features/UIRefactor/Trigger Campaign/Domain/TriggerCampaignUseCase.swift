//
//  TriggerCampaignTargetUseCase.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 31/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import Moya
import RxSwift

public class TriggerCampaignTargetUseCase {
    public class func requestQRTriggerCampaign(identifier: String) -> Observable<TriggerCampaignResponse> {
        return TriggerCampaignNetworkProvider()
            .request(.QRTriggerCampaign(identifier: identifier))
            .filterSuccessfulStatusAndRedirectCodes()
            .map(to: TriggerCampaignResponse.self)
    }
}
