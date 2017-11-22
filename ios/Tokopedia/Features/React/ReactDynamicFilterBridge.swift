//
//  ReactDynamicFilterBridge.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 11/13/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import NativeNavigation
import RxSwift
import RxCocoa
import NSObject_Rx

class ReactDynamicFilterBridge: NSObject {
    private var uniqueId = UUID().uuidString
    
    func openFilterScreen(
        from viewController: UIViewController,
        parameters: [String: AnyObject],
        onFilterSelected: (([Any]) -> Void)?) {
        let presented = ReactViewController(
            moduleName: "SearchFilterScreen",
            props: parameters.merged(with: ["uniqueId": uniqueId as NSString])
        )
        
        NotificationCenter.default.rx.notification(Notification.Name("ReactFilterSelected.\(presented.nativeNavigationInstanceId)"))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {notification in
                guard let filter = notification.userInfo?["filters"] as? [Any],
                    let onFilterSelected = onFilterSelected else { return }
                
                onFilterSelected(filter)
            })
            .disposed(by: presented.rx_disposeBag)
        
        viewController.presentReactViewController(presented, animated: true, completion: nil)
    }
    
    deinit {
        UIApplication.shared.reactBridge.dynamicFilter.purgeCache(uniqueId)
    }
}
