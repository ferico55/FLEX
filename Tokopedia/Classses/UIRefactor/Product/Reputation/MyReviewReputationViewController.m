//
//  MyReviewReputationViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "AlertRateView.h"
#import "CMPopTipView.h"
#import "detail.h"
#import "DetailMyInboxReputation.h"
#import "GeneralAction.h"
#import "LoadingView.h"
#import "Paging.h"
#import "SegmentedReviewReputationViewController.h"
#import "MyReviewReputation.h"
#import "MyReviewReputationViewModel.h"
#import "MyReviewReputationViewController.h"
#import "NavigateViewController.h"
#import "SplitReputationViewController.h"
#import "string_inbox_message.h"
#import "SmileyAndMedal.h"
#import "String_Reputation.h"
#import "ShopBadgeLevel.h"
#import "ShopContainerViewController.h"
#import "TokopediaNetworkManager.h"
#import "UserContainerViewController.h"
#import "ViewLabelUser.h"
#import "WebViewInvoiceViewController.h"
#import "NoResultReusableView.h"
#import "RequestLDExtension.h"
#import "NavigateViewController.h"
#import "NavigationHelper.h"
#import "MyReviewDetailViewController.h"
#import "InboxReviewCell.h"
#import "UIImageView+AFNetworking.h"
#import "ReviewRequest.h"
#import "InboxReputationResult.h"
#import "Tokopedia-Swift.h"

#define CFailedGetData @"Proses ambil data gagal"
#define CCellIndetifier @"cell"
#define CActionGetInboxReputation @"get_inbox_reputation"
#define CTagGetInboxReputation 1
#define CTagInsertReputation 2


@interface MyReviewReputationViewController ()<TokopediaNetworkManagerDelegate, LoadingViewDelegate, AlertRateDelegate, CMPopTipViewDelegate, SmileyDelegate, NoResultDelegate, requestLDExttensionDelegate, InboxReviewCellDelegate, UISearchBarDelegate>
@end

@implementation MyReviewReputationViewController
{
    AlertRateView *alertRateView;
    NoResultReusableView *_noResultView;
    CMPopTipView *cmPopTitpView;
    LoadingView *loadingView;
    NSMutableArray *arrList;
    NSString *strRequestingInsertReputation;
    TokopediaNetworkManager *tokopediaNetworkManager, *tokopediaNetworkInsertReputation;
    NSString *emoticonState, *strInsertReputationRole;
    
    NSString *givenSmileyImageString;
    int page;
    BOOL isRefreshing;
    BOOL hasShownData;
    NSString *strUriNext;
    NSIndexPath *indexPathInsertReputation;
    NSString *currentFilter;
    UIRefreshControl *refreshControl;
    
    NSString *_keyword;
    
    RequestLDExtension *_requestLD;
    NavigateViewController *_navigate;
    
    ReviewRequest *_reviewRequest;
}
@synthesize strNav;

- (void)dealloc
{
    [tokopediaNetworkManager requestCancel];
    tokopediaNetworkManager.delegate = nil;
    tokopediaNetworkManager = nil;
    
    [tokopediaNetworkInsertReputation requestCancel];
    tokopediaNetworkInsertReputation.delegate = nil;
    tokopediaNetworkInsertReputation = nil;
}

