//
//  DetailMyReviewReputationCell.m
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "DetailReviewReputaionViewModel.h"
#import "DetailMyReviewReputationCell.h"
#define CStringKomentar @"Komentar"
#define CStringPembeliBelumBeriUlasan @"Pembeli belum memberikan ulasan"

@implementation CustomBtnSkip : UIButton
@synthesize isLewati, isLapor;
@end



@implementation DetailMyReviewReputationCell
- (void)awakeFromNib {
//    self.contentView.backgroundColor = [UIColor clearColor];
//    self.backgroundColor = [UIColor clearColor];
    
    _strRole = @"";
    lblDesc = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    lblDesc.delegate = self;
    [viewContent addSubview:lblDesc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    imgProduct.frame = CGRectMake(imgProduct.frame.origin.x, imgProduct.frame.origin.y, CDiameterImage, CDiameterImage);
    btnProduct.frame = CGRectMake(imgProduct.frame.origin.x+imgProduct.bounds.size.width+CPaddingTopBottom, imgProduct.frame.origin.y, self.bounds.size.width-(CPaddingTopBottom*5)-CDiameterImage, (lblDate.isHidden? CDiameterImage:CDiameterImage/2.0f));
    
    
    //Set content star
    viewContentStar.frame = CGRectMake(imgProduct.frame.origin.x, lblDesc.frame.origin.y+lblDesc.bounds.size.height+CPaddingTopBottom, viewContent.bounds.size.width-(imgProduct.frame.origin.x*2), (viewContentStar.isHidden)?0:CHeightContentStar);
    lblKualitas.frame = CGRectMake(lblKualitas.frame.origin.x, 0, lblKualitas.bounds.size.width, viewContentStar.bounds.size.height);
    viewKualitas.frame = CGRectMake(lblKualitas.frame.origin.x+lblKualitas.bounds.size.width, (viewContentStar.bounds.size.height-viewKualitas.bounds.size.height)/2.0f, viewKualitas.bounds.size.width, viewKualitas.bounds.size.height);
    
    viewAkurasi.frame = CGRectMake(viewContentStar.bounds.size.width-viewAkurasi.bounds.size.width-lblKualitas.frame.origin.x, viewKualitas.frame.origin.y, viewAkurasi.bounds.size.width, viewAkurasi.bounds.size.height);
    lblAkurasi.frame = CGRectMake(viewAkurasi.frame.origin.x-lblAkurasi.bounds.size.width, viewAkurasi.frame.origin.y+3, lblAkurasi.bounds.size.width, lblAkurasi.bounds.size.height);
    
    
    //set content action
    viewContentAction.frame = CGRectMake(0, viewContentStar.frame.origin.y+viewContentStar.bounds.size.height, viewContentStar.bounds.size.width+(viewContentStar.frame.origin.x*2), viewContentAction.isHidden?0:CHeightContentAction);
    viewSeparatorContentAction.frame = CGRectMake(0, 0, viewContentAction.bounds.size.width, viewSeparatorContentAction.bounds.size.height);
    btnKomentar.frame = CGRectMake(CPaddingTopBottom, 0, 100, viewContentAction.bounds.size.height);
    btnUbah.frame = CGRectMake(viewContentStar.bounds.size.width-100-CPaddingTopBottom, 0, 100, viewContentAction.bounds.size.height);
    
    viewContent.frame = CGRectMake(CPaddingTopBottom, CPaddingTopBottom, self.contentView.bounds.size.width-(CPaddingTopBottom*2), viewContentAction.frame.origin.y+viewContentAction.bounds.size.height);
    self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, 0, self.contentView.bounds.size.width, viewContent.frame.origin.y+viewContent.bounds.size.height+CPaddingTopBottom);
}


#pragma mark - Getter
- (TTTAttributedLabel *)getLabelDesc {
    return lblDesc;
}


#pragma mark - Method
- (void)setHiddenAction:(BOOL)hidden {
    viewContentAction.hidden = hidden;
}

- (UIButton *)getBtnKomentar {
    return btnKomentar;
}

- (UIButton *)getBtnUbah {
    return btnUbah;
}

- (IBAction)actionBeriReview:(id)sender {
    [_delegate actionBeriReview:sender];
}

- (void)setHiddenRating:(BOOL)hidden {
    viewContentStar.hidden = hidden;
}

- (IBAction)actionUbah:(id)sender {
    [_delegate actionUbah:sender];
}

- (IBAction)actionProduct:(id)sender {
    [_delegate actionProduct:sender];
}

