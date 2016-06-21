//
//  TrackOrderHistory.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrackOrderHistory : UIViewController

@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *city;

+ (RKObjectMapping *)mapping;

@end
