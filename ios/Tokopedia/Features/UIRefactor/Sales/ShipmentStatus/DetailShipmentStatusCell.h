//
//  DetailShipmentStatusCell.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailShipmentStatusCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (nonatomic) BOOL lineHidden;

- (void)setColorThemeForActionBy:(NSString *)subject;
- (void)setSubjectLabelText:(NSString *)text;
- (void)setStatusLabelText:(NSString *)text;

+ (CGFloat)maxTextWidth;
+ (CGSize)messageSize:(NSString*)message;

@end
