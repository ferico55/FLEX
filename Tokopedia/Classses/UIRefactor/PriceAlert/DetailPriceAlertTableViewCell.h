//
//  DetailPriceAlertTableViewCell.h
//  Tokopedia
//
//  Created by Tokopedia on 5/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailPriceAlertTableViewCell : UITableViewCell
{
    IBOutlet UIImageView *imageProduct, *imagePerson;
    IBOutlet UILabel *lblName, *lblProductName, *lblConditionProduct, *lblPriceProduct, *lblProductDate;
    IBOutlet UIButton *btnBuy;
}
@property (nonatomic, strong) UIViewController *viewController;

- (IBAction)actionBuy:(id)sender;
- (void)setImgProduct:(UIImage *)imgProduct;
- (void)setImgPerson:(UIImage *)imgPerson;
- (void)setName:(NSString *)strName;
- (void)setNameProduct:(NSString *)strNameProduct;
- (void)setKondisiProduct:(NSString *)strKondisiProduct;
- (void)setDateProduct:(NSDate *)date;
@end
