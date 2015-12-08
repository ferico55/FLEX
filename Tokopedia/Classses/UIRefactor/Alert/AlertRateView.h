//
//  AlertRateView.h
//  Tokopedia
//
//  Created by Tokopedia on 7/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "String_Reputation.h"
#define CTagMerah 1
#define CTagKuning 2
#define CTagHijau 3


@protocol AlertRateDelegate
- (void)closeWindow;
- (void)submitWithSelected:(int)tag;
@end

@interface AlertRateView : UIView
{
    id<AlertRateDelegate> del;
}

- (instancetype)initViewWithDelegate:(id<AlertRateDelegate>)delegate withDefaultScore:(NSString *)tag from:(NSString *)strFrom;
- (void)show;
@end
