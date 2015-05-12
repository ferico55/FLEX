//
//  FavoriteShopViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 10/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "FavoritedShopViewController.h"
#import "string_home.h"
#import "detail.h"
#import "ShopTalkViewController.h"
#import "ShopReviewViewController.h"
#import "ShopNotesViewController.h"
#import "TKPDTabShopViewController.h"
#import "FavoritedShopCell.h"
#import "FavoritedShop.h"
#import "FavoriteShopAction.h"
#import "ShopContainerViewController.h"
#import "TokopediaNetworkManager.h"
#import "LoadingView.h"

#define CTagFavoriteButton 11
#define CTagRequest 234

@interface FavoritedShopViewController ()<UITableViewDataSource, UITableViewDelegate, FavoritedShopCellDelegate, TokopediaNetworkManagerDelegate, LoadingViewDelegate>
{
    BOOL _isnodata;
    BOOL _isrefreshview;
    NSString *strTempShopID;
    
    NSOperationQueue *_operationQueue;
    NSMutableArray *_shop;
    NSMutableArray *_goldshop;
    NSMutableDictionary *_shopdictionary;
    NSArray *_shopdictionarytitle;
    NSInteger _page;
    NSInteger _limit;
    NSInteger _requestcount;
    BOOL is_already_updated;
    
    LoadingView *loadingView;
    
    /** url to the next page **/
    NSString *_urinext;
    NSTimer *_timer;
    BOOL hasInitData;
    NSString *strUserID;
    
    UIRefreshControl *_refreshControl;
    __weak RKObjectManager *_objectmanager;
    TokopediaNetworkManager *tokopediaNetworkManager;
    
}

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@property (strong, nonatomic) IBOutlet UIView *footer;
@property (strong, nonatomic) IBOutlet UITableView *table;

@property (nonatomic, strong) NSMutableArray *shop;
@property (nonatomic, strong) NSMutableArray *goldshop;
@property (nonatomic, strong) NSDictionary *shopdictionary;
@end

@implementation FavoritedShopViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _operationQueue = [NSOperationQueue new];
    
    /** create new **/
    _shop = [NSMutableArray new];
    _goldshop = [NSMutableArray new];
    _shopdictionary = [NSMutableDictionary new];
    
    /** set first page become 1 **/
    _page = 1;
    
    _limit = kTKPDHOMEHOTLIST_LIMITPAGE;
    
    /** set table view datasource and delegate **/
    _table.delegate = self;
    _table.dataSource = self;
    
    /** set table footer view (loading act) **/
    _table.tableFooterView = _footer;
    //    [self setHeaderData:_goldshop];
    [_act startAnimating];
    
    tokopediaNetworkManager = [TokopediaNetworkManager new];
    tokopediaNetworkManager.delegate = self;
    
    _table.contentInset = UIEdgeInsetsMake(0, 0, 53, 0);
    
    if (_shop.count + _goldshop.count > 0) {
        _isnodata = NO;
    }
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshView:)
                                                 name:@"notifyFav"
                                               object:nil];
    
    if (!_isrefreshview) {
        [self configureRestKit];
        if (_isnodata || (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0)) {
            [self request];
        }
    }
    
    _table.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, 0)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Check Difference userID
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *_auth = [secureStorage keychainDictionary];
    _auth = [_auth mutableCopy];
    
    if(hasInitData)
    {
        hasInitData = !hasInitData;
        strUserID = [NSString stringWithFormat:@"%@", [_auth objectForKey:kTKPD_USERIDKEY]];
    }
    else if(! [strUserID isEqualToString:[NSString stringWithFormat:@"%@", [_auth objectForKey:kTKPD_USERIDKEY]]]) {
        strUserID = [NSString stringWithFormat:@"%@", [_auth objectForKey:kTKPD_USERIDKEY]];
        _page = 1;
        _isnodata = YES;
        _shop = [NSMutableArray new];
        _goldshop = [NSMutableArray new];
        _isrefreshview = NO;
        _urinext = nil;
        [self configureRestKit];
        [self request];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [tokopediaNetworkManager requestCancel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isrefreshview = NO;
        _isnodata = YES;
    }
    return self;
}


