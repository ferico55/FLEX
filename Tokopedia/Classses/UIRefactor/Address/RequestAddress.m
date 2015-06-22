//
//  RequestAddress.m
//  Tokopedia
//
//  Created by Renny Runiawati on 6/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "RequestAddress.h"
#import "TokopediaNetworkManager.h"
#import "AddressObj.h"

#define TagRequestGetCity 11
#define TagRequestGetDistrict 12

@interface RequestAddress ()<TokopediaNetworkManagerDelegate>

@end

@implementation RequestAddress
{
    TokopediaNetworkManager *_cityNetworkManager;
    TokopediaNetworkManager *_districtNetworkManager;
    
    AddressObj *_address;
}

-(TokopediaNetworkManager*)cityNetworkManager
{
    if (!_cityNetworkManager) {
        _cityNetworkManager = [TokopediaNetworkManager new];
        _cityNetworkManager.delegate = self;
        _cityNetworkManager.tagRequest = TagRequestGetCity;
    }
    return _cityNetworkManager;
}

-(TokopediaNetworkManager*)districtNetworkManager
{
    if (!_districtNetworkManager) {
        _districtNetworkManager = [TokopediaNetworkManager new];
        _districtNetworkManager.delegate = self;
        _districtNetworkManager.tagRequest = TagRequestGetDistrict;
    }
    
    return _districtNetworkManager;
}

#pragma mark - Network Manager Delegate
-(NSDictionary *)getParameter:(int)tag
{
    NSDictionary *param =@{};
    if (tag == TagRequestGetCity) {
        param = @{ @"action" : @"get_city",
                   @"province_id" : _provinceID
                 };
    }

    if (tag == TagRequestGetDistrict) {
        param = @{ @"action" : @"get_district",
                   @"city_id" : _cityID
                   };
    }
    
    return param;
}

-(id)getObjectManager:(int)tag
{
    RKObjectManager *objecManager = [RKObjectManager sharedClient];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[AddressObj class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[AddressResult class]];
    
    RKObjectMapping *citiesMapping = [RKObjectMapping mappingForClass:[AddressCity class]];
    [citiesMapping addAttributeMappingsFromArray:@[@"city_id",
                                                 @"city_name"
                                                 ]
     ];
    
    RKObjectMapping *districtsMapping = [RKObjectMapping mappingForClass:[AddressCity class]];
    [districtsMapping addAttributeMappingsFromArray:@[@"district_id",
                                                      @"district_name"
                                                      ]
     ];
    
    // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    RKRelationshipMapping *cityRelMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"cities"
                                                                                        toKeyPath:@"cities"
                                                                                      withMapping:citiesMapping];
    [resultMapping addPropertyMapping:cityRelMapping];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    RKRelationshipMapping *districtRelMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"districts"
                                                                                        toKeyPath:@"districts"
                                                                                      withMapping:districtsMapping];
    [resultMapping addPropertyMapping:districtRelMapping];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:@"ws/address.pl"
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objecManager addResponseDescriptor:responseDescriptor];
    
    return objecManager;
}

-(NSString *)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id info = [resultDict objectForKey:@""];
    _address = info;
    
    return _address.status;
}

-(NSString *)getPath:(int)tag
{
    return @"ws/address.pl";
}

@end
