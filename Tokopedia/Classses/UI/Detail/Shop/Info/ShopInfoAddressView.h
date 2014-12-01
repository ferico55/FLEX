//
//  ShopInfoAddressView.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/7/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopInfoAddressView : UIView

@property (weak, nonatomic) IBOutlet UILabel *labelname;
@property (weak, nonatomic) IBOutlet UILabel *labelDistric;
@property (weak, nonatomic) IBOutlet UILabel *labelcity;
@property (weak, nonatomic) IBOutlet UILabel *labelpostal;
@property (weak, nonatomic) IBOutlet UILabel *labelprov;

@property (weak, nonatomic) IBOutlet UILabel *labelemail;
@property (weak, nonatomic) IBOutlet UILabel *labelphone;
@property (weak, nonatomic) IBOutlet UILabel *labelfax;

@property (weak, nonatomic) IBOutlet UIView *horizontalBorder;

+(id)newview;

@end
