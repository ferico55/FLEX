//
//  ProductLabel.m
//  Tokopedia
//
//  Created by Tonito Acen on 10/24/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ProductLabel.h"

@implementation ProductLabel
+(RKObjectMapping *)mapping{
    RKObjectMapping *labelMapping = [RKObjectMapping mappingForClass:[ProductLabel class]];
    [labelMapping addAttributeMappingsFromArray:@[@"title", @"color"]];
    return labelMapping;
}

- (NSString*)title {
    return _title ?:@"";
}

@end
