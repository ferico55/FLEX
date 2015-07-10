//
//  ProductReputationViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 6/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "AdvanceReview.h"
#import "CMPopTipView.h"
#import "DetailReputationReview.h"
#import "LoadingView.h"
#import "NoResultView.h"
#import "ProductReputationCell.h"
#import "ProductOwner.h"
#import "ProductDetailReputationViewController.h"
#import "ProductReputationViewController.h"
#import "Paging.h"
#import "RatingList.h"
#import "ReviewResponse.h"
#import "Review.h"
#import "String_Reputation.h"
#import "TokopediaNetworkManager.h"
#define CCellIdentifier @"cell"
#define CTagGetProductReview 1

@interface ProductReputationViewController ()<TTTAttributedLabelDelegate, productReputationDelegate, CMPopTipViewDelegate, UIActionSheetDelegate, TokopediaNetworkManagerDelegate, LoadingViewDelegate>
@end

@implementation ProductReputationViewController
{
    NSMutableParagraphStyle *style;
    CMPopTipView *popTipView;
    UIRefreshControl *refreshControl;
    LoadingView *loadingView;
    NoResultView *noResultView;
    
    int page;
    NSString *strUri;
    Review *review;
    NSMutableArray *arrList;
    TokopediaNetworkManager *tokopediaNetworkManager;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    page = 0;
    
    [self initTable];
    tableContent.allowsSelection = NO;
    tableContent.backgroundColor = [UIColor clearColor];

    [self setLoadingView:YES];
    [[self getNetworkManager:CTagGetProductReview] doRequest];
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

- (void)initNavigation {
    self.navigationController.title = @"Reputasi";
    [self.navigationController.navigationBar sizeToFit];
}

- (void)setRateStar:(int)tag withAnimate:(BOOL)isAnimate {
    int nRate1, nRate2, nRate3, nRate4, nRate5;
    float totalCount = 0;
    nRate1 = nRate2 = nRate3 = nRate4 = nRate5 = 0;
    
    
    for(RatingList *tempRatingList in review.result.advance_review.rating_list) {
        switch ([tempRatingList.rating_rating_star_point intValue]) {
            case 5:
            {
                nRate5 = [(tag==0? tempRatingList.rating_rating:tempRatingList.rating_rate_accuracy) intValue];
                totalCount += nRate5;
            }
                break;
            case 4:
            {
                nRate4 = [(tag==0? tempRatingList.rating_rating:tempRatingList.rating_rate_accuracy) intValue];
                totalCount += nRate4;
            }
                break;
            case 3:
            {
                nRate3 = [(tag==0? tempRatingList.rating_rating:tempRatingList.rating_rate_accuracy) intValue];
                totalCount += nRate3;
            }
                break;
            case 2:
            {
                nRate2 = [(tag==0? tempRatingList.rating_rating:tempRatingList.rating_rate_accuracy) intValue];
                totalCount += nRate2;
            }
                break;
            case 1:
            {
                nRate1 = [(tag==0? tempRatingList.rating_rating:tempRatingList.rating_rate_accuracy) intValue];
                totalCount += nRate1;
            }
                break;
        }
    }
    
    //Set Progress
    if(totalCount == 0) {
        [progress1 setProgress:0 animated:isAnimate];
        [progress2 setProgress:0 animated:isAnimate];
        [progress3 setProgress:0 animated:isAnimate];
        [progress4 setProgress:0 animated:isAnimate];
        [progress5 setProgress:0 animated:isAnimate];
    }
    else {
        [progress1 setProgress:nRate1/totalCount animated:isAnimate];
        [progress2 setProgress:nRate2/totalCount animated:isAnimate];
        [progress3 setProgress:nRate3/totalCount animated:isAnimate];
        [progress4 setProgress:nRate4/totalCount animated:isAnimate];
        [progress5 setProgress:nRate5/totalCount animated:isAnimate];
    }
    
    lblTotal1Rate.text = [NSString stringWithFormat:@"(%d)", nRate1];
    lblTotal2Rate.text = [NSString stringWithFormat:@"(%d)", nRate2];
    lblTotal3Rate.text = [NSString stringWithFormat:@"(%d)", nRate3];
    lblTotal4Rate.text = [NSString stringWithFormat:@"(%d)", nRate4];
    lblTotal5Rate.text = [NSString stringWithFormat:@"(%d)", nRate5];
    
    //Calculate widht total rate
    UILabel *tempLabel = [UILabel new];
    tempLabel.text = lblTotal1Rate.text;
    tempLabel.font = lblTotal1Rate.font;
    tempLabel.textColor = lblTotal1Rate.textColor;
    tempLabel.numberOfLines = 0;
    CGSize tempSize = [tempLabel sizeThatFits:CGSizeMake(self.view.bounds.size.width/5.3f, 9999)];
    constWidthLblRate1.constant = constWidthLblRate2.constant = constWidthLblRate3.constant = constWidthLblRate4.constant = constWidthLblRate5.constant = tempSize.width;
    
    
    
    //Set header rate
    for(int i=0;i<arrImageHeaderRating.count;i++) {
        UIImageView *tempImageView = arrImageHeaderRating[i];
        tempImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(i<3)?@"icon_star_active":@"icon_star" ofType:@"png"]];
    }
    
    lblTotalHeaderRating.text = [NSString stringWithFormat:@"%.1f Out of %d", [review.result.advance_review.product_rating_point floatValue], 5];
    lblDescTotalHeaderRating.text = [NSString stringWithFormat:@"Based on %d ratings in the post %d months", [review.result.advance_review.product_rating_point intValue], 6];
}