- (void)initNoResultView{
    _noResultView = [[NoResultReusableView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    _noResultView.delegate = self;
    [_noResultView generateAllElements:nil
                                 title:@"Belum ada ulasan"
                                  desc:@""
                              btnTitle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _navigate = [NavigateViewController new];
    currentFilter = @"all";
    _keyword = @"";
    page = 0;
    tableContent.allowsSelection = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    tableContent.backgroundColor = [UIColor colorWithRed:231/255.0f green:231/255.0f blue:231/255.0f alpha:1.0f];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [tableContent addSubview:refreshControl];
    [self initNoResultView];
    
    _searchBar.delegate = self;
    _searchBar.showsCancelButton = NO;
    _searchBar.layer.borderColor = [[UIColor colorWithRed:231.0/255 green:231.0/255 blue:231.0/255 alpha:1.0] CGColor];
    [_searchBar setBackgroundImage:[UIImage new]];
    
    
    
    if ([strNav isEqualToString:@"inbox-reputation"]) {
        _searchBar.placeholder = @"Cari Invoice / Penjual / Pembeli";
    } else if ([strNav isEqualToString:@"inbox-reputation-my-product"]) {
        _searchBar.placeholder = @"Cari Invoice / Pembeli";
    } else if ([strNav isEqualToString:@"inbox-reputation-my-review"]) {
        _searchBar.placeholder = @"Cari Invoice / Penjual";
    }
    
    [self loadMoreData:YES];
    
    _reviewRequest = [[ReviewRequest alloc] init];
    
    [self getInboxReputation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.title = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [AnalyticsManager trackScreenName:@"Inbox Review Page"];
    
    [tableContent reloadData];
    
    if(arrList.count > 0){
        UITableViewCell *firstCell = [tableContent cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            [firstCell setSelected:YES];
        }
    }
}

- (void)viewDidLayoutSubviews {
    CGRect screenRect = tableContent.frame;
    CGRect frame = searchBarView.frame;
    frame.size.width = screenRect.size.width;
    searchBarView.frame = frame;
    _searchBar.frame = frame;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Method
- (void)showAlertAfterGiveRate {
    NSString *strMessage = @"";
    if([emoticonState isEqualToString:CReviewScoreBad]) {
        strMessage = [NSString stringWithFormat:@"Saya Tidak Puas"];
    }
    else if([emoticonState isEqualToString:CReviewScoreNeutral]) {
        strMessage = [NSString stringWithFormat:@"Saya Cukup Puas"];
    }
    else if([emoticonState isEqualToString:CReviewScoreGood]) {
        strMessage = [NSString stringWithFormat:@"Saya Puas!"];
    }
    
    StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[strMessage] delegate:self];
    [stickyAlertView show];
}

- (void)alertWarningReviewSmiley {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Anda hanya bisa mengubah nilai reputasi menjadi lebih baik." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alertView show];
    indexPathInsertReputation = nil;
}


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
    cmPopTitpView = [[CMPopTipView alloc] initWithCustomView:lblShow];
    cmPopTitpView.delegate = self;
    cmPopTitpView.backgroundColor = [UIColor blackColor];
    cmPopTitpView.animation = CMPopTipAnimationSlide;
    cmPopTitpView.dismissTapAnywhere = YES;
    cmPopTitpView.leftPopUp = YES;
    
    UIButton *button = (UIButton *)sender;
    [cmPopTitpView presentPointingAtView:button inView:self.view animated:YES];
}

- (void)refreshView:(id)sender {
    page = 0;
    strUriNext = @"";
    [refreshControl endRefreshing];
    
    isRefreshing = YES;
    [self pressRetryButton];
}

- (void)loadMoreData:(BOOL)load {
    if(load) {
        tableContent.tableFooterView = viewFooter;
        [activityIndicator startAnimating];
    }
    else {
        tableContent.tableFooterView = nil;
        [activityIndicator stopAnimating];
    }
}

- (LoadingView *)getLoadView {
    if(loadingView == nil) {
        loadingView = [LoadingView new];
        loadingView.delegate = self;
    }
    
    return loadingView;
}

- (TokopediaNetworkManager *)getNetworkManager:(int)tag {
    if(tag == CTagGetInboxReputation) {
        if(tokopediaNetworkManager == nil) {
            tokopediaNetworkManager = [TokopediaNetworkManager new];
            tokopediaNetworkManager.tagRequest = tag;
            tokopediaNetworkManager.delegate = self;
        }

        return tokopediaNetworkManager;
    }
    else if(tag == CTagInsertReputation) {
        if(tokopediaNetworkInsertReputation == nil) {
            tokopediaNetworkInsertReputation = [TokopediaNetworkManager new];
            tokopediaNetworkInsertReputation.tagRequest = tag;
            tokopediaNetworkInsertReputation.delegate = self;
        }
        
        return tokopediaNetworkInsertReputation;
    }
    
    return nil;
}

- (void)getInboxReputation {
    [_reviewRequest requestGetInboxReputationWithNavigation:strNav
                                                       page:@(page)
                                                     filter:_segmentedReviewReputationViewController.getSelectedFilter
                                                    keyword:_keyword
                                                  onSuccess:^(InboxReputationResult *result) {
                                                      if (page == 0) {
                                                          isRefreshing = NO;
                                                          arrList = [[NSMutableArray alloc] initWithArray:result.list];
                                                      } else {
                                                          [arrList addObjectsFromArray:result.list];
                                                      }
                                                      
                                                      strUriNext = result.paging.uri_next;
                                                      page = [_reviewRequest getNextPageFromUri:strUriNext];
                                                      
                                                      //Check any data or not
                                                      if(arrList.count == 0) {
                                                          if ([_keyword isEqualToString:@""]) {
                                                              if([currentFilter isEqualToString:@"all"]) {
                                                                  if([strNav isEqualToString:@"inbox-reputation-my-product"]) {
                                                                      [_noResultView setNoResultTitle:@"Belum ada ulasan"];
                                                                  } else if([strNav isEqualToString:@"inbox-reputation-my-review"]) {
                                                                      [_noResultView setNoResultTitle:@"Anda belum memberikan ulasan pada produk apapun"];
                                                                  } else {
                                                                      [_noResultView setNoResultTitle:@"Belum ada ulasan"];
                                                                  }
                                                              } else if([currentFilter isEqualToString:@"not-read"]) {
                                                                  [_noResultView setNoResultTitle:@"Anda sudah membaca semua ulasan"];
                                                              } else if([currentFilter isEqualToString:@"not-review"]) {
                                                                  [_noResultView setNoResultTitle:@"Anda sudah memberikan ulasan"];
                                                              }
                                                          } else {
                                                              [_noResultView setNoResultTitle:@"Hasil pencarian tidak ditemukan"];
                                                          }
                                                          
                                                          tableContent.tableFooterView = _noResultView;
                                                      } else {
                                                          [self loadMoreData:NO];
                                                          [_noResultView removeFromSuperview];
                                                      }
                                                      if(tableContent.delegate == nil) {
                                                          tableContent.delegate = self;
                                                          tableContent.dataSource = self;
                                                      }
                                                      
                                                      [self showFirstDataOnFirstShowInIpad];
                                                      
                                                      [tableContent reloadData];
                                                  }
                                                  onFailure:^(NSError *errorResult) {
                                                      tableContent.tableFooterView = [self getLoadView].view;
                                                  }];
}

#pragma mark - UIScrollView Delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    _keyword = searchBar.text;
    page = 0;
    [AnalyticsManager trackSearchInboxReview];
    [_searchBar resignFirstResponder];
    [arrList removeAllObjects];
    [tableContent reloadData];
    [self loadMoreData:YES];
    [self getInboxReputation];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    CGRect screenRect = tableContent.frame;
    CGRect frame = searchBarView.frame;
    frame.size.width = screenRect.size.width;
    searchBarView.frame = frame;
    _searchBar.frame = frame;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [_searchBar setText:@""];
    [_searchBar resignFirstResponder];
    
    _keyword = @"";
    page = 0;
    
    [arrList removeAllObjects];
    [tableContent reloadData];
    [self loadMoreData:YES];
    [self getInboxReputation];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [_searchBar setShowsCancelButton:YES animated:YES];
    
    UITextField *searchBarTextField = nil;
    
    for (UIView *subView in _searchBar.subviews){
        for (UIView *secondSubView in subView.subviews){
            if ([secondSubView isKindOfClass:[UITextField class]])
            {
                searchBarTextField = (UITextField *)secondSubView;
                break;
            }
        }
    }
    
    searchBarTextField.enablesReturnKeyAutomatically = NO;
}

#pragma mark - UITableView Delegate and DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(arrList!=nil && arrList.count-1 == indexPath.row) {
        if (strUriNext!=nil && ![strUriNext isEqualToString:@"0"]) {
            [self loadMoreData:YES];
            [self getInboxReputation];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InboxReviewCell *cell = (InboxReviewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    DetailMyInboxReputation *current = arrList[indexPath.row];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"InboxReviewCell"
                                                                 owner:self
                                                               options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.delegate = self;
        cell.indexPath = indexPath;
    }
    
    if ([current.reviewee_role isEqualToString:@"2"]) {
        [cell.theirUserImage setImageWithURL:[NSURL URLWithString:current.reviewee_picture]
                            placeholderImage:[UIImage imageNamed:@"icon_default_shop.jpg"]];
    } else {
        [cell.theirUserImage setImageWithURL:[NSURL URLWithString:current.reviewee_picture]
                            placeholderImage:[UIImage imageNamed:@"icon_profile_picture.jpeg"]];
    }
    
    [cell.theirUserImage setCornerRadius:cell.theirUserImage.frame.size.width/2];
    [cell.theirUserImage setClipsToBounds:YES];
    
    [cell.theirUserName setText:current.reviewee_name];
    [cell.theirUserName setText:[UIColor colorWithRed:69/255.0 green:124/255.0 blue:16/255.0 alpha:1.0]
                       withFont:[UIFont smallThemeMedium]];
    [cell.theirUserName setLabelBackground:[current.reviewee_role isEqualToString:@"1"]?@"Pembeli":@"Penjual"];
    
    [cell.button.layer setBorderColor:[[UIColor colorWithRed:60/255.0 green:179/255.0 blue:57/255.0 alpha:1.0] CGColor]];
    
    if([current.role isEqualToString:@"1"]) {//Buyer
        [SmileyAndMedal generateMedalWithLevel:current.shop_badge_level.level withSet:current.shop_badge_level.set withImage:cell.theirReputation isLarge:NO];
        [cell.theirReputation setTitle:@"" forState:UIControlStateNormal];
    }
    else {
        [cell.theirReputation setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_smile_small" ofType:@"png"]] forState:UIControlStateNormal];
        [cell.theirReputation setTitle:[NSString stringWithFormat:@"%@%%", (current.user_reputation==nil? @"0":current.user_reputation.positive_percentage)] forState:UIControlStateNormal];
    }
    
    if ([current.show_bookmark isEqualToString:@"1"]) {
        [cell.unreadIconImage setHidden:NO];
    } else {
        [cell.unreadIconImage setHidden:YES];
    }
    
    if ([current.reputation_days_left intValue] > 0 && [current.reputation_days_left intValue] < 4) {
        cell.remainingTimeLabel.text = current.reputation_days_left_fmt;
    } else {
        cell.remainingTimeView.hidden = YES;
    }
    
    cell.timestampLabel.text = current.create_time_fmt_ws;
    
    [cell.button setTitle:current.review_status_description forState:UIControlStateNormal];
    [cell.button.layer setBorderWidth:2.0];
    [cell.button.layer setCornerRadius:5.0];
    [cell.button setClipsToBounds:YES];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self navigateToReviewDetailAtIndexPath:indexPath];
}

- (void)showFirstDataOnFirstShowInIpad {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (arrList.count && !hasShownData && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            hasShownData = YES;
            NSIndexPath *indexPath = [tableContent indexPathForSelectedRow]?:[NSIndexPath indexPathForRow:0 inSection:0];
            [tableContent selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            [self tapToInboxReviewDetailAtIndexPath:indexPath];
            
        }
    });
}

#pragma mark - LoadingView Delegate
- (void)pressRetryButton
{
    [self loadMoreData:YES];
    [self getInboxReputation];
}

#pragma mark - Action
- (void)actionReview:(id)sender {
    page = 0;
    strUriNext = nil;
    currentFilter = @"all";
    
    [arrList removeAllObjects];
    [tableContent reloadData];
    [self loadMoreData:YES];
    [self getInboxReputation];
}

- (void)actionBelumDibaca:(id)sender {
    page = 0;
    strUriNext = nil;
    currentFilter = @"not-read";

    [arrList removeAllObjects];
    [tableContent reloadData];
    [self loadMoreData:YES];
    [self getInboxReputation];
}

- (void)actionBelumDireview:(id)sender {
    page = 0;
    strUriNext = nil;
    currentFilter = @"not-review";
    
    [arrList removeAllObjects];
    [tableContent reloadData];
    [self loadMoreData:YES];
    [self getInboxReputation];
}

#pragma mark - Inbox Review Cell Delegate

- (void)tapToInboxReviewDetailAtIndexPath:(NSIndexPath *)indexPath {
    [tableContent selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self tableView:tableContent didSelectRowAtIndexPath:indexPath];
}

- (void)navigateToReviewDetailAtIndexPath:(NSIndexPath*)indexPath {
    if(! isRefreshing) {
        DetailMyInboxReputation *tempObj = arrList[indexPath.row];;
        //Set flag to read -> From unread
        tempObj.read_status = CValueRead;
        tempObj.viewModel.read_status = CValueRead;
        
        MyReviewDetailViewController *vc = [MyReviewDetailViewController new];
        vc.detailMyInboxReputation = tempObj;
        vc.tag = (int)indexPath.row;
        vc.autoRead = tempObj.auto_read;
        
        [AnalyticsManager trackEventName:@"clickReview"
                                category:GA_EVENT_CATEGORY_INBOX_REVIEW
                                  action:GA_EVENT_ACTION_VIEW
                                   label:self.strNav];
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [((SegmentedReviewReputationViewController *) self.parentViewController).splitVC setDetailViewController:vc];
        }
        else {
            [self.navigationController pushViewController:vc animated:YES];
        }
    }

}

