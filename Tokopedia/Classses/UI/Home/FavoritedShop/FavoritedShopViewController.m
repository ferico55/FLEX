//
//  FavoriteShopViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 10/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "FavoritedShopViewController.h"
#import "stringhome.h"
#import "detail.h"
#import "ShopProductViewController.h"
#import "ShopTalkViewController.h"
#import "ShopReviewViewController.h"
#import "ShopNotesViewController.h"
#import "TKPDTabShopNavigationController.h"
#import "FavoritedShopCell.h"
#import "FavoritedShop.h"
#import "FavoriteShopAction.h"

@interface FavoritedShopViewController ()<UITableViewDataSource, UITableViewDelegate, FavoritedShopCellDelegate>
{
    BOOL _isnodata;
    BOOL _isrefreshview;
    
    NSOperationQueue *_operationQueue;
    NSMutableArray *_shop;
    NSMutableArray *_goldshop;
    NSMutableDictionary *_shopdictionary;
    NSArray *_shopdictionarytitle;
    NSInteger _page;
    NSInteger _limit;
    NSInteger _requestcount;
    BOOL is_already_updated;
    
    /** url to the next page **/
    NSString *_urinext;
    NSTimer *_timer;
    
    
    UIRefreshControl *_refreshControl;
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    
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
    /** set inset table for different size**/
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
    
    
    /** set table view datasource and delegate **/
    _table.delegate = self;
    _table.dataSource = self;
    
    /** set table footer view (loading act) **/
    _table.tableFooterView = _footer;
    
    //    [self setHeaderData:_goldshop];
    [_act startAnimating];
    
    if (_shop.count > 0) {
        _isnodata = NO;
    }
    
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
//    [self.table setContentInset:UIEdgeInsetsMake(0, 0, 140, 0)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
    if (_shop.count > 0 && _goldshop.count > 0) {
        return 2;
    } else {
        return 1;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.numberOfSections == 2) {
        NSArray *keys = [_shopdictionary allKeys];
        return [[_shopdictionary objectForKey:[keys objectAtIndex:section]] count];
    } else {
        return _shop.count;
    }
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
        
        
        if (_shop.count > indexPath.row ) {
            
            NSString *sectionTitle = [_shopdictionarytitle objectAtIndex:indexPath.section];
            NSArray *sectionDictionary = [_shopdictionary objectForKey:sectionTitle];
            FavoritedShopList *shop = sectionDictionary[indexPath.row];
            
            ((FavoritedShopCell*)cell).shopname.text = shop.shop_name;
            ((FavoritedShopCell*)cell).shoplocation.text = shop.shop_location;
            
            if ([sectionTitle isEqualToString:@"Rekomendasi"]) {
                [((FavoritedShopCell*)cell).isfavoritedshop setImage:[UIImage imageNamed:@"icon_love.png"] forState:UIControlStateNormal];
            } else {
                [((FavoritedShopCell*)cell).isfavoritedshop setImage:[UIImage imageNamed:@"icon_love_active.png"] forState:UIControlStateNormal];
            }
            
            ((FavoritedShopCell*)cell).indexpath = indexPath;
            
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:shop.shop_image?:nil] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            //request.URL = url;
            UIImageView *thumb = ((FavoritedShopCell*)cell).shopimageview;
            thumb.image = nil;
            //thumb.hidden = YES;	//@prepareforreuse then @reset
            
            [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                //NSLOG(@"thumb: %@", thumb);
                [thumb setImage:image animated:YES];
                
#pragma clang diagnostic pop
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            }];
        }
        
        
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
    return 33;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.table.sectionHeaderHeight)];
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
        [_table insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationRight];
        [_table deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        [_table endUpdates];
        
    } else {
//        [_shop removeObjectAtIndex:indexpath.row];
    }
    
    //TODO ini animation nya masih jelek, yg bagus malah bikin bugs, checkthisout later!!
//    [_table reloadData];
    
}

-(void) configureRestkitFav {
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
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
    [statusMapping addPropertyMapping:resulRel];
    
    //register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:@"action/favorite-shop.pl" keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
}

-(void) pressFavoriteAction:(id)shopid withIndexPath:(NSIndexPath*)indexpath{
    //    if (_request.isExecuting) return;
    
    NSDictionary* param = @{
                            kTKPDHOME_APIACTIONKEY:@"fav_shop",
                            @"shop_id":shopid
                            };
    
    _requestcount ++;
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:@"action/favorite-shop.pl" parameters:param];
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestsuccessfav:mappingResult withOperation:operation];
        [_act stopAnimating];
        _table.tableFooterView = nil;
        [_table reloadData];
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestfailurefav:error];
        //[_act stopAnimating];
        _table.tableFooterView = nil;
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
    }];
    
    [_operationQueue addOperation:_request];
    
    _timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
}


