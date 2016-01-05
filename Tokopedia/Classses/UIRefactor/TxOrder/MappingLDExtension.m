//
//  MappingLDExtension.m
//  Tokopedia
//
//  Created by Renny Runiawati on 11/24/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "MappingLDExtension.h"
#import "LuckyDeal.h"

static RKObjectManager *_objectManager = nil;

@implementation MappingLDExtension

+(RKObjectManager*)objectManagerMemberExtendBaseURL:(NSString*)baseURL
{
    _objectManager = [RKObjectManager sharedClient:baseURL];
//    static dispatch_once_t oncePredicate;
//    dispatch_once(&oncePredicate, ^{
        RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[[LuckyDeal mapping] inverseMapping] objectClass:[LuckyDeal class] rootKeyPath:nil method:RKRequestMethodPOST];
        
        [_objectManager addRequestDescriptor:requestDescriptor];
//    });
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[LuckyDeal mapping] method:RKRequestMethodPOST pathPattern:nil keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    [_objectManager addResponseDescriptor:responseDescriptor];
    _objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
     return  _objectManager;
}

@end
