//
//  RequestUploadImageHelper.m
//  Tokopedia
//
//  Created by Renny Runiawati on 10/12/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "RequestUploadImageHelper.h"
#import "UploadImageHelper.h"

@interface RequestUploadImageHelper()<TokopediaNetworkManagerDelegate>
{
    TokopediaNetworkManager *_networkManager;
    NSDictionary *_param;
}

@end

@implementation RequestUploadImageHelper

-(TokopediaNetworkManager*)networkManager
{
    if (!_networkManager) {
        _networkManager = [TokopediaNetworkManager new];
        _networkManager.delegate = self;
        _networkManager.isParameterNotEncrypted = YES;
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

-(NSDictionary *)getParameter:(int)tag
{
    return _param?:@{};
}

-(NSString *)getPath:(int)tag
{
    return @"action/upload-image-helper.pl";
}


-(id)getObjectManager:(int)tag
{
    return [self objectManager];
}

-(NSString *)getRequestStatus:(id)result withTag:(int)tag
{
    UploadImageHelper *reso = [((RKMappingResult *) result).dictionary objectForKey:@""];
    return reso.status;
}

-(void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag
{
    UploadImageHelper *reso = [((RKMappingResult *) successResult).dictionary objectForKey:@""];
    if (reso.result.file_uploaded && ![reso.result.file_uploaded isEqualToString:@""]) {
        [_delegate setFileUploaded:reso.result.file_uploaded];
    }
    else
    {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:reso.message_error?:@[@"Maaf, Permohonan Anda tidak dapat diproses saat ini. Mohon dicoba kembali."] delegate:[((UINavigationController*)((UITabBarController*)[[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentedViewController]).selectedViewController). viewControllers lastObject]];
        [alert show];
    }
}

-(void)actionAfterFailRequestMaxTries:(int)tag
{
    [_delegate actionAfterFailRequestMaxTries:_tag];
}

-(RKObjectManager*)objectManager
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@/ws",_upload_host];
    RKObjectManager *objectManager = [RKObjectManager sharedClient:urlString];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[UploadImageHelper mapping]
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:[self getPath:_tag]
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    return objectManager;
}

@end

