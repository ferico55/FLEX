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
#import "ImageResult.h"
#import "UploadImage.h"

@implementation TKPMappingManager

static RKObjectManager *_objectManager;


+ (RKObjectManager*)objectManagerGetAddress
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

+ (RKObjectManager*)objectManagerEditAddress
{
    _objectManager = [RKObjectManager sharedClientHttps];
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{

        RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[[RequestObjectEditAddress mapping] inverseMapping] objectClass:[RequestObjectEditAddress class] rootKeyPath:nil method:RKRequestMethodGET];
        
        [_objectManager addRequestDescriptor:requestDescriptor];
    });
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[ProfileSettings mapping]
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:nil
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    return _objectManager;
}

+ (RKObjectManager *)objectManagerUploadImageWithBaseURL:(NSString*)baseURL
                                             pathPattern:(NSString*)pathPattern {
    _objectManager = [RKObjectManager sharedClient:baseURL];
    //TODO: pake oncePredicate
//    dispatch_once(&oncePredicate, ^{
        RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[[RequestObjectUploadImage mapping] inverseMapping]
                                                                                       objectClass:[RequestObjectUploadImage class]
                                                                                       rootKeyPath:nil
                                                                                            method:RKRequestMethodPOST];
        
        [_objectManager addRequestDescriptor:requestDescriptor];
//    });
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[ImageResult mapping]
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:pathPattern
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    RKResponseDescriptor *responseStatusDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[UploadImage mapping]
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:pathPattern
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptor];
    [_objectManager addResponseDescriptor:responseStatusDescriptor];
    
    return _objectManager;
}

+ (RKObjectManager *)resolutionObjectManagerWithBaseURL:(NSString*)baseURL
                                            pathPattern:(NSString*)pathPattern {
    RKObjectManager* objectManager = [RKObjectManager sharedClient:baseURL];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[[RequestObjectUploadImage mapping] inverseMapping]
                                                                                   objectClass:[RequestObjectUploadImage class]
                                                                                   rootKeyPath:nil
                                                                                        method:RKRequestMethodPOST];
    
    [objectManager addRequestDescriptor:requestDescriptor];
    
    
    RKResponseDescriptor *responseStatusDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[ImageResult mapping]
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:pathPattern
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManager addResponseDescriptor:responseStatusDescriptor];
    
    return objectManager;
}



@end
