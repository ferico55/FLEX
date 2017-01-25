//
//  InboxTalkViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 11/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//
#import "ViewLabelUser.h"
#import "LikeDislikePostResult.h"
#import "LikeDislikePost.h"
#import "TotalLikeDislike.h"
#import "TotalLikeDislikePost.h"
#import "DetailTotalLikeDislike.h"
#import "TotalLikeDislike.h"
#import "LikeDislike.h"
#import "LoginViewController.h"
#import "LikeDislikeResult.h"
#import "CMPopTipView.h"
#import "ProductDetailReputationViewController.h"
#import "ProductReputationCell.h"
#import "TKPDTabInboxTalkNavigationController.h"
#import "ShopReviewPageViewController.h"
#import "TTTAttributedLabel.h"
//#import "GeneralReviewCell.h"

#import "Review.h"
#import "ReportViewController.h"
#import "GeneralAction.h"
#import "InboxTalk.h"
#import "SmileyAndMedal.h"

#import "inbox.h"
#import "string_home.h"
#import "stringrestkit.h"
#import "string_inbox_talk.h"
#import "string_inbox_review.h"
#import "detail.h"
#import "TokopediaNetworkManager.h"
#import "NoResultReusableView.h"
#import "URLCacheController.h"
#import "ProductReputationSimpleCell.h"
#import "ShopPageRequest.h"
#import "NSString+TPBaseUrl.h"
#import "Tokopedia-Swift.h"

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
    LoginViewDelegate,
    ReportViewControllerDelegate,
    UIActionSheetDelegate,
    productReputationDelegate,
    SmileyDelegate,
    UIScrollViewDelegate,
    UIAlertViewDelegate,
    NoResultDelegate,
    ProductReputationSimpleDelegate,
    ShopTabChild
>

@property (strong, nonatomic) IBOutlet UIView *footer;

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (nonatomic, strong) NSDictionary *userinfo;
@property (nonatomic, strong) NSMutableArray *list;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) Shop *shop;

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
    
    ShopPageRequest *_shopPageRequest;
    
    NSMutableParagraphStyle *style;
    CMPopTipView *popTipView;
    Review *_review;
    NSDictionary *_auth;
    Shop *_shop;
    NoResultReusableView *_noResultView;
    
    TokopediaNetworkManager *_networkManager;
    UserAuthentificationManager *_userManager;
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

- (instancetype)initWithShop:(Shop *)shop {
    if (self = [super init]) {
        _shop = shop;
    }
    
    return self;
}

- (void)initNoResultView{
    _noResultView = [[NoResultReusableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 200)];
    _noResultView.delegate = self;
    [_noResultView generateAllElements:nil
                                 title:@"Toko ini belum mempunyai ulasan"
                                  desc:@""
                              btnTitle:nil];
}

