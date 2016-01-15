//
//  TKPGooglePlaceDetailProductStore.m
//  Tokopedia
//
//  Created by Renny Runiawati on 10/30/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "TKPGooglePlaceDetailProductStore.h"
#import "GooglePlacesDetail.h"
#import "GoogleDistanceMatrix.h"
#import "TKPStoreManager.h"

@implementation TKPGooglePlaceDetailProductStore

- (instancetype)initWithStoreManager:(TKPStoreManager *)storeManager {
    self = [super init];
    if (self != nil) {
        _storeManager = storeManager;
    }
    
    return self;
}

-(void)fetchPlaceDetail:(NSString *)placeID success:(void (^)(NSString *, GooglePlacesDetail *))success failure:(void (^)(NSString *, NSError *))failure
{
    RKObjectManager *objectManager = [RKObjectManager sharedClient:@"https://maps.googleapis.com"];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[GooglePlacesDetail mapping]
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:nil
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    NSDictionary *parameters = @{@"placeid" : placeID,
                                 @"key":@"AIzaSyActrtB1TbqJ-KCzRdkZoEBoGj-kr9AOU0"};
    RKObjectRequestOperation *operation = [objectManager appropriateObjectRequestOperationWithObject:nil method:RKRequestMethodGET path:@"maps/api/place/details/json" parameters:parameters];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSDictionary *result = [mappingResult dictionary];
        GooglePlacesDetail *placeDetail = result[@""];
        if (mappingResult != nil) {
            success(placeID, placeDetail);
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(placeID, error);
    }];
    
    [self.storeManager.networkQueue addOperation:operation];
}

-(void)fetchGeocodeAddress:(NSString *)address success:(void (^)(NSString *, GooglePlacesDetail *))success failure:(void (^)(NSString *, NSError *))failure
{
    RKObjectManager *objectManager = [RKObjectManager sharedClient:@"https://maps.googleapis.com"];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[GooglePlacesDetail mapping]
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:nil
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    NSDictionary *parameters = @{@"address" : address,
                                 @"sensor":@"true"};
    
    RKObjectRequestOperation *operation = [objectManager appropriateObjectRequestOperationWithObject:nil method:RKRequestMethodGET path:@"maps/api/geocode/json" parameters:parameters];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSDictionary *result = [mappingResult dictionary];
        GooglePlacesDetail *placeDetail = result[@""];
        placeDetail.result = placeDetail.results[0];
        if (mappingResult != nil) {
            success(address, placeDetail);
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(address, error);
    }];
    
    [self.storeManager.networkQueue addOperation:operation];
}

-(void)fetchDistanceFromOrigin:(NSString *)origin toDestination:(NSString *)destination success:(void (^)(NSString *, NSString *, GoogleDistanceMatrix *))success failure:(void (^)(NSString *, NSString *, NSError *))failure
{
    RKObjectManager *objectManager = [RKObjectManager sharedClient:@"https://maps.googleapis.com"];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[GoogleDistanceMatrix mapping]
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:nil
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    /**
     list mode          : https://developers.google.com/maps/documentation/distance-matrix/intro#travel_modes
     list restrictions  : https://developers.google.com/maps/documentation/distance-matrix/intro#Restrictions
     list language      : https://developers.google.com/maps/faq#languagesupport
     list unit system   : https://developers.google.com/maps/documentation/distance-matrix/intro#unit_systems
     **/
    
    NSDictionary *parameters = @{@"origins"     : origin,
                                 @"destinations": destination,
                                 @"mode"        : @"driving",
                                 @"avoid"       : @"tolls",
                                 @"language"    : @"id",
                                 @"units"       : @"metric"};

    RKObjectRequestOperation *operation = [objectManager appropriateObjectRequestOperationWithObject:nil method:RKRequestMethodGET path:@"maps/api/distancematrix/json" parameters:parameters];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSDictionary *result = [mappingResult dictionary];
        GoogleDistanceMatrix *placeDistance = result[@""];
        if (mappingResult != nil) {
            success(origin,destination, placeDistance);
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(origin, destination, error);
    }];
    
    [self.storeManager.networkQueue addOperation:operation];
}

@end
