//
//  InboxTalkViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 11/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//
#import "DetailTotalLikeDislike.h"
#import "TotalLikeDislike.h"
#import "LikeDislike.h"
#import "LikeDislikeResult.h"
#import "CMPopTipView.h"
#import "ProductDetailReputationViewController.h"
#import "ProductReputationCell.h"
#import "TKPDTabInboxTalkNavigationController.h"
#import "ShopReviewPageViewController.h"
#import "DetailReviewViewController.h"
#import "TTTAttributedLabel.h"
//#import "GeneralReviewCell.h"

#import "Review.h"
#import "GeneralAction.h"
#import "InboxTalk.h"

#import "inbox.h"
#import "string_home.h"
#import "stringrestkit.h"
#import "string_inbox_talk.h"
#import "string_inbox_review.h"
#import "detail.h"
#import "ShopPageHeader.h"
#import "TokopediaNetworkManager.h"
#import "NoResultView.h"
#import "URLCacheController.h"

#define CTagGetTotalLike 1
#define CTagLike 2
#define CTagDislike 3

@interface ShopReviewPageViewController () <
UITableViewDataSource,
UITableViewDelegate,
TKPDTabInboxTalkNavigationControllerDelegate,
TTTAttributedLabelDelegate,
CMPopTipViewDelegate,
TokopediaNetworkManagerDelegate,
//GeneralReviewCellDelegate,
UIActionSheetDelegate,
productReputationDelegate,
ShopPageHeaderDelegate,
UIScrollViewDelegate,
UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *footer;
@property (strong, nonatomic) IBOutlet UIView *header;
@property (strong, nonatomic) IBOutlet UIView *stickyTab;
@property (strong, nonatomic) IBOutlet UIView *fakeStickyTab;

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (nonatomic, strong) NSDictionary *userinfo;
@property (nonatomic, strong) NSMutableArray *list;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@end

@implementation ShopReviewPageViewController
{
    BOOL _isNoData;
    BOOL _isRefreshView;
    BOOL _iseditmode;
    
    NSInteger _page;
    NSInteger _limit;
    NSInteger _viewposition;
    
    NSMutableDictionary *_paging;
    
    NSString *_uriNext;
    NSString *_talkNavigationFlag;
    NSString *_reviewIsOwner;
    
    UIRefreshControl *_refreshControl;
    NSInteger _requestCount;
    NSInteger _requestUnfollowCount;
    NSInteger _requestDeleteCount;
    
    NSTimer *_timer;
    UISearchBar *_searchbar;
    NSString *_keyword;
    NSString *_readstatus;
    NSString *_navthatwillrefresh;
    BOOL _isrefreshnav;
    BOOL _isNeedToInsertCache;
    BOOL _isLoadFromCache;
    
    NSMutableParagraphStyle *style;
    __weak RKObjectManager *_objectManager;
    __weak RKObjectManager *_objectUnfollowmanager;
    __weak RKObjectManager *_objectDeletemanager;
    
    __weak RKManagedObjectRequestOperation *_request;
    __weak RKManagedObjectRequestOperation *_requestUnfollow;
    __weak RKManagedObjectRequestOperation *_requestDelete;
    
    NSOperationQueue *_operationQueue;
    NSOperationQueue *_operationUnfollowQueue;
    NSOperationQueue *_operationDeleteQueue;
    CMPopTipView *popTipView;
    TokopediaNetworkManager *tokopediaGetTotalLikeNManager, *tokopediaLikeNManager, *tokopediaDislikeNManager;
    
    NSString *_cachePath;
    URLCacheController *_cacheController;
    URLCacheConnection *_cacheConnection;
    NSTimeInterval _timeInterval;
    Review *_review;
    Shop *_shop;
    NoResultView *_noResult;
    NSMutableDictionary *dictLikeDislike, *loadingLikeDislike;
}

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isRefreshView = NO;
        _isNoData = YES;
    }
    
    return self;
}


- (void)initNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTotalReviewComment:)
                                                 name:@"updateTotalReviewComment" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateReviewHeaderPosition:)
                                                 name:@"updateReviewHeaderPosition" object:nil];
}