- (void)setView:(DetailReviewReputaionViewModel *)viewModel {
    if(viewModel==nil || viewModel.review_message==nil || [viewModel.review_message isEqualToString:@"0"]) {
        if([_strRole isEqualToString:@"2"]) {
            lblDate.text = CStringPembeliBelumBeriUlasan;
        }
    }
    else
        lblDate.text = viewModel.review_create_time==nil||[viewModel.review_create_time isEqualToString:@"0"]? @"":viewModel.review_create_time;
    [btnProduct setTitle:viewModel.product_name forState:UIControlStateNormal];
    
    //Set star akurasi and kualitas
    for(int i=0;i<arrImgKualitas.count;i++) {
        UIImageView *tempImage = arrImgKualitas[i];
        tempImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(i < [viewModel.product_rating_point intValue])?@"icon_star_active":@"icon_star" ofType:@"png"]];
    }
    for(int i=0;i<arrImgAkurasi.count;i++) {
        UIImageView *tempImage = arrImgAkurasi[i];
        tempImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(i < [viewModel.product_accuracy_point intValue])?@"icon_star_active":@"icon_star" ofType:@"png"]];
    }
    
    
    
    //Set image product
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:viewModel.product_uri] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    UIImageView *thumb = imgProduct;
    thumb.image = nil;
    [thumb setImageWithURLRequest:request placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_profile_picture" ofType:@"jpeg"]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        //NSLOG(@"thumb: %@", thumb);
        [thumb setImage:image];
#pragma clang diagnostic pop
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];


    [self setHiddenRating:NO];
    //check skipable
    if([viewModel.review_is_skipable isEqualToString:@"1"]) {
        [btnUbah setTitle:@"Lewati" forState:UIControlStateNormal];
        [btnUbah setTitleColor:[UIColor colorWithRed:117/255.0f green:117/255.0f blue:117/255.0f alpha:1.0f] forState:UIControlStateNormal];
        btnUbah.isLewati = YES;
        btnUbah.isLapor = NO;
        btnUbah.hidden = NO;
    }
    else if(viewModel.review_message!=nil && viewModel.review_message.length>0 && ![viewModel.review_message isEqualToString:@"0"] && [viewModel.review_is_allow_edit isEqualToString:@"1"] && ![_strRole isEqualToString:@"2"]) {
        [btnUbah setTitle:@"Ubah" forState:UIControlStateNormal];
        [btnUbah setTitleColor:[UIColor colorWithRed:10/255.0f green:126/255.0f blue:7/255.0f alpha:1.0f] forState:UIControlStateNormal];
        btnUbah.isLewati = NO;
        btnUbah.isLapor = NO;
        btnUbah.hidden = NO;
    }
    else if([_strRole isEqualToString:@"2"]) {
        [btnUbah setTitle:@"Lapor" forState:UIControlStateNormal];
        [btnUbah setTitleColor:[UIColor colorWithRed:10/255.0f green:126/255.0f blue:7/255.0f alpha:1.0f] forState:UIControlStateNormal];
        btnUbah.isLewati = NO;
        btnUbah.isLapor = YES;
        btnUbah.hidden = NO;
    }
    else {
        btnUbah.isLapor = NO;
        btnUbah.isLewati = NO;
        btnUbah.hidden = YES;
    }
    
    //Set description
    [_delegate initLabelDesc:lblDesc withText:viewModel.review_message==nil||[viewModel.review_message isEqualToString:@"0"]?@"":viewModel.review_message];
    lblDesc.frame = CGRectMake(imgProduct.frame.origin.x, CPaddingTopBottom + imgProduct.frame.origin.y+imgProduct.bounds.size.height, viewContent.bounds.size.width-(imgProduct.frame.origin.x*2), 0);
    CGSize tempSizeDesc = [lblDesc sizeThatFits:CGSizeMake(lblDesc.bounds.size.width, 9999)];
    CGRect tempLblRect = lblDesc.frame;
    tempLblRect.size.height = tempSizeDesc.height;
    lblDesc.frame = tempLblRect;
    
    if((viewModel.review_message==nil || [viewModel.review_message isEqualToString:@"0"]) && [_strRole isEqualToString:@"1"]) {
        btnKomentar.hidden = NO;
        [self setHiddenRating:YES];
        btnKomentar.enabled = YES;
        [btnKomentar setTitle:@"Beri Review" forState:UIControlStateNormal];
        [btnKomentar setTitleColor:[UIColor colorWithRed:10/255.0f green:126/255.0f blue:7/255.0f alpha:1.0f] forState:UIControlStateNormal];
    }
    else {
        btnKomentar.hidden = NO;
        btnKomentar.enabled = NO;
        
        if(viewModel.review_response!=nil && viewModel.review_response.response_message!=nil && viewModel.review_response.response_message.length>0 && ![viewModel.review_response.response_message isEqualToString:@"0"])
            [btnKomentar setTitle:[NSString stringWithFormat:@"1 %@", CStringKomentar] forState:UIControlStateNormal];
        else
            [btnKomentar setTitle:[NSString stringWithFormat:@"0 %@", CStringKomentar] forState:UIControlStateNormal];
        [btnKomentar setTitleColor:[UIColor colorWithRed:117/255.0f green:117/255.0f blue:117/255.0f alpha:1.0f] forState:UIControlStateNormal];
    }
}

#pragma mark - TTTAttributedLabel delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    [_delegate attributedLabel:label didSelectLinkWithURL:url];
}
@end