- (void)tapToReputationDetail:(id)sender atIndexPath:(NSIndexPath *)indexPath {
    DetailMyInboxReputation *selectedInbox = arrList[indexPath.row];
    
    if ([selectedInbox.reviewee_role isEqualToString:@"1"]) {
        int paddingRightLeftContent = 10;
        UIView *viewContentPopUp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (CWidthItemPopUp*3)+paddingRightLeftContent, CHeightItemPopUp)];
        SmileyAndMedal *tempSmileyAndMedal = [SmileyAndMedal new];
        [tempSmileyAndMedal showPopUpSmiley:viewContentPopUp andPadding:paddingRightLeftContent withReputationNetral:selectedInbox.user_reputation.neutral withRepSmile:selectedInbox.user_reputation.positive withRepSad:selectedInbox.user_reputation.negative withDelegate:self];
        
        //Init pop up
        cmPopTitpView = [[CMPopTipView alloc] initWithCustomView:viewContentPopUp];
        cmPopTitpView.delegate = self;
        cmPopTitpView.backgroundColor = [UIColor whiteColor];
        cmPopTitpView.animation = CMPopTipAnimationSlide;
        cmPopTitpView.dismissTapAnywhere = YES;
        cmPopTitpView.leftPopUp = YES;
        
        UIButton *button = (UIButton *)sender;
        [cmPopTitpView presentPointingAtView:button inView:self.view animated:YES];
    } else {
        NSString *strText = [NSString stringWithFormat:@"%@ %@", selectedInbox.reputation_score, CStringPoin];
        [self initPopUp:strText withSender:sender withRangeDesc:NSMakeRange(strText.length-CStringPoin.length, CStringPoin.length)];
    }
}