#pragma mark - Life Cycle
- (void)addBottomInsetWhen14inch {
    if (is4inch) {
        UIEdgeInsets inset = _table.contentInset;
        inset.bottom += 155;
        _table.contentInset = inset;
    }
    else{
        UIEdgeInsets inset = _table.contentInset;
        inset.bottom += 240;
        _table.contentInset = inset;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addBottomInsetWhen14inch];
    
    dictLikeDislike = [NSMutableDictionary new];
    loadingLikeDislike = [NSMutableDictionary new];
    style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    _talkNavigationFlag = [_data objectForKey:@"nav"];
    _page = 1;
    _noResult = [[NoResultView alloc] initWithFrame:CGRectMake(0, 100, 320, 200)];
    
    _operationQueue = [NSOperationQueue new];
    _operationUnfollowQueue = [NSOperationQueue new];
    _operationDeleteQueue = [NSOperationQueue new];
    _cacheConnection = [URLCacheConnection new];
    _cacheController = [URLCacheController new];
    _list = [NSMutableArray new];
    _refreshControl = [[UIRefreshControl alloc] init];
    
    
    _table.delegate = self;
    _table.dataSource = self;
    
    _shopPageHeader = [ShopPageHeader new];
    _shopPageHeader.delegate = self;
    _shopPageHeader.data = _data;
    
    _header = _shopPageHeader.view;
    
    UIView *btmGreenLine = (UIView *)[_header viewWithTag:21];
    [btmGreenLine setHidden:NO];
    _stickyTab = [(UIView *)_header viewWithTag:18];
    
    _table.tableFooterView = _footer;
    _table.tableHeaderView = _header;
    
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    if (_list.count > 0) {
        _isNoData = NO;
    }
    
    [_fakeStickyTab.layer setShadowOffset:CGSizeMake(0, 0.5)];
    [_fakeStickyTab.layer setShadowColor:[UIColor colorWithWhite:0 alpha:1].CGColor];
    [_fakeStickyTab.layer setShadowRadius:1];
    [_fakeStickyTab.layer setShadowOpacity:0.3];
    
    [self initNotification];
    [self configureRestKit];
    
    [self loadData];
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Shop - Review List";
    if (!_isRefreshView) {
        [self configureRestKit];
        
        if (_isNoData && _page < 1) {
            [self loadData];
        }
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


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



#pragma mark - Method
- (TokopediaNetworkManager *)getNetworkManager:(int)tag {
    if(tag == CTagDislike) {
        tokopediaDislikeNManager = [TokopediaNetworkManager new];
        tokopediaDislikeNManager.tagRequest = tag;
        tokopediaDislikeNManager.delegate = self;
        
        return tokopediaDislikeNManager;
    }
    else if(tag == CTagLike) {
        tokopediaLikeNManager = [TokopediaNetworkManager new];
        tokopediaLikeNManager.tagRequest = tag;
        tokopediaLikeNManager.delegate = self;

        return tokopediaLikeNManager;
    }
    else if(tag == CTagGetTotalLike) {
        tokopediaGetTotalLikeNManager = [TokopediaNetworkManager new];
        tokopediaGetTotalLikeNManager.tagRequest = tag;
        tokopediaGetTotalLikeNManager.delegate = self;
        
        return tokopediaGetTotalLikeNManager;
    }
    
    return nil;
}

- (void)configureLikeDislikeReskit
{

}

- (void)updateDataInDetailView:(LikeDislike *)likeDislike {
    if([[self.navigationController.viewControllers lastObject] isMemberOfClass:[ProductDetailReputationViewController class]]) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [((ProductDetailReputationViewController *) [self.navigationController.viewControllers lastObject]) updateLikeDislike:likeDislike];
        });
    }
}

- (void)actionGetLikeStatus:(NSArray *)arrList {
    if(loadingLikeDislike.count > 10)
        return;
    
    ReviewList *list = [arrList firstObject];
    RKObjectManager *tempObjectManager = [self getObjectManager:CTagGetTotalLike];
    NSDictionary *param = @{kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETLIKEDISLIKE,
                            kTKPDDETAIL_REVIEWIDS : list.review_id,
                            kTKPDDETAIL_APISHOPIDKEY : list.review_shop_id};
    RKManagedObjectRequestOperation *tempRequest = [tempObjectManager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:[self getPath:CTagGetTotalLike] parameters:[param encrypt]];
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        NSTimer *timerLikeDislike = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(timeOutGetLikeDislike:) userInfo:list.review_id repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timerLikeDislike forMode:NSRunLoopCommonModes];
        [loadingLikeDislike setObject:@[tempRequest, [NSIndexPath indexPathForRow:[[arrList lastObject] intValue] inSection:0], timerLikeDislike] forKey:list.review_id];
    

        [tempRequest setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSTimer *temporaryTimer = [[loadingLikeDislike objectForKey:list.review_id] lastObject];
            [temporaryTimer invalidate];
            
            NSDictionary *result = ((RKMappingResult*) mappingResult).dictionary;
            LikeDislike *obj = [result objectForKey:@""];
            [dictLikeDislike setObject:((TotalLikeDislike *) [obj.result.like_dislike_review firstObject]) forKey:((TotalLikeDislike *) [obj.result.like_dislike_review firstObject]).review_id];
            [self performSelectorInBackground:@selector(updateDataInDetailView:) withObject:obj];
            
            //Update UI
            [_table reloadRowsAtIndexPaths:@[[[loadingLikeDislike objectForKey:list.review_id] objectAtIndex:1]] withRowAnimation:UITableViewRowAnimationNone];
            [loadingLikeDislike removeObjectForKey:list.review_id];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            /** failure **/
            NSTimer *temporaryTimer = [[loadingLikeDislike objectForKey:list.review_id] lastObject];
            [temporaryTimer invalidate];
            [loadingLikeDislike removeObjectForKey:list.review_id];
        }];
        [_operationQueue addOperation:tempRequest];
    });
}

- (void)timeOutGetLikeDislike:(NSTimer *)temp {
    RKManagedObjectRequestOperation *operation = [[loadingLikeDislike objectForKey:[temp userInfo]] firstObject];
    [operation cancel];
    operation = nil;
    [loadingLikeDislike removeObjectForKey:[temp userInfo]];
}

