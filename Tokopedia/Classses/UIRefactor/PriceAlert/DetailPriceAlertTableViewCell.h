//
//  DetailPriceAlertTableViewCell.h
//  Tokopedia
//
//  Created by Tokopedia on 5/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface CustomButton:UIButton
@property (nonatomic, strong) NSIndexPath *tagIndexPath;
@end


@interface DetailPriceAlertTableViewCell : UITableViewCell
{
    IBOutlet UILabel *lblConditionProduct, *lblPriceProduct;
    IBOutlet CustomButton *btnBuy, *btnProductName;
}
@property (nonatomic, strong) UIViewController *viewController;

- (IBAction)actionBuy:(id)sender;
- (IBAction)actionProductName:(id)sender;
- (CustomButton *)getBtnBuy;
- (CustomButton *)getBtnProductName;
- (void)setNameProduct:(NSString *)strNameProduct;
- (void)setKondisiProduct:(NSString *)strKondisiProduct;
- (void)setProductPrice:(NSString *)strPriceProduct;
@end