- (void)initTable {
    //Refresh Control
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
    [refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [tableContent addSubview:refreshControl];
    tableContent.tableHeaderView = viewHeader;
}



#pragma mark - UITableView Delegate and DataSource 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTTAttributedLabel *tempLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    [self setPropertyLabelDesc:tempLabel];
    [self initLabelDesc:tempLabel withText:@"pasjk pdlf klksa jflj asldf jsadj flkjsalkdf jask jdflksa jdlkf jaslkdj flkas jdfl ajslkdf jsakl jflkasj dlfk jaslk jflksd"];

    CGSize tempSizeDesc = [tempLabel sizeThatFits:CGSizeMake(self.view.bounds.size.width-(CPaddingTopBottom*4), 9999)];//4 padding left and right of label description
    return tempSizeDesc.height + (CPaddingTopBottom*8) + 2 + CPaddingTopBottom + CHeightDate + CHeightViewStar + CHeightButton + CheightImage; //9 is total padding of each row component
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == arrList.count-1) {
        if(strUri!=nil && ![strUri isEqualToString:@"0"]) {
            [self setLoadingView:YES];
            [[self getNetworkManager:CTagGetProductReview] doRequest];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductReputationCell *cell = [tableView dequeueReusableCellWithIdentifier:CCellIdentifier];
    if(cell == nil) {
        NSArray *tempArr = [[NSBundle mainBundle] loadNibNamed:@"ProductReputationCell" owner:nil options:0];
        cell = [tempArr objectAtIndex:0];
        cell.delegate = self;
        [self setPropertyLabelDesc:cell.getLabelDesc];
    }
    
    cell.getBtnRateEmoji.tag = cell.getBtnChat.tag = cell.getBtnDisLike.tag = cell.getBtnLike.tag = cell.getBtnMore.tag = cell.getLabelDesc.tag = indexPath.row;
    DetailReputationReview *detailReputationReview = [arrList objectAtIndex:indexPath.row];
    
    //Set Image
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:detailReputationReview.review_user_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    [cell.getImageProfile setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [cell.getImageProfile setImage:image];
#pragma clang diagnostic pop
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];
    
    //Set data
    [cell setLabelUser:detailReputationReview.review_user_name withTag:0];
    [cell setPercentage:detailReputationReview.review_user_reputation.positive_percentage];
    [cell setLabelDate:detailReputationReview.review_create_time];
    [cell setDescription:detailReputationReview.review_message];
    [cell setImageKualitas:[detailReputationReview.review_rate_service intValue]];
    [cell setImageAkurasi:[detailReputationReview.review_rate_accuracy intValue]];
    
    return cell;
}

- (void)mappingAttribute:(DetailReputationReview *)reputationReview {
    reputationReview.product_rating_point = reputationReview.review_rate_service;
    reputationReview.product_accuracy_point = reputationReview.review_rate_accuracy;
    reputationReview.review_full_name = reputationReview.review_user_name;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DetailReputationReview *detailReputationReview = arrList[indexPath.row];
    ProductDetailReputationViewController *productDetailReputationViewController = [ProductDetailReputationViewController new];
    
    [self mappingAttribute:detailReputationReview];
    productDetailReputationViewController.detailReputaitonReview = detailReputationReview;
    [self.navigationController pushViewController:productDetailReputationViewController animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrList.count;
}


#pragma mark - TTTAttributeLabel Delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didLongPressLinkWithURL:(NSURL *)url atPoint:(CGPoint)point
{
    
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    DetailReputationReview *detailReputationReview = arrList[label.tag];
    ProductDetailReputationViewController *productDetailReputationViewController = [ProductDetailReputationViewController new];
    
    [self mappingAttribute:detailReputationReview];
    productDetailReputationViewController.detailReputaitonReview = detailReputationReview;
    [self.navigationController pushViewController:productDetailReputationViewController animated:YES];
}


#pragma mark - Action
- (void)refreshView:(UIRefreshControl*)refresh
{
    NSLog(@"sdf");
    [refresh endRefreshing];
}

- (IBAction)actionFilter6Month:(id)sender {
}

- (IBAction)actionFilterAllTime:(id)sender {

}

- (IBAction)actionSegmentedValueChange:(id)sender {
    switch (((UISegmentedControl *) sender).selectedSegmentIndex) {
        case 0:
        {
            [self setRateStar:0 withAnimate:YES];
        }
            break;
        case 1:
        {
            [self setRateStar:1 withAnimate:YES];
        }
            break;
    }
}

- (void)actionVote:(id)sender {
    [self dismissAllPopTipViews];
}


#pragma mark - Method
- (void)setLoadingView:(BOOL)isLoad {
    if(isLoad) {
        tableContent.tableFooterView = viewFooter;
        [footerActIndicator startAnimating];
    }
    else {
        [footerActIndicator stopAnimating];
        tableContent.tableFooterView = nil;
    }
}


- (TokopediaNetworkManager *)getNetworkManager:(int)tag {
    if(tag == CTagGetProductReview) {
        if(tokopediaNetworkManager == nil) {
            tokopediaNetworkManager = [TokopediaNetworkManager new];
            tokopediaNetworkManager.tagRequest = tag;
            tokopediaNetworkManager.delegate = self;
        }
        
        return tokopediaNetworkManager;
    }
    
    return nil;
}

- (void)dismissAllPopTipViews
{
    [popTipView dismissAnimated:YES];
    popTipView = nil;
}

- (void)setPropertyLabelDesc:(TTTAttributedLabel *)lblDesc {
    lblDesc.backgroundColor = [UIColor clearColor];
    lblDesc.textAlignment = NSTextAlignmentLeft;
    lblDesc.font = [UIFont fontWithName:@"GothamBook" size:13.0f];
    lblDesc.textColor = [UIColor colorWithRed:117/255.0f green:117/255.0f blue:117/255.0f alpha:1.0f];
    lblDesc.lineBreakMode = NSLineBreakByWordWrapping;
    lblDesc.numberOfLines = 0;
}


#pragma mark - ProductReputation Delegate
- (void)initLabelDesc:(TTTAttributedLabel *)lblDesc withText:(NSString *)strDescription {
    NSString *strLihatSelengkapnya = @"Lihat Selengkapnya";
    if(strDescription.length > 100) {
        strDescription = [NSString stringWithFormat:@"%@... %@", [strDescription substringToIndex:100], strLihatSelengkapnya];
        
        NSRange range = [strDescription rangeOfString:strLihatSelengkapnya];
        lblDesc.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        lblDesc.delegate = self;
        lblDesc.activeLinkAttributes = @{(id)kCTForegroundColorAttributeName:[UIColor lightGrayColor], NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone)};
        lblDesc.linkAttributes = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone)};
        [lblDesc addLinkToURL:[NSURL URLWithString:@""] withRange:range];
        
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:strDescription];
        [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, strDescription.length)];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(strDescription.length-strLihatSelengkapnya.length, strLihatSelengkapnya.length)];
        lblDesc.attributedText = str;
    }
    else {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:strDescription];
        [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, strDescription.length)];
        lblDesc.attributedText = str;
        lblDesc.delegate = nil;
        [lblDesc addLinkToURL:[NSURL URLWithString:@""] withRange:NSMakeRange(0, 0)];
    }
}

