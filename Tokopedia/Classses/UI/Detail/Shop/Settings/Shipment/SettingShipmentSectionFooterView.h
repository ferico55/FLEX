//
//  SettingShipmentSectionFooterView.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingShipmentSectionFooterViewDelegate <NSObject>
@required
-(void)SettingShipmentSectionFooterView:(UIView*)view;

@end

@interface SettingShipmentSectionFooterView : UIView

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<SettingShipmentSectionFooterViewDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<SettingShipmentSectionFooterViewDelegate> delegate;
#endif

@property (weak, nonatomic) IBOutlet UILabel *labelinfo;
@property (weak, nonatomic) IBOutlet UIView *viewinfo;
@property (weak, nonatomic) IBOutlet UISwitch *switchweightmin;
@property (weak, nonatomic) IBOutlet UILabel *labelweightmin;
@property (weak, nonatomic) IBOutlet UIStepper *stepperminweight;
@property (weak, nonatomic) IBOutlet UISwitch *switchfee;
@property (weak, nonatomic) IBOutlet UITextField *textfieldfee;

- (IBAction)switchoutsidecity:(id)sender;

+ (id)newview;

@end
