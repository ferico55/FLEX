//
//  ProfileFavoriteShopViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "FavoriteShop.h"
#import "ProfileInfo.h"
#import "detail.h"

#import "profile.h"
#import "ProfileFavoriteShopViewController.h"
#import "ProfileFavoriteShopCell.h"

#import "URLCacheController.h"
#import "UserPageHeader.h"
#import "NoResultReusableView.h"
#import "Tokopedia-Swift.h"

#pragma mark - Profile Favorite Shop View Controller
@interface ProfileFavoriteShopViewController ()<UITableViewDataSource, UITableViewDelegate, ProfileFavoriteShopCellDelegate, UIScrollViewDelegate, UserPageHeaderDelegate>
{
    NSInteger _page;
    NSString *_urinext;
    
    NSMutableDictionary *_param;
    NSMutableArray <ListFavoriteShop*>*_list;
    BOOL _isnodata;
    
    BOOL _isrefreshview;
    UIRefreshControl *_refreshControl;

    ProfileInfo *_profile;

    NoResultReusableView *_noResultView;
    NSTimeInterval _timeinterval;
    UserPageHeader *_userHeader;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (strong, nonatomic) IBOutlet UIView *header;
@property (strong, nonatomic) IBOutlet UIView *fakeStickyTab;
@property (strong, nonatomic) IBOutlet UIView *stickyTab;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@end

@implementation ProfileFavoriteShopViewController

#pragma mark - Initializations
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodata = YES;
    }
    return self;
}

- (void)initNoResultView{
    _noResultView = [[NoResultReusableView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 200)];
    [_noResultView generateAllElements:nil
                                 title:@"Belum ada toko favorit"
                                  desc:@""
                              btnTitle:nil];
}

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initNoResultView];
    _list = [NSMutableArray new];
    [self initNotification];
    _page = 1;
    
    if (_list.count>2) {
        _isnodata = NO;
    }
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    _userHeader = [UserPageHeader new];
    _userHeader.delegate = self;
    _userHeader.data = _data;
    
    _header = _userHeader.view;
    UIView *btmGreenLine = (UIView *)[_header viewWithTag:20];
    [btmGreenLine setHidden:NO];
    
    _stickyTab = [(UIView *)_header viewWithTag:18];

    //_table.tableHeaderView = _header;
    _table.tableFooterView = _footer;
    _table.delegate = self;
}

- (void)initNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFavoriteShopScroll:)
                                                 name:@"updateFavoriteShopScroll" object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [AnalyticsManager trackScreenName:@"Profile - Favorited Shop"];
}
#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef kTKPDHOTLISTRESULT_NODATAENABLE
    return _isnodata?1:_list.count;
#else
    return _isnodata?0:_list.count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        
        NSString *cellid = kTKPDPROFILEFAVORITESHOPCELL_IDENTIFIER;
		
		cell = (ProfileFavoriteShopCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [ProfileFavoriteShopCell newcell];
			((ProfileFavoriteShopCell*)cell).delegate = self;
		}
        
        if (_list.count > indexPath.row) {
            ListFavoriteShop *list = _list[indexPath.row];
            ((ProfileFavoriteShopCell*)cell).label.text = list.shop_name;
            ((ProfileFavoriteShopCell*)cell).indexpath = indexPath;
            NSString *urlstring = list.shop_image;
            
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlstring] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            
            UIImageView *thumb = (UIImageView*)((ProfileFavoriteShopCell*)cell).thumb;
            thumb = [UIImageView circleimageview:thumb];
            
            thumb.image = nil;
            
            UIActivityIndicatorView *act = (UIActivityIndicatorView*)((ProfileFavoriteShopCell*)cell).act;
            [act startAnimating];
            
            [thumb setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"icon_default_shop@2x.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                //NSLOG(@"thumb: %@", thumb);
                [thumb setImage:image];
                
                [act stopAnimating];
#pragma clang diagnostic pop
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [act stopAnimating];
            }];
        }
        
		return cell;
    } else {
        static NSString *CellIdentifier = kTKPDPROFILE_STANDARDTABLEVIEWCELLIDENTIFIER;
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = kTKPDPROFILE_NODATACELLTITLE;
        cell.detailTextLabel.text = kTKPDPROFILE_NODATACELLDESCS;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_isnodata) {
		cell.backgroundColor = [UIColor whiteColor];
	}
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
	if (row == indexPath.row) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0) {
            /** called if need to load next page **/
            //NSLog(@"%@", NSStringFromSelector(_cmd));
            [self loadData];
        }
	}
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 205;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _header;
}

#pragma mark - Memory Management
- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Request and Mapping
- (void)loadData {
    
    [ProfileFavoriteRequest fetchListFavoriteShop:_page profileUserID:_profileUserID?:@"" onSuccess:^(FavoriteShopResult * data) {

        [_act stopAnimating];
        _table.hidden = NO;
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [self successRequestList:data.list];
        
        _urinext = data.paging.uri_next;
        _page = [[TokopediaNetworkManager getPageFromUri:_urinext] integerValue];

    } onFailure:^{
        
        [_act stopAnimating];
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        
    }];
    
}

-(void)successRequestList:(NSArray *)list{
    [_list addObjectsFromArray:list];
    _isnodata = NO;
    
    if([_list count] > 0) {
        [_noResultView removeFromSuperview];
        [_table reloadData];
    } else {
        _isnodata = YES;
        _table.tableFooterView = _noResultView;
    }
}

#pragma mark - Methods

-(void)refreshView:(UIRefreshControl*)refresh
{
    /** clear object **/
    _page = 1;
    [_list removeAllObjects];
    _isrefreshview = YES;
    
    [_table reloadData];
    /** request data **/
    [self loadData];
}

#pragma mark - Cell Delegate
-(void)ProfileFavoriteShopCellDelegate:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    ListFavoriteShop *list = _list[indexpath.row];
    
    ShopViewController *container = [[ShopViewController alloc] init];
    
    container.data = @{kTKPDDETAIL_APISHOPIDKEY:list.shop_id};
    [self.navigationController pushViewController:container animated:YES];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListFavoriteShop *list = _list[indexPath.row];
    
    ShopViewController *container = [[ShopViewController alloc] init];
    
    container.data = @{kTKPDDETAIL_APISHOPIDKEY:list.shop_id};
    [self.navigationController pushViewController:container animated:YES];

}

#pragma mark - UserPageHeader Delegate
- (void)didReceiveProfile:(ProfileInfo *)profile {
    _profile = profile;
    
    if(_profile && _page == 1) {
        [self loadData];
    }
}

- (void)didLoadImage:(UIImage *)image {
    
}

- (id)didReceiveNavigationController {
    return nil;
}

-(void) setHeaderData: (ProfileInfo*) profile {
    _profile = profile;
    [_userHeader setHeaderProfile:_profile];
}

@end
