//
//  AlertReputation.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "AlertReputation.h"

@implementation AlertReputation



- (void)awakeFromNib
{
//    UIFont *font = [UIFont fontWithName:@"GothamBook" size:12];
//    
//    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
//    style.lineSpacing = 6.0;
//    style.alignment = NSTextAlignmentCenter;
//    
//    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
//                                 NSFontAttributeName: font,
//                                 NSParagraphStyleAttributeName: style,
//                                 };
//    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:_infoLabel.text attributes:attributes];
//                                          
//    _infoLabel.attributedText = attributedText;
    
    self.layer.cornerRadius = 5;
}

#pragma mark - TKPDTabNavigationController Tap Button Notification
-(IBAction)tap:(id)sender {
    if ([sender isKindOfClass: [UIButton class]]) {
        UIButton *btn = (UIButton *)sender;
        
        switch (btn.tag) {
            case 10:
            {
                [_shopRatingLabel setText:@"Saya Puas!"];
                break;
            }
            case 11:
            {
                [_shopRatingLabel setText:@"Saya Cukup Puas!"];
                break;
            }
            case 12:
            {
                [_shopRatingLabel setText:@"Saya Tidak Puas!"];
                break;
            }
                
            case 13:
            {
                //do confirm here
                break;
            }
            default:
                break;
        }
    }
}



@end