- (void)actionLike:(id)sender {
    
}
- (void)actionDisLike:(id)sender {
    
}
- (void)actionChat:(id)sender {
    ProductDetailReputationViewController *productDetailReputationViewController = [ProductDetailReputationViewController new];
    [self.navigationController pushViewController:productDetailReputationViewController animated:YES];
}

- (void)actionMore:(id)sender {

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:CStringBatal destructiveButtonTitle:nil otherButtonTitles:CStringLapor, nil];
    actionSheet.tag = ((UIButton *) sender).tag;
    [actionSheet showInView:self.view];
}


- (void)actionRate:(id)sender {
    int paddingRightLeftContent = 10;
    DetailReputationReview *tempDetailReputationView = arrList[((UIView *) sender).tag];
    UIView *viewContentPopUp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (CWidthItemPopUp*3)+paddingRightLeftContent+paddingRightLeftContent, CHeightItemPopUp)];
    viewContentPopUp.backgroundColor = [UIColor clearColor];
    
    UIButton *btnMerah = (UIButton *)[self initButtonContentPopUp:tempDetailReputationView.review_user_reputation.negative withImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_sad" ofType:@"png"]] withFrame:CGRectMake(paddingRightLeftContent, 0, CWidthItemPopUp, CHeightItemPopUp) withTextColor:[UIColor colorWithRed:244/255.0f green:67/255.0f blue:54/255.0f alpha:1.0f]];
    UIButton *btnKuning = (UIButton *)[self initButtonContentPopUp:tempDetailReputationView.review_user_reputation.neutral withImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_netral" ofType:@"png"]] withFrame:CGRectMake(btnMerah.frame.origin.x+btnMerah.bounds.size.width, 0, CWidthItemPopUp, CHeightItemPopUp) withTextColor:[UIColor colorWithRed:255/255.0f green:193/255.0f blue:7/255.0f alpha:1.0f]];
    UIButton *btnHijau = (UIButton *)[self initButtonContentPopUp:tempDetailReputationView.review_user_reputation.positive withImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_smile" ofType:@"png"]] withFrame:CGRectMake(btnKuning.frame.origin.x+btnKuning.bounds.size.width, 0, CWidthItemPopUp, CHeightItemPopUp) withTextColor:[UIColor colorWithRed:0 green:128/255.0f blue:0 alpha:1.0f]];
    
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


#pragma mark - PopUp
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    [self dismissAllPopTipViews];
}


#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"%d", (int)buttonIndex);
}


#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag {
    if(tag == CTagGetProductReview) {
        return @{@"action" : @"get_product_review",
                 @"shop_domain" : _strShopDomain,
                 @"product_id" : _strProductID,
                 @"page" : @(page)};
    }
    
    return nil;
}

