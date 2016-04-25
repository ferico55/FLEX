//
//  FilterLocationViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "CatalogLocation.h"

#import "sortfiltershare.h"
#import "search.h"
#import "DBManager.h"
#import "FilterLocationViewCell.h"
#import "FilterLocationViewController.h"

#import "District.h"

#pragma mark - Filter Location View Controller
@interface FilterLocationViewController () <FilterLocationViewCellDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (nonatomic, strong) NSMutableArray *locationnames;
@property (nonatomic, strong) NSMutableArray *locationvalues;

@end

@implementation FilterLocationViewController{
    
    NSInteger _type;
    
    NSInteger _viewposition;
    
    //NSMutableArray *_hotlist;
    NSMutableDictionary *_paging;
    
    NSMutableDictionary *_selectedlocation;
    
    /** url to the next page **/
    NSString *_urinext;
    
    BOOL _isnodata;
}

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = kTKPDFILTER_TITLEFILTERLOCATIONKEY;

    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    /** create new **/
    _paging = [NSMutableDictionary new];
    _locationnames = [NSMutableArray new];
    _locationvalues = [NSMutableArray new];
    _selectedlocation = [NSMutableDictionary new];
    
    UIBarButtonItem *barbutton1;
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(tap:)];
//    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
//    barButtonItem.tag = 10;
//    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Selesai"
                                                  style:UIBarButtonItemStyleDone
                                                 target:(self)
                                                 action:@selector(tap:)];
	[barbutton1 setTag:11];
    self.navigationItem.rightBarButtonItem = barbutton1;
    
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
    
    _type = [[_data objectForKey:kTKPDFILTER_APITYPEKEY]integerValue];
    NSInteger index = 0;
    switch (_type) {
        case kTKPDFILTER_DATATYPESHOPSHIPPINGPROVINCYKEY:
        {
            NSArray *districts = [_data objectForKey:kTKPDFILTERLOCATION_DATALOCATIONARRAYKEY];
            for (int i=0; i<districts.count; i++) {
                District *district = districts[i];
                [_locationnames addObject:district.district_name];
                [_locationvalues addObject:@(district.district_id)];
            }
            NSInteger districtid = [[_data objectForKey:kTKPDFILTER_APISELECTEDDISTRICTIDKEY]integerValue];
            if (districtid!=0) index = [_locationvalues indexOfObject:@(districtid)];
            break;
        }
        default:
        {
            /** Set isnull value (title and icon for category) **/
            [_locationvalues addObject:@""];
            [_locationnames addObject:@"All Location"];
            
            NSArray *locations =[_data objectForKey:kTKPDFILTERLOCATION_DATALOCATIONARRAYKEY]?:@[];
            if (locations.count>0) {
                for (int i = 0; i<locations.count; i++) {
                    CatalogLocation *location = locations[i];
                    [_locationnames addObject:location.location_name];
                    [_locationvalues addObject:location.location_id];
                }
            }
            else{
                NSArray *name = [[DBManager getSharedInstance]LoadDataQueryLocationName:[NSString stringWithFormat:@"select d.district_name from ws_district d WHERE d.district_id IN (select distinct d.district_id from ws_shipping_city sc LEFT JOIN ws_district d ON sc.district_id = d.district_id order by d.district_name) order by d.district_name"]];
                
                NSArray *value = [[DBManager getSharedInstance]LoadDataQueryLocationValue:[NSString stringWithFormat:@"select distinct sc.district_id from ws_shipping_city sc, ws_district d where sc.district_id = d.district_id order by d.district_name"]];
                
                [_locationnames addObjectsFromArray:@[@"Jabodetabek"]];
                [_locationvalues addObjectsFromArray:@[@"2210,2228,5573,1940,1640,2197"]];
                [_locationnames addObjectsFromArray:name];
                [_locationvalues addObjectsFromArray:value];
            }
            break;
        }
    }
    
    if (_locationnames.count > 0) {
        _isnodata = NO;
    }
    NSIndexPath *indexpath = (index == 0)?[_data objectForKey:kTKPDFILTER_DATAINDEXPATHKEY]:[NSIndexPath indexPathForRow:index inSection:0];
    //NSIndexPath *indexpath = [_data objectForKey:kTKPDFILTER_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    [_selectedlocation setObject:indexpath forKey:kTKPDFILTER_DATAINDEXPATHKEY];
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
                [self.navigationController popViewControllerAnimated:YES];
                //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
                break;
            }
            case 11:
            {
                NSIndexPath *indexpath = [_selectedlocation objectForKey:kTKPDFILTER_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                NSDictionary *data = @{kTKPDFILTER_APILOCATIONKEY : _locationvalues[indexpath.row]?:@(0),
                                       kTKPDFILTER_APILOCATIONNAMEKEY :  _locationnames[indexpath.row]?:@"none",
                                       kTKPDFILTERLOCATION_DATAINDEXPATHKEY:indexpath
                                       };
                [_delegate FilterLocationViewController:self withdata:data];
                [self.navigationController popViewControllerAnimated:YES];
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
        NSString *cellid = kTKPDFILTERLOCATIONVIEWCELL_IDENTIFIER;
		
		cell = (FilterLocationViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [FilterLocationViewCell newcell];
			((FilterLocationViewCell*)cell).delegate = self;
		}
        if (indexPath.row != ((NSIndexPath*)[_selectedlocation objectForKey:kTKPDFILTER_DATAINDEXPATHKEY]).row) {
            ((FilterLocationViewCell*)cell).imageview.hidden = YES;
        }
        else
            ((FilterLocationViewCell*)cell).imageview.hidden = NO;
        
        //if (indexPath.row>_locationnames.count) {
            ((FilterLocationViewCell*)cell).data = @{kTKPDSEARCH_DATAINDEXPATHKEY: indexPath, kTKPDSEARCH_DATACOLUMNSKEY: _locationnames[indexPath.row]};
        //}
        
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
-(void)FilterLocationViewCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [_selectedlocation setObject:indexpath forKey:kTKPDFILTER_DATAINDEXPATHKEY];
    [_table reloadData];
}

@end
