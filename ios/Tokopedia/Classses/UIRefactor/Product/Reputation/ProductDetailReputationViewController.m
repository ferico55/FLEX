
//
//  ProductDetailReputationViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 6/30/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
#import "CMPopTipView.h"
#import "detail.h"
#import "DetailReputationReview.h"
#import "GeneralAction.h"
#import "HPGrowingTextView.h"
#import "LikeDislike.h"
#import "LikeDislikePost.h"
#import "LikeDislikePostResult.h"
#import "MGSwipeButton.h"
#import "ProductReputationCell.h"
#import "ProductDetailReputationCell.h"
#import "ProductReputationViewController.h"
#import "ProductDetailReputationViewController.h"
#import "ResponseCommentResult.h"
#import "ResponseComment.h"
#import "ReviewList.h"
#import "ShopReputation.h"
#import "SmileyAndMedal.h"
#import "ShopBadgeLevel.h"
#import "ShopReviewPageViewController.h"
#import "string_inbox_message.h"
#import "string_inbox_review.h"
#import "String_Reputation.h"
#import "TotalLikeDislike.h"
#import "TotalLikeDislikePost.h"
#import "TokopediaNetworkManager.h"
#import "UserContainerViewController.h"
#import "ViewLabelUser.h"
#import "NavigateViewController.h"
#import "NavigationHelper.h"
#import "ReviewRequest.h"
#import "ReviewImageAttachment.h"
#import "Tokopedia-Swift.h"

#define CStringLimitText @"Panjang pesan harus lebih besar dari 5 karakter"
#define CStringSuccessSentComment @"Anda berhasil memberikan komentar"
#define CCellIdentifier @"cell"
#define CTagLikeDislike 1
#define CTagComment 2
#define CTagHapus 3

@interface ProductDetailReputationViewController () <
productReputationDelegate,
CMPopTipViewDelegate,
HPGrowingTextViewDelegate,
ProductDetailReputationDelegate,
SmileyDelegate,
MGSwipeTableCellDelegate
>
@end

@implementation ProductDetailReputationViewController {
    ProductReputationCell *productReputationCell;
    NSOperationQueue *operationQueueLikeDislike;
    CMPopTipView *popTipView;
    
    NSInteger _count;
    NavigateViewController *_TKPDNavigator;
    
    ReviewRequest *reviewRequest;
    TotalLikeDislike *_totalLikeDislike;
    
    __block NSTimer *_timer;
    BOOL isSuccessSentMessage, isDeletingMessage;
    NSMutableDictionary *dictCell, *dictRequestLikeDislike;
    float heightScreenView;
}
@synthesize loadingLikeDislike, dictLikeDislike;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTable];
    [self initNavigation];
    
    CGRect newFrame = [UIScreen mainScreen].bounds;
    newFrame.size.height -= 60;
    self.view.frame = newFrame;
    
    btnSend.layer.cornerRadius = 5.0f;
    btnSend.layer.masksToBounds = isSuccessSentMessage = YES;
    _TKPDNavigator = [NavigateViewController new];
    
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
    growTextView.delegate = self;
    growTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    growTextView.backgroundColor = [UIColor whiteColor];
    growTextView.placeholder = CKirimPesanMu;
    dictRequestLikeDislike = [NSMutableDictionary new];
    
    tableReputation.estimatedRowHeight = 44.0;
    tableReputation.rowHeight = UITableViewAutomaticDimension;
    
    
    //Disable send button
    if(!_isMyProduct) {
        constraintHeightViewMessage.constant = 0;
    }
    else {
        if(_detailReputationReview.product_owner!=nil && _detailReputationReview.review_response!=nil && _detailReputationReview.review_response.response_create_time!=nil && ![_detailReputationReview.review_response.response_create_time isEqualToString:@"0"])
            constraintHeightViewMessage.constant = 0;
        
    }
    
    //check comment can deleted or not
    if(_detailReputationReview!=nil && _detailReputationReview.review_response!=nil && _detailReputationReview.review_response.response_message!=nil && ![_detailReputationReview.review_response.response_message isEqualToString:@"0"]) {
        _detailReputationReview.review_response.canDelete = YES;
    }
    
    reviewRequest = [[ReviewRequest alloc] init];
    [reviewRequest requestReviewLikeDislikesWithId:_detailReputationReview.review_id
                                            shopId:_detailReputationReview.shop_id?:_detailReputationReview.review_shop_id
                                         onSuccess:^(TotalLikeDislike *totalLikeDislike) {
                                             _totalLikeDislike = totalLikeDislike;
                                             _strTotalLike = totalLikeDislike.total_like_dislike.total_like;
                                             _strTotalDisLike = totalLikeDislike.total_like_dislike.total_dislike;
                                             _strLikeStatus = totalLikeDislike.like_status;
                                             if(_detailReputationReview!=nil && [totalLikeDislike.review_id isEqualToString:_detailReputationReview.review_id]) {
                                                 [productReputationCell setHiddenViewLoad:YES];
                                                 [productReputationCell.getBtnDisLike setTitle:totalLikeDislike.total_like_dislike.total_dislike forState:UIControlStateNormal];
                                                 [productReputationCell.getBtnLike setTitle:totalLikeDislike.total_like_dislike.total_like  forState:UIControlStateNormal];
                                                 
                                                 [self setLikeDislikeActive:totalLikeDislike.like_status];
                                             }
                                         } onFailure:^(NSError *errorResult) {
                                         }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    heightScreenView = self.view.bounds.size.height;
    constHeightViewContent.constant = heightScreenView;
    
    [AnalyticsManager trackScreenName:@"Product Review Detail Page"];
    
    [tableReputation setHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if(! isSuccessSentMessage) {
        _detailReputationReview.review_response.response_create_time = _detailReputationReview.viewModel.review_response.response_create_time = nil;
        _detailReputationReview.review_response.response_message = _detailReputationReview.viewModel.review_response.response_message = nil;
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [tableReputation setHidden:NO];
    [tableReputation mas_makeConstraints: ^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.left.equalTo(@0);
    }];
    [tableReputation.tableHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.left.equalTo(@0);
        make.height.equalTo(productReputationCell.contentView.mas_height);
    }];
    [tableReputation reloadData];
}

