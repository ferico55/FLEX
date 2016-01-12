//
//  RequestAddAddress.m
//  Tokopedia
//
//  Created by Renny Runiawati on 12/29/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "RequestAddAddress.h"
#import "RequestObject.h"
#import "ProfileSettings.h"

@implementation RequestAddAddress
{
    AddressFormList *_addedAddress;
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
        _addedAddress = address;
        [[self networkManager] doRequest];
    }
}

- (NSDictionary*)getParameter:(int)tag
{
    AddressFormList *list = _addedAddress;

    NSString *action = @"edit_address";
    NSString *addressid = [NSString stringWithFormat:@"%zd",list.address_id?:0];
    NSString *city = [NSString stringWithFormat:@"%zd",[list.city_id integerValue]?:0];
    NSString *province = [NSString stringWithFormat:@"%zd",[list.province_id integerValue]?:0];
    NSString *district = [NSString stringWithFormat:@"%zd",[list.district_id integerValue]?:0];

    NSString *longitude = list.longitude;
    NSString *latitude = list.latitude;
    
    NSString *recievername = list.receiver_name?:@"";
    NSString *addressname = list.address_name?:@"";
    NSString *phone = list.receiver_phone?:@"";
    NSString *postalcode = list.postal_code?:@"";
    
    NSString *addressstreet = list.address_street?:@"";

    
    NSDictionary *param =@{@"action":action,
                           @"address_id" : addressid,
                           @"city" : city,
                           @"receiver_name" : recievername,
                           @"address_name" : addressname,
                           @"receiver_phone" : phone,
                           @"province" : province,
                           @"postal_code" : postalcode,
                           @"address_street" : addressstreet,
                           @"district" : district,
                           @"longitude": longitude,
                           @"latitude": latitude,
                           @"is_from_cart":@"1"
                           };
    
    return param;
}

//-(id)getRequestObject:(int)tag
//{
//    AddressFormList *list = _addedAddress;
//    
//    NSString *action = @"edit_address";
//    NSString *addressid = [NSString stringWithFormat:@"%zd",list.address_id?:0];
//    NSString *city = [NSString stringWithFormat:@"%zd",[list.city_id integerValue]?:0];
//    NSString *province = [NSString stringWithFormat:@"%zd",[list.province_id integerValue]?:0];
//    NSString *district = [NSString stringWithFormat:@"%zd",[list.district_id integerValue]?:0];
//    
//    NSString *longitude = list.longitude;
//    NSString *latitude = list.latitude;
//    
//    RequestObjectEditAddress *AddAddress = [RequestObjectEditAddress new];
//    AddAddress.action = action;
//    AddAddress.address_id = addressid;
//    AddAddress.city = city;
//    AddAddress.receiver_name = list.receiver_name?:@"";
//    AddAddress.address_name = list.address_name?:@"";
//    AddAddress.receiver_phone = list.receiver_phone?:@"";
//    AddAddress.province = province;
//    AddAddress.postal_code = list.postal_code?:@"";
//    AddAddress.address_street = list.address_street?:@"";
//    AddAddress.district = district;
//    AddAddress.longitude = longitude;
//    AddAddress.latitude = latitude;
//    AddAddress.is_from_cart = @"1";
//    
//    return AddAddress;
//}

-(int)getRequestMethod:(int)tag
{
    return RKRequestMethodGET;
}

- (NSString *)getPath:(int)tag {
    return @"/v4/action/people/add_address.pl";
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
        StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:stat.message_error?:@[@"Gagal menambah alamat"] delegate:_delegate];
        [alert show];
    }
    else{
        StickyAlertView *alert = [[StickyAlertView alloc]initWithSuccessMessages:stat.message_status?:@[@"Anda berhasil menambah alamat"] delegate:_delegate];
        [alert show];
        _addedAddress.address_id = [stat.data.address_id integerValue];
        [_delegate requestSuccessAddAddress:_addedAddress];
    }
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
