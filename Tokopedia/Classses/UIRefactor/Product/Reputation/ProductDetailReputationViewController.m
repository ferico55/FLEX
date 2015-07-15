//
//  ProductDetailReputationViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 6/30/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
#import "CMPopTipView.h"
#import "DetailReputationReview.h"
#import "GeneralAction.h"
#import "HPGrowingTextView.h"
#import "LikeDislike.h"
#import "ProductReputationCell.h"
#import "ProductDetailReputationCell.h"
#import "ProductReputationViewController.h"
#import "ProductDetailReputationViewController.h"
#import "ResponseCommentResult.h"
#import "ResponseComment.h"
#import "ReviewList.h"
#import "string_inbox_message.h"
#import "string_inbox_review.h"
#import "String_Reputation.h"
#import "TotalLikeDislike.h"
#import "TokopediaNetworkManager.h"
#import "ViewLabelUser.h"

#define CStringLimitText @"Panjang pesan harus lebih besar dari 5 karakter"
#define CStringSuccessSentComment @"Anda berhasil memberikan komentar"
#define CCellIdentifier @"cell"
#define CTagLikeDislike 1
#define CTagComment 2
#define CTagHapus 3

@interface ProductDetailReputationViewController ()<productReputationDelegate, TokopediaNetworkManagerDelegate, CMPopTipViewDelegate, HPGrowingTextViewDelegate, ProductDetailReputationDelegate>

@end

@implementation ProductDetailReputationViewController {
    ProductReputationCell *productReputationCell;
    TokopediaNetworkManager *tokopediaNetworkManagerLike, *tokopediaNetworkManager;
    CMPopTipView *popTipView;
    
    BOOL isSuccessSentMessage;
    NSMutableDictionary *dictCell, *dictRequestLikeDislike;
    float heightScreenView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTable];
    [self initNavigation];
    btnSend.layer.cornerRadius = 5.0f;
    btnSend.layer.masksToBounds = isSuccessSentMessage = YES;
    
    growTextView.isScrollable = NO;
    growTextView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    growTextView.layer.borderWidth = 0.5f;
    growTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    growTextView.layer.cornerRadius = 5;
    growTextView.layer.masksToBounds = YES;
    
    growTextView.minNumberOfLines = 1;
    growTextView.maxNumberOfLines = 6;
    // you can also set the maximum height in points with maxHeight
    // textView.maxHeight = 200.0f;
    growTextView.returnKeyType = UIReturnKeyGo; //just as an example
    //    _growingtextview.font = [UIFont fontWithName:@"GothamBook" size:13.0f];
    growTextView.delegate = self;
    growTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    growTextView.backgroundColor = [UIColor whiteColor];
    growTextView.placeholder = CKirimPesanMu;
    dictRequestLikeDislike = [NSMutableDictionary new];
    
    
    //Disable send button
    if(!_isMyProduct) {
        constraintHeightViewMessage.constant = 0;
    }
    else {
        if(_detailReputaitonReview != nil) {
            if(_detailReputaitonReview.product_owner!=nil && _detailReputaitonReview.review_response!=nil && _detailReputaitonReview.review_response.response_create_time!=nil && ![_detailReputaitonReview.review_response.response_create_time isEqualToString:@"0"])
                constraintHeightViewMessage.constant = 0;
        }
        else {
            if(_reviewList.review_product_owner!=nil && _reviewList.review_response!=nil && _reviewList.review_response.response_create_time!=nil && ![_reviewList.review_response.response_create_time isEqualToString:@"0"])
                constraintHeightViewMessage.constant = 0;
        }
    }
    
    //check comment can deleted or not
    if(_detailReputaitonReview!=nil && _detailReputaitonReview.review_response!=nil && _detailReputaitonReview.review_response.response_message!=nil && ![_detailReputaitonReview.review_response.response_message isEqualToString:@"0"]) {
        _detailReputaitonReview.review_response.canDelete = YES;
    }
    else if(_reviewList!=nil && _reviewList.review_response!=nil && _reviewList.review_response.response_message!=nil && ![_reviewList.review_response.response_message isEqualToString:@"0"]) {
        _reviewList.review_response.canDelete = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    heightScreenView = self.view.bounds.size.height;
    constHeightViewContent.constant = heightScreenView;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if(! isSuccessSentMessage) {
        if(_detailReputaitonReview != nil) {
            _detailReputaitonReview.review_response.response_create_time = nil;
            _detailReputaitonReview.review_response.response_message = nil;
        }
        else if(_reviewList != nil) {
            _reviewList.review_response.response_create_time = nil;
            _reviewList.review_response.response_message = nil;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Method View
- (void)initPopUp:(NSString *)strText withSender:(id)sender withRangeDesc:(NSRange)range
{
    UILabel *lblShow = [[UILabel alloc] init];
    CGFloat fontSize = 13;
    UIFont *boldFont = [UIFont boldSystemFontOfSize:fontSize];
    UIFont *regularFont = [UIFont systemFontOfSize:fontSize];
    UIColor *foregroundColor = [UIColor whiteColor];
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys: boldFont, NSFontAttributeName, foregroundColor, NSForegroundColorAttributeName, nil];
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:regularFont, NSFontAttributeName, foregroundColor, NSForegroundColorAttributeName, nil];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:strText attributes:attrs];
    [attributedText setAttributes:subAttrs range:range];
    [lblShow setAttributedText:attributedText];
    
    
    CGSize tempSize = [lblShow sizeThatFits:CGSizeMake(self.view.bounds.size.width-40, 9999)];
    lblShow.frame = CGRectMake(0, 0, tempSize.width, tempSize.height);
    lblShow.backgroundColor = [UIColor clearColor];
    
    //Init pop up
    popTipView = [[CMPopTipView alloc] initWithCustomView:lblShow];
    popTipView.delegate = self;
    popTipView.backgroundColor = [UIColor blackColor];
    popTipView.animation = CMPopTipAnimationSlide;
    popTipView.dismissTapAnywhere = YES;
    
    UIButton *button = (UIButton *)sender;
    [popTipView presentPointingAtView:button inView:self.view animated:YES];
}

