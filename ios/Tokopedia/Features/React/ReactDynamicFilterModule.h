//
//  ReactDynamicFilterModule.h
//  Tokopedia
//
//  Created by Samuel Edwin on 9/25/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTEventEmitter.h>

@interface ReactDynamicFilterModule : RCTEventEmitter

- (void)purgeCache:(NSString *)uniqueId;

@end

@interface RCTBridge(DynamicFilter)

@property(readonly) ReactDynamicFilterModule *dynamicFilter;

@end
