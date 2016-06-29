//
//  RejectReasonWrongPriceCell.m
//  Tokopedia
//
//  Created by Johanes Effendi on 6/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RejectReasonWrongPriceCell.h"

@implementation RejectReasonWrongPriceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setViewModel:(ProductModelView *)viewModel{
    [_productName setText:viewModel.productName];
    [_productPrice setText:viewModel.productPriceIDR];
    
    //to make the "stok kosong" label fit next to price label
    //[_productPrice sizeToFit];
    
    [_productWeight setText:viewModel.productTotalWeight];
    
    [_emptyStockLabel setHidden:viewModel.isProductBuyAble];
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:viewModel.productThumbUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    [_productImage setContentMode:UIViewContentModeScaleAspectFill];
    [_productImage setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [self.productImage setContentMode:UIViewContentModeScaleAspectFill];
        [self.productImage setImage:image];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [self.productImage setImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"]];
    }];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
- (IBAction)changePriceButtonTapped:(id)sender {
    [self.delegate tableViewCell:self changeProductPriceAtIndexPath:_indexPath];
}

@end
