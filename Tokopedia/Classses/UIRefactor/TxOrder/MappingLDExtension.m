//
//  MappingLDExtension.m
//  Tokopedia
//
//  Created by Renny Runiawati on 11/24/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "MappingLDExtension.h"
#import "LuckyDeal.h"

@implementation MappingLDExtension

+(RKObjectManager*)objectManagerMemberExtendBaseURL:(NSString*)baseURL
{
    RKObjectManager *objectManager = [RKObjectManager sharedClient:baseURL];
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[[LuckyDeal mapping] inverseMapping] objectClass:[LuckyDeal class] rootKeyPath:nil method:RKRequestMethodPOST];
        
        [objectManager addRequestDescriptor:requestDescriptor];
    });
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[LuckyDeal mapping] method:RKRequestMethodPOST pathPattern:nil keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    return  objectManager;
}

@end
