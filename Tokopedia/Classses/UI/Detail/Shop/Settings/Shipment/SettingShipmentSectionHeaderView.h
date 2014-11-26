//
//  SettingShipmentSectionHeaderView.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/18/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingShipmentSectionHeaderView : UIView
@property (weak, nonatomic) IBOutlet UILabel *labeltitle;
@property (weak, nonatomic) IBOutlet UIImageView *thumb;
@property (weak, nonatomic) IBOutlet UILabel *labelnotsupported;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

+ (id)newview;

@end
