//
//  AddressFormList.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "AddressFormList.h"

@implementation AddressFormList

static NSString *noAddress = @"-1";

-(NSString *)postal_code{
    return _postal_code?:_address_postal;
}

-(NSString *)province_id{
    return _province_id?:_address_province_id;
}

-(NSString *)district_id{
    return _district_id?:_address_district_id;
}

-(NSString *)city_id{
    return _city_id?:_address_city_id;
}

- (NSString *)address_name {
    return [_address_name kv_decodeHTMLCharacterEntities];
}

- (NSString *)receiver_name {
    return [_receiver_name kv_decodeHTMLCharacterEntities];
}

- (NSString *)address_street {
    return [_address_street kv_decodeHTMLCharacterEntities];
}

-(NSString *)address_id{
    return ([_address_id integerValue]==0)?noAddress:_address_id;
}

- (AddressViewModel *)viewModel {
    if(_viewModel == nil) {
        AddressViewModel *tempViewModel = [AddressViewModel new];
        tempViewModel.receiverName = _receiver_name;
        tempViewModel.receiverNumber = _receiver_phone;
        tempViewModel.addressName = _address_name;
        tempViewModel.addressStreet = _address_street;
        tempViewModel.addressCity = _address_city?:_city_name;
        tempViewModel.addressDistrict = _address_district?:_district_name;
        tempViewModel.addressProvince = _address_province?:_province_name;
        tempViewModel.addressPostalCode = _address_postal?:_postal_code;
        tempViewModel.addressCountry = _address_country?:_country_name;
        tempViewModel.latitude = _latitude;
        tempViewModel.longitude = _longitude;
        _viewModel = tempViewModel;
    }
    
    return _viewModel;
}

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"country_name",
                      @"receiver_name",
                      @"address_name",
                      @"address_id",
                      @"receiver_phone",
                      @"province_name",
                      @"postal_code",
                      @"address_status",
                      @"address_street",
                      @"district_name",
                      @"province_id",
                      @"city_id",
                      @"district_id",
                      @"city_name",
                      @"address_country",
                      @"address_postal",
                      @"address_district",
                      @"address_city",
                      @"address_province",
                      @"addr_id",
                      @"addr_name",
                      @"longitude",
                      @"latitude",
                      @"address_district_id",
                      @"address_province_id",
                      @"address_city_id"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}
@end
