//
//  RequestCancelResolution.m
//  Tokopedia
//
//  Created by IT Tkpd on 5/18/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "RequestCancelResolution.h"
#import "string_inbox_resolution_center.h"
#import "InboxResolutionCenter.h"
#import "ResolutionAction.h"
#import "TokopediaNetworkManager.h"

@interface RequestCancelResolution()
<TokopediaNetworkManagerDelegate>

@end

@implementation RequestCancelResolution
{
    TokopediaNetworkManager *_network;
}

#pragma mark - Request
-(void)doRequest
{
    _network = [self network];
    [_network doRequest];
}

-(TokopediaNetworkManager *)network
{
    if (!_network) {
        _network = [TokopediaNetworkManager new];
        _network.delegate = self;
    }
    
    return _network;
}

-(id)getObjectManager:(int)tag
{
    return [self objectManagerCancelComplain];
}


-(NSDictionary *)getParameter:(int)tag
{
        NSDictionary* param = @{API_ACTION_KEY : ACTION_CANCEL_RESOLUTION,
                                API_RESOLUTION_ID_KEY : @(_resolutionID)?:@""
                                };
        return param;
}

-(NSString *)getPath:(int)tag
{
    return API_PATH_ACTION_RESOLUTION_CENTER;
}

-(NSString *)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    ResolutionAction *resolution = stat;
    return resolution.status;
}

-(void)actionBeforeRequest:(int)tag
{

}

-(void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag
{
    [self requestSuccessCancelComplain:successResult withOperation:operation];
}

-(void)requestSuccessCancelComplain:(id)successResult withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
    id stat = [result objectForKey:@""];
    ResolutionAction *resolution = stat;
    BOOL status = [resolution.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if(resolution.message_error)
        {
            [_delegate failedCancelComplain:_resolution errors:resolution.message_error];

        }
        if (resolution.result.is_success == 1) {
            [_delegate successCancelComplain:_resolution successStatus:@[@"Anda telah berhasil membatalkan komplain."]];
        }
        else
        {
            [_delegate failedCancelComplain:_resolution errors:resolution.message_error?:@[@"Anda gagal membatalkan komplain. Silahkan coba kembali"]];

        }
    }
    else
    {
        [_delegate failedCancelComplain:_resolution errors:@[@"Anda gagal membatalkan komplain. Silahkan coba kembali"]];
    }
}

-(void)actionAfterFailRequestMaxTries:(int)tag
{
    [_delegate failedCancelComplain:_resolution errors:@[@"Anda gagal membatalkan komplain. Silahkan coba kembali"]];
}

#pragma mark - Object Manager

-(RKObjectManager*)objectManagerCancelComplain
//-(void)configureRestKitCancelComplain
{
    RKObjectManager *objectManagerCancelComplain = [RKObjectManager sharedClient];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[ResolutionAction mapping]
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:API_PATH_ACTION_RESOLUTION_CENTER
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManagerCancelComplain addResponseDescriptor:responseDescriptor];
    
    return objectManagerCancelComplain;
}


@end
