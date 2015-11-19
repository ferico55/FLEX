//
//  TKPMappingManager.m
//  Tokopedia
//
//  Created by Renny Runiawati on 11/19/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "TKPMappingManager.h"
#import "AddressForm.h"
#import "RequestObject.h"
#import "ProfileSettings.h"

@implementation TKPMappingManager

static RKObjectManager *_objectManager;


+(RKObjectManager*)objectManagerGetAddress
{
    _objectManager = [RKObjectManager sharedClientHttps];
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[[RequestObjectGetAddress mapping] inverseMapping] objectClass:[RequestObjectGetAddress class] rootKeyPath:nil method:RKRequestMethodPOST];
        
        [_objectManager addRequestDescriptor:requestDescriptor];
    });
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[AddressForm mapping] method:RKRequestMethodPOST pathPattern:nil keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    return  _objectManager;
}

+(RKObjectManager*)objectManagerEditAddress
{
    _objectManager = [RKObjectManager sharedClientHttps];
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{

        RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[[RequestObjectEditAddress mapping] inverseMapping] objectClass:[RequestObjectEditAddress class] rootKeyPath:nil method:RKRequestMethodPOST];
        
        [_objectManager addRequestDescriptor:requestDescriptor];
    });
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[ProfileSettings mapping]
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:nil
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    return _objectManager;
}


@end
