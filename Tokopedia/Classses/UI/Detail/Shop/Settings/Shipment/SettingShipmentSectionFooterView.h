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
-(void)MoveToInfoView:(UIView*)view;

@end

@interface SettingShipmentSectionFooterView : UIView <UITextFieldDelegate>

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<SettingShipmentSectionFooterViewDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<SettingShipmentSectionFooterViewDelegate> delegate;
#endif

@property (weak, nonatomic) IBOutlet UILabel *labelinfo;
@property (weak, nonatomic) IBOutlet UISwitch *switchweightmin;
@property (weak, nonatomic) IBOutlet UILabel *labelweightmin;
@property (weak, nonatomic) IBOutlet UIStepper *stepperminweight;
@property (weak, nonatomic) IBOutlet UISwitch *switchfee;
@property (weak, nonatomic) IBOutlet UITextField *textfieldfee;
@property (weak, nonatomic) IBOutlet UISwitch *switchdiffdistrict;
@property (weak, nonatomic) IBOutlet UILabel *labelfee;

@property (weak, nonatomic) IBOutlet UIView *viewinfo;

@property (weak, nonatomic) IBOutlet UIView *viewfee;
@property (weak, nonatomic) IBOutlet UIView *viewminweightflag;
@property (weak, nonatomic) IBOutlet UIView *viewdiffcity;
@property (weak, nonatomic) IBOutlet UIView *viewminweight;
@property (weak, nonatomic) IBOutlet UIView *viewswitchfee;
+ (id)newview;

-(void)updateView;
@end