- (void)tapToUserAtIndexPath:(NSIndexPath *)indexPath {
    if(! isRefreshing) {
        DetailMyInboxReputation *tempObj = arrList[indexPath.row];
        UserContainerViewController *container;
        ShopContainerViewController *containerShop;
        
        
        if([tempObj.role isEqualToString:@"2"]) {//2 is seller
            container = [UserContainerViewController new];
            UserAuthentificationManager *_userManager = [UserAuthentificationManager new];
            NSDictionary *auth = [_userManager getUserLoginData];
            
            if(tempObj.reviewee_uri!=nil && tempObj.reviewee_uri.length>0) {
                NSArray *arrUri = [tempObj.reviewee_uri componentsSeparatedByString:@"/"];
                container.data = @{
                                   @"user_id" : [arrUri lastObject],
                                   @"auth" : auth?:[NSNull null]
                                   };
                
                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    [((SegmentedReviewReputationViewController *) self.parentViewController).splitVC setDetailViewController:container];
                }
                else {
                    [self.navigationController pushViewController:container animated:YES];
                }
            }
        }
        else {
            containerShop = [[ShopContainerViewController alloc] init];
            TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
            NSDictionary *auth = [secureStorage keychainDictionary];
            
            containerShop.data = @{kTKPDDETAIL_APISHOPIDKEY:tempObj.shop_id,
                                   kTKPD_AUTHKEY:auth?:[NSNull null]};
            
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                [((SegmentedReviewReputationViewController *) self.parentViewController).splitVC setDetailViewController:containerShop];
            }
            else {
                [self.navigationController pushViewController:containerShop animated:YES];
            }
        }
    }
}

