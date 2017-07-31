//
//  ShopFavoritedViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "ShopFavoritedViewController.h"
#import "ShopFavoritedCell.h"

#import "ProfileFavoriteShopViewController.h"
#import "ProfileContactViewController.h"

#import "URLCacheController.h"
#import "UserContainerViewController.h"
#import "NavigateViewController.h"
#import "Tokopedia-Swift.h"

@interface ShopFavoritedViewController ()<UITableViewDataSource, UITableViewDelegate, ShopFavoritedCellDelegate>
{
    NSInteger _page;
    NSInteger _totalPage;
    
    NSMutableArray <ListFavorited*>*_list;
    UIRefreshControl *_refreshControl;
    
}
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@end

@implementation ShopFavoritedViewController

#pragma mark - Initializations
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = KTKPDTITLE_FAV_THIS_SHOP;
    }
    return self;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _list = [NSMutableArray new];
    _page = 1;

    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];

    [self requestFavoritedShopID:_shopID];
}


#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _list.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    NSString *cellid = kTKPDSHOPFAVORITEDCELL_IDENTIFIER;
    
    cell = (ShopFavoritedCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [ShopFavoritedCell newcell];
        ((ShopFavoritedCell*)cell).delegate = self;
    }
    
    if (_list.count > indexPath.row) {
        ListFavorited *list = _list[indexPath.row];
        ((ShopFavoritedCell*)cell).label.text = list.user_name;
        ((ShopFavoritedCell*)cell).indexpath = indexPath;
        NSString *urlstring = list.user_image;
        
        NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlstring] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        
        UIImageView *thumb = (UIImageView*)((ShopFavoritedCell*)cell).thumb;
        thumb = [UIImageView circleimageview:thumb];
        thumb.image = nil;
        
        UIActivityIndicatorView *act = (UIActivityIndicatorView*)((ShopFavoritedCell*)cell).act;
        [act startAnimating];
        
        [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
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

}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
	if (row == indexPath.row) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
        if ([self hasMoreData]) {
            _page++;
            [self requestFavoritedShopID:_shopID];
        }
	}
}

#pragma mark - Memory Management
- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

#pragma mark - Request and Mapping
- (void)requestFavoritedShopID:(NSString*)shopID {
    
    [ShopRequest fetchListShopFavorited:_page shopID:shopID onSuccess:^(FavoritedResult * data) {

        [_act stopAnimating];
        _table.hidden = NO;
        [_refreshControl endRefreshing];
        _table.tableFooterView = nil;
        [self setListFavorited:data.list];
        
        _page = [data.page integerValue];
        _totalPage = data.total_page;
        
    } onFailure:^{
        
        [_act stopAnimating];
        [_refreshControl endRefreshing];
    }];
}

-(void)setListFavorited:(NSArray*)list{

    [_list addObjectsFromArray:list];

    [_table reloadData];
}


#pragma mark - Methods

-(BOOL)hasMoreData{
    return _list.count > _page && _page < _totalPage;
}


-(void)refreshView:(UIRefreshControl*)refresh
{
    /** clear object **/
    _page = 1;
    [_list removeAllObjects];

    
    [_table reloadData];
    _table.tableFooterView = nil;
    
    /** request data **/
    [self requestFavoritedShopID:_shopID];
}

#pragma mark - Cell Delegate
-(void)ShopFavoritedCellDelegate:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    //go to profile
    NSArray *favs = _list;
    ListFavorited *fav = favs[indexpath.row];
    NSInteger userid = fav.user_id;
    
    NavigateViewController *navigateController = [NavigateViewController new];
    [navigateController navigateToProfileFromViewController:self withUserID:[NSString stringWithFormat:@"%ld", (long)userid]];
    
}

@end
