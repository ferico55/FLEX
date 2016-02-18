//
//  ProductDetailReputationViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 6/30/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
#import "CMPopTipView.h"
#import "detail.h"
#import "DetailMyReviewReputationViewController.h"
#import "DetailReputationReview.h"
#import "GeneralAction.h"
#import "HPGrowingTextView.h"
#import "LikeDislike.h"
#import "LikeDislikePost.h"
#import "LikeDislikePostResult.h"
#import "LoginViewController.h"
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
#import "ShopContainerViewController.h"
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

#define CStringLimitText @"Panjang pesan harus lebih besar dari 5 karakter"
#define CStringSuccessSentComment @"Anda berhasil memberikan komentar"
#define CCellIdentifier @"cell"
#define CTagLikeDislike 1
#define CTagComment 2
#define CTagHapus 3

@interface ProductDetailReputationViewController ()<
productReputationDelegate,
TokopediaNetworkManagerDelegate,
CMPopTipViewDelegate,
HPGrowingTextViewDelegate,
ProductDetailReputationDelegate,
LoginViewDelegate,
SmileyDelegate,
MGSwipeTableCellDelegate,
ReviewRequestDelegate>
@end

@implementation ProductDetailReputationViewController {
    ProductReputationCell *productReputationCell;
    TokopediaNetworkManager *tokopediaNetworkManager;
    NSOperationQueue *operationQueueLikeDislike;
    CMPopTipView *popTipView;
    
    TAGContainer *_gtmContainer;
    NSString *baseActionUrl;
    NSString *postActionUrl;
    NavigateViewController *_TKPDNavigator;

    ReviewRequest *reviewRequest;
    
    __block NSTimer *_timer;
    BOOL isSuccessSentMessage, isDeletingMessage;
    NSMutableDictionary *dictCell, *dictRequestLikeDislike;
    float heightScreenView;
}
@synthesize loadingLikeDislike, dictLikeDislike;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureGTM];
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
    
    reviewRequest = [[ReviewRequest alloc] init];
    reviewRequest.delegate = self;
    [reviewRequest requestReviewLikeDislikesWithId:_detailReputaitonReview.review_id shopId:_detailReputaitonReview.shop_id];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    heightScreenView = self.view.bounds.size.height;
    constHeightViewContent.constant = heightScreenView;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if(! isSuccessSentMessage) {
        if(_detailReputaitonReview != nil) {
            _detailReputaitonReview.review_response.response_create_time = _detailReputaitonReview.viewModel.review_response.response_create_time = nil;
            _detailReputaitonReview.review_response.response_message = _detailReputaitonReview.viewModel.review_response.response_message = nil;
        }
        else if(_reviewList != nil) {
            _reviewList.review_response.response_create_time = nil;
            _reviewList.review_response.response_message = nil;
        }
    }
}

