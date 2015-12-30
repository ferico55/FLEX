//
//  RequestEditAddress.m
//  Tokopedia
//
//  Created by Renny Runiawati on 12/29/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "RequestEditAddress.h"
#import "RequestObject.h"
#import "ProfileSettings.h"

@implementation RequestEditAddress
{
    AddressFormList *_editedAddress;
    TokopediaNetworkManager *_networkManager;
}

-(TokopediaNetworkManager*)networkManager
{
    if (!_networkManager) {
        _networkManager = [TokopediaNetworkManager new];
        _networkManager.delegate = self;
        _networkManager.isUsingHmac = YES;
    }
    return _networkManager;
}

-(void)doRequestWithAddress:(AddressFormList *)address
{
    if (address) {
        _editedAddress = address;
        [[self networkManager] doRequest];
    }
}

- (NSDictionary*)getParameter:(int)tag
{
    return @{};
}

-(id)getRequestObject:(int)tag
{
    AddressFormList *list = _editedAddress;
    
    NSString *action = @"edit_address";
    NSString *addressid = [NSString stringWithFormat:@"%zd",list.address_id?:0];
    NSString *city = [NSString stringWithFormat:@"%zd",[list.city_id integerValue]?:0];
    NSString *province = [NSString stringWithFormat:@"%zd",[list.province_id integerValue]?:0];
    NSString *district = [NSString stringWithFormat:@"%zd",[list.district_id integerValue]?:0];
    
    NSString *longitude = list.longitude;
    NSString *latitude = list.latitude;
    
    RequestObjectEditAddress *editAddress = [RequestObjectEditAddress new];
    editAddress.action = action;
    editAddress.address_id = addressid;
    editAddress.city = city;
    editAddress.receiver_name = list.receiver_name?:@"";
    editAddress.address_name = list.address_name?:@"";
    editAddress.receiver_phone = list.receiver_phone?:@"";
    editAddress.province = province;
    editAddress.postal_code = list.postal_code?:@"";
    editAddress.address_street = list.address_street?:@"";
    editAddress.district = district;
    editAddress.longitude = longitude;
    editAddress.latitude = latitude;
    editAddress.is_from_cart = @"1";
    
    return editAddress;
}

-(int)getRequestMethod:(int)tag
{
    return RKRequestMethodPOST;
}

- (NSString *)getPath:(int)tag {
    return @"/web-service/v4/action/people/edit_address.pl";
}

- (id)getObjectManager:(int)tag
{
    RKObjectManager *objectManager = [TKPMappingManager objectManagerEditAddress];
    return objectManager;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    return ((ProfileSettings *) stat).status;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)successResult).dictionary;
    ProfileSettings *stat = [resultDict objectForKey:@""];
    if (stat.data.is_success != 1) {
        StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:stat.message_error?:@[@"Gagal mengubah lokasi"] delegate:_delegate];
        [alert show];
    }
    else [_delegate requestSuccessEditAddress:successResult withOperation:operation];
}

- (void)actionBeforeRequest:(int)tag
{
}

- (void)actionRequestAsync:(int)tag
{
}

- (void)actionAfterFailRequestMaxTries:(int)tag
{
}


@end
