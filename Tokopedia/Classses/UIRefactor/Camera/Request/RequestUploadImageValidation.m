//
//  RequestUploadImageValidation.m
//  Tokopedia
//
//  Created by Renny Runiawati on 10/12/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "RequestUploadImageValidation.h"

#import "RequestUploadImageHelper.h"
#import "UploadImageValidation.h"

@interface RequestUploadImageValidation()<TokopediaNetworkManagerDelegate>
{
    TokopediaNetworkManager *_networkManager;
    NSDictionary *_param;
    NSString *_path;
}

@end

@implementation RequestUploadImageValidation

-(TokopediaNetworkManager*)networkManager
{
    if (!_networkManager) {
        _networkManager = [TokopediaNetworkManager new];
        _networkManager.delegate = self;
    }
    return _networkManager;
}

-(void)doRequest
{
    [[self networkManager] doRequest];
}


#pragma mark - Network Manager Delegate

-(void)setParam:(NSDictionary *)param
{
    _param = param;
}

-(void)setPath:(NSString *)path
{
    _path = path;
}

-(NSDictionary *)getParameter:(int)tag
{
    return _param?:@{};
}

-(NSString *)getPath:(int)tag
{
    return _path?:@"";
}


-(id)getObjectManager:(int)tag
{
    return [self objectManager];
}

-(NSString *)getRequestStatus:(id)result withTag:(int)tag
{
    UploadImageValidation *reso = [((RKMappingResult *) result).dictionary objectForKey:@""];
    return reso.status;
}

-(void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag
{
    UploadImageValidation *reso = [((RKMappingResult *) successResult).dictionary objectForKey:@""];
    
    if (reso.message_error) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:reso.message_error delegate:[self lastViewController]];
        [alert show];
        return;
    }
    
    [_delegate setPostKey:reso.result.post_key];
}

-(UIViewController*)lastViewController
{
    UIViewController * lastVC = [((UINavigationController*)((UITabBarController*)[[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentedViewController]).selectedViewController). viewControllers lastObject];
    return lastVC;
}


-(void)actionAfterFailRequestMaxTries:(int)tag
{
    [_delegate actionAfterFailRequestMaxTries:_tag];
}

-(RKObjectManager*)objectManager
{
    RKObjectManager *objectManager = [RKObjectManager sharedClient];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[UploadImageValidation mapping]
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:[self getPath:_tag]
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    return objectManager;
}

@end
