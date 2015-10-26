//
//  RequestUploadImageSubmit.m
//  Tokopedia
//
//  Created by Renny Runiawati on 10/12/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "RequestUploadImageSubmit.h"
#import "UploadImageSubmit.h"

@interface RequestUploadImageSubmit()<TokopediaNetworkManagerDelegate>
{
    TokopediaNetworkManager *_networkManager;
    NSDictionary *_param;
    NSString *_path;
}

@end

@implementation RequestUploadImageSubmit

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
    UploadImageSubmit *reso = [((RKMappingResult *) result).dictionary objectForKey:@""];
    return reso.status;
}

-(void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag
{
    UploadImageSubmit *reso = [((RKMappingResult *) successResult).dictionary objectForKey:@""];
    
    if ([reso.result.is_success integerValue] == 1) {
        [_delegate successSubmitMessage:reso.message_status];
        return;
    }
    else
    {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:reso.message_error delegate:[self lastViewController]];
        [alert show];
        return;
    }
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
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[UploadImageSubmit mapping]
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:[self getPath:_tag]
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    return objectManager;
}

@end