- (void)actionReviewRate:(id)sender
{
    if(! isRefreshing) {
        DetailMyInboxReputation *tempObj = arrList[((UIButton *) sender).tag];
        
        if([tempObj.reputation_progress isEqualToString:@"2"]) {
            // add some stickey message
            StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[@"Mohon maaf penilaian ini telah dikunci, Anda telah melewati batas waktu penilaian."] delegate:self];
            [stickyAlertView show];
        } else {
            alertRateView = [[AlertRateView alloc] initViewWithDelegate:self withDefaultScore:[tempObj.role isEqualToString:@"2"]?tempObj.buyer_score:tempObj.seller_score from:[tempObj.viewModel.role isEqualToString:@"1"]? CPembeli:CPenjual];
            alertRateView.tag = ((UIButton *) sender).tag;
            [alertRateView show];
        }
        

    }
}

- (void)actionInvoice:(id)sender
{
    if(! isRefreshing) {
        DetailMyInboxReputation *tempObj = arrList[((UIButton *) sender).tag];

        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UserAuthentificationManager *auth = [UserAuthentificationManager new];
            WebViewInvoiceViewController *VC = [WebViewInvoiceViewController new];
            NSDictionary *invoiceURLDictionary = [NSDictionary dictionaryFromURLString:tempObj.invoice_uri];
            NSString *invoicePDF = [invoiceURLDictionary objectForKey:@"pdf"];
            NSString *invoiceID = [invoiceURLDictionary objectForKey:@"id"];
            NSString *userID = [auth getUserId];
            NSString *invoiceURLforWS = [NSString stringWithFormat:@"%@/invoice.pl?invoice_pdf=%@&id=%@&user_id=%@", kTkpdBaseURLString, invoicePDF, invoiceID, userID];
            VC.urlAddress = invoiceURLforWS?:@"";
            
            [((SegmentedReviewReputationViewController *) self.parentViewController).splitVC setDetailViewController:VC];
        }
        else {
            if(tempObj.invoice_uri!=nil && tempObj.invoice_uri.length>0) {
                [NavigateViewController navigateToInvoiceFromViewController:self withInvoiceURL:tempObj.invoice_uri];
            }
        }
    }
}



