//
//  ProdukFeedView.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/27/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "home.h"
#import "ProductFeedViewCell.h"
#import "ProductFeedViewController.h"

@interface ProductFeedViewController()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UITableView *table;

@property (nonatomic, strong) NSMutableArray *product;

@end

@implementation ProductFeedViewController
{
    NSInteger _page;
    NSInteger _limit;
    
    NSInteger _viewposition;
    
    //NSMutableArray *_hotlist;
    NSMutableDictionary *_paging;
    
    /** url to the next page **/
    NSString *_urinext;
    
    BOOL _isnodata;
}

#pragma mark - Factory Method

- (id)initWithPosition:(NSInteger)position withNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _viewposition = position;
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    /** this will setup the position in the UIScrollView **/
    [self.view setFrame:CGRectMake(320*_viewposition, 0, 320, 460)];
    
    /** create new **/
    _paging = [NSMutableDictionary new];
    _product = [NSMutableArray new];
    
    /** set max data per page request **/
    _limit = kTKPDHOMEHOTLIST_LIMITPAGE;
    
    /** set inset table for different size**/
    if (is4inch) {
        UIEdgeInsets inset = _table.contentInset;
        inset.bottom += 150;
        _table.contentInset = inset;
    }
    else{
        UIEdgeInsets inset = _table.contentInset;
        inset.bottom += 240;
        _table.contentInset = inset;
    }
    
    _table.delegate = self;
    _table.dataSource = self;
    
    NSArray *product =@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8"];
    [_product addObjectsFromArray:product];
    
    if (_product.count > 0) {
        _isnodata = NO;
    }
    
    /** adjust refresh control **/
    //[self request:YES withrefreshControl:nil];
    //UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    //refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    //[refresh addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    //[_hotlisttable addSubview:refresh];
    
    //[self configureRestKit];
    //[self loadVenues];
}

-(void)refreshView:(UIRefreshControl*)refresh
{
    
    [_product removeAllObjects];
    [_paging removeAllObjects];
    [_table reloadData];
    //static dispatch_once_t onceToken;
    
    //dispatch_once (&onceToken, ^{
    //[self request:YES withrefreshControl:refresh];
    //});
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}


#pragma mark - Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef kTKPDHOMEHOTLIST_NODATAENABLE
        return _isnodata ? 1 : (_product.count-1)/2+1;
#else
        return _isnodata ? 0 : (_product.count-1)/2+1;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        NSString *cellid = kTKPDPRODUKFEEDCELL_IDENTIFIER;
		
		cell = (ProductFeedViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [ProductFeedViewCell newcell];
			((ProductFeedViewCell*)cell).delegate = self;
		}
		
        /** Flexible view count **/ //TODO::sederhanakan
        NSArray *itemsForView;
        NSUInteger kItemsPerView = 2;
        NSUInteger startIndex = indexPath.row * kItemsPerView;
        NSUInteger count = MIN( _product.count - startIndex, kItemsPerView );
		if ((_product.count/2) > indexPath.row &&!((_product.count-1)/2+1 == indexPath.row+1))
            itemsForView = [_product subarrayWithRange: NSMakeRange( startIndex, count)];
        else if((_product.count-1)/2+1 == indexPath.row+1){
            if (_product.count%2==0) {
                itemsForView = [_product subarrayWithRange: NSMakeRange( startIndex, count)];
            }
            else
                itemsForView = @[_product[_product.count-1]];
            
		}
        
        ((ProductFeedViewCell*)cell).data = @{kTKPDHOME_DATAINDEXPATHKEY: indexPath, kTKPDHOME_DATACOLUMNSKEY: itemsForView};
        
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

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_isnodata) {
		cell.backgroundColor = [UIColor whiteColor];
	}
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1;
	if (row == indexPath.row) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
		
        if (_urinext != NULL && ![_urinext isEqualToString:@""]) {
            //NSLog(@"%@", NSStringFromSelector(_cmd));
            //[self request:NO withrefreshControl:nil];
        }
	}
}


