//
//  TKPGoogleDistanceMatrixProductStore.h
//  Tokopedia
//
//  Created by Renny Runiawati on 11/2/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoogleDistanceMatrix.h"

@interface TKPGoogleDistanceMatrixProductStore : NSObject

- (instancetype)initWithStoreManager:(TKPStoreManager *)storeManager;

//- (void)fetchPlaceDetail:(NSString*)placeID
//                 success:(void (^)(NSString *placeID, GoogleDistanceMatrix*placeDetail))success
//                 failure:(void(^)(NSString *placeID, NSError *error))failure;

@property (weak, nonatomic) TKPStoreManager *storeManager;

@end