- (void)dealloc {
    tokopediaNetworkManager.delegate = nil;
    [tokopediaNetworkManager requestCancel];
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
    [([self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2]) setPropertyLabelDesc:productReputationCell.getLabelDesc];
    
    productReputationCell.frame = CGRectMake(productReputationCell.frame.origin.x, productReputationCell.frame.origin.y, self.view.bounds.size.width, productReputationCell.bounds.size.height);
    productReputationCell.getViewContent.frame = CGRectMake(CPaddingTopBottom, productReputationCell.getViewContent.frame.origin.y, productReputationCell.bounds.size.width-(CPaddingTopBottom*2), productReputationCell.getViewContent.bounds.size.height);

    
    productReputationCell.contentView.backgroundColor = productReputationCell.getViewContent.backgroundColor;
    productReputationCell.getBtnMore.frame = CGRectZero;
    [productReputationCell.getBtnMore removeFromSuperview];
    productReputationCell.getBtnMore.hidden = YES;
    [productReputationCell.getLabelUser setText:[UIColor colorWithRed:62/255.0f green:114/255.0f blue:9/255.0f alpha:1.0f] withFont:[UIFont fontWithName:@"Gotham Medium" size:14.0f]];
    
    //Set profile image
    BOOL isResizeSeparatorProduct;
    NSString *strTempProductID = _detailReputaitonReview==nil? _reviewList.review_product_id : _detailReputaitonReview.product_id;
    if(((_detailReputaitonReview!=nil && _detailReputaitonReview.review_message!=nil && ![_detailReputaitonReview.review_message isEqualToString:@"0"]) || (_reviewList!=nil && _reviewList.review_message!=nil && ![_reviewList.review_message isEqualToString:@"0"])) && (strTempProductID!=nil && ![strTempProductID isEqualToString:@""])) {
        [productReputationCell initProductCell];
        

        NSString *strTempProductName = (_detailReputaitonReview!=nil)?_detailReputaitonReview.product_name:_reviewList.review_product_name;
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
        
        
        NSString *strProductStatus = (_detailReputaitonReview != nil)?_detailReputaitonReview.product_status:_reviewList.review_product_status;
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
        NSURLRequest *userImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:(_detailReputaitonReview!=nil)?_detailReputaitonReview.product_image : (_reviewList.product_images==nil? _reviewList.review_product_image:_reviewList.product_images)] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        productReputationCell.getProductImage.image = nil;
        [productReputationCell.getProductImage setImageWithURLRequest:userImageRequest placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_toped_loading_grey" ofType:@"png"]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            [productReputationCell.getProductImage setImage:image];
#pragma clang diagnostic pop
        } failure:nil];
    }
    
    
    //Set image profile
    NSURLRequest *userImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:(_detailReputaitonReview!=nil? (_detailReputaitonReview.user_image==nil? _detailReputaitonReview.review_user_image:_detailReputaitonReview.user_image):_reviewList.review_user_image)] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    UIImageView *userImageView = productReputationCell.getImageProfile;
    userImageView.image = nil;
    [userImageView setImageWithURLRequest:userImageRequest placeholderImage:[UIImage imageNamed:@"icon_profile_picture.jpeg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [userImageView setImage:image];
#pragma clang diagnostic pop
    } failure:nil];
    [productReputationCell setLabelUser:(_detailReputaitonReview!=nil? _detailReputaitonReview.review_full_name:_reviewList.review_user_name)
                          withUserLabel:(_detailReputaitonReview!=nil)?_detailReputaitonReview.review_user_label:_reviewList.review_user_label];
    
    [productReputationCell setPercentage:(_detailReputaitonReview!=nil? _detailReputaitonReview.review_user_reputation.positive_percentage:_reviewList.review_user_reputation.positive_percentage)];
    [productReputationCell setLabelDate:(_detailReputaitonReview!=nil? (_detailReputaitonReview.review_create_time?:@""):(_reviewList.review_create_time?:@""))];
    
    if(_detailReputaitonReview!=nil && [[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2] isMemberOfClass:[DetailMyReviewReputationViewController class]]) {
        productReputationCell.getViewContentAction.hidden = YES;
    }
    else {
        NSString *strResponseMessage = (_detailReputaitonReview==nil? _reviewList.review_response.response_message:_detailReputaitonReview.review_response.response_message);
        NSString *strUserID = (_detailReputaitonReview==nil? _reviewList.review_product_owner.user_id:_detailReputaitonReview.product_owner.user_id);

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
        if([loadingLikeDislike objectForKey:(_detailReputaitonReview==nil? _reviewList.review_id:_detailReputaitonReview.review_id)]) {
            [productReputationCell setHiddenViewLoad:NO];
        }
    }
    
    [productReputationCell setImageKualitas:[(_detailReputaitonReview!=nil? _detailReputaitonReview.product_rating_point:_reviewList.review_rate_quality) intValue]];
    [productReputationCell setImageAkurasi:[(_detailReputaitonReview!=nil? _detailReputaitonReview.product_accuracy_point:_reviewList.review_rate_accuracy) intValue]];
    [productReputationCell setDescription:[NSString convertHTML:(_detailReputaitonReview!=nil? (_detailReputaitonReview.review_message?:@""):(_reviewList.review_message?:@""))]];
    
    if(_strTotalDisLike != nil || ![_strTotalDisLike isEqualToString:@""]) {
        [productReputationCell.getBtnLike setTitle:_strTotalLike forState:UIControlStateNormal];
        [productReputationCell.getBtnDisLike setTitle:_strTotalDisLike forState:UIControlStateNormal];
        [self setLikeDislikeActive:_strLikeStatus];
    }else{
        [productReputationCell.getBtnLike setTitle:_detailReputaitonReview.review_like_dislike.total_like forState:UIControlStateNormal];
        [productReputationCell.getBtnDisLike setTitle:_detailReputaitonReview.review_like_dislike.total_dislike forState:UIControlStateNormal];
        [self setLikeDislikeActive:_strLikeStatus];

    }
    
    [productReputationCell layoutSubviews];
    //productReputationCell.contentView.frame = CGRectMake(0, 0, productReputationCell.contentView.bounds.size.width, productReputationCell.contentView.bounds.size.height-CPaddingTopBottom-CPaddingTopBottom);
    productReputationCell.contentView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, productReputationCell.contentView.bounds.size.height-CPaddingTopBottom-CPaddingTopBottom);
    
    productReputationCell.getViewContent.frame = CGRectMake(productReputationCell.getViewContent.frame.origin.x, 0, [[UIScreen mainScreen] bounds].size.width, productReputationCell.getViewContent.bounds.size.height-CPaddingTopBottom);
    
    if(isResizeSeparatorProduct)
        [productReputationCell.getViewSeparatorProduct setFrame:CGRectMake(0, productReputationCell.getViewSeparatorProduct.frame.origin.y+productReputationCell.getViewContent.frame.origin.y, ((AppDelegate *) [UIApplication sharedApplication].delegate).window.bounds.size.width, productReputationCell.getViewSeparatorProduct.bounds.size.height)];
    
    //Add separator
    UIView *viewSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, productReputationCell.contentView.bounds.size.height-1, ((AppDelegate *) [UIApplication sharedApplication].delegate).window.bounds.size.width, 1.0f)];
    viewSeparator.backgroundColor = [UIColor colorWithRed:231/255.0f green:231/255.0f blue:231/255.0f alpha:1.0f];
    [productReputationCell.contentView addSubview:viewSeparator];
    
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
    if([(_detailReputaitonReview!=nil?_detailReputaitonReview.review_user_label:_reviewList.review_user_label) caseInsensitiveCompare:CPenjual] == NSOrderedSame) {
        UserAuthentificationManager *_userManager = [UserAuthentificationManager new];
        NSDictionary *auth = [_userManager getUserLoginData];

        ShopContainerViewController *shopContainerViewController = [ShopContainerViewController new];
        shopContainerViewController.data = @{kTKPDDETAIL_APISHOPIDKEY:(_detailReputaitonReview!=nil?_detailReputaitonReview.shop_id:_reviewList.review_shop_id),
                                             kTKPD_AUTHKEY:auth?:@{}};
        [self.navigationController pushViewController:shopContainerViewController animated:YES];
    }
    else {
        UserContainerViewController *container = [UserContainerViewController new];
        UserAuthentificationManager *_userManager = [UserAuthentificationManager new];
        NSDictionary *auth = [_userManager getUserLoginData];

        container.data = @{
                           @"user_id" : (_detailReputaitonReview==nil? _reviewList.review_user_id:_detailReputaitonReview.review_user_id),
                           @"auth" : auth?:[NSNull null]
                           };
        [self.navigationController pushViewController:container animated:YES];
    }
}

- (void)goToDetailProduct:(id)sender {
    [_TKPDNavigator navigateToProductFromViewController:self withName:(_detailReputaitonReview!=nil)?_detailReputaitonReview.product_name:_reviewList.review_product_name withPrice:nil withId:(_detailReputaitonReview==nil? _reviewList.review_product_id:_detailReputaitonReview.product_id) withImageurl:(_detailReputaitonReview!=nil)?_detailReputaitonReview.product_image : (_reviewList.product_images==nil? _reviewList.review_product_image:_reviewList.product_images) withShopName:_detailReputaitonReview!=nil? _detailReputaitonReview.product_owner.shop_name:_reviewList.review_product_owner.user_name];
}

- (void)actionVote:(id)sender
{
    [self dismissAllPopTipViews];
}

