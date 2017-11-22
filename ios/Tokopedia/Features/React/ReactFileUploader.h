//
//  ReactFileUploader.h
//  Tokopedia
//
//  Created by Ferico Samuel on 9/25/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface ReactFileUploader : NSObject<RCTBridgeModule>

@property (nonatomic, weak, readonly) RCTBridge *bridge;

@end
