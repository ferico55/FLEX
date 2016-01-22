//
//  AddressViewModel.h
//  Tokopedia
//
//  Created by Renny Runiawati on 12/22/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddressViewModel : NSObject

@property (strong, nonatomic) NSString *receiverNumber;
@property (strong, nonatomic) NSString *addressStreet;
@property (strong, nonatomic) NSString *addressPostalCode;
@property (strong, nonatomic) NSString *addressDistrict;
@property (strong, nonatomic) NSString *addressProvince;
@property (strong, nonatomic) NSString *addressCountry;
@property (strong, nonatomic) NSString *addressCity;
@property (strong, nonatomic) NSString *receiverName;
@property (strong, nonatomic) NSString *addressName;
@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;

@end
