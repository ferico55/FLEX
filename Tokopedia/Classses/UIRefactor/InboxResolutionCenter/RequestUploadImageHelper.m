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
    }
    return _networkManager;
}


-(void)doRequest
{
    [[self networkManager] doRequest];
}

#pragma mark - Network Manager Delegate

-(void)setParamResolutionImageFromID:(NSString*)resolutionID
                    attachmentString:(NSString*)attachmentString
                            serverID:(NSString*)serverID
{
    NSDictionary *param = @{@"action"            :@"create_resolution_picture",
                            @"resolution_id"     :resolutionID?:@"",
                            @"attachment_string" :attachmentString?:@"",
                            @"server_id"         :serverID?:@""
                            };
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
    
}

-(void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{
    NSError *error = errorResult;
    NSArray *errors;
    
    if (error.code==-1009 || error.code==-999) {
        errors = @[@"Tidak ada koneksi internet"];
    } else {
        errors = @[@"Mohon maaf, terjadi kendala pada server"];
    }
    
    StickyAlertView *failedAlert = [[StickyAlertView alloc]initWithErrorMessages:errors?:@[@"Error"] delegate:_delegate];
    [failedAlert show];
}

-(void)actionAfterFailRequestMaxTries:(int)tag
{
    
}

-(RKObjectManager*)objectManager
{
    RKObjectManager *objectManager = [RKObjectManager sharedClient];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[UploadImageHelper mapping]
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:nil
                                                                                           keyPath:[self getPath:0]
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    return objectManager;
}

@end

