//
//  ReactWalletHelper.h
//  Tokopedia
//
//  Created by Ferico Samuel on 18/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface ReactWalletHelper : NSObject<RCTBridgeModule>

@property (nonatomic, weak, readonly) RCTBridge *bridge;

@end