- (void)initNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTotalReviewComment:)
                                                 name:@"updateTotalReviewComment" object:nil];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin:) name:TKPDUserDidLoginNotification object:nil];
    [self addBottomInsetWhen14inch];
    _userManager = [UserAuthentificationManager new];
    _auth = [_userManager getUserLoginData];

    style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    _talkNavigationFlag = [_data objectForKey:@"nav"];
    _page = 1;
    [self initNoResultView];
    
    _shopPageRequest = [[ShopPageRequest alloc]init];
    
    _list = [NSMutableArray new];
    _refreshControl = [[UIRefreshControl alloc] init];
    
    _table.delegate = self;
    _table.dataSource = self;
    _table.allowsSelection = YES;
    _table.estimatedRowHeight = 250;
    _table.rowHeight = UITableViewAutomaticDimension;
    
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    if (_list.count > 0) {
        _isNoData = NO;
    }
    
    // hack to fix y offset
    UIView *dummy = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    _table.tableHeaderView = dummy;
    
    UINib *cellNib = [UINib nibWithNibName:@"ProductReputationTableViewCell" bundle:nil];
    [_table registerNib:cellNib forCellReuseIdentifier:@"ProductReputationTableViewCellIdentifier"];
    
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.isUsingHmac = YES;
    _networkManager.isParameterNotEncrypted = NO;
    
    if (!_isRefreshView) {
        _table.tableFooterView = _footer;
        [_act startAnimating];
    }
    
    [_networkManager requestWithBaseUrl:[NSString v4Url]
                                   path:@"/v4/shop/get_shop_review.pl"
                                 method:RKRequestMethodGET
                              parameter:@{@"page": @(_page),
                                          @"per_page" : @(5),
                                          @"shop_domain" : [_data objectForKey:@"shop_domain"]?:@"",
                                          @"shop_id" : [_data objectForKey:@"shop_id"]?:@""}
                                mapping:[Review mapping]
                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                  NSDictionary *result = successResult.dictionary;
                                  
                                  id stats = [result objectForKey:@""];
                                  
                                  _review = stats;
                                  
                                  NSArray *list = _review.data.list;
                                  _reviewIsOwner = _review.data.is_owner;
                                  [_list addObjectsFromArray:list];
                                  _isNoData = NO;
                                  
                                  _uriNext = _review.data.paging.uri_next;
                                  
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
                                      _table.tableFooterView = _noResultView;
                                  } else {
                                      [_noResultView removeFromSuperview];
                                  }
                                  
                                  [_timer invalidate];
                                  _timer = nil;
                                  [_act stopAnimating];
                                  _table.hidden = NO;
                                  _isRefreshView = NO;
                                  [_refreshControl endRefreshing];
                              } onFailure:^(NSError *errorResult) {
                                  
                                  
                              }];
    
    [self initNotification];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [AnalyticsManager trackScreenName:@"Shop - Review List"];
    
    if (!_isRefreshView) {
        _table.tableFooterView = _footer;
        [_act startAnimating];
        [_networkManager requestWithBaseUrl:[NSString v4Url]
                                       path:@"/v4/shop/get_shop_review.pl" method:RKRequestMethodGET
                                  parameter:@{@"page": @(_page),
                                              @"per_page" : @(5),
                                              @"shop_domain" : [_data objectForKey:@"shop_domain"]?:@"",
                                              @"shop_id" : [_data objectForKey:@"shop_id"]?:@""}
                                    mapping:[Review mapping]
                                  onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                      NSDictionary *result = successResult.dictionary;
                                      
                                      id stats = [result objectForKey:@""];
                                      
                                      _review = stats;
                                      
                                      NSArray *list = _review.data.list;
                                      _reviewIsOwner = _review.data.is_owner;
                                      [_list addObjectsFromArray:list];
                                      _isNoData = NO;
                                      
                                      _uriNext = _review.data.paging.uri_next;
                                      
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
                                          _table.tableFooterView = _noResultView;
                                      } else {
                                          [_noResultView removeFromSuperview];
                                      }
                                      
                                      [_timer invalidate];
                                      _timer = nil;
                                      [_act stopAnimating];
                                      _table.hidden = NO;
                                      _isRefreshView = NO;
                                      [_refreshControl endRefreshing];
                                  } onFailure:^(NSError *errorResult) {
                                      
                                      
                                  }];
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


