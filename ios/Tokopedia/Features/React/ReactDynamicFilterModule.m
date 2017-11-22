//
//  ReactDynamicFilterModule.m
//  Tokopedia
//
//  Created by Samuel Edwin on 9/25/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "ReactDynamicFilterModule.h"
#import "Tokopedia-Swift.h"

@implementation ReactDynamicFilterModule {
    NSMutableDictionary *filterBlockCallbackById;
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(setFilters:(NSArray *)filters navigationId:(NSString *)navigationId ) {
    NSArray<ListOption *> *options = [filters bk_map:^ListOption *(NSDictionary *dict) {
        NSString *key = dict[@"key"];
        NSString *value = dict[@"value"];
        
        ListOption *option = [ListOption new];
        option.key = key;
        option.value = value;
        
        return option;
    }];
    
    [NSNotificationCenter.defaultCenter postNotificationName:[NSString stringWithFormat:@"ReactFilterSelected.%@", navigationId]
                                                      object:nil
                                                    userInfo:@{@"filters": options}];
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"purgeCache"];
}

- (void)purgeCache:(NSString *)uniqueId {
    [self sendEventWithName:@"purgeCache" body:uniqueId];
}

@end

@implementation RCTBridge(DynamicFilter)

- (ReactDynamicFilterModule *)dynamicFilter {
    return [self moduleForClass:[ReactDynamicFilterModule class]];
}

@end
