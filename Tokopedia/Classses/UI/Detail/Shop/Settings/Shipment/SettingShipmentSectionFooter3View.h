//
//  SettingShipmentSectionFooter3View.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/20/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingShipmentSectionFooter3ViewDelegate <NSObject>
@required
-(void)SettingShipmentSectionFooter3View:(UIView*)view;

@end

@interface SettingShipmentSectionFooter3View : UIView

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<SettingShipmentSectionFooter3ViewDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<SettingShipmentSectionFooter3ViewDelegate> delegate;
#endif

+ (id)newview;
@property (weak, nonatomic) IBOutlet UILabel *labelinfo;
@property (weak, nonatomic) IBOutlet UIView *viewinfo;
@property (weak, nonatomic) IBOutlet UISwitch *switchweightmin;
@property (weak, nonatomic) IBOutlet UIStepper *stepperweightmin;
@property (weak, nonatomic) IBOutlet UILabel *labelweightmin;
@property (weak, nonatomic) IBOutlet UISwitch *switchfee;
@property (weak, nonatomic) IBOutlet UITextField *textfieldfee;

@end
