//
//  DetailPriceAlertTableViewCell.h
//  Tokopedia
//
//  Created by Tokopedia on 5/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface CustomButtonBuy:UIButton
@property (nonatomic, strong) NSIndexPath *tagIndexPath;
@end


@interface DetailPriceAlertTableViewCell : UITableViewCell
{
    IBOutlet UILabel *lblProductName, *lblConditionProduct, *lblPriceProduct;
    IBOutlet CustomButtonBuy *btnBuy;
}
@property (nonatomic, strong) UIViewController *viewController;

- (IBAction)actionBuy:(id)sender;
- (CustomButtonBuy *)getBtnBuy;
- (void)setNameProduct:(NSString *)strNameProduct;
- (void)setKondisiProduct:(NSString *)strKondisiProduct;
- (void)setProductPrice:(NSString *)strPriceProduct;
@end
