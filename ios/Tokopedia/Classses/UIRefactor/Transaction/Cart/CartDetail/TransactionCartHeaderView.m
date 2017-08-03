//
//  TransactionCartHeaderView.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/13/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionCartHeaderView.h"
#import "Tokopedia-Swift.h"

@implementation TransactionCartHeaderView

#pragma mark - Factory Method
+ (id)newview
{
    NSArray* views = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil];
    for (id view in views) {
        if ([view isKindOfClass:[self class]]) {
            return view;
        }
    }
    return nil;
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    [_delegate deleteTransactionCartHeaderView:self atSection:_section];
}
- (IBAction)gesture:(id)sender {
    [_delegate didTapShopAtSection:_section];
}

-(void)setViewModel:(CartModelView*)viewModel page:(NSInteger)page section:(NSInteger)section delegate:(UIViewController*)delegate {
    
    BOOL isLuckyMerchant = ([viewModel.isLuckyMerchant integerValue] == 1);
    
    self.LMBadgeImageView.hidden = (!isLuckyMerchant);
    self.constraintwidthbadge.constant = (isLuckyMerchant)?20:0;
    self.constraintXShopName.constant = (isLuckyMerchant)?8:0;
    
    self.shopNameLabel.text = viewModel.cartShopName;
    if (page==1) {
        self.shopNameLabel.textColor = [UIColor blackColor];
        self.deleteButton.hidden = YES;
        self.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1];
    }
    self.section = section;
    self.delegate = delegate;
    
    if (viewModel.errors.count > 0) {
        Errors *error = viewModel.errors[0];
        if (![error.name isEqualToString:@"product-not-available"]) {
            NSString *string = @"";
            if (error.desc == nil) {
                string = error.title;
            } else {
                string = [NSString stringWithFormat:@"%@\n\n%@", error.title, error.desc];
            }
            CGSize maximumLabelSize = CGSizeMake(250,9999);
            NSStringDrawingContext *context = [NSStringDrawingContext new];
            CGSize expectedLabelSize = [string boundingRectWithSize:maximumLabelSize
                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                         attributes:@{NSFontAttributeName:[UIFont title1Theme]}
                                                            context:context].size;
            _errorViewHeightConstraint.constant = expectedLabelSize.height;
            _errorLabel.text = string;
        } else {
            _errorViewHeightConstraint.constant = 0;
        }
    } else {
        _errorViewHeightConstraint.constant = 0;
    }
    
//    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 44 + _errorViewHeightConstraint.constant, self.frame.size.width,1)];
//    lineView.backgroundColor = [UIColor colorWithRed:(230.0/255.0f) green:(233/255.0f) blue:(237.0/255.0f) alpha:1.0f];
//    [self addSubview:lineView];
}

@end