- (id)initButtonContentPopUp:(NSString *)strTitle withImage:(UIImage *)image withFrame:(CGRect)rectFrame withTextColor:(UIColor *)textColor
{
    int spacing = 3;
    
    UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tempBtn.frame = rectFrame;
    [tempBtn setImage:image forState:UIControlStateNormal];
    [tempBtn setTitle:strTitle forState:UIControlStateNormal];
    [tempBtn setTitleColor:textColor forState:UIControlStateNormal];
    
    CGSize imageSize = tempBtn.imageView.bounds.size;
    CGSize titleSize = tempBtn.titleLabel.bounds.size;
    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
    
    tempBtn.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
    tempBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (totalHeight - titleSize.height),0.0);
    
    return (id)tempBtn;
}

- (void)resignKeyboardView:(id)sender {
    [growTextView resignFirstResponder];
}

- (void)initNavigation {
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
}

- (void)initTable {
    NSArray *tempArr = [[NSBundle mainBundle] loadNibNamed:@"ProductReputationCell" owner:nil options:0];
    productReputationCell = [tempArr objectAtIndex:0];
    productReputationCell.delegate = self;
    [([self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2]) setPropertyLabelDesc:productReputationCell.getLabelDesc];
    
    productReputationCell.contentView.backgroundColor = productReputationCell.getViewContent.backgroundColor;
    productReputationCell.getBtnMore.frame = CGRectZero;
    [productReputationCell.getBtnMore removeFromSuperview];
    
    
    //Set profile image
    if((_detailReputaitonReview!=nil && _detailReputaitonReview.review_message!=nil && ![_detailReputaitonReview.review_message isEqualToString:@"0"]) || (_reviewList!=nil && _reviewList.review_message!=nil && ![_reviewList.review_message isEqualToString:@"0"])) {
        [productReputationCell initProductCell];
        [productReputationCell setLabelProductName:(_detailReputaitonReview!=nil)?_detailReputaitonReview.product_name:_reviewList.review_product_name];
        
        
        //Set image product
        NSURLRequest *userImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:(_detailReputaitonReview!=nil)?_detailReputaitonReview.product_uri : _reviewList.product_images] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        productReputationCell.getProductImage.image = nil;
        [productReputationCell.getProductImage setImageWithURLRequest:userImageRequest placeholderImage:[UIImage imageNamed:@"icon_profile_picture.jpeg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            [productReputationCell.getProductImage setImage:image];
#pragma clang diagnostic pop
        } failure:nil];
    }
    
    
    //Set image profile
    NSURLRequest *userImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:(_detailReputaitonReview!=nil? _detailReputaitonReview.user_image:_reviewList.review_user_image)] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    UIImageView *userImageView = productReputationCell.getImageProfile;
    userImageView.image = nil;
    [userImageView setImageWithURLRequest:userImageRequest placeholderImage:[UIImage imageNamed:@"icon_profile_picture.jpeg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [userImageView setImage:image];
#pragma clang diagnostic pop
    } failure:nil];
    [productReputationCell setLabelUser:(_detailReputaitonReview!=nil? _detailReputaitonReview.review_full_name:_reviewList.review_user_name) withUserLabel:(_detailReputaitonReview!=nil)?_detailReputaitonReview.review_user_label:_reviewList.review_user_label];
    [productReputationCell setPercentage:(_detailReputaitonReview!=nil? _detailReputaitonReview.review_user_reputation.positive_percentage:_reviewList.review_user_reputation.positive_percentage)];
    [productReputationCell setLabelDate:(_detailReputaitonReview!=nil? (_detailReputaitonReview.review_create_time?:@""):(_reviewList.review_create_time?:@""))];
    
    if(_detailReputaitonReview != nil) {
        productReputationCell.getViewContentAction.hidden = YES;
    }
    else {
        //Set chat total
        if([_reviewList.review_response.response_message isEqualToString:@"0"]) {
            [productReputationCell.getBtnChat setTitle:_reviewList.review_response.response_message forState:UIControlStateNormal];
        }
        else {
            [productReputationCell.getBtnChat setTitle:@"1" forState:UIControlStateNormal];
        }
    }
    
    [productReputationCell setImageKualitas:[(_detailReputaitonReview!=nil? _detailReputaitonReview.product_service_point:_reviewList.review_rate_quality) intValue]];
    [productReputationCell setImageAkurasi:[(_detailReputaitonReview!=nil? _detailReputaitonReview.product_accuracy_point:_reviewList.review_rate_accuracy) intValue]];
    [productReputationCell setDescription:[NSString convertHTML:(_detailReputaitonReview!=nil? (_detailReputaitonReview.review_message?:@""):(_reviewList.review_message?:@""))]];
    
    if(_strTotalDisLike != nil) {
        [productReputationCell.getBtnLike setTitle:_strTotalLike forState:UIControlStateNormal];
        [productReputationCell.getBtnDisLike setTitle:_strTotalDisLike forState:UIControlStateNormal];
    }
    [productReputationCell layoutSubviews];
    
    //Add separator
    UIView *viewSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, productReputationCell.contentView.bounds.size.height-1, self.view.bounds.size.width, 1.0f)];
    viewSeparator.backgroundColor = [UIColor lightGrayColor];
    [productReputationCell.contentView addSubview:viewSeparator];
    
    productReputationCell.getViewSeparatorKualitas.frame = CGRectMake(0, productReputationCell.getViewContent.frame.origin.y+productReputationCell.getViewContentAction.frame.origin.y, self.view.bounds.size.width, 1);
    [productReputationCell.contentView addSubview:productReputationCell.getViewSeparatorKualitas];
    
    tableReputation.tableHeaderView = productReputationCell.contentView;
    tableReputation.backgroundColor = [UIColor colorWithRed:231/255.0f green:231/255.0f blue:231/255.0f alpha:1.0f];
    tableReputation.delegate = self;
    tableReputation.dataSource = self;
    [tableReputation reloadData];
    
    [tableReputation addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboardView:)]];
}