- (void)dealloc {
    [_timer invalidate];
    [operationQueueLikeDislike cancelAllOperations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    UIButton *button = (UIButton *)sender;
    popTipView = [[CMPopTipView alloc] initWithCustomView:lblShow];
    popTipView.delegate = self;
    popTipView.backgroundColor = [UIColor blackColor];
    popTipView.animation = CMPopTipAnimationSlide;
    popTipView.dismissTapAnywhere = YES;
    popTipView.leftPopUp = YES;
    [popTipView presentPointingAtView:button inView:self.view animated:YES];
}

- (void)resignKeyboardView:(id)sender {
    [growTextView resignFirstResponder];
}

- (void)initNavigation {
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    self.title = @"Detil Ulasan";
}


- (void)initTable {
    NSArray *tempArr = [[NSBundle mainBundle] loadNibNamed:@"ProductReputationCell" owner:nil options:0];
    productReputationCell = [tempArr objectAtIndex:0];
    productReputationCell.delegate = self;
    productReputationCell.hasAttachedImages = (_detailReputationReview.review_image_attachment.count > 0);
    
    [([self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2]) setPropertyLabelDesc:productReputationCell.getLabelDesc];
    
    productReputationCell.frame = CGRectMake(productReputationCell.frame.origin.x, productReputationCell.frame.origin.y, self.view.bounds.size.width, productReputationCell.bounds.size.height);
    productReputationCell.getViewContent.frame = CGRectMake(CPaddingTopBottom, productReputationCell.getViewContent.frame.origin.y, productReputationCell.bounds.size.width-(CPaddingTopBottom*2), productReputationCell.getViewContent.bounds.size.height);
    
    
    productReputationCell.contentView.backgroundColor = productReputationCell.getViewContent.backgroundColor;
    productReputationCell.getBtnMore.frame = CGRectZero;
    [productReputationCell.getBtnMore removeFromSuperview];
    productReputationCell.getBtnMore.hidden = YES;
    [productReputationCell.getLabelUser setText:[UIColor colorWithRed:62/255.0f green:114/255.0f blue:9/255.0f alpha:1.0f] withFont:[UIFont largeThemeMedium]];
    
    //Set profile image
    BOOL isResizeSeparatorProduct;
    if(_isShowingProductView) {
        [productReputationCell initProductCell];
        
        NSString *strTempProductName = _detailReputationReview.product_name;
        if(strTempProductName==nil || [strTempProductName isEqualToString:@"0"]) {
            [productReputationCell setLabelProductName:@"-"];
            constraintHeightViewMessage.constant = 0;
        }
        else
            [productReputationCell setLabelProductName:strTempProductName];
        [[productReputationCell getLabelProductName] addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToDetailProduct:)]];
        [productReputationCell getLabelProductName].userInteractionEnabled = [NavigationHelper shouldDoDeepNavigation];
        [productReputationCell.getViewSeparatorProduct removeFromSuperview];
        isResizeSeparatorProduct = YES;
        [productReputationCell.contentView addSubview:productReputationCell.getViewSeparatorProduct];
        
        
        NSString *strProductStatus = _detailReputationReview.review_product_status;
        //check product deleted
        if([strProductStatus isEqualToString:@"1"]) {
            productReputationCell.getLabelProductName.userInteractionEnabled = [NavigationHelper shouldDoDeepNavigation];
            [productReputationCell.getLabelProductName setTextColor:[UIColor colorWithRed:66/255.0f green:66/255.0f blue:66/255.0f alpha:1.0f]];
        }
        else {
            productReputationCell.getLabelProductName.userInteractionEnabled = NO;
            [productReputationCell.getLabelProductName setTextColor:[UIColor colorWithRed:117/255.0f green:117/255.0f blue:117/255.0f alpha:1.0f]];
        }
        
        //Set image product
        NSURLRequest *userImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_detailReputationReview.product_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        productReputationCell.getProductImage.image = nil;
        [productReputationCell.getProductImage setImageWithURLRequest:userImageRequest placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_toped_loading_grey" ofType:@"png"]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            [productReputationCell.getProductImage setImage:image];
#pragma clang diagnostic pop
        } failure:nil];
    }
    
    //Set image profile
    NSURLRequest *userImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_detailReputationReview.review_user_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    UIImageView *userImageView = productReputationCell.getImageProfile;
    userImageView.image = nil;
    [userImageView setImageWithURLRequest:userImageRequest placeholderImage:[UIImage imageNamed:@"icon_profile_picture.jpeg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [userImageView setImage:image];
#pragma clang diagnostic pop
    } failure:nil];
    [productReputationCell setLabelUser:_detailReputationReview.review_user_name
                          withUserLabel:_detailReputationReview.review_user_label];
    
    [productReputationCell setPercentage:(_detailReputationReview.review_user_reputation.positive_percentage)];
    [productReputationCell setLabelDate:_detailReputationReview.review_create_time];
    
    NSString *strResponseMessage = _detailReputationReview.review_response.response_message;
    NSString *strUserID = _detailReputationReview.product_owner.user_id;
    
    UserAuthentificationManager *_userManager = [UserAuthentificationManager new];
    NSDictionary *auth = [_userManager getUserLoginData];
    if(auth!=nil && [[NSString stringWithFormat:@"%@", [auth objectForKey:@"user_id"]] isEqualToString:strUserID]) {
        [productReputationCell.getBtnChat setHidden:NO];
        
        //Set chat total
        if([strResponseMessage isEqualToString:@"0"]) {
            [productReputationCell.getBtnChat setTitle:[NSString stringWithFormat:@"%@ Komentar", strResponseMessage] forState:UIControlStateNormal];
        }
        else {
            [productReputationCell.getBtnChat setTitle:@"1 Komentar" forState:UIControlStateNormal];
        }
    }
    else {
        [productReputationCell.getBtnChat setHidden:YES];
    }
    
    //Set loading like dislike
    if([loadingLikeDislike objectForKey:_detailReputationReview.review_id]) {
        [productReputationCell setHiddenViewLoad:NO];
    }
    
    [productReputationCell setImageKualitas:[_detailReputationReview.product_rating_point intValue]];
    [productReputationCell setImageAkurasi:[_detailReputationReview.product_accuracy_point intValue]];
    [productReputationCell setDescription:[NSString convertHTML:_detailReputationReview.review_message]];
    
    if (_detailReputationReview.review_image_attachment.count > 0) {
        [productReputationCell setAttachedImages:_detailReputationReview.review_image_attachment];
    }
    
    if(_strTotalDisLike != nil || ![_strTotalDisLike isEqualToString:@""]) {
        [productReputationCell.getBtnLike setTitle:_strTotalLike forState:UIControlStateNormal];
        [productReputationCell.getBtnDisLike setTitle:_strTotalDisLike forState:UIControlStateNormal];
        [self setLikeDislikeActive:_strLikeStatus];
    }else{
        [productReputationCell.getBtnLike setTitle:_detailReputationReview.review_like_dislike.total_like forState:UIControlStateNormal];
        [productReputationCell.getBtnDisLike setTitle:_detailReputationReview.review_like_dislike.total_dislike forState:UIControlStateNormal];
        [self setLikeDislikeActive:_strLikeStatus];
        
    }
    
    [productReputationCell layoutSubviews];
    //productReputationCell.contentView.frame = CGRectMake(0, 0, productReputationCell.contentView.bounds.size.width, productReputationCell.contentView.bounds.size.height-CPaddingTopBottom-CPaddingTopBottom);
    productReputationCell.contentView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, productReputationCell.contentView.bounds.size.height-CPaddingTopBottom-CPaddingTopBottom);
    
    productReputationCell.getViewContent.frame = CGRectMake(productReputationCell.getViewContent.frame.origin.x, 0, [[UIScreen mainScreen] bounds].size.width, productReputationCell.getViewContent.bounds.size.height-CPaddingTopBottom);
    
    if(isResizeSeparatorProduct)
        [productReputationCell.getViewSeparatorProduct setFrame:CGRectMake(0, productReputationCell.getViewSeparatorProduct.frame.origin.y+productReputationCell.getViewContent.frame.origin.y, ((AppDelegate *) [UIApplication sharedApplication].delegate).window.bounds.size.width, productReputationCell.getViewSeparatorProduct.bounds.size.height)];
    
    productReputationCell.getViewSeparatorKualitas.frame = CGRectMake(0, productReputationCell.getViewContent.frame.origin.y+productReputationCell.getViewContentAction.frame.origin.y, ((AppDelegate *) [UIApplication sharedApplication].delegate).window.bounds.size.width, 1);
    [productReputationCell.contentView addSubview:productReputationCell.getViewSeparatorKualitas];
    [productReputationCell.getLabelUser addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToShopView:)]];
    productReputationCell.getLabelUser.userInteractionEnabled = [NavigationHelper shouldDoDeepNavigation];
    
    tableReputation.tableHeaderView = productReputationCell.contentView;
    tableReputation.backgroundColor = [UIColor colorWithRed:231/255.0f green:231/255.0f blue:231/255.0f alpha:1.0f];
    tableReputation.delegate = self;
    tableReputation.dataSource = self;
    [tableReputation reloadData];
    
    [tableReputation addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboardView:)]];
}