- (void)userHasLogin {
    [productReputationCell setHiddenViewLoad:NO];
    
    UIViewController *viewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    if([viewController isMemberOfClass:[ProductReputationViewController class]]) {
        [((ProductReputationViewController *) viewController) requestLikeStatusAgain:_indexPathSelected];
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
    if(isDeletingMessage)
        return 0;
    
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
//    NSURLRequest *userImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_detailReputaitonReview!=nil? _detailReputaitonReview.product_owner.user_url:_reviewList.review_product_owner.user_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
//    productReputationCell.getProductImage.image = nil;
//    [productReputationCell.getProductImage setImageWithURLRequest:userImageRequest placeholderImage:[UIImage imageNamed:@"icon_profile_picture.jpeg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-retain-cycles"
//        [productReputationCell.getProductImage setImage:image];
//#pragma clang diagnostic pop
//    } failure:nil];
    
    
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.del = self;
        cell.delegate = self;
        cell.getViewLabelUser.userInteractionEnabled = [NavigationHelper shouldDoDeepNavigation];
        [cell.getViewLabelUser addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapCellLabelUser:)]];
    }
    
    cell.getViewLabelUser.tag = indexPath.row;
    cell.getTvDesc.text = _detailReputaitonReview!=nil? _detailReputaitonReview.review_response.response_message:_reviewList.review_response.response_message;
    cell.getLblDate.text = _detailReputaitonReview!=nil? _detailReputaitonReview.review_response.response_create_time:_reviewList.review_response.response_create_time;
    cell.getBtnTryAgain.tag = indexPath.row;
    cell.getBtnTryAgain.hidden = !(_detailReputaitonReview!=nil? _detailReputaitonReview.review_response.failedSentMessage:_reviewList.review_response.failedSentMessage);
    
    //Set image
    NSURLRequest *userImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_detailReputaitonReview!=nil? _detailReputaitonReview.product_owner.shop_img:_reviewList.review_product_owner.user_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    [cell.getImgProfile setImageWithURLRequest:userImageRequest placeholderImage:[UIImage imageNamed:@"icon_profile_picture.jpeg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [cell.getImgProfile setImage:image];
#pragma clang diagnostic pop
    } failure:nil];
    
    

    [cell setStar:_shopBadgeLevel.level withSet:_shopBadgeLevel.set];
    [cell.getViewLabelUser setText:_detailReputaitonReview!=nil? _detailReputaitonReview.product_owner.shop_name:_reviewList.review_shop_name];
    [cell.getViewLabelUser setText:[UIColor colorWithRed:10/255.0f green:126/255.0f blue:7/255.0f alpha:1.0f] withFont:[UIFont fontWithName:@"Gotham Medium" size:13.0f]];
    [cell.getViewLabelUser setLabelBackground:(_detailReputaitonReview!=nil)?_detailReputaitonReview.product_owner.user_label:CPenjual];
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
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"GothamBook" size:lblDesc.font.pointSize] range:NSMakeRange(0, strDescription.length)];
    
    
    lblDesc.attributedText = str;
    lblDesc.delegate = nil;
    [lblDesc addLinkToURL:[NSURL URLWithString:@""] withRange:NSMakeRange(0, 0)];
}

- (void)actionLike:(id)sender {
    UserAuthentificationManager *_userManager = [UserAuthentificationManager new];
    NSDictionary *auth = [_userManager getUserLoginData];

    if(auth) {
        NSString *strReviewID = (_detailReputaitonReview==nil)?_reviewList.review_id:_detailReputaitonReview.review_id;
        int tagRequest = 3;//3 is netral
        if([dictLikeDislike objectForKey:strReviewID] && ([((TotalLikeDislike *)[dictLikeDislike objectForKey:strReviewID]).like_status isEqualToString:@"3"] || [((TotalLikeDislike *)[dictLikeDislike objectForKey:strReviewID]).like_status isEqualToString:@"0"] || [((TotalLikeDislike *)[dictLikeDislike objectForKey:strReviewID]).like_status isEqualToString:@"2"] || [((TotalLikeDislike *)[dictLikeDislike objectForKey:strReviewID]).like_status isEqualToString:@"2"])) { //2 dislike, 1 like
            tagRequest = 1;
            
            [productReputationCell.getBtnDisLike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_dislike" ofType:@"png"]] forState:UIControlStateNormal];
            [UIView animateWithDuration:0.5 animations:^{
                productReputationCell.getBtnLike.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [productReputationCell.getBtnLike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_like_active" ofType:@"png"]] forState:UIControlStateNormal];
                [UIView animateWithDuration:0.5 animations:^{
                    productReputationCell.getBtnLike.alpha = 1.0f;
                }];
            }];
            
            
            //Set data total
            ((TotalLikeDislike *) [dictLikeDislike objectForKey:strReviewID]).total_like_dislike.total_like = [NSString stringWithFormat:@"%d", ([((TotalLikeDislike *) [dictLikeDislike objectForKey:strReviewID]).total_like_dislike.total_like intValue] + 1)];
            if([((TotalLikeDislike *)[dictLikeDislike objectForKey:strReviewID]).like_status isEqualToString:@"2"]) {
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:strReviewID]).total_like_dislike.total_dislike = [NSString stringWithFormat:@"%d", ([((TotalLikeDislike *) [dictLikeDislike objectForKey:strReviewID]).total_like_dislike.total_dislike intValue] - 1)];
            }
            ((TotalLikeDislike *) [dictLikeDislike objectForKey:strReviewID]).like_status = @"1";
        }
        else {
            if([((TotalLikeDislike *) [dictLikeDislike objectForKey:strReviewID]).like_status isEqualToString:@"1"]) {
                tagRequest = 3;
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:strReviewID]).like_status = @"0";
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:strReviewID]).total_like_dislike.total_like = [NSString stringWithFormat:@"%d", ([((TotalLikeDislike *) [dictLikeDislike objectForKey:strReviewID]).total_like_dislike.total_like intValue] - 1)];
                [productReputationCell.getBtnLike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_like" ofType:@"png"]] forState:UIControlStateNormal];
            }
            else {
                tagRequest = 1;
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:strReviewID]).like_status = @"1";
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:strReviewID]).total_like_dislike.total_like = [NSString stringWithFormat:@"%d", ([((TotalLikeDislike *) [dictLikeDislike objectForKey:strReviewID]).total_like_dislike.total_like intValue] + 1)];
                [productReputationCell.getBtnLike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_like_active" ofType:@"png"]] forState:UIControlStateNormal];
            }
        }

        [productReputationCell.getBtnLike setTitle:((TotalLikeDislike *) [dictLikeDislike objectForKey:strReviewID]).total_like_dislike.total_like forState:UIControlStateNormal];
        [productReputationCell.getBtnDisLike setTitle:((TotalLikeDislike *) [dictLikeDislike objectForKey:strReviewID]).total_like_dislike.total_dislike forState:UIControlStateNormal];
        [loadingLikeDislike setObject:_indexPathSelected forKey:strReviewID];
        [self doActionLikeDislike:tagRequest withView:productReputationCell.getBtnLike];
    }
    else {
        [self showLoginView];
    }
}

