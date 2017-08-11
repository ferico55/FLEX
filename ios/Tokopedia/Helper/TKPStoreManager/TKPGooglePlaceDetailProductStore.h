//
//  TKPGooglePlaceDetailProductStore.h
//  Tokopedia
//
//  Created by Renny Runiawati on 10/30/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TKPStoreManager;
@class GooglePlacesDetail;
@class GoogleDistanceMatrix;

@interface TKPGooglePlaceDetailProductStore : NSObject

- (instancetype)initWithStoreManager:(TKPStoreManager *)storeManager;

- (void)fetchPlaceDetail:(NSString*)placeID
                 success:(void (^)(NSString *placeID, GooglePlacesDetail*placeDetail))success
                 failure:(void(^)(NSString *placeID, NSError *error))failure;

-(void)fetchGeocodeAddress:(NSString *)address
                   success:(void (^)(NSString *address, GooglePlacesDetail *placeDetail))success
                   failure:(void (^)(NSString *address, NSError *error))failure;

-(void)fetchDistanceFromOrigin:(NSString *)origin
                 toDestination:(NSString*)destination
                       success:(void (^)(NSString *origin, NSString *destination, GoogleDistanceMatrix *dinstanceMatrix))success
                       failure:(void (^)(NSString *origin, NSString *destination, NSError *error))failure;

@property (weak, nonatomic) TKPStoreManager *storeManager;

@end
