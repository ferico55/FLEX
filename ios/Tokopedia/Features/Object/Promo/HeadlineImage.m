//
//  HeadlineImage.m
//  Tokopedia
//
//  Created by Billion Goenawan on 29/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "HeadlineImage.h"

@implementation HeadlineImage

+(RKObjectMapping *)mapping{
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[HeadlineImage class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"full_url":@"fullUrl"}];
    return resultMapping;
}

@end
