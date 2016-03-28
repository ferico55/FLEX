//
//  RequestResoInputAddress.m
//  Tokopedia
//
//  Created by IT Tkpd on 5/18/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "RequestResoInputAddress.h"
#import "string_inbox_resolution_center.h"
#import "InboxResolutionCenter.h"
#import "ResolutionAction.h"
#import "TokopediaNetworkManager.h"
#import "AddressFormList.h"

@interface RequestResoInputAddress()
<TokopediaNetworkManagerDelegate>

@end

@implementation RequestResoInputAddress
{
    TokopediaNetworkManager *_network;
    NSDictionary *_param;
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
    RKObjectManager *objectManager = [RKObjectManager sharedClient];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[ResolutionAction mapping]
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:API_PATH_ACTION_RESOLUTION_CENTER
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    
    return objectManager;
}

-(void)setParamInputAddress:(AddressFormList*)address resolutionID:(NSString*)resolutionID oldDataID:(NSString*)oldDataID isEditAddress:(BOOL)isEditAddress action:(NSString*)action
{
    NSMutableDictionary *param = [NSMutableDictionary new];
    [param addEntriesFromDictionary:@{@"action":action,
                            @"resolution_id":resolutionID?:@"",
                            @"address_name":address.address_name?:@"",
                            @"receiver_name":address.receiver_name?:@"",
                            @"receiver_phone":address.receiver_phone?:@"",
                            @"postal_code":address.postal_code?:@"",
                            @"province":address.province_id?:@"",
                            @"city":address.city_id?:@"",
                            @"district":address.district_id?:@"",
                            @"address_street":address.address_street?:@"",
                            @"address_id":@(address.address_id)?:@"",
                            @"address":@(address.address)?:@""
                                }];
    if (oldDataID && ![oldDataID isEqualToString:@""]) {
        [param setObject:oldDataID forKey:@"old_data_id"];
    }
    _param = [param mutableCopy];
}

-(NSDictionary *)getParameter:(int)tag
{
    return _param;
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
    
    NSString *errorMessage = @"Anda gagal mengubah alamat pengembalian barang. Silahkan coba kembali.";
    if ([_param[@"action"] isEqualToString:@"input_address_resolution"]) {
        errorMessage = @"Anda gagal menambahkan alamat pengembalian barang. Silahkan coba kembali.";
    }
    
    if (status) {
        if(resolution.message_error)
        {
            [_delegate failedAddress:_resolution errors:resolution.message_error];

        }
        if (resolution.result.is_success == 1) {
            NSString *successMessage = @"Anda berhasil mengubah alamat pengembalian barang.";
            if ([_param[@"action"] isEqualToString:@"input_address_resolution"]) {
                successMessage = @"Anda berhasil menambahkan alamat pengembalian barang.";
            }
            [_delegate successAddress:_resolution successStatus:@[successMessage]];
        }
        else
        {
            [_delegate failedAddress:_resolution errors:resolution.message_error?:@[errorMessage]];

        }
    }
    else
    {
        [_delegate failedAddress:_resolution errors:@[errorMessage]];
    }
}

-(void)actionAfterFailRequestMaxTries:(int)tag
{
    NSString *errorMessage = @"Anda gagal mengubah alamat pengembalian barang. Silahkan coba kembali.";
    if ([_param[@"action"] isEqualToString:@"input_address_resolution"]) {
        errorMessage = @"Anda gagal menambahkan alamat pengembalian barang. Silahkan coba kembali.";
    }
    [_delegate failedAddress:_resolution errors:@[errorMessage]];
}

@end
