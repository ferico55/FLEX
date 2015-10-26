//
//  TransactionCartCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionCartCell.h"

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
    [_productNameLabel sizeToFit];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)tap:(id)sender
{
    [_delegate tapMoreButtonActionAtIndexPath:_indexPath];
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
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    
    style.lineSpacing = 8.0;
    
    
    NSMutableDictionary* textAttributes = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                          
                                                                                          NSFontAttributeName            : [UIFont fontWithName:@"GothamBook" size:14],
                                                                                          
                                                                                          NSParagraphStyleAttributeName  : style,
                                                                                          
                                                                                          NSForegroundColorAttributeName : [UIColor colorWithRed:10.0/255.0 green:126.0/255.0 blue:7.0/255.0 alpha:1],
                                                                                          
                                                                                          }];
    
    
    
    NSAttributedString *attributedText;
    
    if (_indexPage==0) {
        
        UIColor *color = [UIColor colorWithRed:10.0/255.0 green:126.0/255.0 blue:7.0/255.0 alpha:1];
        
        [textAttributes setObject:color forKey:NSForegroundColorAttributeName];
        
        attributedText = [[NSAttributedString alloc] initWithString:viewModel.productName
                          
                                                         attributes:textAttributes];
        
    } else {
        
        [textAttributes setObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
        
        attributedText = [[NSAttributedString alloc] initWithString:viewModel.productName
                          
                                                         attributes:textAttributes];
        
    }
    
    [self.productNameLabel setAttributedText:attributedText];
    
    
    
    NSString *priceIsChangedString = [NSString stringWithFormat:@"%@ (Sebelumnya %@)", viewModel.productPriceIDR, viewModel.productPriceBeforeChange];
    
    NSString *productSebelumnya = [NSString stringWithFormat:@"(Sebelumnya %@)", viewModel.productPriceBeforeChange];
    
    NSString *priceString = viewModel.productPriceIDR;
    
    
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:priceIsChangedString];
    
    [attributedString addAttribute:NSFontAttributeName
     
                             value:FONT_GOTHAM_BOOK_10
     
                             range:[priceIsChangedString rangeOfString:productSebelumnya]];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:158.0/255.0 green:158.0/255.0 blue:158.0/255.0 alpha:1] range:[priceIsChangedString rangeOfString:productSebelumnya]];
    
    
    
    
    
    if ( [[viewModel.productPriceBeforeChange priceFromStringIDR] integerValue] != 0)
        
        self.productPriceLabel.attributedText = attributedString;
    
    else
        
        self.productPriceLabel.text = priceString;
    
    
    
    NSString *weightTotal = [NSString stringWithFormat:@"%@ Barang (%@ kg)",viewModel.productQuantity, viewModel.productTotalWeight];
    
    attributedString = [[NSMutableAttributedString alloc] initWithString:weightTotal];
    
    [attributedString addAttribute:NSFontAttributeName
     
                             value:FONT_GOTHAM_BOOK_12
     
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
    
    
    
    if (([viewModel.productErrorMessage isEqualToString:@""] ||
         
         [viewModel.productErrorMessage isEqualToString:@"0"] ||
         
         viewModel.productErrorMessage == nil ) &&
        
        [[viewModel.productPriceBeforeChange priceFromStringIDR] integerValue] == 0) {
        
        self.errorProductLabel.hidden = YES;
        
    }
    
    else
        
    {
        
        self.errorProductLabel.hidden = NO;
        
        if ([viewModel.productErrorMessage isEqualToString:@"Produk ini berada di gudang"]) {
            
            self.errorProductLabel.text = @"GUDANG";
            
        }
        
        else if ([viewModel.productErrorMessage isEqualToString:@"Produk ini dalam moderasi"])
            
        {
            
            self.errorProductLabel.text = @"MODERASI";
            
        }
        
        else if ([viewModel.productErrorMessage isEqualToString:@"Maksimal pembelian produk ini adalah 999 item"])
            
        {
            
            [self.errorProductLabel setCustomAttributedText:@"Maks\n999 item"];
            
        }
        
        else if ([viewModel.productErrorMessage isEqualToString:@"Produk ini sudah dihapus oleh penjual"])
            
            self.errorProductLabel.text = @"HAPUS";
        
        else if ([_viewModelCart.cartIsPriceChanged integerValue] == 1)
            
        {
            
            [self.errorProductLabel setCustomAttributedText:@"HARGA BERUBAH"];
            
        }
        
        else
            
            self.errorProductLabel.text = @"TIDAK VALID";
    }
    
}



@end
