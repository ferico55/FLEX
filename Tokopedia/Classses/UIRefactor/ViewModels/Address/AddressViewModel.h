//
//  AddressViewModel.h
//  Tokopedia
//
//  Created by Renny Runiawati on 12/22/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddressViewModel : NSObject

@property (strong, nonatomic, nonnull) NSString *receiverNumber;
@property (strong, nonatomic, nonnull) NSString *addressStreet;
@property (strong, nonatomic, nonnull) NSString *addressPostalCode;
@property (strong, nonatomic, nonnull) NSString *addressDistrict;
@property (strong, nonatomic, nonnull) NSString *addressProvince;
@property (strong, nonatomic, nonnull) NSString *addressCountry;
@property (strong, nonatomic, nonnull) NSString *addressCity;
@property (strong, nonatomic, nonnull) NSString *receiverName;
@property (strong, nonatomic, nonnull) NSString *addressName;
@property (strong, nonatomic, nonnull) NSString *latitude;
@property (strong, nonatomic, nonnull) NSString *longitude;

@end