- (void)actionDisLike:(id)sender {
    UserAuthentificationManager *_userManager = [UserAuthentificationManager new];
    NSDictionary *auth = [_userManager getUserLoginData];
    
    if(auth) {
        int tagRequest = 3;
        NSString *strReviewID = (_detailReputaitonReview==nil)?_reviewList.review_id:_detailReputaitonReview.review_id;
        
        if([dictLikeDislike objectForKey:strReviewID] && ([((TotalLikeDislike *)[dictLikeDislike objectForKey:strReviewID]).like_status isEqualToString:@"3"] || [((TotalLikeDislike *)[dictLikeDislike objectForKey:strReviewID]).like_status isEqualToString:@"0"] || [((TotalLikeDislike *)[dictLikeDislike objectForKey:strReviewID]).like_status isEqualToString:@"1"])) {
            tagRequest = 2;
    
            [productReputationCell.getBtnLike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_like" ofType:@"png"]] forState:UIControlStateNormal];
            [UIView animateWithDuration:0.5 animations:^{
                productReputationCell.getBtnDisLike.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [productReputationCell.getBtnDisLike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_dislike_active" ofType:@"png"]] forState:UIControlStateNormal];
                [UIView animateWithDuration:0.5 animations:^{
                    productReputationCell.getBtnDisLike.alpha = 1.0f;
                }];
            }];
            
            
            //Set data total
            ((TotalLikeDislike *) [dictLikeDislike objectForKey:strReviewID]).total_like_dislike.total_dislike = [NSString stringWithFormat:@"%d", ([((TotalLikeDislike *) [dictLikeDislike objectForKey:strReviewID]).total_like_dislike.total_dislike intValue] + 1)];
            if([((TotalLikeDislike *)[dictLikeDislike objectForKey:strReviewID]).like_status isEqualToString:@"1"]) {
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:strReviewID]).total_like_dislike.total_like = [NSString stringWithFormat:@"%d", ([((TotalLikeDislike *) [dictLikeDislike objectForKey:strReviewID]).total_like_dislike.total_like intValue] - 1)];
            }
            ((TotalLikeDislike *) [dictLikeDislike objectForKey:strReviewID]).like_status = @"2";
        }
        else {
            if([((TotalLikeDislike *)[dictLikeDislike objectForKey:strReviewID]).like_status isEqualToString:@"2"]) {
                tagRequest = 3;
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:strReviewID]).like_status = @"0";
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:strReviewID]).total_like_dislike.total_dislike = [NSString stringWithFormat:@"%d", ([((TotalLikeDislike *) [dictLikeDislike objectForKey:strReviewID]).total_like_dislike.total_dislike intValue] - 1)];
                [productReputationCell.getBtnDisLike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_dislike" ofType:@"png"]] forState:UIControlStateNormal];
            }
            else {
                tagRequest = 2;
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:strReviewID]).like_status = @"2";
                ((TotalLikeDislike *) [dictLikeDislike objectForKey:strReviewID]).total_like_dislike.total_dislike = [NSString stringWithFormat:@"%d", ([((TotalLikeDislike *) [dictLikeDislike objectForKey:strReviewID]).total_like_dislike.total_dislike intValue] + 1)];
                [productReputationCell.getBtnDisLike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_dislike_active" ofType:@"png"]] forState:UIControlStateNormal];
            }
        }
        
        [productReputationCell.getBtnLike setTitle:((TotalLikeDislike *) [dictLikeDislike objectForKey:strReviewID]).total_like_dislike.total_like forState:UIControlStateNormal];
        [productReputationCell.getBtnDisLike setTitle:((TotalLikeDislike *) [dictLikeDislike objectForKey:strReviewID]).total_like_dislike.total_dislike forState:UIControlStateNormal];
        [loadingLikeDislike setObject:_indexPathSelected forKey:strReviewID];
        [self doActionLikeDislike:tagRequest withView:productReputationCell.getBtnDisLike];
    }
    else {
        [self showLoginView];
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
    [tempSmileyAndMedal showPopUpSmiley:viewContentPopUp andPadding:paddingRightLeftContent withReputationNetral:(_detailReputaitonReview!=nil? _detailReputaitonReview.review_user_reputation.neutral:_reviewList.review_user_reputation.neutral) withRepSmile:(_detailReputaitonReview!=nil? _detailReputaitonReview.review_user_reputation.positive:_reviewList.review_user_reputation.positive) withRepSad:(_detailReputaitonReview!=nil? _detailReputaitonReview.review_user_reputation.negative:_reviewList.review_user_reputation.negative) withDelegate:self];
    
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
- (void)setMappingNewComment:(RKObjectManager *)objectManager withTag:(int)tag {
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
}

- (void)setMappingOldComment:(RKObjectManager *)objectManager withTag:(int)tag {
    RKObjectMapping *responseCommentMapping = [RKObjectMapping mappingForClass:[ResponseComment class]];
    [responseCommentMapping addAttributeMappingsFromArray:@[CStatus,
                                                            CServerProcessTime,
                                                            CMessageError]];
    
    RKObjectMapping *responseCommentResultMapping = [RKObjectMapping mappingForClass:[ResponseCommentResult class]];
    [responseCommentResultMapping addAttributeMappingsFromArray:@[CShopID,
                                                                  CIsSuccess,
                                                                  CShopName,
                                                                  CShopImgUri]];
    
    RKObjectMapping *shopReputationMapping = [RKObjectMapping mappingForClass:[ShopReputation class]];
    [shopReputationMapping addAttributeMappingsFromArray:@[CToolTip,
                                                           CReputationScore,
                                                           CMinBadgeScore,
                                                           CScore]];
    
    
    RKObjectMapping *productOwnerMapping = [RKObjectMapping mappingForClass:[ProductOwner class]];
    [productOwnerMapping addAttributeMappingsFromArray:@[CUserImg,
                                                         CUserLabel,
                                                         CUserLabelID,
                                                         CUserURL,
                                                         CuserID,
                                                         CFullName]];
    
    RKObjectMapping *reviewResponseMapping = [RKObjectMapping mappingForClass:[ReviewResponse class]];
    [reviewResponseMapping addAttributeMappingsFromDictionary:@{CResponseMsg:CResponseMessage,
                                                                CResponseTimeFmt:CResponseTimeFmt,
                                                                CResponseTimeAgo:CResponseTimeAgo
                                                                }];
    
    RKObjectMapping *reputationBadgeMapping = [RKObjectMapping mappingForClass:[ShopBadgeLevel class]];
    [reputationBadgeMapping addAttributeMappingsFromArray:@[CLevel, CSet]];
    
    
    //Relation
    [responseCommentMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CResult toKeyPath:CResult withMapping:responseCommentResultMapping]];
    [shopReputationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReputationBadge toKeyPath:CReputationBadgeObject withMapping:reputationBadgeMapping]];
    [shopReputationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CResult toKeyPath:CResult withMapping:responseCommentResultMapping]];
    [responseCommentResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"review_owner" toKeyPath:CProductOwner withMapping:productOwnerMapping]];
    [responseCommentResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReviewResponse toKeyPath:CReviewResponse withMapping:reviewResponseMapping]];
    [responseCommentResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"get_shop_reputation_set" toKeyPath:CShopReputation withMapping:shopReputationMapping]];

    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:responseCommentMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:[self getPath:tag]
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManager addResponseDescriptor:responseDescriptorStatus];
}