//#pragma mark - request
//-(void)cancel
//{
//    NSLog(@"%@", NSStringFromSelector(_cmd));
//	
//	//AFHTTPClient* client = [AFHTTPClient sharedClient];
//	//[client cancelAllHTTPOperationsWithMethod:@"GET" path:kJYRANKINGLIST_APIPATH];
//	[_request cancel];
//	_request = nil;
//	
//	_table.tableFooterView = nil;
//    [_act stopAnimating];
//}
//
//-(void)request:(BOOL)refresh withrefreshControl:(UIRefreshControl *)refreshControl
//{
//    if (_request.isExecuting) return;
//    
//    if (refresh) {
//        _page = 1;
//        
//        refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
//    }
//    
//    _table.tableFooterView = _footer;
//    [_act startAnimating];
//    
//	NSDictionary* param = @{kTKPDAUTHKEY:@(1),
//                            kTKPDPRODUCTLIST_APIACTDATA:kTKPDPRODUCTLISTHOTLISTACT,
//                            kTKPDPRODUCTLIST_APIPAGEDATA : @(_page),
//                            kTKPDPRODUCTLIST_APILIMITPAGEDATA : @(kTKPDPRODUCTLISTHOTLIST_LIMITPAGE)
//                            };
//    
//    /** Use This For Post Param**/
//    //[Client setParameterEncoding:AFJSONParameterEncoding];
//    //_requestaction = (AFJSONRequestOperation*)[client postPath:kTKPDLOGIN_APIPATH parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
//    
//    TraktAPIClient *client = [TraktAPIClient sharedClient];
//    
//    [client GET:kTKPDPRODUCTLISTHOTLIST_APIPATH  parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        _request = nil;
//        
//        _table.tableFooterView = nil;
//        [_act stopAnimating];
//        [self requestsuccess:responseObject];
//        
//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        [formatter setDateFormat:@"MMM d, h:mm a"];
//        NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@", [formatter stringFromDate:[NSDate date]]];
//        refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
//        [refreshControl endRefreshing];
//        //_hotlisttable.scrollEnabled = YES;
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//        _request = nil;
//        _table.tableFooterView = nil;
//        [_act stopAnimating];
//        [self requestfailure:error];
//        
//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        [formatter setDateFormat:@"MMM d, h:mm a"];
//        NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@", [formatter stringFromDate:[NSDate date]]];
//        refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
//        [refreshControl endRefreshing];
//        //_hotlisttable.scrollEnabled = YES;
//    }];
//}
//
//-(void)requestsuccess:(id)object
//{
//    NSDictionary *response = (NSDictionary*)object;
//    //[_hotlist addEntriesFromDictionary:response];
//    NSString *status = [response objectForKey:kTKPDPRODUCTLIST_APISTATUSDATA];
//    
//    if (status) {
//        
//        NSDictionary *result = [response objectForKey:kTKPDPRODUCTLIST_APIRESULTDATA];
//        NSArray *list = [result objectForKey:kTKPDPRODUCTLIST_APILISTDATA];
//        NSDictionary *paging = [result objectForKey:kTKPDPRODUCTLIST_APIPAGINGDATA];
//        
//        if (_page == 1) {
//            [_product removeAllObjects];
//            [_paging removeAllObjects];
//        }
//        
//        if (list.count >0) {
//            [_paging removeAllObjects];
//            
//            [_product addObjectsFromArray:list];
//            [_paging addEntriesFromDictionary:paging];
//            _urinext = [_paging objectForKey:kTKPDPRODUCTLIST_APIURINEXTDATA];
//            NSURL *url = [NSURL URLWithString:_urinext];
//            NSArray* querry = [[url query] componentsSeparatedByString: @"&"];
//            
//            NSMutableDictionary *queries = [NSMutableDictionary new];
//            [queries removeAllObjects];
//            for (NSString *keyValuePair in querry)
//            {
//                NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
//                NSString *key = [pairComponents objectAtIndex:0];
//                NSString *value = [pairComponents objectAtIndex:1];
//                
//                [queries setObject:value forKey:key];
//            }
//            _page = [[queries objectForKey:kTKPDPRODUCTLIST_APIPAGEDATA] integerValue];
//            NSLog(@"next page : %d",_page);
//        }
//        /** uri split **/
//        //NSLog(@"scheme: %@", [url scheme]);
//        //NSLog(@"host: %@", [url host]);
//        //NSLog(@"port: %@", [url port]);
//        //NSLog(@"path: %@", [url path]);
//        //NSLog(@"path components: %@", [url pathComponents]);
//        //NSLog(@"parameterString: %@", [url parameterString]);
//        //NSLog(@"query: %@", [url query]);
//        //NSLog(@"fragment: %@", [url fragment]);
//        
//#ifdef _DEBUG
//        NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:kTKPDPRODUCTLISTHOTLIST_APIRSPONSEFILE];
//        [response writeToFile:path atomically:YES];
//#endif
//        
//        
//    }else{
//        [self requestfailure:object];
//    }
//    
//    [self requestprocess];
//}
//
//-(void)requestfailure:(id)object
//{
//    
//#ifdef _DEBUG
//    
//    [self requestprocess];
//#endif
//    
//	NSDictionary* response;
//	
//	NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:kTKPDPRODUCTLISTHOTLIST_APIRSPONSEFILE];
//	response = [NSDictionary dictionaryWithContentsOfFile:path];
//    
//    NSDictionary *result = [response objectForKey:kTKPDPRODUCTLIST_APIRESULTDATA];
//    NSArray *list = [result objectForKey:kTKPDPRODUCTLIST_APILISTDATA];
//    NSDictionary *paging = [result objectForKey:kTKPDPRODUCTLIST_APIPAGINGDATA];
//    
//    if (_page == 1) {
//        [_product removeAllObjects];
//        [_paging removeAllObjects];
//        [_product addObjectsFromArray:list];
//        [_paging addEntriesFromDictionary:paging];
//    }
//    else
//    {
//        [_product addObjectsFromArray:list];
//        [_paging removeAllObjects];
//        [_paging addEntriesFromDictionary:paging];
//    }
//    
//    _urinext = [_paging objectForKey:kTKPDPRODUCTLIST_APIURINEXTDATA];
//    NSURL *url = [NSURL URLWithString:_urinext];
//    NSArray* querry = [[url query] componentsSeparatedByString: @"&"];
//    
//    NSMutableDictionary *pages = [NSMutableDictionary new];
//    
//    for (NSString *keyValuePair in querry)
//    {
//        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
//        NSString *key = [pairComponents objectAtIndex:0];
//        NSString *value = [pairComponents objectAtIndex:1];
//        
//        [pages setObject:value forKey:key];
//    }
//    _page = [[pages objectForKey:kTKPDPRODUCTLIST_APIPAGEDATA] integerValue];
//    
//    [self requestprocess];
//}
//
//-(void)requestprocess
//{
//    if (_product.count>0) {
//        _isnodata = NO;
//    }
//    else
//    {
//        _isnodata = YES;
//    }
//    
//    //    if (_urinext != NULL && ![_urinext isEqualToString:@""]) {
//    //        //NSLog(@"%@", NSStringFromSelector(_cmd));
//    //        [self request:NO withrefreshControl:nil];
//    //    }
//    
//    [_table reloadData];
//    
//}

#pragma mark - Delegate
//-(void)ProductFeedViewCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath withdata:(NSDictionary *)data
//{
//    [_delegate ProductFeedViewDelegateCell:cell withindexpath:indexpath withdata:data];
//}

@end
