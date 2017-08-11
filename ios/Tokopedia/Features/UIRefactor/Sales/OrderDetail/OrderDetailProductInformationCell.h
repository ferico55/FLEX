//
//  OrderDetailProductInformationCell.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/20/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderDetailProductInformationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *productInformationLabel;

+ (CGFloat)maxTextWidth;
+ (CGSize)messageSize:(NSString*)message;
+ (CGFloat)textMarginVertical;

@end