- (void)setMappingNewDeleteComment:(RKObjectManager *)objectManager withTag:(int)tag {
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
    
    //Relation
    [responseCommentMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CResult toKeyPath:CResult withMapping:responseCommentResultMapping]];
    [responseCommentResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CProductOwner toKeyPath:CProductOwner withMapping:productOwnerMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:responseCommentMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:[self getPath:tag]
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManager addResponseDescriptor:responseDescriptorStatus];
}


- (void)actionTapCellLabelUser:(UITapGestureRecognizer *)sender {
    if([(_detailReputaitonReview!=nil)?_detailReputaitonReview.product_owner.user_label:CPenjual caseInsensitiveCompare:CPenjual] == NSOrderedSame) {
        UserAuthentificationManager *_userManager = [UserAuthentificationManager new];
        NSDictionary *auth = [_userManager getUserLoginData];
        
        ShopContainerViewController *shopContainerViewController = [ShopContainerViewController new];
        shopContainerViewController.data = @{kTKPDDETAIL_APISHOPIDKEY:(_detailReputaitonReview!=nil?_detailReputaitonReview.shop_id:_reviewList.review_shop_id),
                                             kTKPD_AUTHKEY:auth?:@{}};
        [self.navigationController pushViewController:shopContainerViewController animated:YES];
    }
    else {
        UserContainerViewController *container = [UserContainerViewController new];
        UserAuthentificationManager *_userManager = [UserAuthentificationManager new];
        NSDictionary *auth = [_userManager getUserLoginData];
        
        container.data = @{
                           @"user_id" : (_detailReputaitonReview==nil? _reviewList.review_user_id:_detailReputaitonReview.review_user_id),
                           @"auth" : auth?:[NSNull null]
                           };
        [self.navigationController pushViewController:container animated:YES];
    }
}

- (void)configureRestKitLikeDislike:(RKObjectManager *)objectManager {
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[LikeDislikePost class]];
    [statusMapping addAttributeMappingsFromDictionary:@{CLStatus:CLStatus,
                                                        CLServerProcessTime:CLServerProcessTime,
                                                        CLMessageError:CLMessageError}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[LikeDislikePostResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{CIsSuccess:CIsSuccess}];
    
    RKObjectMapping *totalLikeDislikePostMapping = [RKObjectMapping mappingForClass:[TotalLikeDislikePost class]];
    RKObjectMapping *detailTotalLikeMapping = [RKObjectMapping mappingForClass:[DetailTotalLikeDislike class]];
    [detailTotalLikeMapping addAttributeMappingsFromDictionary:@{CTotalLike:CTotalLike,
                                                                 CTotalDislike:CTotalDislike}];
    
    
    //add relationship mapping
    [totalLikeDislikePostMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CTotalLikeDislike toKeyPath:CTotalLikeDislike withMapping:detailTotalLikeMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CContent toKeyPath:CContent withMapping:totalLikeDislikePostMapping]];
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:@"action/review.pl"
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManager addResponseDescriptor:responseDescriptorStatus];
}

