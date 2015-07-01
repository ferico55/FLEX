//
//  ViewLabelUser.h
//  Tokopedia
//
//  Created by Tokopedia on 6/23/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class InboxMessageCell;

@interface ViewLabelUser : UIView
@property (nonatomic, unsafe_unretained) InboxMessageCell *inboxMessageCell;
@property (nonatomic, unsafe_unretained, setter=setText:, getter=getText) NSString *text;

- (UILabel *)getLblText;
- (void)setColor:(int)tagCase;
- (void)setLabelBackground:(NSString*)type;
- (NSString *)getText;
- (void)setText:(NSString *)strText;
- (void)setText:(UIColor *)color withFont:(UIFont *)font;
@end
