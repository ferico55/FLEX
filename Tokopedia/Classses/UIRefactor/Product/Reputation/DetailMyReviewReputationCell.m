//
//  DetailMyReviewReputationCell.m
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "DetailReviewReputationViewModel.h"
#import "DetailMyReviewReputationCell.h"
#import "NavigationHelper.h"
#define CStringKomentar @"Komentar"
#define CStringPembeliBelumBeriUlasan @"Pembeli belum memberikan ulasan"
#define CStringPembeliLewatiUlasan @"Pembeli telah melewati ulasan"

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
    btnProduct.frame = CGRectMake(imgProduct.frame.origin.x+imgProduct.bounds.size.width+CPaddingTopBottom, ((labelInfoSkip.isHidden && lblDate.text.length>0)? imgProduct.frame.origin.y:(imgProduct.frame.origin.y+((imgProduct.bounds.size.height-lblDate.bounds.size.height)/2.0f))), self.bounds.size.width-(CPaddingTopBottom*5)-CDiameterImage, (lblDate.isHidden? CDiameterImage:CDiameterImage/2.0f));
    
    //Set Attached Images
    viewAttachedImages.frame = CGRectMake(imgProduct.frame.origin.x,lblDesc.frame.origin.y+lblDesc.bounds.size.height+8,(self.bounds.size.width-(CPaddingTopBottom*2))-(imgProduct.frame.origin.x*2), (viewAttachedImages.isHidden)?0:60);
    
    //Set content star
    viewContentStar.frame = CGRectMake(imgProduct.frame.origin.x, viewAttachedImages.frame.origin.y+viewAttachedImages.bounds.size.height+CPaddingTopBottom, (self.bounds.size.width-(CPaddingTopBottom*2))-(imgProduct.frame.origin.x*2), (viewContentStar.isHidden)?0:CHeightContentStar);
    lblKualitas.frame = CGRectMake(lblKualitas.frame.origin.x, 0, lblKualitas.bounds.size.width, viewContentStar.bounds.size.height);
    viewKualitas.frame = CGRectMake(lblKualitas.frame.origin.x+lblKualitas.bounds.size.width, (viewContentStar.bounds.size.height-viewKualitas.bounds.size.height)/2.0f, viewKualitas.bounds.size.width, viewKualitas.bounds.size.height);
    
    viewAkurasi.frame = CGRectMake(viewContentStar.bounds.size.width-viewAkurasi.bounds.size.width-lblKualitas.frame.origin.x, viewKualitas.frame.origin.y, viewAkurasi.bounds.size.width, viewAkurasi.bounds.size.height);
    lblAkurasi.frame = CGRectMake(viewAkurasi.frame.origin.x-lblAkurasi.bounds.size.width, viewAkurasi.frame.origin.y+3, lblAkurasi.bounds.size.width, lblAkurasi.bounds.size.height);
    
    //set content action
    viewContentAction.frame = CGRectMake(0, viewContentStar.frame.origin.y+viewContentStar.bounds.size.height, viewContentStar.bounds.size.width+(viewContentStar.frame.origin.x*2), viewContentAction.isHidden?0:CHeightContentAction);
    viewSeparatorContentAction.frame = CGRectMake(0, 0, viewContentAction.bounds.size.width, viewSeparatorContentAction.bounds.size.height);
    btnKomentar.frame = CGRectMake(CPaddingTopBottom, 0, 100, viewContentAction.bounds.size.height);
    btnUbah.frame = CGRectMake(viewContentStar.bounds.size.width-100, 0, 100, viewContentAction.bounds.size.height);
    
    labelInfoSkip.frame = CGRectMake(0, 0, viewContentAction.bounds.size.width, viewContentAction.bounds.size.height);
    
    viewContent.frame = CGRectMake(CPaddingTopBottom, CPaddingTopBottom, self.bounds.size.width-(CPaddingTopBottom*2), viewContentAction.frame.origin.y+viewContentAction.bounds.size.height);
    self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, 0, self.bounds.size.width, viewContent.frame.origin.y+viewContent.bounds.size.height+CPaddingTopBottom);
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

- (UIButton *)getBtnProduct {
    return btnProduct;
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

- (void)setUnClickViewAction {
    [viewContentAction setUserInteractionEnabled:YES];
    [viewContentAction addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEmptyAction:)]];
}

- (void)tapEmptyAction:(id)sender {

}

