//
//  ProductEditWholesaleCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 12/11/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "string_product.h"
#import "ProductEditWholesaleCell.h"
#import "Tokopedia-Swift.h"
#import "NSNumberFormatter+IDRFormater.h"

@interface ProductEditWholesaleCell()

@property (weak, nonatomic) IBOutlet UITextField *minimumProductTextField;
@property (weak, nonatomic) IBOutlet UITextField *maximumProductTextField;
@property (weak, nonatomic) IBOutlet UILabel *productCurrencyLabel;
@property (weak, nonatomic) IBOutlet UITextField *productPriceTextField;

@property (copy, nonatomic) void (^removeWholesale)(WholesalePrice *wholesale);
@property (copy, nonatomic) void (^editWholesale)(WholesalePrice *wholesale);

@end

@implementation ProductEditWholesaleCell

#pragma mark - Factory methods
+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"ProductEditWholesaleCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}


-(void)setProductPriceCurency:(NSString *)productPriceCurency{
    _productPriceCurency = productPriceCurency;
    
    CGFloat priceInteger = [_wholesale.wholesale_price floatValue];
    
    NSString *wholesalePrice = @"";
    
    if ([_productPriceCurency integerValue] == PRICE_CURRENCY_ID_RUPIAH) {
        wholesalePrice = [[NSNumberFormatter IDRFormarterWithoutCurency] stringFromNumber:@(priceInteger)];
        self.productCurrencyLabel.text = @"Rp";
    } else {
        wholesalePrice = [[NSNumberFormatter USDFormarter] stringFromNumber:@(priceInteger)];
        self.productCurrencyLabel.text = @"US$";
    }
    
    self.productPriceTextField.text = ([wholesalePrice isEqualToString:@"0"])?@"":wholesalePrice;
    self.minimumProductTextField.text = _wholesale.wholesale_min;
    self.maximumProductTextField.text = _wholesale.wholesale_max;
}

#pragma mark - View Action
- (IBAction)onTapRemoveWholesale:(id)sender {
    if (self.removeWholesale) {
        self.removeWholesale(_wholesale);
    }
}
- (IBAction)didEndEditingMax:(UITextField *)textField {
    _wholesale.wholesale_max = textField.text;
    if (self.editWholesale) {
        self.editWholesale(_wholesale);
    }
}

- (IBAction)didEndEditingPrice:(UITextField *)textField {
    NSNumber *price;
    if ([_productPriceCurency integerValue] == PRICE_CURRENCY_ID_RUPIAH)
        price = [[NSNumberFormatter IDRFormarterWithoutCurency] numberFromString:textField.text];
    else
        price = [[NSNumberFormatter USDFormarter] numberFromString:textField.text];

    _wholesale.wholesale_price = [price stringValue];
    if (self.editWholesale) {
        self.editWholesale(_wholesale);
    }
}

- (IBAction)didEndEditingMin:(UITextField *)textField {
    _wholesale.wholesale_min = textField.text;
    if (self.editWholesale) {
        self.editWholesale(_wholesale);
    }
}

#pragma mark - Textfield Delegate


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSInteger priceCurencyID = [_productPriceCurency integerValue]?:1;
    BOOL isIDRCurrency = (priceCurencyID == PRICE_CURRENCY_ID_RUPIAH);
    if (textField == _productPriceTextField) {
        if (isIDRCurrency) {
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            if([string length]==0)
            {
                [formatter setGroupingSeparator:@"."];
                [formatter setGroupingSize:4];
                [formatter setUsesGroupingSeparator:YES];
                [formatter setSecondaryGroupingSize:3];
                NSString *num = textField.text ;
                num = [num stringByReplacingOccurrencesOfString:@"." withString:@""];
                NSString *str = [formatter stringFromNumber:[NSNumber numberWithDouble:[num doubleValue]]];
                textField.text = str;
            }
            else {
                [formatter setGroupingSeparator:@"."];
                [formatter setGroupingSize:2];
                [formatter setUsesGroupingSeparator:YES];
                [formatter setSecondaryGroupingSize:3];
                NSString *num = textField.text ;
                if(![num isEqualToString:@""])
                {
                    num = [num stringByReplacingOccurrencesOfString:@"." withString:@""];
                    NSString *str = [formatter stringFromNumber:[NSNumber numberWithDouble:[num doubleValue]]];
                    textField.text = str;
                }
            }
            return YES;
        }
        else
        {
            NSString *cleanCentString = [[textField.text
                                          componentsSeparatedByCharactersInSet:
                                          [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                         componentsJoinedByString:@""];
            // Parse final integer value
            NSInteger centAmount = cleanCentString.integerValue;
            // Check the user input
            if (string.length > 0) {
                // Digit added
                centAmount = centAmount * 10 + string.integerValue;
            } else {
                // Digit deleted
                centAmount = centAmount / 10;
            }
            // Update call amount value
            NSNumber *amount = [[NSNumber alloc] initWithFloat:(float)centAmount / 100.0f];
            // Write amount with currency symbols to the textfield
            NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
            [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [currencyFormatter setCurrencyCode:@"USD"];
            [currencyFormatter setNegativeFormat:@"-¤#,##0.00"];
            textField.text = [currencyFormatter stringFromNumber:amount];
            return NO;
        }
    }
    return YES;
}

@end
