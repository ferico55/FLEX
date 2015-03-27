//
//  AlertView.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/19/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomAlertViewDelegate <NSObject>

- (void)alertViewDismissed:(UIView *)alertView;

@end

@interface AlertView : UIView

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (weak, nonatomic) id<CustomAlertViewDelegate> delegate;

- (id)initWithTitle:(NSString *)title;
- (void)show;
- (void)dismiss;

@end