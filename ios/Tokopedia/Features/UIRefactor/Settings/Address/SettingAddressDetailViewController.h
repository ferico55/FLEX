//
//  SettingAddressDetailViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingAddressDetailViewController : UIViewController

@property (nonatomic, strong) AddressFormList *address;
@property (nonatomic, strong) ShipmentKeroToken *keroToken;

- (void)getSuccessSetDefaultAddress:(void (^)(AddressFormList* address))onSuccess;
- (void)getSuccessDeleteAddress:(void (^)(AddressFormList* address))onSuccess;

@end
