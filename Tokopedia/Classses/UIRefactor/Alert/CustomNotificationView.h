//
//  CustomNotificationView.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 5/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomNotificationViewDelegate <NSObject>
@required
- (void)didTapCloseButton;
- (void)didTapActionButton;
@end

@interface CustomNotificationView : UIView

@property (weak, nonatomic) id<CustomNotificationViewDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UIButton *closeButton;
@property (strong, nonatomic) IBOutlet UIButton *actionButton;

+ (id)newView;
- (void)setMessageLabelWithText:(NSString *)text;
- (void)setActionButtonLabelWithText:(NSString *)text;
- (void)hideActionButton;
- (void)hideCloseButton;

@end
