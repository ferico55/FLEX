//
//  CategoryResultViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/2/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "DBManager.h"
#import "category.h"
#import "CategoryResultViewCell.h"
#import "CategoryResultViewController.h"
#import "CategoryMenuViewController.h"

@interface CategoryResultViewController () <CategoryResultViewCellDelegate, UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentcontrol;
@property (weak, nonatomic) IBOutlet UISearchBar *searchbar;
@property (weak, nonatomic) IBOutlet UITableView *table;

@property (nonatomic, strong) NSMutableArray *product;

@end

@implementation CategoryResultViewController{
    NSInteger _page;
    NSInteger _limit;
    
    NSInteger _d_id;
    
    NSInteger _viewposition;
    
    //NSMutableArray *_hotlist;
    NSMutableDictionary *_paging;
    
    /** url to the next page **/
    NSString *_urinext;
    
    BOOL _isnodata;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    /** create new **/
    _paging = [NSMutableDictionary new];
    _product = [NSMutableArray new];
    
    UIBarButtonItem *barbutton1;
    NSBundle* bundle = [NSBundle mainBundle];
    //TODO:: Change image
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONBACK ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    }
    else
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
	[barbutton1 setTag:10];
    self.navigationItem.leftBarButtonItem = barbutton1;
    
    img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONMORECATEGORY ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    }
    else
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    
	[barbutton1 setTag:11];
    self.navigationItem.rightBarButtonItem = barbutton1;
    
    /** set max data per page request **/
    _limit = kTKPDCATEGORYRESULT_LIMITPAGE;
    
    _d_id = [[_data objectForKey:kTKPDCATEGORY_DATADIDKEY]integerValue];
    
    /** set inset table for different size**/
    //if (is4inch) {
    //    UIEdgeInsets inset = _table.contentInset;
    //    inset.bottom += 120;
    //    _table.contentInset = inset;
    //}
    //else{
    //    UIEdgeInsets inset = _table.contentInset;
    //    inset.bottom += 240;
    //    _table.contentInset = inset;
    //}
    
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

#pragma mark - View Gesture
-(IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem*)sender;
        switch (btn.tag) {
            case 10:
            {
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                break;
            }
            case 11:
            {
                CategoryMenuViewController *vc = [CategoryMenuViewController new];
                vc.data = @{kTKPDCATEGORY_DATADIDKEY:@(_d_id)};
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef kTKPDPRODUCTLISTHOTLIST_NODATAENABLE
    return _isnodata ? 1 : (_product.count-1)/2+1;
#else
    return _isnodata ? 0 : (_product.count-1)/2+1;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        NSString *cellid = kTKPDCATEGORYRESULTVIEWCELL_IDENTIFIER;
		
		cell = (CategoryResultViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [CategoryResultViewCell newcell];
			((CategoryResultViewCell*)cell).delegate = self;
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
        
        ((CategoryResultViewCell*)cell).data = @{kTKPDCATEGORY_DATAINDEXPATHKEY: indexPath, kTKPDCATEGORY_DATACOLUMNSKEY: itemsForView};
        
	} else {
		static NSString *CellIdentifier = kTKPDCATEGORY_STANDARDTABLEVIEWCELLIEDNTIFIER;
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		cell.textLabel.text = kTKPDCATEGORY_NODATACELLTITLE;
		cell.detailTextLabel.text = kTKPDCATEGORY_NODATACELLDESCS;
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


#pragma mark - Cell Delegate
-(void)CategoryResultViewCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath withdata:(NSDictionary *)data
{
    
}

@end