#pragma mark - Action
- (void)actionVote:(id)sender
{
    [self dismissAllPopTipViews];
}

- (IBAction)actionSend:(id)sender
{
    NSString *strPesan = [growTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(strPesan.length < 5) {
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringLimitText] delegate:self];
        [stickyAlertView show];
        
        return;
    }
    
    isSuccessSentMessage = NO;
    constraintHeightViewMessage.constant = 0;
    if(growTextView.isFirstResponder)
        [growTextView resignFirstResponder];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy-MM-dd";
    if(_detailReputaitonReview != nil) {
        if(_detailReputaitonReview.review_response == nil) {
            _detailReputaitonReview.review_response = [ReviewResponse new];
        }
        
        _detailReputaitonReview.review_response.response_create_time = [formatter stringFromDate:[NSDate date]];
        _detailReputaitonReview.review_response.response_message = strPesan;
        _detailReputaitonReview.review_response.failedSentMessage = NO;
    }
    else {
        if(_reviewList.review_response == nil) {
            _reviewList.review_response = [ReviewResponse new];
        }
        
        _reviewList.review_response.response_create_time = [formatter stringFromDate:[NSDate date]];
        _reviewList.review_response.response_message = strPesan;
        _reviewList.review_response.failedSentMessage = NO;
    }
    
    [tableReputation reloadData];
    [[self getNetworkManager:CTagComment] doRequest];
}