- (void)actionVote:(id)sender {
    [self dismissAllPopTipViews];
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

- (NSString *)convertHTML:(NSString *)html
{
    NSScanner *myScanner;
    NSString *text = nil;
    myScanner = [NSScanner scannerWithString:html];
    
    while ([myScanner isAtEnd] == NO) {
        [myScanner scanUpToString:@"<" intoString:NULL];
        [myScanner scanUpToString:@">" intoString:&text];
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
    html = [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    return html;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isNoData) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    if (row == indexPath.row) {
        if (_uriNext != NULL && ![_uriNext isEqualToString:@"0"] && _uriNext != 0) {
            [self configureRestKit];
            [self loadData];
        } else {
            _table.tableFooterView = nil;
            [_act stopAnimating];
        }
    }
}


#pragma mark - TableView Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _isNoData ? 0 : _list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReviewList *list = _list[indexPath.row];
    TTTAttributedLabel *tempLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    [self setPropertyLabelDesc:tempLabel];
    [self initLabelDesc:tempLabel withText:[self convertHTML:list.review_message?:@""]];
    
    CGSize tempSizeDesc = [tempLabel sizeThatFits:CGSizeMake(self.view.bounds.size.width-(CPaddingTopBottom*4), 9999)];//4 padding left and right of label description
//    if([list.review_id isEqualToString:NEW_REVIEW_STATE]) {
        tempSizeDesc.height += CHeightContentAction;
//    } else {
        tempSizeDesc.height += CHeightContentRate;
//    }

    return tempSizeDesc.height + CHeightDate + (CheightImage*2) + (CPaddingTopBottom*7); //6 is total padding of each row component
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = nil;
    if (!_isNoData) {
        
        NSString *cellid = @"cell";
//
//        cell = (GeneralReviewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
//        if (cell == nil) {
//            cell = [GeneralReviewCell newcell];
//            ((GeneralReviewCell*)cell).delegate = self;
//        }
//        
//        if (_list.count > indexPath.row) {
//            
//            ReviewList *list = _list[indexPath.row];
//            
//            ((GeneralReviewCell*)cell).userNamelabel.text = list.review_user_name;
//            ((GeneralReviewCell*)cell).timelabel.text = list.review_create_time?:@"";
//            ((GeneralReviewCell*)cell).indexpath = indexPath;
//            ((GeneralReviewCell*)cell).data = list;
//            
//            ((GeneralReviewCell*)cell).productNamelabel.text = list.review_product_name;
//            
//            if([list.review_response.response_message isEqualToString:@"0"]) {
//                [((GeneralReviewCell*)cell).commentbutton setTitle:@"0 Komentar" forState:UIControlStateNormal];
//            } else {
//                [((GeneralReviewCell*)cell).commentbutton setTitle:@"1 Komentar" forState:UIControlStateNormal];
//            }
//            
//            if([list.review_is_allow_edit isEqualToString:@"1"] && ![list.review_product_status isEqualToString:STATE_PRODUCT_BANNED] && ![list.review_product_status isEqualToString:STATE_PRODUCT_DELETED]) {
//                ((GeneralReviewCell*)cell).editReviewButton.hidden = NO;
//            } else {
//                ((GeneralReviewCell*)cell).editReviewButton.hidden = YES;
//            }
//            
//            if ([list.review_message length] > 50) {
//                NSRange stringRange = {0, MIN([list.review_message length], 50)};
//                stringRange = [list.review_message rangeOfComposedCharacterSequencesForRange:stringRange];
//                ((GeneralReviewCell *)cell).commentlabel.text = [self convertHTML:[NSString stringWithFormat:@"%@...", [list.review_message substringWithRange:stringRange]]];
//            } else {
//                ((GeneralReviewCell *)cell).commentlabel.text = [self convertHTML:list.review_message?:@""];
//            }
//            
//            if([list.review_id isEqualToString:NEW_REVIEW_STATE]) {
//                ((GeneralReviewCell *)cell).ratingView.hidden = YES;
//                ((GeneralReviewCell *)cell).inputReviewView.hidden = NO;
//                ((GeneralReviewCell *)cell).commentView.hidden = YES;
//            } else {
//                ((GeneralReviewCell *)cell).ratingView.hidden = NO;
//                ((GeneralReviewCell *)cell).inputReviewView.hidden = YES;
//                ((GeneralReviewCell *)cell).commentView.hidden = NO;
//            }
//
//            ((GeneralReviewCell*)cell).qualityrate.starscount = [list.review_rate_quality integerValue];
//            ((GeneralReviewCell*)cell).speedrate.starscount = [list.review_rate_speed integerValue];
//            ((GeneralReviewCell*)cell).servicerate.starscount = [list.review_rate_service integerValue];
//            ((GeneralReviewCell*)cell).accuracyrate.starscount = [list.review_rate_accuracy integerValue];
//            
//            NSURLRequest *userImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.review_user_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
//            UIImageView *userImageView = ((GeneralReviewCell *)cell).userImageView;
//            userImageView.image = nil;
//            [userImageView setImageWithURLRequest:userImageRequest
//                                 placeholderImage:[UIImage imageNamed:@"icon_profile_picture.jpeg"]
//                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-retain-cycles"
//                                              [userImageView setImage:image];
//#pragma clang diagnostic pop
//                                          } failure:nil];
//            
//            NSURLRequest *productImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.review_product_image]
//                                                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                                                  timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
//            UIImageView *productImageView = ((GeneralReviewCell*)cell).productImageView;
//            productImageView.image = nil;
//            [productImageView setImageWithURLRequest:productImageRequest
//                                    placeholderImage:nil
//                                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-retain-cycles"
//                                                 [productImageView setImage:image];
//#pragma clang diagnostic pop
//                                             } failure:nil];
//        }
//        
//        return cell;
        
        ProductReputationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
        if(cell == nil) {
            NSArray *tempArr = [[NSBundle mainBundle] loadNibNamed:@"ProductReputationCell" owner:nil options:0];
            cell = [tempArr objectAtIndex:0];
            cell.delegate = self;
            [cell initProductCell];
            [self setPropertyLabelDesc:cell.getLabelDesc];
        }
        
        ReviewList *list = _list[indexPath.row];
        [cell setLabelUser:list.review_user_name withTag:0];
        [cell setLabelDate:list.review_create_time?:@""];
        [cell setLabelProductName:list.review_product_name];
        [cell setPercentage:list.review_user_reputation.positive_percentage];
        cell.getBtnRateEmoji.tag = indexPath.row;
        cell.getBtnLike.tag = indexPath.row;
        cell.getBtnDisLike.tag = indexPath.row;
        cell.getLabelDesc.tag = indexPath.row;
        
        //Hidden review rate and comment
//        if([list.review_id isEqualToString:NEW_REVIEW_STATE]) {
//            [cell setHiddenRating:YES];
//            [cell setHiddenAction:NO];
//        } else {
//            [cell setHiddenRating:NO];
//            [cell setHiddenAction:YES];
//        }

        
        //Set chat total
        if([list.review_response.response_message isEqualToString:@"0"]) {
            [cell.getBtnChat setTitle:list.review_response.response_message forState:UIControlStateNormal];
        }
        else {
            [cell.getBtnChat setTitle:@"1" forState:UIControlStateNormal];
        }
        
        //Set like dislike total
        if([dictLikeDislike objectForKey:list.review_id]) {
            [cell setHiddenViewLoad:YES];
            
            TotalLikeDislike *totalLikeDislike = [dictLikeDislike objectForKey:list.review_id];
            [cell.getBtnLike setTitle:totalLikeDislike.total_like_dislike.total_like forState:UIControlStateNormal];
            [cell.getBtnDisLike setTitle:totalLikeDislike.total_like_dislike.total_dislike forState:UIControlStateNormal];
        }
        else {
            [cell setHiddenViewLoad:NO];
            if(! [loadingLikeDislike objectForKey:list.review_id]) {
                [loadingLikeDislike setObject:list.review_id forKey:list.review_id];
                [self performSelectorInBackground:@selector(actionGetLikeStatus:) withObject:@[list, [NSNumber numberWithInt:(int)indexPath.row]]];
            }
        }
        

        [cell setDescription:[self convertHTML:list.review_message?:@""]];
        [cell setImageKualitas:[list.review_rate_quality intValue]];
        [cell setImageAkurasi:[list.review_rate_accuracy intValue]];
        
        
        //Set profile image
        NSURLRequest *userImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.review_user_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        UIImageView *userImageView = cell.getImageProfile;
        userImageView.image = nil;
        [userImageView setImageWithURLRequest:userImageRequest placeholderImage:[UIImage imageNamed:@"icon_profile_picture.jpeg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-retain-cycles"
                [userImageView setImage:image];
                #pragma clang diagnostic pop
            } failure:nil];
        
        //Set product image
        NSURLRequest *productImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.review_product_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        UIImageView *productImageView = cell.getProductImage;
        productImageView.image = nil;
        [productImageView setImageWithURLRequest:productImageRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-retain-cycles"
            [productImageView setImage:image];
            #pragma clang diagnostic pop
        } failure:nil];
        
        return cell;
    } else {
        static NSString *CellIdentifier = kTKPDDETAIL_STANDARDTABLEVIEWCELLIDENTIFIER;
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = kTKPDDETAIL_NODATACELLTITLE;
        cell.detailTextLabel.text = kTKPDDETAIL_NODATACELLDESCS;
    }
    return cell;
}