#pragma mark - Action
- (void)goToShopView:(id)sender {
    if([_detailReputationReview.review_user_label caseInsensitiveCompare:CPenjual] == NSOrderedSame) {
        ShopViewController *shopViewController = [ShopViewController new];
        shopViewController.data = @{kTKPDDETAIL_APISHOPIDKEY:_detailReputationReview.shop_id};
        [self.navigationController pushViewController:shopViewController animated:YES];
    }
    else {
        UserContainerViewController *container = [UserContainerViewController new];
        container.profileUserID = _detailReputationReview.review_user_id;
        [self.navigationController pushViewController:container animated:YES];
    }
}

- (void)goToDetailProduct:(id)sender {
    [_TKPDNavigator navigateToProductFromViewController:self
                                               withName:_detailReputationReview.product_name
                                              withPrice:nil
                                                 withId:_detailReputationReview.review_product_id
                                           withImageurl:_detailReputationReview.product_image
                                           withShopName:_detailReputationReview.product_owner.shop_name];
}

- (void)actionVote:(id)sender
{
    [self dismissAllPopTipViews];
}

- (void)userHasLogin {
    [productReputationCell setHiddenViewLoad:NO];
    
    UIViewController *viewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    if([viewController isMemberOfClass:[ProductReputationViewController class]]) {
        [reviewRequest requestReviewLikeDislikesWithId:_detailReputationReview.review_id
                                                shopId:_detailReputationReview.shop_id?:_detailReputationReview.review_shop_id
                                             onSuccess:^(TotalLikeDislike *totalLikeDislike) {
                                                 _strTotalLike = totalLikeDislike.total_like_dislike.total_like;
                                                 _strTotalDisLike = totalLikeDislike.total_like_dislike.total_dislike;
                                                 
                                                 if([totalLikeDislike.review_id isEqualToString:_detailReputationReview.review_id]) {
                                                     [productReputationCell setHiddenViewLoad:YES];
                                                     [productReputationCell.getBtnDisLike setTitle:totalLikeDislike.total_like_dislike.total_dislike forState:UIControlStateNormal];
                                                     [productReputationCell.getBtnLike setTitle:totalLikeDislike.total_like_dislike.total_like  forState:UIControlStateNormal];
                                                     
                                                     [self setLikeDislikeActive:totalLikeDislike.like_status];
                                                 }
                                             } onFailure:^(NSError *errorResult) {
                                                 
                                             }];
    }
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
    if(_detailReputationReview.review_response == nil) {
        _detailReputationReview.review_response = [ReviewResponse new];
    }
    
    _detailReputationReview.review_response.response_create_time = [formatter stringFromDate:[NSDate date]];
    _detailReputationReview.review_response.response_message = strPesan;
    _detailReputationReview.review_response.failedSentMessage = NO;
    
    [tableReputation reloadData];
    [self requestInsertReputationResponse];
}