- (void)doActionLikeDislike:(int)likeDislikeTag withView:(UIView *)btnLike {
    //1 is like
    //2 is dislike
    //3 is unlike or undislike
    RKObjectManager *objectManager = [RKObjectManager sharedClient];
    [self configureRestKitLikeDislike:objectManager];

    
    NSString *strReviewID, *strShopID;
    if(_detailReputaitonReview != nil) {
        strReviewID = _detailReputaitonReview.review_id;
        strShopID = _detailReputaitonReview.shop_id;
    }
    else {
        strReviewID = _reviewList.review_id;
        strShopID = _reviewList.review_shop_id;
    }
    
    NSDictionary* param = @{@"action":@"like_dislike_review",
                            @"review_id":strReviewID,
                            @"like_status":@(likeDislikeTag),
                            @"shop_id":strShopID,
                            @"product_id":_strProductID};
    
    RKObjectRequestOperation *request = [objectManager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:@"action/review.pl" parameters:[param encrypt]];
    [request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"%@", operation.HTTPRequestOperation.responseString);
        [_timer invalidate];
        _timer = nil;
        
        //Result
        NSDictionary *result = ((RKMappingResult*) mappingResult).dictionary;
        LikeDislikePost *likeDislikePost = [result objectForKey:@""];
        LikeDislikePostResult *likeDislikePostResult = likeDislikePost.result;
        BOOL status = [likeDislikePostResult.is_success isEqualToString:@"1"];
        
        [loadingLikeDislike removeObjectForKey:strReviewID];
        TotalLikeDislike *totalLikeDislike = [dictLikeDislike objectForKey:strReviewID];
        if(status) {
            if(totalLikeDislike) {
                totalLikeDislike.total_like_dislike.total_like = likeDislikePostResult.content.total_like_dislike.total_like;
                totalLikeDislike.total_like_dislike.total_dislike = likeDislikePostResult.content.total_like_dislike.total_dislike;
                totalLikeDislike.like_status = [NSString stringWithFormat:@"%d", likeDislikeTag];
                _strLikeStatus = totalLikeDislike.like_status;
                _strTotalLike = totalLikeDislike.total_like_dislike.total_like;
                _strTotalDisLike = totalLikeDislike.total_like_dislike.total_dislike;
                
                //Reload UI
                [self initTable];
                UIViewController *viewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
                if([viewController isMemberOfClass:[ProductReputationViewController class]]) {
                    [((ProductReputationViewController *) viewController) reloadTable];
                }
                else if([viewController isMemberOfClass:[ShopContainerViewController class]]) {
                    viewController = [((ShopContainerViewController *) viewController) getActiveViewController];
                    if([viewController isMemberOfClass:[ShopReviewPageViewController class]])
                        [((ShopReviewPageViewController *) viewController) reloadTable];
                }
            }
        }
        else {
            if(likeDislikePost.message_error!=nil && likeDislikePost.message_error.count>0) {
                StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:likeDislikePost.message_error delegate:self];
                [stickyAlertView show];
            }
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.HTTPRequestOperation.responseString);
        [_timer invalidate];
        _timer = nil;
        [loadingLikeDislike removeObjectForKey:strReviewID];
    }];
    
    if(operationQueueLikeDislike == nil) {
        operationQueueLikeDislike = [NSOperationQueue new];
    }
    [operationQueueLikeDislike addOperation:request];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeout:) userInfo:strReviewID repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)requestTimeout:(NSTimer *)timer {
    [loadingLikeDislike removeObjectForKey:[timer userInfo]];
    
    RKObjectRequestOperation *objectReputation = [operationQueueLikeDislike.operations firstObject];
    [objectReputation cancel];
}