#pragma mark - Request + Mapping
#pragma mark - Request and Mapping

-(void)cancel
{
    [_request cancel];
    _request = nil;
    
    [_objectManager.operationQueue cancelAllOperations];
    _objectManager = nil;
}

- (void)configureRestKit
{
    // initialize RestKit
    _objectManager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Review class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ReviewResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"is_owner":@"is_owner"}];
    
    RKObjectMapping *ratinglistMapping = [RKObjectMapping mappingForClass:[RatingList class]];
    [ratinglistMapping addAttributeMappingsFromArray:@[kTKPDREVIEW_APIRATINGSTARPOINTKEY,
                                                       kTKPDREVIEW_APIRATINGACCURACYKEY,
                                                       kTKPDREVIEW_APIRATINGQUALITYKEY
                                                       ]];
    
    RKObjectMapping *reviewUserReputation = [RKObjectMapping mappingForClass:[ReputationDetail class]];
    [reviewUserReputation addAttributeMappingsFromDictionary:@{CPositivePercentage:CPositivePercentage,
                                                               CNegative:CNegative,
                                                               CNeutral:CNeutral,
                                                               CPositif:CPositif}];
    
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[ReviewList class]];
    [listMapping addAttributeMappingsFromArray:@[kTKPDREVIEW_APIREVIEWSHOPIDKEY,
                                                 kTKPDREVIEW_APIREVIEWUSERIMAGEKEY,
                                                 kTKPDREVIEW_APIREVIEWCREATETIMEKEY,
                                                 kTKPDREVIEW_APIREVIEWIDKEY,
                                                 kTKPDREVIEW_APIREVIEWUSERNAMEKEY,
                                                 kTKPDREVIEW_APIREVIEWMESSAGEKEY,
                                                 kTKPDREVIEW_APIREVIEWUSERIDKEY,
                                                 kTKPDREVIEW_APIREVIEWRATEQUALITY,
                                                 kTKPDREVIEW_APIREVIEWRATESPEEDKEY,
                                                 kTKPDREVIEW_APIREVIEWRATESERVICEKEY,
                                                 kTKPDREVIEW_APIREVIEWRATEACCURACYKEY,
                                                 kTKPDREVIEW_APIPRODUCTNAMEKEY,
                                                 kTKPDREVIEW_APIPRODUCTIDKEY,
                                                 kTKPDREVIEW_APIPRODUCTIMAGEKEY,
                                                 kTKPDREVIEW_APIREVIEWISOWNERKEY,
                                                 kTKPDREVIEW_APIPRODUCTSTATUSKEY
                                                 ]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIURINEXTKEY:kTKPDDETAIL_APIURINEXTKEY}];
    
    //add relationship mapping
    RKObjectMapping *reviewResponseMapping = [RKObjectMapping mappingForClass:[ReviewResponse class]];
    [reviewResponseMapping addAttributeMappingsFromDictionary:@{
                                                                REVIEW_RESPONSE_CREATE_TIME:REVIEW_RESPONSE_CREATE_TIME,
                                                                REVIEW_RESPONSE_MESSAGE:REVIEW_RESPONSE_MESSAGE
                                                                }];
    
    RKObjectMapping *reviewProductOwnerMapping = [RKObjectMapping mappingForClass:[ReviewProductOwner class]];
    [reviewProductOwnerMapping addAttributeMappingsFromDictionary:@{
                                                                    REVIEW_PRODUCT_OWNER_USER_ID:REVIEW_PRODUCT_OWNER_USER_ID,
                                                                    REVIEW_PRODUCT_OWNER_USER_IMAGE:REVIEW_PRODUCT_OWNER_USER_IMAGE,
                                                                    REVIEW_PRODUCT_OWNER_USER_NAME:REVIEW_PRODUCT_OWNER_USER_NAME
                                                                    }];

    [ratinglistMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReviewUserReputation toKeyPath:CReviewUserReputation withMapping:reviewUserReputation]];

    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReviewUserReputation toKeyPath:CReviewUserReputation withMapping:reviewUserReputation]];
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:REVIEW_RESPONSE
                                                                                toKeyPath:REVIEW_RESPONSE
                                                                              withMapping:reviewResponseMapping]];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:REVIEW_PRODUCT_OWNER
                                                                                toKeyPath:REVIEW_PRODUCT_OWNER
                                                                              withMapping:reviewProductOwnerMapping]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY
                                                                                 toKeyPath:kTKPD_APILISTKEY
                                                                               withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIPAGINGKEY
                                                                                 toKeyPath:kTKPDDETAIL_APIPAGINGKEY
                                                                               withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:@"shop.pl"
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptorStatus];
}