#pragma mark - Table View Data Source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    if (section == 0) {
        // Gold shops
        rows = [_goldshop count];
    } else {
        // Normal shops
        rows = [_shop count];
    }
    return rows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (!_isnodata) {
        NSString *cellid = kTKPDFAVORITEDSHOPCELL_IDENTIFIER;
        
        cell = (FavoritedShopCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [FavoritedShopCell newcell];
            ((FavoritedShopCell*)cell).delegate = self;
        }
        
        
        //if (_shop.count > indexPath.row ) {
            NSArray *shops;
            if (indexPath.section == 0) {
                shops = _goldshop;
            } else {
                shops = _shop;
            }
            FavoritedShopList *shop = shops[indexPath.row];
            
            ((FavoritedShopCell*)cell).shopname.text = shop.shop_name;
            ((FavoritedShopCell*)cell).shoplocation.text = shop.shop_location;
            
            if (indexPath.section == 0) {
                [((FavoritedShopCell*)cell).isfavoritedshop setImage:[UIImage imageNamed:@"icon_love.png"] forState:UIControlStateNormal];
            } else {
                [((FavoritedShopCell*)cell).isfavoritedshop setImage:[UIImage imageNamed:@"icon_love_active.png"] forState:UIControlStateNormal];
            }
            
            ((FavoritedShopCell*)cell).indexpath = indexPath;
            
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:shop.shop_image?:nil]
                                                          cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                      timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            
            UIImageView *thumb = ((FavoritedShopCell*)cell).shopimageview;
            thumb.image = nil;
            
            [thumb setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"icon_default_shop.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                [thumb setImage:image animated:YES];
#pragma clang diagnostic pop
            } failure:nil];
        //}
        
        
        return cell;
    } else {
        static NSString *CellIdentifier = kTKPDHOME_STANDARDTABLEVIEWCELLIDENTIFIER;
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = kTKPDHOME_NODATACELLTITLE;
        cell.detailTextLabel.text = kTKPDHOME_NODATACELLDESCS;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0) {
        if (_goldshop.count > 0) {
            return 33;
        } else {
            return 0;
        }
    }
    else {
        if (_shop.count > 0) {
            return 33;
        } else {
            return 0;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section==1 && _shop.count==0) {
        return nil;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.table.sectionHeaderHeight)];
    [view setBackgroundColor:tableView.backgroundColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.view.frame.size.width, self.table.sectionHeaderHeight)];
    [label setFont:[UIFont fontWithName:@"GothamBook" size:15]];
    [label setTextColor:[UIColor colorWithRed:66.0/255.0 green:66.0/255.0 blue:66.0/255.0 alpha:1]];
    label.text = [_shopdictionarytitle objectAtIndex:section];
    [view addSubview:label];
    return view;
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
        NSLog(@"%ld", (long)row);
        
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0) {
            [self configureRestKit];
            [self request];
        }
    }
}


