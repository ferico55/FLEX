//
//  ResolutionCenterCreateStepTwoCell.h
//  Tokopedia
//
//  Created by Johanes Effendi on 8/4/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownPicker.h"

@protocol ResolutionCenterCreateStepTwoCellDelegate <NSObject>
- (void) didChangeStepperValue:(UIStepper*)stepper;
@end

@interface ResolutionCenterCreateStepTwoCell : UITableViewCell
@property (strong, nonatomic) IBOutlet DownPicker *troublePicker;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *problemView;

@property (strong, nonatomic) IBOutlet UIButton *productName;
@property (strong, nonatomic) IBOutlet UIImageView *prosecureBadge;
@property (strong, nonatomic) IBOutlet UILabel *prosecureLabel;
@property (strong, nonatomic) IBOutlet UIImageView *productImage;
@property (strong, nonatomic) IBOutlet UIStepper *quantityStepper;
@property (strong, nonatomic) IBOutlet UILabel *quantityLabel;
@property (strong, nonatomic) IBOutlet UITextView *problemTextView;

@property (weak, nonatomic) id<ResolutionCenterCreateStepTwoCellDelegate> delegate;

+ (id)newcell;
@end