- (void)loadData
{
    if (_request.isExecuting) return;
    
    _requestCount++;
    
    NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY    :   kTKPDDETAIL_APIGETSHOPREVIEWKEY,
                            kTKPDDETAIL_APISHOPIDKEY    :   [_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]?:@(0),
                            kTKPDDETAIL_APIPAGEKEY      :   @(_page),
                            kTKPDDETAIL_APILIMITKEY     :   @(kTKPDDETAILREVIEW_LIMITPAGE)};
    
    
    
    if (!_isRefreshView) {
        _table.tableFooterView = _footer;
        [_act startAnimating];
    }
    _request = [_objectManager appropriateObjectRequestOperationWithObject:self
                                                                    method:RKRequestMethodPOST
                                                                      path:@"shop.pl"
                                                                parameters:[param encrypt]];
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"%@", operation.HTTPRequestOperation.responseString);
        [_timer invalidate];
        _timer = nil;
        [_act stopAnimating];
        _table.hidden = NO;
        _isRefreshView = NO;
        [_refreshControl endRefreshing];
        [self requestsuccess:mappingResult withOperation:operation];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [_timer invalidate];
        _timer = nil;
        [_act stopAnimating];
        _isRefreshView = NO;
        [_refreshControl endRefreshing];
        [self requestfailure:error];
    }];
    [_operationQueue addOperation:_request];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                              target:self
                                            selector:@selector(requestTimeout)
                                            userInfo:nil repeats:NO];
    
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
}

-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stats = [result objectForKey:@""];
    _review = stats;
    BOOL status = [_review.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestprocess:object];
    }
}