#pragma mark - Method
- (void)reloadTable {
    [_table reloadData];
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

- (ProductReputationCell *)getCell:(UIView *)btn {
    UIView *tempView = btn.superview;
    while(tempView) {
        if([tempView isMemberOfClass:[ProductReputationCell class]]) {
            return (ProductReputationCell *)tempView;
        }
        
        tempView = tempView.superview;
    }
    
    return nil;
}

- (void)updateDataInDetailView:(LikeDislike *)likeDislike {
    if([[self.navigationController.viewControllers lastObject] isMemberOfClass:[ProductDetailReputationViewController class]]) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [((ProductDetailReputationViewController *) [self.navigationController.viewControllers lastObject]) updateLikeDislike:likeDislike];
        });
    }
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
    lblDesc.font = [UIFont smallTheme];
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
        cell.backgroundColor = [UIColor clearColor];
    }
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    if (row == indexPath.row) {
        if (_uriNext != NULL && ![_uriNext isEqualToString:@"0"] && _uriNext != 0) {
//            [self configureRestKit];
//            [self loadData];
            if (!_isRefreshView) {
                _table.tableFooterView = _footer;
                [_act startAnimating];
            }
            [_networkManager requestWithBaseUrl:[NSString v4Url]
                                           path:@"/v4/shop/get_shop_review.pl" method:RKRequestMethodGET
                                      parameter:@{@"page": @(_page),
                                                  @"per_page" : @(5),
                                                  @"shop_domain" : [_data objectForKey:@"shop_domain"]?:@"",
                                                  @"shop_id" : [_data objectForKey:@"shop_id"]?:@""}
                                        mapping:[Review mapping]
                                      onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                          NSDictionary *result = successResult.dictionary;
                                          
                                          id stats = [result objectForKey:@""];
                                          
                                          _review = stats;
                                          
                                          NSArray *list = _review.data.list;
                                          _reviewIsOwner = _review.data.is_owner;
                                          [_list addObjectsFromArray:list];
                                          _isNoData = NO;
                                          
                                          _uriNext = _review.data.paging.uri_next;
                                          
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
                                              _table.tableFooterView = _noResultView;
                                          } else {
                                              [_noResultView removeFromSuperview];
                                          }
                                          
                                          [_timer invalidate];
                                          _timer = nil;
                                          [_act stopAnimating];
                                          _table.hidden = NO;
                                          _isRefreshView = NO;
                                          [_refreshControl endRefreshing];
                                      } onFailure:^(NSError *errorResult) {
                                          
                                          
                                      }];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self redirectToProductDetailReputation:_list[indexPath.row] withIndexPath:indexPath];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DetailReputationReview *list = _list[indexPath.row];
    
    __weak typeof(self) weakSelf = self;
    
    ProductReputationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductReputationTableViewCellIdentifier"];
    cell.viewModel = list.viewModel;
    cell.onTapProductName = ^(NSString *productName, NSString *productID){
        [NavigateViewController navigateToProductFromViewController:weakSelf withName:productName withPrice:nil withId:productID withImageurl:nil withShopName:nil];
    };
    
    return cell;
}

#pragma mark - Request
-(void)requestReview{
    [_noResultView removeFromSuperview];
    [_shopPageRequest requestForShopReviewPageListingWithShopId:[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]?:@(0)
                                                           page:_page
                                                    shop_domain:[_data objectForKey:@"shop_domain"]?:@""
                                                      onSuccess:^(Review *review) {
                                                          _review = review;
                                                          NSArray *list = _review.result.list;
                                                          _reviewIsOwner = _review.result.is_owner;
                                                          [_list addObjectsFromArray:list];
                                                          _isNoData = NO;
                                                          _uriNext =  _review.result.paging.uri_next;
                                                          _page = [[_shopPageRequest splitUriToPage:_uriNext] integerValue];
                                                          
                                                          [_table reloadData];
                                                          if (_list.count == 0) {
                                                              _act.hidden = YES;
                                                              _table.tableFooterView = _noResultView;
                                                          }else{
                                                              [_noResultView removeFromSuperview];
                                                          }
                                                          [_refreshControl endRefreshing];
                                                          [_refreshControl setHidden:YES];
                                                          [_refreshControl setEnabled:NO];
                                                      } onFailure:^(NSError *error) {
                                                          [_act stopAnimating];
                                                          _table.tableFooterView = nil;
                                                          StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:@[@"Kendala koneksi internet"] delegate:self];
                                                          [alert show];
                                                          
                                                          [_refreshControl endRefreshing];
                                                          [_refreshControl setHidden:YES];
                                                          [_refreshControl setEnabled:NO];
                                                      }];
}


#pragma mark - General Talk Delegate
- (id)navigationController:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath {
    return self;
}

-(void)GeneralReviewCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath {
    
}



#pragma mark - Refresh View
- (void)refreshContent {
    [self refreshView:nil];
}

