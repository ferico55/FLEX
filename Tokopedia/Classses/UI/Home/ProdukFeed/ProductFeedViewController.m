//
//  ProdukFeedView.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/27/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "home.h"
#import "GeneralProductCell.h"
#import "ProductFeedViewController.h"

@interface ProductFeedViewController() <UITableViewDataSource, UITableViewDelegate, GeneralProductCellDelegate>

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
    __weak RKObjectManager *_objectmanager;
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
    NSLog(@"going here first");
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
    
    [self loadData];
    
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
    NSLog(@"going here again");
#ifdef kTKPDHOMEHOTLIST_NODATAENABLE
        return _isnodata ? 1 : (_product.count-1)/2+1;
#else
        return _isnodata ? 0 : (_product.count-1)/2+1;
#endif
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"going here");
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        NSString *cellid = kTKPDGENERALPRODUCTCELL_IDENTIFIER;
		
		cell = (GeneralProductCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [GeneralProductCell newcell];
			((GeneralProductCell*)cell).delegate = self;
		}
        
        if(_product.count > indexPath.row) {
            
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
        
        ((GeneralProductCell*)cell).data = @{kTKPDHOME_DATAINDEXPATHKEY: indexPath, kTKPDHOME_DATACOLUMNSKEY: itemsForView};
        
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
    [self configureRestKit];
    [self loadData];
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

-(void)loadData
{
    _table.tableFooterView = _footer;
    [_act startAnimating];
    
    NSDictionary *param = @{
                            kTKPDHOME_APIACTIONKEY : @"get_product_feed"
                            };
    
    NSLog(@"====GET LIST OF FEED====");
    
    [_objectmanager getObjectsAtPath:kTKPDHOMEHOTLIST_APIPATH parameters:param
                    success:
                    ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
                        [self requestsuccess:mappingResult];
                        [_act stopAnimating];
                        [_table reloadData];
//                        [_refreshControl endRefreshing];
                    }
                    failure:
                    ^(RKObjectRequestOperation *operation, NSError *error) {
                        
                    }];
    
    NSLog(@"====END GET LIST OF FEED====");
    
}

-(void) configureRestKit
{
    _objectmanager = [RKObjectManager sharedClient];
}

-(void)requestsuccess:(id)object
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    
    
}

@end