-(void)requestfailure:(id)object
{
    if (_timeInterval > _cacheController.URLCacheInterval || _page > 1 || _isRefreshView) {
        [self requestprocess:object];
    }
    else{
        NSError* error;
        NSData *data = [NSData dataWithContentsOfFile:_cachePath];
        if(data == nil)
            return;
        
        id parsedData = [RKMIMETypeSerialization objectFromData:data
                                                       MIMEType:RKMIMETypeJSON
                                                          error:&error];
        if (parsedData == nil && error) {
            NSLog(@"parser error");
        }
        
        NSMutableDictionary *mappingsDictionary = [[NSMutableDictionary alloc] init];
        for (RKResponseDescriptor *descriptor in _objectManager.responseDescriptors) {
            [mappingsDictionary setObject:descriptor.mapping forKey:descriptor.keyPath];
        }
        
        RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData
                                                                   mappingsDictionary:mappingsDictionary];
        NSError *mappingError = nil;
        BOOL isMapped = [mapper execute:&mappingError];
        if (isMapped && !mappingError) {
            RKMappingResult *mappingresult = [mapper mappingResult];
            NSDictionary *result = mappingresult.dictionary;
            id stats = [result objectForKey:@""];
            _review = stats;
            BOOL status = [_review.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                [self requestprocess:mappingresult];
            }
        }
    }
}

-(void)requestprocess:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            
            id stats = [result objectForKey:@""];
            
            _review = stats;
            BOOL status = [_review.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                NSArray *list = _review.result.list;
                _reviewIsOwner = _review.result.is_owner;
                [_list addObjectsFromArray:list];
                _isNoData = NO;
                
                _uriNext =  _review.result.paging.uri_next;
                NSURL *url = [NSURL URLWithString:_uriNext];
                NSArray* querry = [[url query] componentsSeparatedByString: @"&"];
                
                NSMutableDictionary *queries = [NSMutableDictionary new];
                [queries removeAllObjects];
                for (NSString *keyValuePair in querry)
                {
                    NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
                    NSString *key = [pairComponents objectAtIndex:0];
                    NSString *value = [pairComponents objectAtIndex:1];
                    
                    [queries setObject:value forKey:key];
                }
                
                _page = [[queries objectForKey:kTKPDDETAIL_APIPAGEKEY] integerValue];
                NSLog(@"next page : %zd",_page);
                
                [_table reloadData];
                if (_list.count == 0) {
                    _act.hidden = YES;
                    _table.tableFooterView = _noResult;
                }
                
            }
            else{
                [self cancel];
                NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
                if ([(NSError*)object code] == NSURLErrorCancelled) {
                    if (_requestCount<kTKPDREQUESTCOUNTMAX) {
                        NSLog(@" ==== REQUESTCOUNT %zd =====",_requestCount);
                        _table.tableFooterView = _footer;
                        [_act startAnimating];
                        [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                        [self performSelector:@selector(request) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    }
                    else
                    {
                        [_act stopAnimating];
                        _table.tableFooterView = nil;
                    }
                }
                else
                {
                    [_act stopAnimating];
                    _table.tableFooterView = nil;
                }
            }
        }
    }
}

-(void)requestTimeout
{
    [self cancel];
}



#pragma mark - General Talk Delegate
- (id)navigationController:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath {
    return self;
}

-(void)GeneralReviewCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath {
    DetailReviewViewController *vc = [DetailReviewViewController new];
    NSInteger row = indexpath.row;
    vc.data = _list[row];
    vc.index = [NSString stringWithFormat:@"%ld",(long)row];
    vc.shop = _shop;
    vc.is_owner = _reviewIsOwner;
    vc.indexPath = indexpath;
    
    [self.navigationController pushViewController:vc animated:YES];
}



#pragma mark - Refresh View
-(void)refreshView:(UIRefreshControl*)refresh
{
    /** clear object **/
    [self cancel];
    _requestCount = 0;
    [_list removeAllObjects];
    _page = 1;
    _isRefreshView = YES;
    
    [_table reloadData];
    /** request data **/
    [self configureRestKit];
    [self loadData];
}

#pragma mark - Notification Handler

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    for(NSArray *tempArr in [loadingLikeDislike allValues]) {
        RKManagedObjectRequestOperation *operation = [tempArr firstObject];
        [operation cancel];
        
        NSTimer *timer = [tempArr lastObject];
        [timer invalidate];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    BOOL isFakeStickyVisible = scrollView.contentOffset.y > (_header.frame.size.height - _stickyTab.frame.size.height);
    
    if(isFakeStickyVisible) {
        _fakeStickyTab.hidden = NO;
    } else {
        _fakeStickyTab.hidden = YES;
    }
    [self determineOtherScrollView:scrollView];
    
}


- (void)determineOtherScrollView:(UIScrollView *)scrollView {
    NSDictionary *userInfo = @{@"y_position" : [NSNumber numberWithFloat:scrollView.contentOffset.y]};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTalkHeaderPosition" object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateNotesHeaderPosition" object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateProductHeaderPosition" object:nil userInfo:userInfo];
    
}

- (void)updateReviewHeaderPosition:(NSNotification *)notification
{
    id userinfo = notification.userInfo;
    float ypos;
    if([[userinfo objectForKey:@"y_position"] floatValue] < 0) {
        ypos = 0;
    } else {
        ypos = [[userinfo objectForKey:@"y_position"] floatValue];
    }
    
    CGPoint cgpoint = CGPointMake(0, ypos);
    _table.contentOffset = cgpoint;
    
    
}


