//
//  CloseShopViewController.h
//  Tokopedia
//
//  Created by Johanes Effendi on 5/9/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKPDTextView.h"
#import "ClosedScheduleDetail.h"

@protocol CloseShopDelegate <NSObject>
-(void)didChangeShopStatus;
@end

@interface CloseShopViewController : UIViewController

@property (nonatomic, weak) id<CloseShopDelegate> delegate;
@property (strong, nonatomic) ClosedScheduleDetail *scheduleDetail;
@property (strong, nonatomic) NSString *closedNote;



@end