- (void)actionFlagReview:(id)sender {
    DetailMyInboxReputation *object = arrList[((UIView *)sender).tag];
    BOOL loggedInUserIsSeller = [object.role isEqualToString:@"2"];

    NSString *img = object.my_score_image;
    NSString *opponentRole;
    NSString *alertString;
    if(!loggedInUserIsSeller) {
        //score given to me as buyer role
        opponentRole = @"Penjual";
    } else {
        //score given to me as seller role
        opponentRole = @"Pembeli";
    }
    
    if([img isEqualToString:@"smiley_neutral"]) {
        alertString = [NSString stringWithFormat:@"Penilaian dari %@ adalah cukup puas", opponentRole];
    } else if([img isEqualToString:@"smiley_bad"]) {
        alertString = [NSString stringWithFormat:@"Penilaian dari %@ adalah tidak puas", opponentRole];
    } else if([img isEqualToString:@"smiley_good"]) {
        alertString = [NSString stringWithFormat:@"Penilaian dari %@ adalah puas", opponentRole];
    } else if([img isEqualToString:@"grey_question_mark"] || [img isEqualToString:@"smiley_none"]) {
        alertString = [NSString stringWithFormat:@"%@ belum memberikan penilaian untuk Anda", opponentRole];
    } else if([img isEqualToString:@"blue_question_mark"]) {
        alertString = [NSString stringWithFormat:@"Penasaran ? \n Isi penilaian untuk %@ dulu ya!", opponentRole];
    }
    
    UIAlertView *alertView;
    alertView = [[UIAlertView alloc] initWithTitle:@"" message:alertString delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];

}


#pragma mark - AlertRate Delegate
- (void)closeWindow {
    alertRateView = nil;
}

#pragma mark - CMPopTipView Delegate
- (void)dismissAllPopTipViews
{
    [cmPopTitpView dismissAnimated:YES];
    cmPopTitpView = nil;
}


- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    [self dismissAllPopTipViews];
}


#pragma mark - Smiley Delegate
- (void)actionVote:(id)sender {
    [self dismissAllPopTipViews];
}


#pragma mark - Badge Extendsion
- (void)showPopUpLuckyDeal:(LuckyDealWord *)words
{
    [_navigate popUpLuckyDeal:words];
}

@end
