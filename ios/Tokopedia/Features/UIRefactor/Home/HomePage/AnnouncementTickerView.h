//
//  AnnouncementTickerView.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 7/27/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@import TTTAttributedLabel;

@interface AnnouncementTickerView : UIView <TTTAttributedLabelDelegate>

@property (copy) void(^onTapMessageWithUrl)(NSURL *url);
@property (copy) void(^onTapCloseButton)();

-(instancetype)initWithMessage:(NSString *)message colorHexString:(NSString *)colorHexString;

- (void)setMessage:(NSString *)text withContentColorHexString:(NSString *)contentColorHexString;

@end
