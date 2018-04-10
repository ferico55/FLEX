//
//  PaymentSaveCCViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 25/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final public class PaymentSaveCCViewModel: ViewModelType {
    
    public struct Input {
        public let trigger: Driver<Void>
        public let URLRequestTrigger: Driver<(request: URLRequest, navigationType: UIWebViewNavigationType)>
    }
    
    public struct Output {
        public let isFetching: Driver<Bool>
        public let urlRequest: Driver<URLRequest>
        public let isCallback: Driver<Bool>
    }
    
    private let navigator: PaymentSaveCCNavigator
    
    public init(navigator: PaymentSaveCCNavigator) {
        self.navigator = navigator
    }
    
    public func transform(input: Input) -> Output {
        
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        let ccRegiterIframeResponse = input.trigger.flatMapLatest {
            return PaymentUseCase.requestCCRegisterIframe()
                .trackActivity(activityIndicator)
                .trackError(errorTracker)
                .asDriverOnErrorJustComplete()
        }
        
        let url = ccRegiterIframeResponse.flatMapLatest { response -> SharedSequence<DriverSharingStrategy, URL> in
            guard let stringURL = response.data?.apiInfo?.host, let url = URL(string: stringURL) else {
                return Driver.empty()
            }
            return Driver.just(url)
        }
        
        let headers = ccRegiterIframeResponse.flatMapLatest { response -> SharedSequence<DriverSharingStrategy, Dictionary<String, String>> in
            guard let headers = response.data?.apiInfo?.headers else { return Driver.empty() }
            return Driver.just(headers)
        }
        
        let parameters = ccRegiterIframeResponse.flatMapLatest { response -> SharedSequence<DriverSharingStrategy, String> in
            guard let parameters = response.data?.ccIframeEncode else { return Driver.empty() }
            return Driver.just(parameters)
        }
        
        let method = ccRegiterIframeResponse.map { response -> String in
            guard let method = response.data?.apiInfo?.method else { return "POST" }
            return method
        }
        
        let urlRequest = Driver.combineLatest(url, headers, parameters, method)
            .flatMapLatest { url, headers, parameters, method -> SharedSequence<DriverSharingStrategy, URLRequest> in
                var urlRequest = URLRequest(url: url)
                for (key, value) in headers {
                    urlRequest.addValue(value, forHTTPHeaderField: key)
                }
                urlRequest.httpMethod = method
                urlRequest.httpBody = parameters.data(using: String.Encoding.utf8, allowLossyConversion: true)
                return Driver.just(urlRequest)
            }
        
        let callbackURL = ccRegiterIframeResponse.map { response -> String in
            return response.data?.ccIframe?.callbackUrl ?? ""
        }
        
        let isCallback = input.URLRequestTrigger.withLatestFrom(callbackURL) { urlRequest, callbackURL -> Bool in
            let (request, _) = urlRequest
            guard request.url?.absoluteString == callbackURL else { return false }
            return true
        }
        
        return Output(isFetching: activityIndicator.asDriver(),
                      urlRequest: urlRequest,
                      isCallback: isCallback)
    }
}
