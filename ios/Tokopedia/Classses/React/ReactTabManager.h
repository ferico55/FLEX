//
//  ReactTabManager.h
//  Tokopedia
//
//  Created by Samuel Edwin on 5/8/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface ReactTabManager : RCTEventEmitter<RCTBridgeModule>

- (void)sendScrollToTopEvent;

@end