- (void)showLoginView {
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    navigationController.navigationBar.translucent = NO;
    navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    
    LoginViewController *controller = [LoginViewController new];
    controller.delegate = self;
    controller.isPresentedViewController = YES;
    controller.redirectViewController = self;
    navigationController.viewControllers = @[controller];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

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

- (TokopediaNetworkManager *)getNetworkManager:(int)tag {
    if(tag==CTagComment || tag==CTagHapus) {
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
    if(likeDislikeObj.result.like_dislike_review.count > 0) {
        TotalLikeDislike *tempTotalLikeDislike = ((TotalLikeDislike *) [likeDislikeObj.result.like_dislike_review firstObject]);
        
        if((_detailReputaitonReview!=nil && [tempTotalLikeDislike.review_id isEqualToString:_detailReputaitonReview.review_id]) ||
           (_reviewList!=nil && [tempTotalLikeDislike.review_id isEqualToString:_reviewList.review_id])) {
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
    if(_detailReputaitonReview == nil) {
        strText = [NSString stringWithFormat:@"%@ Poin", strNReputation];
        [self initPopUp:strText withSender:sender withRangeDesc:NSMakeRange(strText.length-4, 4)];
    }
    else {
        strText = _detailReputaitonReview.product_owner.user_shop_reputation.tooltip;
        
        if(strText != nil) {
            NSArray *tempStr = [strText componentsSeparatedByString:@" "];
            [self initPopUp:strText withSender:sender withRangeDesc:NSMakeRange(strText.length-((NSString *)[tempStr lastObject]).length, ((NSString *)[tempStr lastObject]).length)];
        }
        else {
            strNReputation = _detailReputaitonReview.product_owner.shop_reputation_score;
            strText = [NSString stringWithFormat:@"%@ Poin", strNReputation];
            [self initPopUp:strText withSender:sender withRangeDesc:NSMakeRange(strText.length-4, 4)];
        }
    }
}


#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag {
    if(tag == CTagComment) {
        if(_isFromInboxNotification) {
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
        else {
            if(_detailReputaitonReview != nil) {
                return @{@"action":@"add_comment_review",
                     @"reputation_id":_detailReputaitonReview.reputation_id==nil? @"":_detailReputaitonReview.reputation_id,
                     @"product_id":_strProductID,
                     @"review_id":_detailReputaitonReview.review_id,
                     @"text_comment":[growTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]};
            }
            else if(_reviewList != nil) {
                return @{@"action":@"add_comment_review",
                         @"reputation_id":_reviewList.review_reputation_id==nil? @"":_reviewList.review_reputation_id,
                         @"product_id":_strProductID,
                         @"review_id":_reviewList.review_id,
                         @"text_comment":[growTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]};
            }
        }
    }
    else if(tag == CTagHapus) {
        if(_isFromInboxNotification) {
            if(_detailReputaitonReview != nil) {
                return @{@"action":@"delete_reputation_review_response",
                         @"reputation_id":_detailReputaitonReview.reputation_id,
                         @"shop_id":_detailReputaitonReview.shop_id,
                         @"review_id":_detailReputaitonReview.review_id,
                         @"product_id":_strProductID
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
        else {
            if(_detailReputaitonReview != nil) {
                return @{@"action":@"delete_comment_review",
                         @"review_id":_detailReputaitonReview.review_id
                         };
            }
            else if(_reviewList != nil) {
                return @{@"action":@"delete_comment_review",
                         @"review_id":_reviewList.review_id
                         };
            }
        }
    }
    
    return nil;
}


- (NSString*)getPath:(int)tag {
    if(tag==CTagComment || tag==CTagHapus) {
        if(_isFromInboxNotification) {
            return [postActionUrl isEqualToString:@""] ? @"action/reputation.pl" : postActionUrl;
        }
        else
            return [postActionUrl isEqualToString:@""] ? @"action/review.pl" : postActionUrl;
    }
    
    return nil;
}


- (id)getObjectManager:(int)tag {
    if(tag == CTagComment) {
        RKObjectManager *objectManager;
        if([baseActionUrl isEqualToString:kTkpdBaseURLString] || [baseActionUrl isEqualToString:@""]) {
            objectManager = [RKObjectManager sharedClient];
        } else {
            objectManager = [RKObjectManager sharedClient:baseActionUrl];
        }
        
        if(_isFromInboxNotification) {
            [self setMappingNewComment:objectManager withTag:tag];
        }
        else {
            [self setMappingOldComment:objectManager withTag:tag];
        }
        
        return objectManager;
    }
    else if(tag == CTagHapus) {
        RKObjectManager *objectManager;
        if([baseActionUrl isEqualToString:kTkpdBaseURLString] || [baseActionUrl isEqualToString:@""]) {
            objectManager = [RKObjectManager sharedClient];
        } else {
            objectManager = [RKObjectManager sharedClient:baseActionUrl];
        }
        
        [self setMappingNewDeleteComment:objectManager withTag:tag];
        
        return objectManager;
    }
    
    return nil;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag {
    if(tag==CTagComment || tag==CTagHapus) {
        ResponseComment *responseComment = [((RKMappingResult *) result).dictionary objectForKey:@""];
        
        return responseComment.status;
    }

    return nil;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag {
    ResponseComment *responseComment = [((RKMappingResult *) successResult).dictionary objectForKey:@""];
    
    if(tag == CTagComment) {
        if([responseComment.result.is_success isEqualToString:@"1"]) {
            isSuccessSentMessage = YES;
            
            if(_detailReputaitonReview != nil) {
                _detailReputaitonReview.review_response.response_create_time = _detailReputaitonReview.viewModel.review_response.response_create_time = responseComment.result.review_response.response_time_fmt;
                _detailReputaitonReview.review_response.response_message = _detailReputaitonReview.viewModel.review_response.response_message = responseComment.result.review_response.response_message;
                _detailReputaitonReview.review_response.failedSentMessage = _detailReputaitonReview.viewModel.review_response.failedSentMessage = NO;
                _detailReputaitonReview.review_response.canDelete = _detailReputaitonReview.viewModel.review_response.canDelete = YES;
                
                
                if(responseComment.result.product_owner != nil) {
                    _detailReputaitonReview.product_owner.user_label_id = responseComment.result.product_owner.user_label_id;
                    _detailReputaitonReview.product_owner.user_label = responseComment.result.product_owner.user_label;
                    
                    if(_isFromInboxNotification) {
                        _detailReputaitonReview.product_owner.shop_id = responseComment.result.product_owner.shop_id;
                        
                        _detailReputaitonReview.product_owner.user_url = responseComment.result.product_owner.user_url;
                        _detailReputaitonReview.product_owner.shop_img = responseComment.result.product_owner.shop_img;
                        _detailReputaitonReview.product_owner.shop_url = responseComment.result.product_owner.shop_url;
                        _detailReputaitonReview.product_owner.shop_name = responseComment.result.product_owner.shop_name;
                        _detailReputaitonReview.product_owner.full_name = responseComment.result.product_owner.full_name;
                        _detailReputaitonReview.product_owner.user_img = responseComment.result.product_owner.user_img;
                        _detailReputaitonReview.product_owner.user_id = responseComment.result.product_owner.user_id;
                        _detailReputaitonReview.product_owner.shop_reputation_badge = responseComment.result.product_owner.shop_reputation_badge;
                        _detailReputaitonReview.product_owner.shop_reputation_score = responseComment.result.product_owner.shop_reputation_score;
                    }
                    else {
                        _shopBadgeLevel = _detailReputaitonReview.shop_badge_level = responseComment.result.shop_reputation.reputation_badge_object;
                        _detailReputaitonReview.product_owner.shop_reputation_score = responseComment.result.shop_reputation.reputation_score;
                        _detailReputaitonReview.product_owner.shop_id = responseComment.result.shop_id;
                        _detailReputaitonReview.product_owner.shop_name = responseComment.result.shop_name;
                        _detailReputaitonReview.product_owner.shop_url = responseComment.result.shop_img_uri;
                    }
                }
            }
            else if(_reviewList != nil) {
                _reviewList.review_response.response_create_time = responseComment.result.review_response.response_time_ago;
                _reviewList.review_response.response_message = responseComment.result.review_response.response_message;
                _reviewList.review_response.failedSentMessage = NO;
                _reviewList.review_response.canDelete = YES;
                
                if(responseComment.result.product_owner != nil) {
                    _reviewList.review_product_owner.user_name = responseComment.result.product_owner.full_name;
                    _reviewList.review_product_owner.user_id = responseComment.result.product_owner.user_id;
                    _reviewList.review_product_owner.user_image = responseComment.result.product_owner.user_img;
                }
                
                //Set badge number
                if(! _isFromInboxNotification) {
                    _shopBadgeLevel.level = responseComment.result.shop_reputation.reputation_badge_object.level;
                    _shopBadgeLevel.set = responseComment.result.shop_reputation.reputation_badge_object.set;
                }
            }
            
            StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[CStringSuccessSentComment] delegate:self];
            [stickyAlertView show];
            
            //Reload data in DetailMyReviewReputationViewController
            UIViewController *viewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
            if([viewController isMemberOfClass:[DetailMyReviewReputationViewController class]]) {
                [((DetailMyReviewReputationViewController *) viewController) successGiveComment];
            }
            else if([viewController isMemberOfClass:[ShopContainerViewController class]]) {
                viewController = [((ShopContainerViewController *) viewController) getActiveViewController];
                if([viewController isMemberOfClass:[ShopReviewPageViewController class]]) {
                    [((ShopReviewPageViewController *) viewController) reloadTable];
                }
            }
            else if([viewController isMemberOfClass:[ProductReputationViewController class]]) {
                [((ProductReputationViewController *) viewController) reloadTable];
            }
            
            
            //Update Header
            NSString *strResponseMessage = (_detailReputaitonReview==nil? _reviewList.review_response.response_message:_detailReputaitonReview.review_response.response_message);
            if(strResponseMessage==nil || [strResponseMessage isEqualToString:@"0"]) {
                [productReputationCell.getBtnChat setTitle:[NSString stringWithFormat:@"%@ Komentar", strResponseMessage] forState:UIControlStateNormal];
            }
            else {
                [productReputationCell.getBtnChat setTitle:@"1 Komentar" forState:UIControlStateNormal];
            }
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
        isDeletingMessage = NO;
        if(successResult && [((ResponseComment *) [((RKMappingResult *) successResult).dictionary objectForKey:@""]).result.is_success isEqualToString:@"1"]) {
            if(_detailReputaitonReview != nil) {
                _detailReputaitonReview.review_response.canDelete = _detailReputaitonReview.viewModel.review_response.canDelete = NO;
                _detailReputaitonReview.review_response.response_create_time = _detailReputaitonReview.viewModel.review_response.response_create_time = responseComment.result.review_response.response_time_fmt;
                _detailReputaitonReview.review_response.response_message = _detailReputaitonReview.viewModel.review_response.response_message = responseComment.result.review_response.response_message;
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
                _reviewList.review_response.canDelete = NO;
                _reviewList.review_response.response_create_time = responseComment.result.review_response.response_time_fmt;
                _reviewList.review_response.response_message = responseComment.result.review_response.response_message;
                _reviewList.review_product_owner.user_image = responseComment.result.product_owner.user_img;
                _reviewList.review_product_owner.user_name = responseComment.result.product_owner.full_name;
                _reviewList.review_product_owner.user_id = responseComment.result.product_owner.user_id;
            }
            
            StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[CStringSuccessRemoveMessage] delegate:self];
            [stickyAlertView show];
            
            //Reload data in DetailMyReviewReputationViewController
            UIViewController *viewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
            if([viewController isMemberOfClass:[DetailMyReviewReputationViewController class]]) {
                [((DetailMyReviewReputationViewController *) viewController) successHapusComment];
            }
            else if([viewController isMemberOfClass:[ShopContainerViewController class]]) {
                viewController = [((ShopContainerViewController *) viewController) getActiveViewController];
                if([viewController isMemberOfClass:[ShopReviewPageViewController class]]) {
                    [((ShopReviewPageViewController *) viewController) reloadTable];
                }
            }
            else if([viewController isMemberOfClass:[ProductReputationViewController class]]) {
                [((ProductReputationViewController *) viewController) reloadTable];
            }
            
            
            //Update Header
            NSString *strResponseMessage = (_detailReputaitonReview==nil? _reviewList.review_response.response_message:_detailReputaitonReview.review_response.response_message);
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
            if(_detailReputaitonReview != nil) {
                _detailReputaitonReview.review_response.canDelete = YES;
            }
            else if(_reviewList != nil) {
                _reviewList.review_response.canDelete = YES;
            }
            
            StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringFailedRemoveMessage] delegate:self];
            [stickyAlertView show];
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
        isDeletingMessage = NO;
        if(_detailReputaitonReview != nil) {
            _detailReputaitonReview.review_response.canDelete = YES;
        }
        else {
            _reviewList.review_response.canDelete = YES;
        }
        
        [tableReputation reloadData];
    }
}

#pragma mark - LoginView Delegate
- (void)redirectViewController:(id)viewController {

}


#pragma mark - GTM
- (void)configureGTM {
    [TPAnalytics trackUserId];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _gtmContainer = appDelegate.container;
    
    baseActionUrl = [_gtmContainer stringForKey:GTMKeyInboxActionReputationBase];
    postActionUrl = [_gtmContainer stringForKey:GTMKeyInboxActionReputationPost];
}

#pragma mark - Swipe Delegate
-(BOOL)swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
{
    //Delete message
    if((_detailReputaitonReview!=nil? _detailReputaitonReview.review_response.canDelete:_reviewList.review_response.canDelete) && _isMyProduct) {
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
            if(_detailReputaitonReview != nil) {
                _detailReputaitonReview.review_response.canDelete = NO;
            }
            else {
                _reviewList.review_response.canDelete = NO;
            }
            
            isDeletingMessage = YES;
            [tableReputation reloadData];
            [[self getNetworkManager:CTagHapus] doRequest];
            
            return YES;
        }];

        return @[trash];
    }
    
    return nil;
}

#pragma mark - ReviewRequestDelegate
-(void)didReceiveReviewLikeDislikes:(TotalLikeDislike *)totalLikeDislike{
    _strTotalLike = totalLikeDislike.total_like_dislike.total_like;
    _strTotalDisLike = totalLikeDislike.total_like_dislike.total_dislike;
        
    if((_detailReputaitonReview!=nil && [totalLikeDislike.review_id isEqualToString:_detailReputaitonReview.review_id]) ||
       (_reviewList!=nil && [totalLikeDislike.review_id isEqualToString:_reviewList.review_id])) {
        [productReputationCell setHiddenViewLoad:YES];
        [productReputationCell.getBtnDisLike setTitle:totalLikeDislike.total_like_dislike.total_dislike forState:UIControlStateNormal];
        [productReputationCell.getBtnLike setTitle:totalLikeDislike.total_like_dislike.total_like  forState:UIControlStateNormal];
        
        [self setLikeDislikeActive:totalLikeDislike.like_status];
    }
}
- (void)setLikeDislikeActive:(NSString *)strStatusLike {
    if(strStatusLike!=nil && [strStatusLike isEqualToString:@"1"]) {
        [productReputationCell.getBtnLike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_like_active" ofType:@"png"]] forState:UIControlStateNormal];
        [productReputationCell.getBtnDisLike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_dislike" ofType:@"png"]] forState:UIControlStateNormal];
    }
    else if(strStatusLike!=nil && [strStatusLike isEqualToString:@"2"]) {
        [productReputationCell.getBtnDisLike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_dislike_active" ofType:@"png"]] forState:UIControlStateNormal];
        [productReputationCell.getBtnLike setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_like" ofType:@"png"]] forState:UIControlStateNormal];
    }
}
@end
