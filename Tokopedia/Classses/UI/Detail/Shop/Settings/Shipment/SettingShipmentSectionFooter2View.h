//
//  SettingShipmentSectionFooter2View.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/20/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingShipmentSectionFooter2ViewDelegate <NSObject>
@required
-(void)SettingShipmentSectionFooterView:(UIView*)view;
-(void)MoveToInfoView:(UIView*)view;
@end

@interface SettingShipmentSectionFooter2View : UIView

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<SettingShipmentSectionFooter2ViewDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<SettingShipmentSectionFooter2ViewDelegate> delegate;
#endif

+ (id)newview;
@property (weak, nonatomic) IBOutlet UILabel *labelinfo;
@property (weak, nonatomic) IBOutlet UIView *viewinfo;

@end
