//
//  CustomErrorMessageView.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 5/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomErrorMessageViewDelegate <NSObject>
@required
- (void)tapCloseButton;
@end

@interface CustomErrorMessageView : UIView

@property (weak, nonatomic) id<CustomErrorMessageViewDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *errorMessageLabel;
@property (strong, nonatomic) IBOutlet UIButton *closeButton;

+ (id)newView;
- (void)setErrorMessageLabelWithText:(NSString *)text;

@end
