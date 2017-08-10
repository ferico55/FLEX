//
//  FilterConditionViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/2/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "sortfiltershare.h"
#import "search.h"

#import "FilterConditionCell.h"
#import "FilterConditionViewController.h"

#pragma mark - Filter Condition View Controller

@interface FilterConditionViewController () <FilterConditionCellDelegate,UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (nonatomic, strong) NSMutableArray *conditions;

@end

@implementation FilterConditionViewController{
    NSInteger _page;
    NSInteger _limit;
    
    NSInteger _viewposition;
    
    //NSMutableArray *_hotlist;
    NSMutableDictionary *_paging;
    
    NSMutableDictionary *_selectedcondition;
    
    /** url to the next page **/
    NSString *_urinext;
    
    BOOL _isnodata;
}

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = kTKPDFILTER_TITLEFILTERCONDITIONKEY;
        
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
    _conditions = [NSMutableArray new];
    _selectedcondition = [NSMutableDictionary new];
    
    UIBarButtonItem *barbutton1;
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(tap:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 10;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Selesai"
                                                  style:UIBarButtonItemStyleDone
                                                 target:(self)
                                                 action:@selector(tap:)];
	[barbutton1 setTag:11];
    self.navigationItem.rightBarButtonItem = barbutton1;
    
    _table.delegate = self;
    _table.dataSource = self;
    
    /** Set isnull value (title and icon for category) **/
    
    [_conditions addObjectsFromArray:kTKPDSORT_CONDITIONSARRAY];
    
    NSIndexPath *indexpath = [_data objectForKey:kTKPDFILTER_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    [_selectedcondition setObject:indexpath forKey:kTKPDFILTER_DATAINDEXPATHKEY];
    
    if (_conditions.count > 0) {
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
                [self.navigationController popToRootViewControllerAnimated:YES];
                //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
                break;
            }
            case 11:
            {
                NSIndexPath *indexpath = [_selectedcondition objectForKey:kTKPDFILTER_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                NSDictionary *data = @{kTKPDFILTER_DATACONDITIONKEY : _conditions[indexpath.row],
                                       kTKPDFILTERCONDITION_DATAINDEXPATHKEY: indexpath};
                [_delegate FilterConditionViewController:self withdata:data];
                [self.navigationController popToRootViewControllerAnimated:YES];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef kTKPDFILTER_NODATAENABLE
    return _isnodata ? 1 : _condition.count;
#else
    return _isnodata ? 0 : _conditions.count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        NSString *cellid = kTKPDFILTERCONDITIONCELL_IDENTIFIER;
		
		cell = (FilterConditionCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [FilterConditionCell newcell];
			((FilterConditionCell*)cell).delegate = self;
		}
        if (indexPath.row != ((NSIndexPath*)[_selectedcondition objectForKey:kTKPDFILTER_DATAINDEXPATHKEY]).row) {
            ((FilterConditionCell*)cell).imageview.hidden = YES;
        }
        else
            ((FilterConditionCell*)cell).imageview.hidden = NO;
        
        //if (indexPath.row>_locationnames.count) {
        ((FilterConditionCell*)cell).data = @{kTKPDSEARCH_DATAINDEXPATHKEY: indexPath, kTKPDSEARCH_DATACOLUMNSKEY: _conditions[indexPath.row]};
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
-(void)FilterConditionCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [_selectedcondition setObject:indexpath forKey:kTKPDFILTER_DATAINDEXPATHKEY];
    [_table reloadData];
}


@end
