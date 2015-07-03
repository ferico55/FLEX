//
//  RequestAddress.h
//  Tokopedia
//
//  Created by Renny Runiawati on 6/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RequestAddress;
#import "AddressObj.h"

@protocol RequestAddressDelegate <NSObject>
@required
- (void)successRequestAddress:(RequestAddress*)request withResultObj:(AddressObj*)addressObj;
- (void)failedRequestAddress:(NSArray*)errorMessages;

@end

@interface RequestAddress : NSObject

@property (nonatomic, weak) IBOutlet id<RequestAddressDelegate> delegate;

@property (nonatomic, strong) NSNumber *provinceID;
@property (nonatomic, strong) NSNumber *cityID;

@property NSInteger tag;

-(void)doRequestProvinces;
-(void)doRequestCities;
-(void)doRequestDistricts;

@end