-(void)refreshView:(UIRefreshControl*)refresh
{
    /** clear object **/
    _requestCount = 0;
    [_list removeAllObjects];
    _page = 1;
    _isRefreshView = YES;
    
    [_table reloadData];
    /** request data **/
//    [self configureRestKit];
//    [self loadData];
    if (!_isRefreshView) {
        _table.tableFooterView = _footer;
        [_act startAnimating];
    }
    
    [_networkManager requestWithBaseUrl:[NSString v4Url]
                                   path:@"/v4/shop/get_shop_review.pl" method:RKRequestMethodGET
                              parameter:@{@"page": @(_page),
                                          @"per_page" : @(5),
                                          @"shop_domain" : [_data objectForKey:@"shop_domain"]?:@"",
                                          @"shop_id" : [_data objectForKey:@"shop_id"]?:@""}
                                mapping:[Review mapping]
                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                  NSDictionary *result = successResult.dictionary;
                                  
                                  id stats = [result objectForKey:@""];
                                  
                                  _review = stats;
                                  
                                  NSArray *list = _review.data.list;
                                  _reviewIsOwner = _review.data.is_owner;
                                  [_list addObjectsFromArray:list];
                                  _isNoData = NO;
                                  
                                  _uriNext = _review.data.paging.uri_next;
                                  
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
                                      _table.tableFooterView = _noResultView;
                                  } else {
                                      [_noResultView removeFromSuperview];
                                  }
                                  
                                  [_timer invalidate];
                                  _timer = nil;
                                  [_act stopAnimating];
                                  _table.hidden = NO;
                                  _isRefreshView = NO;
                                  [_refreshControl endRefreshing];
                              } onFailure:^(NSError *errorResult) {
                                  
                                  
                              }];

}

#pragma mark - Notification Handler

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver: self];
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
    
    DetailReputationReview *list = _list[index];
    
    list.review_response.response_message = [userinfo objectForKey:@"review_comment"];
    list.review_response.response_create_time = [userinfo objectForKey:@"review_comment_time"];
    
    NSIndexPath *indexPath = [userinfo objectForKey:@"indexPath"];
    [_table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    [_table reloadData];
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
    strDescription = [NSString convertHTML:strDescription];
    
    if(strDescription.length > 100) {
        strDescription = [NSString stringWithFormat:@"%@... %@", [strDescription substringToIndex:100], strLihatSelengkapnya];

        NSRange range = [strDescription rangeOfString:strLihatSelengkapnya];
        lblDesc.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        lblDesc.delegate = self;
        lblDesc.activeLinkAttributes = @{(id)kCTForegroundColorAttributeName:[UIColor lightGrayColor], NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone)};
        lblDesc.linkAttributes = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone)};

        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:strDescription];
        [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, strDescription.length)];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:78/255.0f green:134/255.0f blue:38/255.0f alpha:1.0f] range:NSMakeRange(strDescription.length-strLihatSelengkapnya.length, strLihatSelengkapnya.length)];
        [str addAttribute:NSFontAttributeName value:[UIFont largeTheme] range:NSMakeRange(0, strDescription.length)];
        lblDesc.attributedText = str;
        [lblDesc addLinkToURL:[NSURL URLWithString:@""] withRange:range];
    }
    else {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:strDescription];
        [str addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, strDescription.length)];
        [str addAttribute:NSFontAttributeName value:[UIFont largeTheme] range:NSMakeRange(0, strDescription.length)];
        lblDesc.attributedText = str;
        lblDesc.delegate = nil;
        [lblDesc addLinkToURL:[NSURL URLWithString:@""] withRange:NSMakeRange(0, 0)];
    }
}

- (void)actionRate:(id)sender {
    DetailReputationReview *list = _list[((UIView *) sender).tag];
    
    if(! (list.review_user_reputation.no_reputation!=nil && [list.review_user_reputation.no_reputation isEqualToString:@"1"])) {
        int paddingRightLeftContent = 10;
        UIView *viewContentPopUp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (CWidthItemPopUp*3)+paddingRightLeftContent, CHeightItemPopUp)];
        SmileyAndMedal *tempSmileyAndMedal = [SmileyAndMedal new];
        [tempSmileyAndMedal showPopUpSmiley:viewContentPopUp andPadding:paddingRightLeftContent withReputationNetral:list.review_user_reputation.neutral withRepSmile:list.review_user_reputation.positive withRepSad:list.review_user_reputation.negative withDelegate:self];
        
        
        //Init pop up
        popTipView = [[CMPopTipView alloc] initWithCustomView:viewContentPopUp];
        popTipView.delegate = self;
        popTipView.backgroundColor = [UIColor whiteColor];
        popTipView.animation = CMPopTipAnimationSlide;
        popTipView.dismissTapAnywhere = YES;
        
        UIButton *button = (UIButton *)sender;
        [popTipView presentPointingAtView:button inView:self.view animated:YES];
    }
}