-(void) requestsuccessfav:(id)object withOperation:(RKObjectRequestOperation*)operation {
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    
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
    [_table insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationRight];
    [_table deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    [_table endUpdates];
}


#pragma mark - Request + Mapping
-(void) configureRestKit {
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
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDHOMEHOTLIST_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
    
}

-(void) request {
    if (_request.isExecuting) return;
    
    // create a new one, this one is expired or we've never gotten it
    if (!_isrefreshview) {
        _table.tableFooterView = _footer;
        [_act startAnimating];
    }
    
    NSDictionary* param = @{kTKPDHOME_APIACTIONKEY:kTKPDHOMEFAVORITESHOPACT,
                            kTKPDHOME_APILIMITPAGEKEY : @(kTKPDHOMEHOTLIST_LIMITPAGE),
                            kTKPDHOME_APIPAGEKEY:@(_page)
                            };
    
    _requestcount ++;
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDHOMEHOTLIST_APIPATH parameters:param];
    
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        [self requestsuccess:mappingResult withOperation:operation];
        [_act stopAnimating];
        _table.tableFooterView = nil;
        [_table reloadData];
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestfailure:error];
        //[_act stopAnimating];
        _table.tableFooterView = nil;
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
    }];
    
    [_operationQueue addOperation:_request];
    
    _timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
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
            [_shop addObjectsFromArray: favoritedshop.result.list];
            if(!is_already_updated && _page == 1) {
                [_goldshop addObjectsFromArray: favoritedshop.result.list_gold];
            }

            _shopdictionary = [NSMutableDictionary new];
            
            if (_shop.count > 0) {
                [_shopdictionary setObject:_shop forKey:@"Favorite"];
            }

            if (_goldshop.count > 0) {
                [_shopdictionary setObject:_goldshop forKey:@"Rekomendasi"];
            }
            
            _shopdictionarytitle = [_shopdictionary allKeys];
            
            if (_shop.count >0) {
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
            }
        }
        else{
            
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %d =====",_requestcount);
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
    
    if(section == 1) {
        list = _goldshop[indexpath.row];
    } else {
        list = _shop[indexpath.row];
    }
    
    
    
    NSMutableArray *viewcontrollers = [NSMutableArray new];
    /** create new view controller **/
    ShopProductViewController *v = [ShopProductViewController new];
    v.data = @{kTKPDDETAIL_APISHOPIDKEY:list.shop_id?:@(0)};
    [viewcontrollers addObject:v];
    ShopTalkViewController *v1 = [ShopTalkViewController new];
    v1.data = @{kTKPDDETAIL_APISHOPIDKEY:list.shop_id?:@(0)};
    [viewcontrollers addObject:v1];
    ShopReviewViewController *v2 = [ShopReviewViewController new];
    v2.data = @{kTKPDDETAIL_APISHOPIDKEY:list.shop_id?:@(0)};
    [viewcontrollers addObject:v2];
    ShopNotesViewController *v3 = [ShopNotesViewController new];
    v3.data = @{kTKPDDETAIL_APISHOPIDKEY:list.shop_id?:@(0)};
    [viewcontrollers addObject:v3];
    /** Adjust View Controller **/
    TKPDTabShopNavigationController *tapnavcon = [TKPDTabShopNavigationController new];
    tapnavcon.data = @{
                       kTKPDDETAIL_APISHOPIDKEY:list.shop_id?:0,
                       kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:[NSNull null],
                       @"is_dismissed" : @YES
                       };
    [tapnavcon setViewControllers:viewcontrollers animated:YES];
    [tapnavcon setSelectedIndex:0];
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:tapnavcon];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    
    //    [self.navigationController pushViewController:tapnavcon animated:YES];
    
    
}


-(void)refreshView:(UIRefreshControl*)refresh
{
    [self cancel];
    /** clear object **/
    [_shop removeAllObjects];
    [_goldshop removeAllObjects];
    _page = 1;
    _requestcount = 0;
    _isrefreshview = YES;
    is_already_updated = NO;
    
    [_table reloadData];
    /** request data **/
    [self configureRestKit];
    [self request];
}

-(void)cancel {
    [_request cancel];
    _request = nil;
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}


@end
