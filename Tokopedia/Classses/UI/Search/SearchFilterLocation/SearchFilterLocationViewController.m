//
//  SearchFilterLocationViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "search.h"
#import "DBManager.h"
#import "SearchFilterLocationViewCell.h"
#import "SearchFilterLocationViewController.h"

@interface SearchFilterLocationViewController () <SearchFilterLocationViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (nonatomic, strong) NSMutableArray *locationnames;
@property (nonatomic, strong) NSMutableArray *locationvalues;

@end

@implementation SearchFilterLocationViewController{
    NSInteger _page;
    NSInteger _limit;
    
    NSInteger _viewposition;
    
    //NSMutableArray *_hotlist;
    NSMutableDictionary *_paging;
    
    /** url to the next page **/
    NSString *_urinext;
    
    BOOL _isnodata;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    /** create new **/
    _paging = [NSMutableDictionary new];
    _locationnames = [NSMutableArray new];
    _locationvalues = [NSMutableArray new];
    
    UIBarButtonItem *barbutton1;
    NSBundle* bundle = [NSBundle mainBundle];
    //TODO:: Change image
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONNOTIFICATION ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    }
    else
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
	[barbutton1 setTag:10];
    self.navigationItem.leftBarButtonItem = barbutton1;
    
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
    
    /** Set isnull value (title and icon for category) **/

    NSArray *name = [[DBManager getSharedInstance]LoadDataQueryLocationName:[NSString stringWithFormat:@"select d.district_name from ws_district d WHERE d.district_id IN (select distinct d.district_id from ws_shipping_city sc LEFT JOIN ws_district d ON sc.district_id = d.district_id order by d.district_name) order by d.district_name"]];
    
    NSArray *value = [[DBManager getSharedInstance]LoadDataQueryLocationValue:[NSString stringWithFormat:@"select distinct sc.district_id from ws_shipping_city sc, ws_district d where sc.district_id = d.district_id order by d.district_name"]];
    
    [_locationnames addObjectsFromArray:name];
    [_locationvalues addObjectsFromArray:value];
    
    if (_locationnames.count > 0) {
        _isnodata = NO;
    }
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
            default:
                break;
        }
    }
}

#pragma mark - Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef kTKPDmenuLISTHOTLIST_NODATAENABLE
    return _isnodata ? 1 : _locationnames.count;
#else
    return _isnodata ? 0 : _locationnames.count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        NSString *cellid = kTKPDSEARCHFILTERLOCATIONVIEWCELL_IDENTIFIER;
		
		cell = (SearchFilterLocationViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [SearchFilterLocationViewCell newcell];
			((SearchFilterLocationViewCell*)cell).delegate = self;
		}
        
        ((SearchFilterLocationViewCell*)cell).data = @{kTKPDSEARCH_DATAINDEXPATHKEY: indexPath, kTKPDSEARCH_DATACOLUMNSKEY: _locationnames[indexPath.row]};
        
	} else {
		static NSString *CellIdentifier = kTKPDSEARCH_STANDARDTABLEVIEWCELLIDENTIFIER;
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
        
		cell.textLabel.text = kTKPDSEARCH_NODATACELLTITLE;
		cell.detailTextLabel.text = kTKPDSEARCH_NODATACELLDESCS;
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
-(void)SearchFilterLocationViewCell:(UITableViewCell *)cell withdata:(NSDictionary *)data
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
