//
//  ShopInfoAddressCell.h
//  Tokopedia
//
//  Created by Renny Runiawati on 6/17/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopInfoAddressCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelname;
@property (weak, nonatomic) IBOutlet UILabel *labelDistric;
@property (weak, nonatomic) IBOutlet UILabel *labelcity;
@property (weak, nonatomic) IBOutlet UILabel *labelpostal;
@property (weak, nonatomic) IBOutlet UILabel *labelprov;

@property (weak, nonatomic) IBOutlet UILabel *labelemail;
@property (weak, nonatomic) IBOutlet UILabel *labelphone;
@property (weak, nonatomic) IBOutlet UILabel *labelfax;

@property (weak, nonatomic) IBOutlet UIView *borderView;

+ (id)newcell;

@end