#pragma mark - UITableView Delegate and Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isDeletingMessage)
        return 0;
    
    if(_detailReputationReview.product_owner!=nil && _detailReputationReview.review_response!=nil && _detailReputationReview.review_response.response_create_time!=nil && ![_detailReputationReview.review_response.response_create_time isEqualToString:@"0"])
        return 1;
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductDetailReputationCell *cell = [tableView dequeueReusableCellWithIdentifier:CCellIdentifier];
    if(cell == nil) {
        NSArray *tempArr = [[NSBundle mainBundle] loadNibNamed:@"ProductDetailReputationCell" owner:nil options:0];
        cell = [tempArr objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        cell.getViewLabelUser.userInteractionEnabled = [NavigationHelper shouldDoDeepNavigation];
        [cell.getViewLabelUser addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapCellLabelUser:)]];
    }
    
    cell.getViewLabelUser.tag = indexPath.row;
    cell.getTvDesc.text = _detailReputationReview.review_response.response_message;
    cell.getLblDate.text = _detailReputationReview.review_response.response_time_fmt?:_detailReputationReview.review_response.response_create_time;
    cell.getBtnTryAgain.tag = indexPath.row;
    cell.getBtnTryAgain.hidden = !(_detailReputationReview.review_response.failedSentMessage);
    
    //Set image
    NSURLRequest *userImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_shopImage?:_detailReputationReview.product_owner.shop_img] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    [cell.getImgProfile setImageWithURLRequest:userImageRequest placeholderImage:[UIImage imageNamed:@"icon_profile_picture.jpeg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [cell.getImgProfile setImage:image];
#pragma clang diagnostic pop
    } failure:nil];
    
    
    
    [cell setStar:_shopBadgeLevel.level withSet:_shopBadgeLevel.set];
    [cell.getViewLabelUser setText:_detailReputationReview.review_shop_name?:_detailReputationReview.product_owner.shop_name];
    [cell.getViewLabelUser setText:[UIColor colorWithRed:10/255.0f green:126/255.0f blue:7/255.0f alpha:1.0f] withFont:[UIFont smallThemeMedium]];
    [cell.getViewLabelUser setLabelBackground:(_detailReputationReview!=nil)?_detailReputationReview.product_owner.user_label:CPenjual];
    cell.getViewStar.tag = indexPath.row;
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - ProductReputation Delegate
- (void)initLabelDesc:(TTTAttributedLabel *)lblDesc withText:(NSString *)strDescription {
    strDescription = [NSString convertHTML:strDescription];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:strDescription];
    [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, strDescription.length)];
    [str addAttribute:NSFontAttributeName value:[UIFont largeTheme] range:NSMakeRange(0, strDescription.length)];
    
    
    lblDesc.attributedText = str;
    lblDesc.delegate = nil;
    [lblDesc addLinkToURL:[NSURL URLWithString:@""] withRange:NSMakeRange(0, 0)];
}