- (void)setView:(DetailReviewReputationViewModel *)viewModel {
    lblDate.text = @"";
    [btnProduct setTitle:[NSString convertHTML:viewModel.product_name] forState:UIControlStateNormal];
    
    //Check deleted product status
    if([viewModel.product_status isEqualToString:@"1"]) {
        btnProduct.userInteractionEnabled = [NavigationHelper shouldDoDeepNavigation];

        [btnProduct.titleLabel setTextColor:[UIColor colorWithRed:66/255.0f green:66/255.0f blue:66/255.0f alpha:1.0f]];
    }
    else {
        btnProduct.userInteractionEnabled = NO;
        [btnProduct.titleLabel setTextColor:[UIColor colorWithRed:117/255.0f green:117/255.0f blue:117/255.0f alpha:1.0f]];
    }
    
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
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:viewModel.product_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    UIImageView *thumb = imgProduct;
    thumb.image = nil;
    [thumb setImageWithURLRequest:request placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_toped_loading_grey" ofType:@"png"]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
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
    lblDesc.frame = CGRectMake(imgProduct.frame.origin.x, CPaddingTopBottom+CPaddingTopBottom+ imgProduct.frame.origin.y+imgProduct.bounds.size.height, (self.bounds.size.width-(CPaddingTopBottom*2))-(imgProduct.frame.origin.x*2), 0);
    CGSize tempSizeDesc = [lblDesc sizeThatFits:CGSizeMake(lblDesc.bounds.size.width, 9999)];
    CGRect tempLblRect = lblDesc.frame;
    tempLblRect.size.height = tempSizeDesc.height;
    if(viewModel.review_message==nil || [viewModel.review_message isEqualToString:@"0"] || btnUbah.isLewati) {
        tempLblRect.origin.y -= CPaddingTopBottom;
        tempLblRect.size.height = 0;
    }
    else {
        tempLblRect.size.height += CPaddingTopBottom;
    }
    
    lblDesc.frame = tempLblRect;
    
    if ((viewModel.review_message==nil || [viewModel.review_message isEqualToString:@"0"]) && [_strRole isEqualToString:@"1"]) {
        viewAttachedImages.hidden = YES;
    }
    
    if((viewModel.review_message==nil || [viewModel.review_message isEqualToString:@"0"]) && [_strRole isEqualToString:@"1"]) {
        btnKomentar.hidden = NO;
        [self setHiddenRating:YES];
        [btnKomentar setTitle:@"Beri Review" forState:UIControlStateNormal];
        [btnKomentar setTitleColor:[UIColor colorWithRed:10/255.0f green:126/255.0f blue:7/255.0f alpha:1.0f] forState:UIControlStateNormal];
    }
    else {
        btnKomentar.hidden = NO;
        if(viewModel.review_response!=nil && viewModel.review_response.response_message!=nil && viewModel.review_response.response_message.length>0 && ![viewModel.review_response.response_message isEqualToString:@"0"])
            [btnKomentar setTitle:[NSString stringWithFormat:@"1 %@", CStringKomentar] forState:UIControlStateNormal];
        else
            [btnKomentar setTitle:[NSString stringWithFormat:@"0 %@", CStringKomentar] forState:UIControlStateNormal];
        [btnKomentar setTitleColor:[UIColor colorWithRed:117/255.0f green:117/255.0f blue:117/255.0f alpha:1.0f] forState:UIControlStateNormal];
    }
    
    //Set date
    labelInfoSkip.hidden = YES;
    if([viewModel.review_is_skipped isEqualToString:@"1"]) {
        if([_strRole isEqualToString:@"2"]) {
            btnUbah.hidden = btnKomentar.hidden = YES;
            lblDate.text = @"";
            
            labelInfoSkip.text = CStringPembeliLewatiUlasan;
            viewContentStar.hidden = YES;
            labelInfoSkip.hidden = NO;
        }
    }
    else if(viewModel==nil || viewModel.review_message==nil || [viewModel.review_message isEqualToString:@"0"]) {
        if([_strRole isEqualToString:@"2"]) {
            btnUbah.hidden = btnKomentar.hidden = YES;
            lblDate.text = @"";

            labelInfoSkip.text = CStringPembeliBelumBeriUlasan;
            viewContentStar.hidden = YES;
            labelInfoSkip.hidden = NO;
        }
    }
    else {
        BOOL isEdit = !((viewModel.review_message==nil||[viewModel.review_message isEqualToString:@"0"]) || (viewModel.review_update_time==nil||[viewModel.review_update_time isEqualToString:@"0"]));
        lblDate.text = isEdit? (viewModel.review_update_time==nil||[viewModel.review_update_time isEqualToString:@"0"]? @"":viewModel.review_update_time):(viewModel.review_create_time==nil||[viewModel.review_create_time isEqualToString:@"0"]? @"":viewModel.review_create_time);
    }
}

#pragma mark - TTTAttributedLabel delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    [_delegate attributedLabel:label didSelectLinkWithURL:url];
}

#pragma mark - Gesture
- (IBAction)gesture:(UITapGestureRecognizer*)sender {
    if (((UIImageView*)attachedImages[sender.view.tag-10]).image == nil) {
        return;
    }
    
    NSMutableArray *images = [NSMutableArray new];
    for (UIImageView *imageView in attachedImages) {
        if (imageView.image != nil) {
            [images addObject:imageView];
        }
    }
    
    [_delegate goToImageViewerImages:[images copy] atIndexImage:sender.view.tag-10 atIndexPath:indexPath];
}

@end