#pragma mark - Shop header delegate

- (void)didLoadImage:(UIImage *)image
{
    //    _navigationImageView.image = [image applyLightEffect];
}

- (void)didReceiveShop:(Shop *)shop
{
    _shop = shop;
}

- (id)didReceiveNavigationController {
    return self;
}

#pragma mark - Notification Center Action 
- (void)updateTotalReviewComment:(NSNotification*)notification {
    NSDictionary *userinfo = notification.userInfo;
    NSInteger index = [[userinfo objectForKey:@"index"]integerValue];
    
    ReviewList *list = _list[index];
    
    list.review_response.response_message = [userinfo objectForKey:@"review_comment"];
    list.review_response.response_create_time = [userinfo objectForKey:@"review_comment_time"];
    
    NSIndexPath *indexPath = [userinfo objectForKey:@"indexPath"];
//    [_table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [_table reloadData];
    
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - Product Reputation Delegate
- (void)initLabelDesc:(TTTAttributedLabel *)lblDesc withText:(NSString *)strDescription {
    NSString *strLihatSelengkapnya = @"Lihat Selengkapnya";
    if(strDescription.length > 100) {
        strDescription = [NSString stringWithFormat:@"%@... %@", [strDescription substringToIndex:100], strLihatSelengkapnya];

        NSRange range = [strDescription rangeOfString:strLihatSelengkapnya];
        lblDesc.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        lblDesc.delegate = self;
        lblDesc.activeLinkAttributes = @{(id)kCTForegroundColorAttributeName:[UIColor lightGrayColor], NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone)};
        lblDesc.linkAttributes = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone)};

        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:strDescription];
        [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, strDescription.length)];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(strDescription.length-strLihatSelengkapnya.length, strLihatSelengkapnya.length)];
        lblDesc.attributedText = str;
        [lblDesc addLinkToURL:[NSURL URLWithString:@""] withRange:range];
    }
    else {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:strDescription];
        [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, strDescription.length)];
        lblDesc.attributedText = str;
        lblDesc.delegate = nil;
        [lblDesc addLinkToURL:[NSURL URLWithString:@""] withRange:NSMakeRange(0, 0)];
    }
}

- (void)actionRate:(id)sender {
    ReviewList *list = _list[((UIView *) sender).tag];
    int paddingRightLeftContent = 10;
    UIView *viewContentPopUp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (CWidthItemPopUp*3)+paddingRightLeftContent+paddingRightLeftContent, CHeightItemPopUp)];
    viewContentPopUp.backgroundColor = [UIColor clearColor];
    
    UIButton *btnMerah = (UIButton *)[self initButtonContentPopUp:list.review_user_reputation.negative withImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_sad" ofType:@"png"]] withFrame:CGRectMake(paddingRightLeftContent, 0, CWidthItemPopUp, CHeightItemPopUp) withTextColor:[UIColor redColor]];
    UIButton *btnKuning = (UIButton *)[self initButtonContentPopUp:list.review_user_reputation.neutral withImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_netral" ofType:@"png"]] withFrame:CGRectMake(btnMerah.frame.origin.x+btnMerah.bounds.size.width, 0, CWidthItemPopUp, CHeightItemPopUp) withTextColor:[UIColor yellowColor]];
    UIButton *btnHijau = (UIButton *)[self initButtonContentPopUp:list.review_user_reputation.positive withImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_smile" ofType:@"png"]] withFrame:CGRectMake(btnKuning.frame.origin.x+btnKuning.bounds.size.width, 0, CWidthItemPopUp, CHeightItemPopUp) withTextColor:[UIColor greenColor]];
    
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
    popTipView.has3DStyle = YES;
    popTipView.dismissTapAnywhere = YES;
    
    UIButton *button = (UIButton *)sender;
    [popTipView presentPointingAtView:button inView:self.view animated:YES];
}

- (void)actionLike:(id)sender {
    if (_request.isExecuting) return;
    
    _requestCount++;
    
    
    ReviewList *tempList = _list[((UIView *) sender).tag];
    NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY:@"like_dislike_review",
                            @"review_id":tempList.review_id,
                            @"like_status":@(1),
                            @"shop_id":tempList.review_shop_id,
                            @"product_id":tempList.review_product_id};
    
    
    
    if (!_isRefreshView) {
        _table.tableFooterView = _footer;
        [_act startAnimating];
    }
    _request = [_objectManager appropriateObjectRequestOperationWithObject:self
                                                                    method:RKRequestMethodPOST
                                                                      path:@"shop.pl"
                                                                parameters:[param encrypt]];
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"%@", operation.HTTPRequestOperation.responseString);
        [_timer invalidate];
        _timer = nil;
        [_act stopAnimating];
        _table.hidden = NO;
        _isRefreshView = NO;
        [_refreshControl endRefreshing];
        [self requestsuccess:mappingResult withOperation:operation];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [_timer invalidate];
        _timer = nil;
        [_act stopAnimating];
        _isRefreshView = NO;
        [_refreshControl endRefreshing];
        [self requestfailure:error];
    }];
    [_operationQueue addOperation:_request];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                              target:self
                                            selector:@selector(requestTimeout)
                                            userInfo:nil repeats:NO];
    
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)actionDisLike:(id)sender {
}

