//
//  TransactionCartCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionCartCell.h"
#import "Errors.h"

@implementation TransactionCartCell
{
    CartModelView *_viewModelCart;
    ProductModelView *_viewModelProduct;
}

#pragma mark - Factory methods

+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"TransactionCartCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)awakeFromNib {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)tap:(id)sender
{
    UIActionSheet* popup = nil;
    
    if (_viewModelProduct.productErrors.count > 0) {
        if ([_viewModelProduct.productErrors[0].name isEqualToString:@"product-less-than-min"] ||
            [_viewModelProduct.productErrors[0].name isEqualToString:@"product-more-than-max"]) {
            popup = [[UIActionSheet alloc] initWithTitle:nil
                                                delegate:self
                                       cancelButtonTitle:@"Batal"
                                  destructiveButtonTitle:@"Hapus"
                                       otherButtonTitles:@"Edit", nil];
        } else {
            popup = [[UIActionSheet alloc] initWithTitle:nil
                                                delegate:self
                                       cancelButtonTitle:@"Batal"
                                  destructiveButtonTitle:@"Hapus"
                                       otherButtonTitles:nil];
        }
    } else if (_viewModelCart.errors.count > 0) {
        if ([_viewModelCart.errors[0].name isEqualToString:@"shopping-limit-exceeded"] ||
            [_viewModelCart.errors[0].name isEqualToString:@"courier-max-limit"]) {
            popup = [[UIActionSheet alloc] initWithTitle:nil
                                                delegate:self
                                       cancelButtonTitle:@"Batal"
                                  destructiveButtonTitle:@"Hapus"
                                       otherButtonTitles:@"Edit", nil];
        } else {
            popup = [[UIActionSheet alloc] initWithTitle:nil
                                                delegate:self
                                       cancelButtonTitle:@"Batal"
                                  destructiveButtonTitle:@"Hapus"
                                       otherButtonTitles:nil];
        }
    } else {
        popup = [[UIActionSheet alloc] initWithTitle:nil
                                            delegate:self
                                   cancelButtonTitle:@"Batal"
                              destructiveButtonTitle:@"Hapus"
                                   otherButtonTitles:@"Edit", nil];
    }
    
    [popup showFromRect:_editButton.frame inView:self animated:YES];
    [_delegate tapMoreButtonActionAtIndexPath:_indexPath];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.actionSheetDelegate actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
}

- (IBAction)gesture:(id)sender {
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer*)sender;
    if (gesture.view.tag == 10)
        [_delegate didTapProductAtIndexPath:_indexPath];
}

-(void)setCartViewModel:(CartModelView *)viewModel
{
    _viewModelCart = viewModel;
}

- (void)setViewModel:(ProductModelView *)viewModel {
    
    _viewModelProduct = viewModel;
    
    self.backgroundColor = (_indexPage==0)?[UIColor whiteColor]:[UIColor colorWithRed:247.0f/255.0f green:247.0f/255.0f blue:247.0f/255.0f alpha:1];
    
    if (_indexPage == 1) {
        self.productNameLabel.textColor = [UIColor blackColor];
    }
    
    self.productNameLabel.text = viewModel.productName;
    
    
    NSString *priceIsChangedString = [NSString stringWithFormat:@"%@ (Sebelumnya %@)", viewModel.productPriceIDR, viewModel.productPriceBeforeChange];
    
    NSString *productSebelumnya = [NSString stringWithFormat:@"(Sebelumnya %@)", viewModel.productPriceBeforeChange];
    
    NSString *priceString = viewModel.productPriceIDR;
    
    
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:priceIsChangedString];
    
    [attributedString addAttribute:NSFontAttributeName
     
                             value:[UIFont microTheme]
     
                             range:[priceIsChangedString rangeOfString:productSebelumnya]];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:255/255.0 green:59/255.0 blue:48/255.0 alpha:1] range:[priceIsChangedString rangeOfString:productSebelumnya]];
    
    if ( [[viewModel.productPriceBeforeChange priceFromStringIDR] integerValue] != 0)
        
        self.productPriceLabel.attributedText = attributedString;
    
    else
        
        self.productPriceLabel.text = priceString;
    
    
    
    NSString *weightTotal = [NSString stringWithFormat:@"%@ Barang (%@ kg)",viewModel.productQuantity, viewModel.productTotalWeight];
    
    attributedString = [[NSMutableAttributedString alloc] initWithString:weightTotal];
    
    [attributedString addAttribute:NSFontAttributeName
     
                             value:[UIFont microTheme]
     
                             range:[weightTotal rangeOfString:[NSString stringWithFormat:@"(%@ kg)",viewModel.productTotalWeight]]];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:158.0/255.0 green:158.0/255.0 blue:158.0/255.0 alpha:1] range:[weightTotal rangeOfString:[NSString stringWithFormat:@"(%@ kg)",viewModel.productTotalWeight]]];
    
    self.quantityLabel.attributedText = attributedString;
    
    
    NSString *productNotes = [viewModel.productNotes stringByReplacingOccurrencesOfString:@"\n" withString:@"; "];
    if ([productNotes isEqualToString:@""] || [productNotes isEqualToString:@"0"]) {
        productNotes = @"-";
    }
    
    [self.remarkLabel setCustomAttributedText:productNotes?:@"-"];
    
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:viewModel.productThumbUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    
    UIImageView *thumb = self.productThumbImageView;
    
    [thumb setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey2.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
        [thumb setImage:image];
        [thumb setContentMode:UIViewContentModeScaleAspectFill];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
        thumb.image = [UIImage imageNamed:@"Icon_no_photo_transparan.png"];
        
    }];
    
    self.editButton.hidden = (_indexPage == 1);
    
    if (viewModel.productErrors.count > 0) {
        Errors *error = viewModel.productErrors[0];
        
        NSString *errorText = [NSString stringWithFormat:@"%@\n\n%@", error.title, error.desc];
        CGSize maximumLabelSize = CGSizeMake(250,9999);
        NSStringDrawingContext *context = [NSStringDrawingContext new];
        CGSize expectedLabelSize = [errorText boundingRectWithSize:maximumLabelSize
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:[UIFont title2Theme]}
                                                        context:context].size;
        _errorLabel.text = errorText;
        _errorViewHeightConstraint.constant = expectedLabelSize.height + 16;
    } else {
        _errorViewHeightConstraint.constant = 0;
    }
    
}

@end