- (void)actionChat:(id)sender {
    [self redirectToProductDetailReputation:_list[((UIView *) sender).tag] withIndexPath:[NSIndexPath indexPathForRow:((UIView *) sender).tag inSection:0]];
}

- (void)redirectToProductDetailReputation:(DetailReputationReview *)reviewList withIndexPath:(NSIndexPath *)indexPath {
    if(_shop.result.stats.shop_badge_level == nil) {
        return;
    }
    
    ProductDetailReputationViewController *productDetailReputationViewController = [ProductDetailReputationViewController new];
    productDetailReputationViewController.detailReputationReview = reviewList;
    productDetailReputationViewController.isMyProduct = (_auth!=nil && [[_userManager getUserId] isEqualToString:reviewList.product_owner.user_id]);
    productDetailReputationViewController.shopBadgeLevel = _shop.result.stats.shop_badge_level;
    productDetailReputationViewController.shopImage = _shop.result.info.shop_avatar;
    productDetailReputationViewController.indexPathSelected = indexPath;
    productDetailReputationViewController.strProductID = reviewList.review_product_id;
    productDetailReputationViewController.isShowingProductView = YES;
    [self.navigationController pushViewController:productDetailReputationViewController animated:YES];
}

- (void)actionMore:(id)sender {
    if(_auth) {
        DetailReputationReview *list = _list[((UIButton *)sender).tag];
        UIActionSheet *actionSheet;
        if([list.review_is_allow_edit isEqualToString:@"1"] && ![list.review_product_status isEqualToString:STATE_PRODUCT_BANNED] && ![list.review_product_status isEqualToString:STATE_PRODUCT_DELETED]) {
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Batal" destructiveButtonTitle:@"Lapor" otherButtonTitles:nil, nil];
        }
        else {
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Batal" destructiveButtonTitle:@"Lapor" otherButtonTitles:nil, nil];
        }
        
        actionSheet.tag = ((UIButton *) sender).tag;
        [actionSheet showInView:self.parentViewController.view];
    }
    else {
        [self showLoginView];
    }
}

#pragma mark - TTTAttributeLabel Delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didLongPressLinkWithURL:(NSURL *)url atPoint:(CGPoint)point
{
    
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    [self redirectToProductDetailReputation:_list[label.tag] withIndexPath:[NSIndexPath indexPathForRow:label.tag inSection:0]];
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
        RKObjectManager *tempObjectManager =  [RKObjectManager sharedClient];
        
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
        [totalLikeDislikeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CTotalLikeDislike toKeyPath:CTotalLikeDislike withMapping:detailTotalLikeMapping]];
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
            ReportViewController *reportViewController = [ReportViewController new];
            DetailReputationReview *list = _list[actionSheet.tag];
            
            reportViewController.delegate = self;
            reportViewController.strProductID = list.review_product_id;
            reportViewController.strShopID = list.shop_id;
            reportViewController.strReviewID = list.review_id;

            [self.navigationController pushViewController:reportViewController animated:YES];
        }
            break;
    }
}

#pragma mark - LoginView Delegate
- (void)userDidLogin:(NSNotification*)notification {
    UserAuthentificationManager *_userManager = [UserAuthentificationManager new];
    _auth = [_userManager getUserLoginData];
    
    UIViewController *viewController = [self.navigationController.viewControllers lastObject];
    if([viewController isMemberOfClass:[ProductDetailReputationViewController class]]) {
        [((ProductDetailReputationViewController *) viewController) userHasLogin];
    }
    [_table reloadData];
}

- (void)redirectViewController:(id)viewController{
    
}

- (void)cancelLoginView {

}

#pragma mark - Report Delegate
- (NSDictionary *)getParameter {
    return nil;
}

- (UIViewController *)didReceiveViewController {
    return self;
}

- (NSString *)getPath {
    return @"action/review.pl";
}

- (void)showMoreDidTappedInIndexPath:(NSIndexPath*)indexPath{
    [self redirectToProductDetailReputation:_list[indexPath.row] withIndexPath:indexPath];
}
@end