#pragma mark - UITableView Delegate and Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_detailReputaitonReview != nil) {
        if(_detailReputaitonReview.product_owner!=nil && _detailReputaitonReview.review_response!=nil && _detailReputaitonReview.review_response.response_create_time!=nil && ![_detailReputaitonReview.review_response.response_create_time isEqualToString:@"0"])
            return 1;
        return 0;
    }
    else {
        if(_reviewList.review_product_owner!=nil && _reviewList.review_response!=nil && _reviewList.review_response.response_create_time!=nil && ![_reviewList.review_response.response_create_time isEqualToString:@"0"])
            return 1;
        
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = CCellIdentifier;
    ProductDetailReputationCell *cell = [dictCell objectForKey:reuseIdentifier];
    if (! cell) {
        NSArray *tempArr = [[NSBundle mainBundle] loadNibNamed:@"ProductDetailReputationCell" owner:nil options:0];
        cell = [tempArr objectAtIndex:0];
        [cell.getViewLabelUser setText:[UIColor colorWithRed:10/255.0f green:126/255.0f blue:7/255.0f alpha:1.0f] withFont:[UIFont fontWithName:@"GothamBook" size:15.0f]];
        [dictCell setObject:cell forKey:reuseIdentifier];
    }
    
    
    cell.getTvDesc.text = _detailReputaitonReview!=nil? _detailReputaitonReview.review_response.response_message:_reviewList.review_response.response_message;
    cell.getLblDate.text = _detailReputaitonReview!=nil? _detailReputaitonReview.review_response.response_time_fmt:_reviewList.review_response.response_time_fmt;

    
    //Set image
    NSURLRequest *userImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_detailReputaitonReview!=nil? _detailReputaitonReview.product_owner.user_url:_reviewList.review_product_owner.user_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    productReputationCell.getProductImage.image = nil;
    [productReputationCell.getProductImage setImageWithURLRequest:userImageRequest placeholderImage:[UIImage imageNamed:@"icon_profile_picture.jpeg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [productReputationCell.getProductImage setImage:image];
#pragma clang diagnostic pop
    } failure:nil];
    
    
    [cell.getViewLabelUser setText:_detailReputaitonReview!=nil? _detailReputaitonReview.product_owner.full_name:_reviewList.review_product_owner.user_name];
    [cell.getViewLabelUser setLabelBackground:(_detailReputaitonReview!=nil)?_detailReputaitonReview.review_user_label:_reviewList.review_user_label];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    height += 1;
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductDetailReputationCell *cell = [tableView dequeueReusableCellWithIdentifier:CCellIdentifier];
    if(cell == nil) {
        NSArray *tempArr = [[NSBundle mainBundle] loadNibNamed:@"ProductDetailReputationCell" owner:nil options:0];
        cell = [tempArr objectAtIndex:0];
        cell.delegate = self;
        [cell.getViewLabelUser setText:[UIColor colorWithRed:10/255.0f green:126/255.0f blue:7/255.0f alpha:1.0f] withFont:[UIFont fontWithName:@"GothamBook" size:15.0f]];
    }
    cell.getTvDesc.text = _detailReputaitonReview!=nil? _detailReputaitonReview.review_response.response_message:_reviewList.review_response.response_message;
    cell.getLblDate.text = _detailReputaitonReview!=nil? _detailReputaitonReview.review_response.response_time_fmt:_reviewList.review_response.response_time_fmt;
    cell.getBtnTryAgain.tag = indexPath.row;
    cell.getBtnTryAgain.hidden = !(_detailReputaitonReview!=nil? _detailReputaitonReview.review_response.failedSentMessage:_reviewList.review_response.failedSentMessage);
    
    //Delete message
    if(_detailReputaitonReview!=nil? _detailReputaitonReview.review_response.canDelete:_reviewList.review_response.canDelete) {
        cell.getBtnHapus.hidden = NO;
    }
    else {
        cell.getBtnHapus.hidden = YES;
    }
    
    //Set image
    NSURLRequest *userImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_detailReputaitonReview!=nil? _detailReputaitonReview.product_owner.user_url:_reviewList.review_product_owner.user_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    productReputationCell.getProductImage.image = nil;
    [productReputationCell.getProductImage setImageWithURLRequest:userImageRequest placeholderImage:[UIImage imageNamed:@"icon_profile_picture.jpeg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [productReputationCell.getProductImage setImage:image];
#pragma clang diagnostic pop
    } failure:nil];
    
    
    int nStar = 0;
    if(_detailReputaitonReview != nil) {
        nStar = (_detailReputaitonReview.product_owner.shop_reputation_score==nil||_detailReputaitonReview.product_owner.shop_reputation_score.length==0? 0 : [_detailReputaitonReview.product_owner.shop_reputation_score intValue]);
    }
    else {
        nStar = 0;//(_reviewList.review_product_owner.shop_reputation_score==nil||_reviewList.review_product_owner.shop_reputation_score.length==0? 0 : [_reviewList.review_product_owner.shop_reputation_score intValue]);
    }
    
    [cell setStar:nStar];
    [cell.getViewLabelUser setText:_detailReputaitonReview!=nil? _detailReputaitonReview.product_owner.full_name:_reviewList.review_product_owner.user_name];
    [cell.getViewLabelUser setLabelBackground:(_detailReputaitonReview!=nil)?_detailReputaitonReview.review_user_label:_reviewList.review_user_label];
    cell.getViewStar.tag = indexPath.row;

    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}



