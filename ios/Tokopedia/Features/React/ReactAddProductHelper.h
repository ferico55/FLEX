//
//  ReactAddProductHelper.h
//  Tokopedia
//
//  Created by Ferico Samuel on 01/03/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface ReactAddProductHelper : NSObject<RCTBridgeModule>

@property (nonatomic, weak, readonly) RCTBridge *bridge;

@end