- (void)actionLike:(id)sender {
    [productReputationCell disableTouchLikeDislikeButton];
    UserAuthentificationManager *_userManager = [UserAuthentificationManager new];
    NSDictionary *auth = [_userManager getUserLoginData];
    
    if(auth) {
        //[productReputationCell.getBtnLike setImage:[UIImage imageNamed:@"loading-icon.gif"] forState:UIControlStateNormal];
        if(_strLikeStatus == nil || [_strLikeStatus isEqualToString:@"3"] || [_strLikeStatus isEqualToString:@"2"]){
            [reviewRequest actionLikeWithReviewId:_detailReputationReview.review_id
                                           shopId:_detailReputationReview.shop_id?:_detailReputationReview.review_shop_id
                                        productId:_detailReputationReview.product_id?:_detailReputationReview.review_product_id
                                           userId:[_userManager getUserId]
                                        onSuccess:^(LikeDislikePostResult *likeDislikePostResult) {
                                            
                                            if([likeDislikePostResult.is_success isEqualToString:@"1"]){
                                                _strLikeStatus = @"1";
                                                [[productReputationCell getBtnLike] setTitle:likeDislikePostResult.content.total_like_dislike.total_like forState:UIControlStateNormal];
                                                [[productReputationCell getBtnDisLike] setTitle:likeDislikePostResult.content.total_like_dislike.total_dislike forState:UIControlStateNormal];
                                                [self setLikeDislikeActive:_strLikeStatus];
                                            }else{
                                                StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:@[@"Respon Anda tidak dapat diproses pada ulasan ini."] delegate:self];
                                                [alert show];
                                                [self setLikeDislikeActive:_strLikeStatus];
                                            }
                                        } onFailure:^(NSError *errorResult) {
                                            [self setLikeDislikeActive:_strLikeStatus];
                                            [self showNetworkFailStickyAlert];
                                        }];
        }else{
            [reviewRequest actionCancelLikeDislikeWithReviewId:_detailReputationReview.review_id
                                                        shopId:_detailReputationReview.shop_id?:_detailReputationReview.review_shop_id
                                                     productId:_detailReputationReview.product_id?:_detailReputationReview.review_product_id
                                                        userId:[_userManager getUserId]
                                                     onSuccess:^(LikeDislikePostResult *likeDislikePostResult) {
                                                         if([likeDislikePostResult.is_success isEqualToString:@"1"]){
                                                             [[productReputationCell getBtnLike] setTitle:likeDislikePostResult.content.total_like_dislike.total_like forState:UIControlStateNormal];
                                                             [[productReputationCell getBtnDisLike] setTitle:likeDislikePostResult.content.total_like_dislike.total_dislike forState:UIControlStateNormal];
                                                             _strLikeStatus = @"3";
                                                             [self setLikeDislikeActive:_strLikeStatus];
                                                         }else{
                                                             StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:@[@"Respon Anda tidak dapat diproses pada ulasan ini."] delegate:self];
                                                             [alert show];
                                                             [self setLikeDislikeActive:_strLikeStatus];
                                                         }
                                                     } onFailure:^(NSError *errorResult) {
                                                         [self setLikeDislikeActive:_strLikeStatus];
                                                         [self showNetworkFailStickyAlert];
                                                     }];
        }
    }else {
        [self showLoginView:YES];
    }
}

- (void)actionDisLike:(id)sender {
    [productReputationCell disableTouchLikeDislikeButton];
    UserAuthentificationManager *_userManager = [UserAuthentificationManager new];
    NSDictionary *auth = [_userManager getUserLoginData];
    
    if(auth) {
        //[productReputationCell.getBtnDisLike setImage:[UIImage imageNamed:@"loading-icon.gif"] forState:UIControlStateNormal];
        if(_strLikeStatus == nil || [_strLikeStatus isEqualToString:@"3"] || [_strLikeStatus isEqualToString:@"1"]){
            [reviewRequest actionDislikeWithReviewId:_detailReputationReview.review_id
                                              shopId:_detailReputationReview.shop_id?:_detailReputationReview.review_shop_id
                                           productId:_detailReputationReview.product_id?:_detailReputationReview.review_product_id
                                              userId:[_userManager getUserId]
                                           onSuccess:^(LikeDislikePostResult *likeDislikePostResult) {
                                               if([likeDislikePostResult.is_success isEqualToString:@"1"]){
                                                   _strLikeStatus = @"2";
                                                   [[productReputationCell getBtnLike] setTitle:likeDislikePostResult.content.total_like_dislike.total_like forState:UIControlStateNormal];
                                                   [[productReputationCell getBtnDisLike] setTitle:likeDislikePostResult.content.total_like_dislike.total_dislike forState:UIControlStateNormal];
                                                   [self setLikeDislikeActive:_strLikeStatus];
                                               }else{
                                                   StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:@[@"Respon Anda tidak dapat diproses pada ulasan ini."] delegate:self];
                                                   [alert show];
                                                   [self setLikeDislikeActive:_strLikeStatus];
                                               }
                                           } onFailure:^(NSError *errorResult) {
                                               [self setLikeDislikeActive:_strLikeStatus];
                                               [self showNetworkFailStickyAlert];
                                           }];
        }else{
            [reviewRequest actionCancelLikeDislikeWithReviewId:_detailReputationReview.review_id
                                                        shopId:_detailReputationReview.shop_id?:_detailReputationReview.review_shop_id
                                                     productId:_detailReputationReview.product_id?:_detailReputationReview.review_product_id
                                                        userId:[_userManager getUserId]
                                                     onSuccess:^(LikeDislikePostResult *likeDislikePostResult) {
                                                         if([likeDislikePostResult.is_success isEqualToString:@"1"]){
                                                             _strLikeStatus = @"3";
                                                             [[productReputationCell getBtnLike] setTitle:likeDislikePostResult.content.total_like_dislike.total_like forState:UIControlStateNormal];
                                                             [[productReputationCell getBtnDisLike] setTitle:likeDislikePostResult.content.total_like_dislike.total_dislike forState:UIControlStateNormal];
                                                             _strLikeStatus = @"3";
                                                             [self setLikeDislikeActive:_strLikeStatus];
                                                         }else{
                                                             StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:@[@"Respon Anda tidak dapat diproses pada ulasan ini."] delegate:self];
                                                             [alert show];
                                                             [self setLikeDislikeActive:_strLikeStatus];
                                                         }
                                                     } onFailure:^(NSError *errorResult) {
                                                         [self setLikeDislikeActive:_strLikeStatus];
                                                         [self showNetworkFailStickyAlert];
                                                     }];
        }
        
    }
    else {
        [self showLoginView:NO];
    }
}
- (void)actionChat:(id)sender {
    
}