- (NSString*)getPath:(int)tag {
    if(tag == CTagGetProductReview) {
        return @"product.pl";
    }
    
    return nil;
}

- (id)getObjectManager:(int)tag {
    if(tag == CTagGetProductReview) {
        RKObjectManager *objectManager = [RKObjectManager sharedClient];
        
        // setup object mappings
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Review class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                            kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY}];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ReviewResult class]];
        RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
        [pagingMapping addAttributeMappingsFromArray:@[CUriNext,
                                                       CUriPrevious]];
        
        
        RKObjectMapping *advreviewMapping = [RKObjectMapping mappingForClass:[AdvanceReview class]];
        [advreviewMapping addAttributeMappingsFromDictionary:@{CProductRatingPoint:CProductRatingPoint,
                                                          CProductRateAccuracyPoint:CProductRateAccuracyPoint,
                                                          CProductPositiveReviewRating:CProductPositiveReviewRating,
                                                          CProductNetralReviewRating:CProductNetralReviewRating,
                                                          CProductRatingStarPoint:CProductRatingStarPoint,
                                                          CProductRatingStarDesc:CProductRatingStarDesc,
                                                          CProductNegativeReviewRating:CProductNegativeReviewRating,
                                                          CProductReview:CProductReview,
                                                          CProductRateAccuracy:CProductRateAccuracy,
                                                          CProductAccuracyStarDesc:CProductAccuracyStarDesc,
                                                          CProductRating:CProductRating,
                                                          CProductNetralReviewRateAccuray:CProductNetralReviewRateAccuray,
                                                          CProductAccuacyStarRate:CProductAccuacyStarRate,
                                                          CProductPositiveReviewRateAccuracy:CProductPositiveReviewRateAccuracy,
                                                          CProductNegativeReviewRateAccuracy:CProductNegativeReviewRateAccuracy
                                                        }];
        
        RKObjectMapping *detailReputationReviewMapping = [RKObjectMapping mappingForClass:[DetailReputationReview class]];
        [detailReputationReviewMapping addAttributeMappingsFromDictionary:@{CReviewUpdateTime:CReviewUpdateTime,
                                                                       CReviewRateAccuracyDesc:CReviewRateAccuracyDesc,
                                                                       CReviewUserLabelID:CReviewUserLabelID,
                                                                       CReviewUserName:CReviewUserName,
                                                                       CReviewRateAccuracy:CReviewRateAccuracy,
                                                                       CReviewMessage:CReviewMessage,
                                                                       CReviewRateProductDesc:CReviewRateProductDesc,
                                                                       CReviewRateSpeedDesc:CReviewRateSpeedDesc,
                                                                       CReviewShopID:CShopID,
                                                                       CReviewUserImage:CReviewUserImage,
                                                                       CReviewUserLabel:CReviewUserLabel,
                                                                       CReviewCreateTime:CReviewCreateTime,
                                                                       CReviewID:CReviewID,
                                                                       CReviewRateServiceDesc:CReviewRateServiceDesc,
                                                                       CReviewRateProduct:CReviewRateProduct,
                                                                       CReviewRateSpeed:CReviewRateSpeed,
                                                                       CReviewRateService:CReviewRateService,
                                                                       CReviewUserID:CReviewUserID
                                                                            }];
        
        RKObjectMapping *reviewReputationMapping = [RKObjectMapping mappingForClass:[ReputationDetail class]];
        [reviewReputationMapping addAttributeMappingsFromArray:@[CPositivePercentage,
                                                                CNegative,
                                                                CNeutral,
                                                                CPositif]];
        
        RKObjectMapping *reviewResponseMapping = [RKObjectMapping mappingForClass:[ReviewResponse class]];
        [reviewReputationMapping addAttributeMappingsFromArray:@[CResponseCreateTime,
                                                                CResponseMessage]];
        
        
        RKObjectMapping *productOwnerMapping = [RKObjectMapping mappingForClass:[ProductOwner class]];
        [reviewReputationMapping addAttributeMappingsFromDictionary:@{CUserLabelID:CUserLabelID,
                                                                CUserLabel:CUserLabel,
                                                                CuserID:CuserID,
                                                                CUserImage:CUserImage,
                                                                CFullName:CUserName}];
        

        RKObjectMapping *ratingListMapping = [RKObjectMapping mappingForClass:[RatingList class]];
        [ratingListMapping addAttributeMappingsFromArray:@[CRatingRatingStarPoint,
                                                           CRatingTotalRateAccuracyPersen,
                                                           CRatingRateService,
                                                           CRatingRatingStarDesc,
                                                           CRatingRatingFmt,
                                                           CRatingTotalRatingPersen,
                                                           CRatingUrlFilterRateAccuracy,
                                                           CRatingRating,
                                                           CRatingUrlFilterRating,
                                                           CRatingRateSpeed,
                                                           CRatingRateAccuracy
                                                           CRatingRateAccuracyFmt,
                                                           CRatingRatingPoint]];
        
                                                                
        //add relationship mapping
        [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CPaging toKeyPath:CPaging withMapping:pagingMapping]];
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CAdvanceReview toKeyPath:CAdvanceReview withMapping:advreviewMapping]];
        
        [advreviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CProductRatingList toKeyPath:CRating_List withMapping:ratingListMapping]];
        
        [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReviewUserReputation toKeyPath:CReviewUserReputation withMapping:reviewReputationMapping]];
        [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReviewResponse toKeyPath:CReviewResponse withMapping:reviewResponseMapping]];
        [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReviewProductOwner toKeyPath:CProductOwner withMapping:productOwnerMapping]];
        
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CList toKeyPath:CList withMapping:detailReputationReviewMapping]];

        
        //register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                      method:RKRequestMethodPOST
                                                                                                 pathPattern:[self getPath:tag]
                                                                                                     keyPath:@""
                                                                                                 statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [objectManager addResponseDescriptor:responseDescriptorStatus];
        
        return objectManager;
    }
    
    return nil;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*) result).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    if(tag == CTagGetProductReview) {
        Review *tempReview = stat;
        return tempReview.status;
    }
    
    return nil;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*) successResult).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    if(tag == CTagGetProductReview) {
        review = stat;
        
        if(page==0 && review.result.list!=nil) {
            arrList = [[NSMutableArray alloc] initWithArray:review.result.list];
            
            segmentedControl.enabled = YES;
            btnFilter6Month.enabled = btnFilterAllTime.enabled = YES;
            [self setRateStar:0 withAnimate:YES];
        }
        else if(review.result.list != nil) {
            [arrList addObjectsFromArray:review.result.list];
        }
        
        //Check next page
        strUri = review.result.paging.uri_next;
        page = [[[self getNetworkManager:CTagGetProductReview] splitUriToPage:strUri] integerValue];
        

        //Add delegate to talbe view
        if(arrList!=nil && arrList.count>0) {
            if(tableContent.delegate == nil) {
                tableContent.delegate = self;
                tableContent.dataSource = self;
            }
            
            [tableContent reloadData];
        }
        else  {
            [self setLoadingView:NO];
            
            if(noResultView == nil) {
                noResultView = [NoResultView new];
            }
            tableContent.tableFooterView = noResultView.view;
        }
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
    if(tag == CTagGetProductReview) {
        
    }
}

- (void)actionBeforeRequest:(int)tag {
}

- (void)actionRequestAsync:(int)tag {
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    if(tag == CTagGetProductReview) {
        [self setLoadingView:NO];
        
        
        if(loadingView == nil) {
            loadingView = [LoadingView new];
            loadingView.delegate = self;
        }
        
        tableContent.tableFooterView = loadingView.view;
    }
}


#pragma mark - LoadingView Delegate
- (void)pressRetryButton
{
    [self setLoadingView:YES];
    [[self getNetworkManager:CTagGetProductReview] doRequest];
}
@end
