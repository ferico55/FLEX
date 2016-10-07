//
//  ResolutionCenterCreateStepTwoCell.h
//  Tokopedia
//
//  Created by Johanes Effendi on 8/4/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownPicker.h"
#import "Tokopedia-Swift.h"

@protocol ResolutionCenterCreateStepTwoCellDelegate <NSObject>
- (void)didChangeStepperValue:(UIStepper*)stepper;
- (void)didRemarkTextChange:(RSKPlaceholderTextView*)textView withSelectedCell:(UITableViewCell*)cell;
@end

@interface ResolutionCenterCreateStepTwoCell : UITableViewCell <UITextViewDelegate>
@property (strong, nonatomic) IBOutlet DownPicker *troublePicker;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *problemView;

@property (strong, nonatomic) IBOutlet UIButton *productName;
@property (strong, nonatomic) IBOutlet UIImageView *prosecureBadge;
@property (strong, nonatomic) IBOutlet UILabel *prosecureLabel;
@property (strong, nonatomic) IBOutlet UIImageView *productImage;
@property (strong, nonatomic) IBOutlet UIStepper *quantityStepper;
@property (strong, nonatomic) IBOutlet RSKPlaceholderTextView *problemTextView;
@property (strong, nonatomic) IBOutlet UITextField *quantityTextField;

@property (weak, nonatomic) id<ResolutionCenterCreateStepTwoCellDelegate> delegate;

+ (id)newcell;
@end