- (void)actionMore:(id)sender {
    
}

- (void)actionRate:(id)sender {
    int paddingRightLeftContent = 10;
    UIView *viewContentPopUp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (CWidthItemPopUp*3)+paddingRightLeftContent, CHeightItemPopUp)];
    SmileyAndMedal *tempSmileyAndMedal = [SmileyAndMedal new];
    [tempSmileyAndMedal showPopUpSmiley:viewContentPopUp
                             andPadding:paddingRightLeftContent
                   withReputationNetral:_detailReputationReview.review_user_reputation.neutral
                           withRepSmile:_detailReputationReview.review_user_reputation.positive
                             withRepSad:_detailReputationReview.review_user_reputation.negative
                           withDelegate:self];
    
    //Init pop up
    popTipView = [[CMPopTipView alloc] initWithCustomView:viewContentPopUp];
    popTipView.delegate = self;
    popTipView.backgroundColor = [UIColor whiteColor];
    popTipView.animation = CMPopTipAnimationSlide;
    popTipView.dismissTapAnywhere = YES;
    
    UIButton *button = (UIButton *)sender;
    [popTipView presentPointingAtView:button inView:self.view animated:YES];
}

- (void)actionTryAgain:(id)sender {
    _detailReputationReview.review_response.failedSentMessage = NO;
    [tableReputation reloadData];
    [self requestInsertReputationResponse];
}

- (void)goToImageViewerImages:(NSArray *)images atIndexImage:(NSInteger)index atIndexPath:(NSIndexPath *)indexPath {
    [_TKPDNavigator navigateToShowImageFromViewController:self withImageDictionaries:images imageDescriptions:@[] indexImage:index];
}

- (void)didTapAttachedImage:(UITapGestureRecognizer*)sender {
    NSMutableArray *descriptionArray = [NSMutableArray new];
    NSMutableArray<UIImageView*> *imageArray = [NSMutableArray new];
    
    _count = 0;
    
    for (ReviewImageAttachment *imageAttachment in _detailReputationReview.review_image_attachment) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageAttachment.uri_large]];
        [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        UIImageView *imageView = [UIImageView new];
        [imageView setImageWithURLRequest:request
                         placeholderImage:[UIImage imageNamed:@"attached_image_placeholder.png"]
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                      _count++;
                                      [imageView setImage:image];
                                      [descriptionArray addObject:imageAttachment.desc?:@""];
                                      [imageArray addObject:imageView];
                                      if (_count == _detailReputationReview.review_image_attachment.count) {
                                          [_TKPDNavigator navigateToShowImageFromViewController:self withImageDictionaries:imageArray imageDescriptions:descriptionArray indexImage:sender.view.tag];
                                      }
                                  }
                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                      
                                      
                                  }];
    }
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
- (void)actionTapCellLabelUser:(UITapGestureRecognizer *)sender {
    if([(_detailReputationReview!=nil)?_detailReputationReview.product_owner.user_label:CPenjual caseInsensitiveCompare:CPenjual] == NSOrderedSame) {
        ShopViewController *shopViewController = [ShopViewController new];
        shopViewController.data = @{kTKPDDETAIL_APISHOPIDKEY:_detailReputationReview.shop_id};
        [self.navigationController pushViewController:shopViewController animated:YES];
    }
    else {
        UserContainerViewController *container = [UserContainerViewController new];
        container.profileUserID = _detailReputationReview.review_user_id;
        [self.navigationController pushViewController:container animated:YES];
    }
}

- (void) showLoginView:(bool) isLike {
    [[AuthenticationService sharedService] ensureLoggedInFromViewController:self onSuccess: ^{
        if(isLike)
            [self actionLike:self];
        else
            [self actionDisLike:self];
    }];
    [productReputationCell enableTouchLikeDislikeButton];
}

- (void)updateLikeDislike:(LikeDislike *)likeDislikeObj {
    if(likeDislikeObj.result.like_dislike_review.count > 0) {
        TotalLikeDislike *tempTotalLikeDislike = ((TotalLikeDislike *) [likeDislikeObj.result.like_dislike_review firstObject]);
        
        if(_detailReputationReview!=nil && [tempTotalLikeDislike.review_id isEqualToString:_detailReputationReview.review_id]) {
            [productReputationCell setHiddenViewLoad:YES];
            [productReputationCell.getBtnDisLike setTitle:((TotalLikeDislike *) [likeDislikeObj.result.like_dislike_review firstObject]).total_like_dislike.total_dislike  forState:UIControlStateNormal];
            [productReputationCell.getBtnLike setTitle:((TotalLikeDislike *) [likeDislikeObj.result.like_dislike_review firstObject]).total_like_dislike.total_like  forState:UIControlStateNormal];
            
            [self setLikeDislikeActive:tempTotalLikeDislike.like_status];
        }
    }
}