-(void) removeFavoritedRow:(NSIndexPath*)indexpath{
    is_already_updated = YES;
    
    if(indexpath.section == 0) {
        
        FavoritedShopList *list = _goldshop[indexpath.row];
        
        [_shop insertObject:_goldshop[indexpath.row] atIndex:0];
        [_goldshop removeObjectAtIndex:indexpath.row];
        
        NSArray *insertIndexPaths = [NSArray arrayWithObjects:
                                     [NSIndexPath indexPathForRow:0 inSection:1],nil
                                     ];
        
        NSArray *deleteIndexPaths = [NSArray arrayWithObjects:
                                     [NSIndexPath indexPathForRow:indexpath.row inSection:0], nil
                                     ];
        
        [self configureRestkitFav];
        [self pressFavoriteAction:list.shop_id withIndexPath:indexpath];
        
        
        
        [_table beginUpdates];
        [_table deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationBottom];
        [_table insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
        [_table endUpdates];
        
        
        if(_goldshop.count < 2) {
            NSMutableIndexSet *section = [[NSMutableIndexSet alloc] init];
            [section addIndex:0];
            [_table reloadSections:section withRowAnimation:UITableViewRowAnimationFade];
        }
    } else {
        //        [_shop removeObjectAtIndex:indexpath.row];
    }
    
    //TODO ini animation nya masih jelek, yg bagus malah bikin bugs, checkthisout later!!
    //    [_table reloadData];
    
}

-(void) configureRestkitFav {
    
}

-(void) pressFavoriteAction:(id)shopid withIndexPath:(NSIndexPath*)indexpath{
    strTempShopID = shopid;
    tokopediaNetworkManager.tagRequest = CTagFavoriteButton;
    [tokopediaNetworkManager doRequest];
}


-(void) requestsuccessfav:(id)object withOperation:(RKObjectRequestOperation*)operation {
    //NSDictionary *result = ((RKMappingResult*)object).dictionary;
    //id info = [result objectForKey:@""];
    
}

-(void) requestfailurefav:(id)error{
    
    [_goldshop insertObject:_shop[0] atIndex:0];
    [_shop removeObjectAtIndex:0];
    
    
    NSArray *insertIndexPaths = [NSArray arrayWithObjects:
                                 [NSIndexPath indexPathForRow:0 inSection:0],nil
                                 ];
    
    NSArray *deleteIndexPaths = [NSArray arrayWithObjects:
                                 [NSIndexPath indexPathForRow:0 inSection:1], nil
                                 ];
    
    
    [_table beginUpdates];
    [_table deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationTop];
    [_table insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationBottom];
    [_table endUpdates];
}


#pragma mark - Request + Mapping
-(void) configureRestKit {
    
    
}

-(void) request {
    if (tokopediaNetworkManager.getObjectRequest.isExecuting) return;
    
    // create a new one, this one is expired or we've never gotten it
    if (!_isrefreshview) {
        _table.tableFooterView = _footer;
        [_act startAnimating];
    }
    
    tokopediaNetworkManager.tagRequest = CTagRequest;
    [tokopediaNetworkManager doRequest];
}

-(void) requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation {
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    FavoritedShop *favoritedshop = info;
    BOOL status = [favoritedshop.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if(status) {
        [self requestproceed:object];
        
        NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:kTKPDHOMEHISTORYPRODUCT_APIRESPONSEFILE];
        NSError *error;
        BOOL success = [result writeToFile:path atomically:YES];
        if (!success) {
            NSLog(@"writeToFile failed with error %@", error);
        }
        
    }
}

-(void) requestproceed:(id)object {
    if (object) {
        NSDictionary *result = ((RKMappingResult*)object).dictionary;
        id stat = [result objectForKey:@""];
        FavoritedShop *favoritedshop = stat;
        BOOL status = [favoritedshop.status isEqualToString:kTKPDREQUEST_OKSTATUS];
        
        if (status) {
            if(_page == 1) {
                _shop = [favoritedshop.result.list mutableCopy];
                _goldshop = [favoritedshop.result.list_gold mutableCopy];
            } else {
                [_shop addObjectsFromArray: favoritedshop.result.list];
                [_goldshop addObjectsFromArray: favoritedshop.result.list_gold];
            }
            
            _shopdictionary = [NSMutableDictionary new];
            
            if (_goldshop.count > 0) {
                [_shopdictionary setObject:_goldshop forKey:@"a"];
            }
            
            if (_shop.count > 0) {
                [_shopdictionary setObject:_shop forKey:@"b"];
            }
            
            _shopdictionarytitle = @[@"Rekomendasi",@"Toko Favoritku"];
            
            if (_shop.count + _goldshop.count >0) {
                _isnodata = NO;
                _urinext =  favoritedshop.result.paging.uri_next;
                NSURL *url = [NSURL URLWithString:_urinext];
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
                
                _page = [[queries objectForKey:kTKPDHOME_APIPAGEKEY] integerValue];
            } else {
                _isnodata = YES;
//                _table.tableFooterView = _noResult;
            }
            
            
            
            if(_refreshControl.isRefreshing) {
                [_refreshControl endRefreshing];
                [_table reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            } else  {
                [_table reloadData];
            }

            //
//            [_shop addObjectsFromArray: favoritedshop.result.list];
//            if(!is_already_updated && _page == 1) {
//                [_goldshop addObjectsFromArray: favoritedshop.result.list_gold];
//            }
//            
//            _shopdictionary = [NSMutableDictionary new];
//            
//            if (_goldshop.count > 0) {
//                [_shopdictionary setObject:_goldshop forKey:@"a"];
//            }
//            
//            if (_shop.count > 0) {
//                [_shopdictionary setObject:_shop forKey:@"b"];
//            }
//            
//            _shopdictionarytitle = @[@"Rekomendasi",@"Favorite"];
//            
//            if (_shop.count + _goldshop.count > 0) {
//                _isnodata = NO;
//                _urinext =  favoritedshop.result.paging.uri_next;
//                NSURL *url = [NSURL URLWithString:_urinext];
//                NSArray* querry = [[url query] componentsSeparatedByString: @"&"];
//                
//                NSMutableDictionary *queries = [NSMutableDictionary new];
//                [queries removeAllObjects];
//                for (NSString *keyValuePair in querry)
//                {
//                    NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
//                    NSString *key = [pairComponents objectAtIndex:0];
//                    NSString *value = [pairComponents objectAtIndex:1];
//                    
//                    [queries setObject:value forKey:key];
//                }
//                
//                _page = [[queries objectForKey:kTKPDHOME_APIPAGEKEY] integerValue];
//            }
        }
        else{
            
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %zd =====",_requestcount);
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

-(void) requestfailure:(id)error {
    
}

-(void) requesttimeout {
    [self cancel];
}


#pragma mark - Delegate
-(void)FavoritedShopCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath withimageview:(UIImageView *)imageview
{
    NSInteger section = indexpath.section;
    FavoritedShopList *list;
    
    if(section == 0) {
        list = _goldshop[indexpath.row];
    } else {
        list = _shop[indexpath.row];
    }
    
    ShopContainerViewController *container = [[ShopContainerViewController alloc] init];
    container.data = @{kTKPDDETAIL_APISHOPIDKEY:list.shop_id?:0,
                       kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{},
                       };
    [self.navigationController pushViewController:container animated:YES];
    //
    //Check Difference userID
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *_auth = [secureStorage keychainDictionary];
    _auth = [_auth mutableCopy];
    //    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //    TKPDTabShopViewController *shopViewController = [storyboard instantiateViewControllerWithIdentifier:@"TKPDTabShopViewController"];
    //    shopViewController.data = @{
    //                                kTKPDDETAIL_APISHOPIDKEY:list.shop_id?:0,
    //                                kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{},
    //                                @"is_dismissed" : @YES
    //                                };
    //
    //    [self.delegate pushViewController:shopViewController];
    
}


-(void)refreshView:(UIRefreshControl*)refresh
{
    [self cancel];
    /** clear object **/
//    [_shop removeAllObjects];
//    [_goldshop removeAllObjects];
    _page = 1;
    _requestcount = 0;
    _isrefreshview = YES;
    is_already_updated = NO;
    
//    [_table reloadData];
    /** request data **/
    [self configureRestKit];
    [self request];
}

-(void)cancel {
//    [_request cancel];
//    _request = nil;
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}



#pragma mark - TokoPedia Network Manager Delegate
- (NSDictionary*)getParameter:(int)tag
{
    if(tag == CTagFavoriteButton)
    {
        NSString *tempShopID = [NSString stringWithFormat:@"%@", strTempShopID];
        strTempShopID = nil;
        return @{
                 kTKPDHOME_APIACTIONKEY:@"fav_shop",
                 @"shop_id":tempShopID
                 };
    }
    else
        return @{kTKPDHOME_APIACTIONKEY:kTKPDHOMEFAVORITESHOPACT,
                 kTKPDHOME_APILIMITPAGEKEY : @(kTKPDHOMEHOTLIST_LIMITPAGE),
                 kTKPDHOME_APIPAGEKEY:@(_page)};
}

- (NSString*)getPath:(int)tag
{
    if(tag == CTagFavoriteButton)
        return @"action/favorite-shop.pl";
    else
        return kTKPDHOMEHOTLIST_APIPATH;
}

- (id)getObjectManager:(int)tag
{
    if(tag == CTagFavoriteButton)
    {
        // initialize RestKit
        _objectmanager =  [RKObjectManager sharedClient];
        
        // setup object mappings
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[FavoriteShopAction class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[FavoriteShopActionResult class]];
        [resultMapping addAttributeMappingsFromDictionary:@{@"content":@"content",
                                                            @"is_success":@"is_success"}];
        
        //relation
        RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                      toKeyPath:kTKPD_APIRESULTKEY
                                                                                    withMapping:resultMapping];
        [statusMapping addPropertyMapping:resulRel];
        
        //register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor
                                                          responseDescriptorWithMapping:statusMapping
                                                          method:RKRequestMethodPOST
                                                          pathPattern:@"action/favorite-shop.pl"
                                                          keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [_objectmanager addResponseDescriptor:responseDescriptorStatus];

        return _objectmanager;
    }
    else
    {
        // initialize RestKit
        _objectmanager =  [RKObjectManager sharedClient];
        
        // setup object mappings
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[FavoritedShop class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[FavoritedShopResult class]];
        
        RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
        [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIURINEXTKEY:kTKPDDETAIL_APIURINEXTKEY}];
        
        RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[FavoritedShopList class]];
        [listMapping addAttributeMappingsFromArray:@[
                                                     kTKPDDETAILSHOP_APISHOPIMAGE,
                                                     kTKPDDETAILSHOP_APISHOPLOCATION,
                                                     kTKPDDETAILSHOP_APISHOPID,
                                                     kTKPDDETAILSHOP_APISHOPNAME,
                                                     ]];
        
        RKObjectMapping *listGoldMapping = [RKObjectMapping mappingForClass:[FavoritedShopList class]];
        [listGoldMapping addAttributeMappingsFromArray:@[
                                                         kTKPDDETAILSHOP_APISHOPIMAGE,
                                                         kTKPDDETAILSHOP_APISHOPLOCATION,
                                                         kTKPDDETAILSHOP_APISHOPID,
                                                         kTKPDDETAILSHOP_APISHOPNAME,
                                                         ]];
        
        //relation
        RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
        [statusMapping addPropertyMapping:resulRel];
        
        RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APIPAGINGKEY toKeyPath:kTKPDHOME_APIPAGINGKEY withMapping:pagingMapping];
        [resultMapping addPropertyMapping:pageRel];
        
        RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APILISTKEY toKeyPath:kTKPDHOME_APILISTKEY withMapping:listMapping];
        [resultMapping addPropertyMapping:listRel];
        
        RKRelationshipMapping *listGoldRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APILISTGOLDKEY toKeyPath:kTKPDHOME_APILISTGOLDKEY withMapping:listMapping];
        [resultMapping addPropertyMapping:listGoldRel];
        
        //register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                      method:RKRequestMethodPOST
                                                                                                 pathPattern:kTKPDHOMEHOTLIST_APIPATH
                                                                                                     keyPath:@""
                                                                                                 statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [_objectmanager addResponseDescriptor:responseDescriptorStatus];
        return _objectmanager;
    }
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    if(tag == CTagFavoriteButton)
        return ((FavoriteShopAction *) stat).status;
    else
        return ((FavoritedShop *) stat).status;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag
{
    if(tag == CTagFavoriteButton)
    {
        [self requestsuccessfav:successResult withOperation:operation];
        [_act stopAnimating];
        _table.tableFooterView = nil;
        [_table reloadData];
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
    }
    else
    {
        [self requestsuccess:successResult withOperation:operation];
        [_act stopAnimating];
        _table.tableFooterView = nil;
        [_table reloadData];
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{
    if(tag == CTagFavoriteButton)
    {
        /** failure **/
        [self requestfailurefav:errorResult];
        //[_act stopAnimating];
        _table.tableFooterView = nil;
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
    }
    else
    {
        /** failure **/
        [self requestfailure:errorResult];
        //[_act stopAnimating];
//        _table.tableFooterView = nil;
//        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)actionBeforeRequest:(int)tag
{}

- (void)actionRequestAsync:(int)tag
{}

- (void)actionAfterFailRequestMaxTries:(int)tag
{
    if(tag == CTagFavoriteButton)
    {
    }
    else
    {
        if(loadingView == nil)
        {
            loadingView = [LoadingView new];
            loadingView.delegate = self;
        }
    
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        _table.tableFooterView = loadingView.view;
    }
}


#pragma mark - LoadingView Delegate
- (void)pressRetryButton
{
    _table.tableFooterView = _footer;
    [_act startAnimating];
    tokopediaNetworkManager.tagRequest = CTagRequest;
    [tokopediaNetworkManager doRequest];
}

#pragma mark - Dealloc
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [tokopediaNetworkManager requestCancel];
    tokopediaNetworkManager.delegate = nil;
    tokopediaNetworkManager = nil;
}

@end