- (void)actionChat:(id)sender {
    ProductDetailReputationViewController *productDetailReputationViewController = [ProductDetailReputationViewController new];
    productDetailReputationViewController.reviewList = _list[((UIView *) sender).tag];
    
    if([dictLikeDislike objectForKey:productDetailReputationViewController.reviewList.review_id]) {
        TotalLikeDislike *totalLikeDislike = [dictLikeDislike objectForKey:productDetailReputationViewController.reviewList.review_id];
        productDetailReputationViewController.strTotalDisLike = totalLikeDislike.total_like_dislike.total_dislike;
        productDetailReputationViewController.strTotalLike = totalLikeDislike.total_like_dislike.total_like;
    }
    [self.navigationController pushViewController:productDetailReputationViewController animated:YES];
}

- (void)actionMore:(id)sender {
    ReviewList *list = _list[((UIButton *)sender).tag];
    UIActionSheet *actionSheet;
    if([list.review_is_allow_edit isEqualToString:@"1"] && ![list.review_product_status isEqualToString:STATE_PRODUCT_BANNED] && ![list.review_product_status isEqualToString:STATE_PRODUCT_DELETED]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Batal" destructiveButtonTitle:nil otherButtonTitles:@"Lapor", @"Edit", nil];
    }
    else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Batal" destructiveButtonTitle:nil otherButtonTitles:@"Lapor", nil];
    }
    
    actionSheet.tag = ((UIButton *) sender).tag;
    [actionSheet showInView:self.view];
}

#pragma mark - TTTAttributeLabel Delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didLongPressLinkWithURL:(NSURL *)url atPoint:(CGPoint)point
{
    
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    ProductDetailReputationViewController *productDetailReputationViewController = [ProductDetailReputationViewController new];
    productDetailReputationViewController.reviewList = _list[label.tag];
    if([dictLikeDislike objectForKey:productDetailReputationViewController.reviewList.review_id]) {
        TotalLikeDislike *totalLikeDislike = [dictLikeDislike objectForKey:productDetailReputationViewController.reviewList.review_id];
        productDetailReputationViewController.strTotalDisLike = totalLikeDislike.total_like_dislike.total_dislike;
        productDetailReputationViewController.strTotalLike = totalLikeDislike.total_like_dislike.total_like;
    }
    [self.navigationController pushViewController:productDetailReputationViewController animated:YES];
}


#pragma mark - CMPopTipView Delegate
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    [self dismissAllPopTipViews];
}


#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag {
    if(tag == CTagDislike) {
    
    }
    else if(tag == CTagLike) {
    
    }
    else if(tag == CTagGetTotalLike) {
    }
    
    return nil;
}

- (NSString*)getPath:(int)tag {
    if(tag == CTagDislike) {
        
    }
    else if(tag == CTagLike) {
        
    }
    else if(tag == CTagGetTotalLike) {
        return @"shop.pl";
    }
    
    return nil;
}

- (id)getObjectManager:(int)tag {
    if(tag == CTagDislike) {
        
    }
    else if(tag == CTagLike) {
        
    }
    else if(tag == CTagGetTotalLike) {
        // initialize RestKit
        RKObjectManager *tempObjectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:kTraktBaseURLString]];
        
        // setup object mappings
        RKObjectMapping *productMapping = [RKObjectMapping mappingForClass:[LikeDislike class]];
        [productMapping addAttributeMappingsFromDictionary:@{CLStatus:CLStatus,
                                                             CLServerProcessTime:CLServerProcessTime,
                                                             CLStatus:CLStatus,
                                                             CLMessageError:CLMessageError}];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[LikeDislikeResult class]];
        RKObjectMapping *totalLikeDislikeMapping = [RKObjectMapping mappingForClass:[TotalLikeDislike class]];
        [totalLikeDislikeMapping addAttributeMappingsFromArray:@[CLikeStatus,
                                                                 CReviewID]];

         RKObjectMapping *detailTotalLikeMapping = [RKObjectMapping mappingForClass:[DetailTotalLikeDislike class]];
        [detailTotalLikeMapping addAttributeMappingsFromDictionary:@{CTotalLike:CTotalLike,
                                                                     CTotalDislike:CTotalDislike}];
        
        
        
        //Relation Mapping
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CLikeDislikeReview toKeyPath:CLikeDislikeReview withMapping:totalLikeDislikeMapping]];
        [productMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CLResult toKeyPath:CLResult withMapping:resultMapping]];
        [totalLikeDislikeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CtotalLikeDislike toKeyPath:CtotalLikeDislike withMapping:detailTotalLikeMapping]];
        // Response Descriptor
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:productMapping method:RKRequestMethodPOST pathPattern:[self getPath:tag] keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
        [tempObjectManager addResponseDescriptor:responseDescriptor];
        
        return tempObjectManager;
    }
    
    return nil;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag {
    if(tag == CTagDislike) {
        
    }
    else if(tag == CTagLike) {
        
    }
    else if(tag == CTagGetTotalLike) {
    }
    
    return nil;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag {
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
}


- (void)actionBeforeRequest:(int)tag {
}

- (void)actionRequestAsync:(int)tag {
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    
}


#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
        
        }
            break;
        case 1://Edit
        {
            
        }
            break;
    }
}
@end