- (void)dismissAllPopTipViews
{
    [popTipView dismissAnimated:YES];
    popTipView = nil;
}

- (void)requestInsertReputationResponse {
    [reviewRequest requestInsertReputationReviewResponseWithReputationID:_detailReputationReview.reputation_id
                                                         responseMessage:[growTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                                                                reviewID:_detailReputationReview.review_id
                                                                  shopID:_detailReputationReview.shop_id
                                                               onSuccess:^(ResponseComment *result) {
                                                                   ResponseCommentResult *data = result.data;
                                                                   if([data.is_success isEqualToString:@"1"]) {
                                                                       isSuccessSentMessage = YES;
                                                                       
                                                                       _detailReputationReview.review_response = data.review_response;
                                                                       _detailReputationReview.review_response.response_create_time = data.review_response.response_time_fmt;
                                                                       _detailReputationReview.review_response.response_message = data.review_response.response_msg;
                                                                       _detailReputationReview.review_response.failedSentMessage = NO;
                                                                       _detailReputationReview.review_response.canDelete = YES;
                                                                       
                                                                       
                                                                       if(data.product_owner != nil) {
                                                                           _detailReputationReview.product_owner.user_label_id = data.product_owner.user_label_id;
                                                                           _detailReputationReview.product_owner.user_label = data.product_owner.user_label;
                                                                           
                                                                           if(_isFromInboxNotification) {
                                                                               _detailReputationReview.product_owner.shop_id = data.product_owner.shop_id;
                                                                               
                                                                               _detailReputationReview.product_owner.user_url = data.product_owner.user_url;
                                                                               _detailReputationReview.product_owner.shop_img = data.product_owner.shop_img;
                                                                               _detailReputationReview.product_owner.shop_url = data.product_owner.shop_url;
                                                                               _detailReputationReview.product_owner.shop_name = data.product_owner.shop_name;
                                                                               _detailReputationReview.product_owner.full_name = data.product_owner.full_name;
                                                                               _detailReputationReview.product_owner.user_img = data.product_owner.user_img;
                                                                               _detailReputationReview.product_owner.user_id = data.product_owner.user_id;
                                                                               _detailReputationReview.product_owner.shop_reputation_badge = data.product_owner.shop_reputation_badge;
                                                                               _detailReputationReview.product_owner.shop_reputation_score = data.product_owner.shop_reputation_score;
                                                                           }
                                                                           else {
                                                                               _shopBadgeLevel = _detailReputationReview.shop_badge_level = data.shop_reputation.reputation_badge_object?:_shopBadgeLevel;
                                                                               _detailReputationReview.product_owner.shop_reputation_score = data.product_owner.shop_reputation_score;
                                                                               _detailReputationReview.product_owner.shop_id = data.shop_id;
                                                                               _detailReputationReview.product_owner.shop_name = data.shop_name?:data.product_owner.shop_name;
                                                                               _detailReputationReview.product_owner.shop_url = data.shop_img_uri;
                                                                               _shopImage = data.product_owner.shop_img;
                                                                           }
                                                                       }
                                                                       
                                                                       
                                                                       StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[CStringSuccessSentComment] delegate:self];
                                                                       [stickyAlertView show];
                                                                       
                                                                       //Update Header
                                                                       NSString *strResponseMessage = _detailReputationReview.review_response.response_message;
                                                                       if(strResponseMessage==nil || [strResponseMessage isEqualToString:@"0"]) {
                                                                           [productReputationCell.getBtnChat setTitle:[NSString stringWithFormat:@"%@ Komentar", strResponseMessage] forState:UIControlStateNormal];
                                                                       }
                                                                       else {
                                                                           [productReputationCell.getBtnChat setTitle:@"1 Komentar" forState:UIControlStateNormal];
                                                                       }
                                                                   }
                                                                   else {
                                                                       _detailReputationReview.review_response.failedSentMessage = YES;
                                                                       
                                                                   }
                                                                   
                                                                   [tableReputation reloadData];
                                                               }
                                                               onFailure:^(NSError *error) {
                                                                   _detailReputationReview.review_response.failedSentMessage = YES;
                                                                   
                                                                   
                                                                   [tableReputation reloadData];
                                                               }];
}