#pragma mark - ProductReputation Delegate
- (void)initLabelDesc:(TTTAttributedLabel *)lblDesc withText:(NSString *)strDescription {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:strDescription];
    [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, strDescription.length)];
    lblDesc.attributedText = str;
    lblDesc.delegate = nil;
    [lblDesc addLinkToURL:[NSURL URLWithString:@""] withRange:NSMakeRange(0, 0)];
}

- (void)actionLike:(id)sender {
    
}
- (void)actionDisLike:(id)sender {
    
}
- (void)actionChat:(id)sender {

}

- (void)actionMore:(id)sender {

}


- (void)actionRate:(id)sender {
    int paddingRightLeftContent = 10;
    UIView *viewContentPopUp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (CWidthItemPopUp*3)+paddingRightLeftContent+paddingRightLeftContent, CHeightItemPopUp)];
    viewContentPopUp.backgroundColor = [UIColor clearColor];
    
    UIButton *btnMerah = (UIButton *)[self initButtonContentPopUp:(_detailReputaitonReview!=nil? _detailReputaitonReview.review_user_reputation.negative:_reviewList.review_user_reputation.negative) withImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_sad" ofType:@"png"]] withFrame:CGRectMake(paddingRightLeftContent, 0, CWidthItemPopUp, CHeightItemPopUp) withTextColor:[UIColor colorWithRed:244/255.0f green:67/255.0f blue:54/255.0f alpha:1.0f]];
    UIButton *btnKuning = (UIButton *)[self initButtonContentPopUp:(_detailReputaitonReview!=nil? _detailReputaitonReview.review_user_reputation.neutral:_reviewList.review_user_reputation.neutral) withImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_netral" ofType:@"png"]] withFrame:CGRectMake(btnMerah.frame.origin.x+btnMerah.bounds.size.width, 0, CWidthItemPopUp, CHeightItemPopUp) withTextColor:[UIColor colorWithRed:255/255.0f green:193/255.0f blue:7/255.0f alpha:1.0f]];
    UIButton *btnHijau = (UIButton *)[self initButtonContentPopUp:(_detailReputaitonReview!=nil? _detailReputaitonReview.review_user_reputation.positive:_reviewList.review_user_reputation.positive) withImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_smile" ofType:@"png"]] withFrame:CGRectMake(btnKuning.frame.origin.x+btnKuning.bounds.size.width, 0, CWidthItemPopUp, CHeightItemPopUp) withTextColor:[UIColor colorWithRed:0 green:128/255.0f blue:0 alpha:1.0f]];
    
    btnMerah.tag = CTagMerah;
    btnKuning.tag = CTagKuning;
    btnHijau.tag = CTagHijau;
    
    [btnMerah addTarget:self action:@selector(actionVote:) forControlEvents:UIControlEventTouchUpInside];
    [btnKuning addTarget:self action:@selector(actionVote:) forControlEvents:UIControlEventTouchUpInside];
    [btnHijau addTarget:self action:@selector(actionVote:) forControlEvents:UIControlEventTouchUpInside];
    
    [viewContentPopUp addSubview:btnMerah];
    [viewContentPopUp addSubview:btnKuning];
    [viewContentPopUp addSubview:btnHijau];
    
    
    //Init pop up
    popTipView = [[CMPopTipView alloc] initWithCustomView:viewContentPopUp];
    popTipView.delegate = self;
    popTipView.backgroundColor = [UIColor whiteColor];
    popTipView.animation = CMPopTipAnimationSlide;
    popTipView.dismissTapAnywhere = YES;
    
    UIButton *button = (UIButton *)sender;
    [popTipView presentPointingAtView:button inView:self.view animated:YES];
}

- (void)actionHapus:(id)sender {
    if(_detailReputaitonReview != nil) {
        _detailReputaitonReview.review_response.canDelete = NO;
    }
    else {
        _reviewList.review_response.canDelete = NO;
    }
    
    [tableReputation reloadData];
    [[self getNetworkManager:CTagHapus] doRequest];
}

- (void)actionTryAgain:(id)sender {
    if(_detailReputaitonReview != nil) {
        _detailReputaitonReview.review_response.failedSentMessage = NO;
    }
    else {
        _reviewList.review_response.failedSentMessage = NO;
    }
    
    [tableReputation reloadData];
    [[self getNetworkManager:CTagComment] doRequest];
}


#pragma mark - Notification Keyboard
- (void)keyboardDidShow:(NSNotification *)note {
    [tableReputation scrollRectToVisible:CGRectMake(0, tableReputation.contentSize.height - tableReputation.bounds.size.height, tableReputation.bounds.size.width, tableReputation.bounds.size.height) animated:YES];
}

- (void)keyboardWillShow:(NSNotification *)note {
    NSDictionary *info  = note.userInfo;
    NSValue *value = info[UIKeyboardFrameEndUserInfoKey];
    CGRect rawFrame = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    constHeightViewContent.constant = heightScreenView-keyboardFrame.size.height;
}

- (void)keyboardWillHide:(NSNotification *)note {
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    constHeightViewContent.constant = heightScreenView;
    [UIView commitAnimations];
}

#pragma mark - PopUp
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    [self dismissAllPopTipViews];
}


#pragma mark - Method
- (void)configureRestkit {
    RKObjectManager *_objectManager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[GeneralAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[GeneralActionResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPD_APIISSUCCESSKEY:kTKPD_APIISSUCCESSKEY}];
    
    //relation
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
    [statusMapping addPropertyMapping:resulRel];
    
    
    //register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:ADD_REVIEW_PATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptorStatus];
}

//- (void)doSendComment {
//    if(_request.isExecuting) return;
//    _requestCount++;
//    
//    NSDictionary *param = @{@"action" : @"add_comment_review", @"review_id" : _review.review_id, @"text_comment" : _commentReview};
//    _request = [_objectManager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:ADD_REVIEW_PATH parameters:[param encrypt]];
//    
//    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//        [self requestSuccess:mappingResult withOperation:operation];
//        
//    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//        
//    }];
//    
//    [_operationQueue addOperation:_request];
//}

- (TokopediaNetworkManager *)getNetworkManager:(int)tag {
    if(tag == CTagLikeDislike) {
        if(tokopediaNetworkManagerLike == nil) {
            tokopediaNetworkManagerLike = [TokopediaNetworkManager new];
            tokopediaNetworkManagerLike.tagRequest = tag;
//            tokopediaNetworkManagerLike.delegate = self;
        }
        
        return tokopediaNetworkManagerLike;
    }
    else if(tag==CTagComment || tag==CTagHapus) {
        if(tokopediaNetworkManager == nil) {
            tokopediaNetworkManager = [TokopediaNetworkManager new];
            tokopediaNetworkManager.delegate = self;
        }
        tokopediaNetworkManager.tagRequest = tag;
        
        return tokopediaNetworkManager;
    }
    
    return nil;
}

- (void)updateLikeDislike:(LikeDislike *)likeDislikeObj {
    [productReputationCell.getBtnDisLike setTitle:((TotalLikeDislike *) [likeDislikeObj.result.like_dislike_review firstObject]).total_like_dislike.total_dislike  forState:UIControlStateNormal];
    [productReputationCell.getBtnLike setTitle:((TotalLikeDislike *) [likeDislikeObj.result.like_dislike_review firstObject]).total_like_dislike.total_like  forState:UIControlStateNormal];
}

- (void)dismissAllPopTipViews
{
    [popTipView dismissAnimated:YES];
    popTipView = nil;
}

#pragma mark - HPGrowingTextView Delegate
- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView
{

}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    constraintHeightViewMessage.constant = (height+growingTextView.frame.origin.y*2);
}


#pragma mark - ProductDetailReputation Delegate
- (void)actionTapStar:(UIView *)sender
{
    NSString *strText = @"1,000,100 Like";
    [self initPopUp:strText withSender:sender withRangeDesc:NSMakeRange(strText.length-4, 4)];
}


#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag {
    if(tag == CTagComment) {
        if(_detailReputaitonReview != nil) {
            return @{@"action":@"insert_reputation_review_response",
                 @"reputation_id":_detailReputaitonReview.reputation_id,
                 @"shop_id":_detailReputaitonReview.shop_id,
                 @"review_id":_detailReputaitonReview.review_id,
                 @"response_message":[growTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]};
        }
        else if(_reviewList != nil) {
            return @{@"action":@"insert_reputation_review_response",
                     @"reputation_id":_reviewList.review_reputation_id,
                     @"shop_id":_reviewList.review_shop_id,
                     @"review_id":_reviewList.review_id,
                     @"response_message":[growTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]};
        }
    }
    else if(tag == CTagHapus) {
        if(_detailReputaitonReview != nil) {
            return @{@"action":@"delete_reputation_review_response",
                     @"reputation_id":_detailReputaitonReview.reputation_id,
                     @"shop_id":_detailReputaitonReview.shop_id,
                     @"review_id":_detailReputaitonReview.review_id,
                     @"product_id":_detailReputaitonReview.product_id
                     };
        }
        else if(_reviewList != nil) {
            return @{@"action":@"delete_reputation_review_response",
                     @"reputation_id":_reviewList.review_reputation_id,
                     @"shop_id":_reviewList.review_shop_id,
                     @"review_id":_reviewList.review_id,
                     @"product_id":_reviewList.review_product_id
                     };
        }
    }
    
    return nil;
}