- (void)requestDeleteReputationResponse {
    [reviewRequest requestDeleteReputationReviewResponseWithReputationID:_detailReputationReview.reputation_id
                                                                reviewID:_detailReputationReview.review_id
                                                                  shopID:_detailReputationReview.shop_id
                                                               onSuccess:^(ResponseCommentResult *result) {
                                                                   isDeletingMessage = NO;
                                                                   if([result.is_success isEqualToString:@"1"]) {
                                                                       _detailReputationReview.review_response.canDelete = _detailReputationReview.viewModel.review_response.canDelete = NO;
                                                                       _detailReputationReview.review_response.response_create_time = _detailReputationReview.viewModel.review_response.response_create_time = result.review_response.response_time_fmt;
                                                                       _detailReputationReview.review_response.response_message = _detailReputationReview.viewModel.review_response.response_message = result.review_response.response_message;
                                                                       _detailReputationReview.product_owner.shop_id = result.product_owner.shop_id;
                                                                       _detailReputationReview.product_owner.user_label_id = result.product_owner.user_label_id;
                                                                       _detailReputationReview.product_owner.user_url = result.product_owner.user_url;
                                                                       _detailReputationReview.product_owner.shop_img = result.product_owner.shop_img;
                                                                       _detailReputationReview.product_owner.shop_url = result.product_owner.shop_url;
                                                                       _detailReputationReview.product_owner.shop_name = result.product_owner.shop_name;
                                                                       _detailReputationReview.product_owner.full_name = result.product_owner.full_name;
                                                                       _detailReputationReview.product_owner.user_img = result.product_owner.user_img;
                                                                       _detailReputationReview.product_owner.user_label = result.product_owner.user_label;
                                                                       _detailReputationReview.product_owner.user_id = result.product_owner.user_id;
                                                                       _detailReputationReview.product_owner.shop_reputation_badge = result.product_owner.shop_reputation_badge;
                                                                       _detailReputationReview.product_owner.shop_reputation_score = result.product_owner.shop_reputation_score;
                                                                       
                                                                       
                                                                       StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[CStringSuccessRemoveMessage] delegate:self];
                                                                       [stickyAlertView show];
                                                                       
                                                                       
                                                                       //Update Header
                                                                       NSString *strResponseMessage = _detailReputationReview.review_response.response_message;
                                                                       if(strResponseMessage==nil || [strResponseMessage isEqualToString:@"0"]) {
                                                                           [productReputationCell.getBtnChat setTitle:[NSString stringWithFormat:@"%@ Komentar", strResponseMessage==nil? @"0":strResponseMessage] forState:UIControlStateNormal];
                                                                       }
                                                                       else {
                                                                           [productReputationCell.getBtnChat setTitle:@"1 Komentar" forState:UIControlStateNormal];
                                                                       }
                                                                       
                                                                       
                                                                       //Add Text message
                                                                       growTextView.text = @"";
                                                                       constraintHeightViewMessage.constant = 50; //50 is default height text message
                                                                   }
                                                                   else {
                                                                       _detailReputationReview.review_response.canDelete = YES;
                                                                       
                                                                       
                                                                       StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringFailedRemoveMessage] delegate:self];
                                                                       [stickyAlertView show];
                                                                   }
                                                                   
                                                                   [tableReputation reloadData];
                                                               } onFailure:^(NSError *error) {
                                                                   isDeletingMessage = NO;
                                                                   _detailReputationReview.review_response.canDelete = YES;
                                                                   
                                                                   
                                                                   [tableReputation reloadData];
                                                               }];
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
    NSString *strNReputation = @"0";
    NSString *strText = @"";
    if(_detailReputationReview == nil) {
        strText = [NSString stringWithFormat:@"%@ Poin", strNReputation];
        [self initPopUp:strText withSender:sender withRangeDesc:NSMakeRange(strText.length-4, 4)];
    }
    else {
        strText = _detailReputationReview.product_owner.user_shop_reputation.tooltip;
        
        if(strText != nil) {
            NSArray *tempStr = [strText componentsSeparatedByString:@" "];
            [self initPopUp:strText withSender:sender withRangeDesc:NSMakeRange(strText.length-((NSString *)[tempStr lastObject]).length, ((NSString *)[tempStr lastObject]).length)];
        }
        else {
            strNReputation = _detailReputationReview.product_owner.shop_reputation_score;
            strText = [NSString stringWithFormat:@"%@ Poin", strNReputation];
            [self initPopUp:strText withSender:sender withRangeDesc:NSMakeRange(strText.length-4, 4)];
        }
    }
}

#pragma mark - Swipe Delegate
-(BOOL)swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
{
    //Delete message
    if(_detailReputationReview.review_response.canDelete && _isMyProduct) {
        return YES;
    }
    else {
        return NO;
    }
}


- (NSArray*)swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings
{
    [growTextView resignFirstResponder];
    
    swipeSettings.transition = MGSwipeTransitionStatic;
    expansionSettings.buttonIndex = -1; //-1 not expand, 0 expand
    
    
    if (direction == MGSwipeDirectionRightToLeft) {
        expansionSettings.fillOnTrigger = YES;
        expansionSettings.threshold = 1.1;
        
        CGFloat padding = 15;
        MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:@"Hapus" backgroundColor:[UIColor colorWithRed:255/255 green:59/255.0 blue:48/255.0 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            _detailReputationReview.review_response.canDelete = NO;
            
            
            isDeletingMessage = YES;
            [tableReputation reloadData];
            [self requestDeleteReputationResponse];
            return YES;
        }];
        
        return @[trash];
    }
    
    return nil;
}

- (void)setLikeDislikeActive:(NSString *)strStatusLike {
    if(strStatusLike!=nil && [strStatusLike isEqualToString:@"1"]) {
        [productReputationCell enableLikeButton];
        [productReputationCell disableDislikeButton];
    }
    else if(strStatusLike!=nil && [strStatusLike isEqualToString:@"2"]) {
        [productReputationCell enableDislikeButton];
        [productReputationCell disableLikeButton];
    }else if(strStatusLike != nil && [strStatusLike isEqualToString:@"3"]){
        [productReputationCell resetLikeDislikeButton];
    }
    [productReputationCell enableTouchLikeDislikeButton];
}
- (void)showNetworkFailStickyAlert{
    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Kendala koneksi internet"] delegate:self];
    [alert show];
}

@end