- (NSString*)getPath:(int)tag {
    if(tag==CTagComment || tag==CTagHapus) {
        return @"action/reputation.pl";
    }
    
    return nil;
}

- (id)getObjectManager:(int)tag {
    if(tag == CTagComment) {
        RKObjectManager *objectManager = [RKObjectManager sharedClient];
        RKObjectMapping *responseCommentMapping = [RKObjectMapping mappingForClass:[ResponseComment class]];
        [responseCommentMapping addAttributeMappingsFromArray:@[CStatus,
                                                                CServerProcessTime,
                                                                CMessageError]];
        
        RKObjectMapping *responseCommentResultMapping = [RKObjectMapping mappingForClass:[ResponseCommentResult class]];
        [responseCommentResultMapping addAttributeMappingsFromArray:@[CIsOwner,
                                                                      CReputationReviewCounter,
                                                                      CIsSuccess,
                                                                      CShowBookmark,
                                                                      CReviewID]];
        
        RKObjectMapping *productOwnerMapping = [RKObjectMapping mappingForClass:[ProductOwner class]];
        [productOwnerMapping addAttributeMappingsFromArray:@[CShopID,
                                                             CUserLabelID,
                                                             CUserURL,
                                                             CShopImg,
                                                             CShopUrl,
                                                             CShopName,
                                                             CFullName,
                                                             CUserImg,
                                                             CUserLabel,
                                                             CuserID,
                                                             CShopReputationBadge,
                                                             CShopReputation]];
        
        RKObjectMapping *reviewResponseMapping = [RKObjectMapping mappingForClass:[ReviewResponse class]];
        [reviewResponseMapping addAttributeMappingsFromDictionary:@{CResponseMsg:CResponseMessage,
                                                                    CResponseTimeFmt:CResponseTimeFmt,
                                                                    CResponseTimeAgo:CResponseTimeAgo
                                                                    }];
        
        //Relation
        [responseCommentMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CResult toKeyPath:CResult withMapping:responseCommentResultMapping]];
        [responseCommentResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CProductOwner toKeyPath:CProductOwner withMapping:productOwnerMapping]];
        [responseCommentResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReviewResponse toKeyPath:CReviewResponse withMapping:reviewResponseMapping]];

        // register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:responseCommentMapping
                                                                                                      method:RKRequestMethodPOST
                                                                                                 pathPattern:[self getPath:tag]
                                                                                                     keyPath:@""
                                                                                                 statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [objectManager addResponseDescriptor:responseDescriptorStatus];
        return objectManager;
    }
    else if(tag == CTagHapus) {
        RKObjectManager *objectManager = [RKObjectManager sharedClient];
        
        return objectManager;
    }
    
    return nil;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag {
    if(tag == CTagComment) {
        ResponseComment *responseComment = [((RKMappingResult *) result).dictionary objectForKey:@""];
        
        return responseComment.status;
    }
    
    return nil;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag {
    if(tag == CTagComment) {
        ResponseComment *responseComment = [((RKMappingResult *) successResult).dictionary objectForKey:@""];
        if([responseComment.result.is_success isEqualToString:@"1"]) {
            isSuccessSentMessage = YES;
            
            if(_detailReputaitonReview != nil) {
                _detailReputaitonReview.review_response.response_create_time = responseComment.result.review_response.response_time_ago;
                _detailReputaitonReview.review_response.response_message = responseComment.result.review_response.response_message;
                _detailReputaitonReview.review_response.failedSentMessage = NO;
                _detailReputaitonReview.review_response.canDelete = YES;
                _detailReputaitonReview.product_owner.shop_id = responseComment.result.product_owner.shop_id;
                _detailReputaitonReview.product_owner.user_label_id = responseComment.result.product_owner.user_label_id;
                _detailReputaitonReview.product_owner.user_url = responseComment.result.product_owner.user_url;
                _detailReputaitonReview.product_owner.shop_img = responseComment.result.product_owner.shop_img;
                _detailReputaitonReview.product_owner.shop_url = responseComment.result.product_owner.shop_url;
                _detailReputaitonReview.product_owner.shop_name = responseComment.result.product_owner.shop_name;
                _detailReputaitonReview.product_owner.full_name = responseComment.result.product_owner.full_name;
                _detailReputaitonReview.product_owner.user_img = responseComment.result.product_owner.user_img;
                _detailReputaitonReview.product_owner.user_label = responseComment.result.product_owner.user_label;
                _detailReputaitonReview.product_owner.user_id = responseComment.result.product_owner.user_id;
                _detailReputaitonReview.product_owner.shop_reputation_badge = responseComment.result.product_owner.shop_reputation_badge;
                _detailReputaitonReview.product_owner.shop_reputation_score = responseComment.result.product_owner.shop_reputation_score;
            }
            else if(_reviewList != nil) {
                _reviewList.review_response.response_create_time = responseComment.result.review_response.response_time_ago;
                _reviewList.review_response.response_message = responseComment.result.review_response.response_message;
                 _reviewList.review_response.failedSentMessage = NO;
                 _reviewList.review_response.canDelete = YES;
                _reviewList.review_product_owner.user_image = responseComment.result.product_owner.user_img;
                _reviewList.review_product_owner.user_name = responseComment.result.product_owner.full_name;
                _reviewList.review_product_owner.user_id = responseComment.result.product_owner.user_id;
            }
            
            StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[CStringSuccessSentComment] delegate:self];
            [stickyAlertView show];
        }
        else {
            if(_detailReputaitonReview != nil) {
                _detailReputaitonReview.review_response.failedSentMessage = YES;
            }
            else if(_reviewList != nil) {
                _reviewList.review_response.failedSentMessage = YES;
            }
        }

        [tableReputation reloadData];
    }
    else if(tag == CTagHapus) {
        if(successResult) {
            if(_detailReputaitonReview != nil) {
                _detailReputaitonReview.review_response.canDelete = NO;
                _detailReputaitonReview.review_response.response_message = nil;
                _detailReputaitonReview.review_response.response_create_time = nil;
            }
            else if(_reviewList != nil) {
                _reviewList.review_response.canDelete = NO;
                _reviewList.review_response.response_message = nil;
                _reviewList.review_response.response_create_time = nil;
            }
        }
        else {
            if(_detailReputaitonReview != nil) {
                _detailReputaitonReview.review_response.canDelete = YES;
            }
            else if(_reviewList != nil) {
                _reviewList.review_response.canDelete = YES;
            }
        }
        
        
        
        [tableReputation reloadData];
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {

}

- (void)actionBeforeRequest:(int)tag {

}

- (void)actionRequestAsync:(int)tag {
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    if(tag == CTagComment) {
        if(_detailReputaitonReview != nil) {
            _detailReputaitonReview.review_response.failedSentMessage = YES;
        }
        else {
            _reviewList.review_response.failedSentMessage = YES;
        }
        
        [tableReputation reloadData];
    }
    else if(tag == CTagHapus) {
        if(_detailReputaitonReview != nil) {
            _detailReputaitonReview.review_response.canDelete = YES;
        }
        else {
            _reviewList.review_response.canDelete = YES;
        }
        
        [tableReputation reloadData];
    }
}
@end
