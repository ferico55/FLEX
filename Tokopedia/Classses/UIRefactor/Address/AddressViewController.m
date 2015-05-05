//
//  AddressViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "string_address.h"
#import "DBManager.h"
#import "AddressCell.h"
#import "AddressViewController.h"

#pragma mark - SettingAddress Location View Controller
@interface AddressViewController () <AddressCellDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSInteger _type;
    NSMutableDictionary *_selectedlocation;
    
    BOOL _isnodata;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (nonatomic, strong) NSMutableArray *locationnames;
@property (nonatomic, strong) NSMutableArray *locationvalues;

@end

@implementation AddressViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    /** create new **/

    _locationnames = [NSMutableArray new];
    _locationvalues = [NSMutableArray new];
    _selectedlocation = [NSMutableDictionary new];
    
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Pilih"
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(tap:)];
    doneBarButton.tag = 11;
    self.navigationItem.rightBarButtonItem = doneBarButton;
    
    NSArray *name;
    NSArray *value;
    
    _type =[[_data objectForKey:kTKPDLOCATION_DATALOCATIONTYPEKEY] integerValue];
    NSIndexPath *indexpath;
    NSInteger index = 0;
    switch (_type) {
        case kTKPDLOCATION_DATATYPEPROVINCEKEY:
        {
            NSInteger provid = [[_data objectForKey:kTKPDLOCATION_DATAPROVINCEIDKEY]integerValue];
            self.title = @"Pilih Provinsi";
            name = [[DBManager getSharedInstance]LoadDataQueryLocationName:[NSString stringWithFormat:@"select province_name from ws_province order by province_name"]];
            
            value = [[DBManager getSharedInstance]LoadDataQueryLocationValue:[NSString stringWithFormat:@"select province_id from ws_province order by province_name"]];
            [_locationnames addObjectsFromArray:name];
            [_locationvalues addObjectsFromArray:value];
            if (provid!=0) index = [_locationvalues indexOfObject:[NSString stringWithFormat:@"%zd",provid]];
            break;
        }
        case kTKPDLOCATION_DATATYPEREGIONKEY:
        {
            self.title = @"Pilih Kota";
            NSInteger provid = [[_data objectForKey:kTKPDLOCATION_DATAPROVINCEIDKEY]integerValue];
            NSInteger cityid = [[_data objectForKey:kTKPDLOCATION_DATACITYIDKEY]integerValue];
            name = [[DBManager getSharedInstance]LoadDataQueryLocationName:[NSString stringWithFormat:@"select city_name from ws_city d WHERE province_id = %zd order by city_name",provid]];
            
            value = [[DBManager getSharedInstance]LoadDataQueryLocationValue:[NSString stringWithFormat:@"select city_id from ws_city d WHERE province_id = %zd order by city_name",provid]];
            [_locationnames addObjectsFromArray:name];
            [_locationvalues addObjectsFromArray:value];
            if(cityid!=0) index = [_locationvalues indexOfObject:[NSString stringWithFormat:@"%zd",cityid]];
            break;
        }
        case kTKPDLOCATION_DATATYPEDISTICTKEY:
        {
            self.title = @"Pilih Kecamatan";
            NSInteger provid = [[_data objectForKey:kTKPDLOCATION_DATAPROVINCEIDKEY]integerValue];
            NSInteger cityid = [[_data objectForKey:kTKPDLOCATION_DATACITYIDKEY]integerValue];
            NSInteger districtid = [[_data objectForKey:kTKPDLOCATION_DATADISTRICTIDKEY]integerValue];
            name = [[DBManager getSharedInstance]LoadDataQueryLocationName:[NSString stringWithFormat:@"select district_name from ws_district d WHERE province_id = %zd and city_id=%zd order by district_name",provid,cityid]];
            
            value = [[DBManager getSharedInstance]LoadDataQueryLocationValue:[NSString stringWithFormat:@"select district_id from ws_district d WHERE province_id = %zd and city_id=%zd order by district_id",provid,cityid]];
            [_locationnames addObjectsFromArray:name];
            [_locationvalues addObjectsFromArray:value];
            if(districtid!=0) index = [_locationvalues indexOfObject:[NSString stringWithFormat:@"%zd",districtid]];
            break;
        }
        default:
            break;
    }

    indexpath = (index == 0)?[_data objectForKey:kTKPDLOCATION_DATAINDEXPATHKEY]:[NSIndexPath indexPathForRow:index inSection:0];

    [_selectedlocation setObject:indexpath forKey:kTKPDLOCATION_DATAINDEXPATHKEY];

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
                [self.navigationController popViewControllerAnimated:YES];
                //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
                break;
            }
            case 11:
            {
                NSDictionary *data;
                NSIndexPath *indexpath = [_selectedlocation objectForKey:kTKPDLOCATION_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                switch (_type) {
                    case kTKPDLOCATION_DATATYPEPROVINCEKEY:
                    {
                        data = @{kTKPDLOCATION_DATALOCATIONVALUEKEY : _locationvalues[indexpath.row],
                                 kTKPDLOCATION_DATALOCATIONNAMEKEY :  _locationnames[indexpath.row],
                                 kTKPDLOCATION_DATAPROVINCEINDEXPATHKEY:indexpath,
                                 kTKPDLOCATION_DATALOCATIONTYPEKEY : @(_type)
                                 };
                        break;
                    }
                    case kTKPDLOCATION_DATATYPEREGIONKEY:
                    {
                        data = @{kTKPDLOCATION_DATALOCATIONVALUEKEY : _locationvalues[indexpath.row],
                                 kTKPDLOCATION_DATALOCATIONNAMEKEY :  _locationnames[indexpath.row],
                                 kTKPDLOCATION_DATACITYINDEXPATHKEY:indexpath,
                                 kTKPDLOCATION_DATALOCATIONTYPEKEY : @(_type)
                                 };
                        break;
                    }
                    case kTKPDLOCATION_DATATYPEDISTICTKEY:
                    {
                        data = @{kTKPDLOCATION_DATALOCATIONVALUEKEY : _locationvalues[indexpath.row],
                                 kTKPDLOCATION_DATALOCATIONNAMEKEY :  _locationnames[indexpath.row],
                                 kTKPDLOCATION_DATADISTRICTINDEXPATHKEY:indexpath,
                                 kTKPDLOCATION_DATALOCATIONTYPEKEY : @(_type)
                                 };
                        break;
                    }
                    default:
                        break;
                }

                [_delegate SettingAddressLocationView:self withData:data];
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
        NSString *cellid = ADDRRESS_CELL_IDENTIFIER;
		
		cell = (AddressCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [AddressCell newcell];
			((AddressCell*)cell).delegate = self;
		}
        if (indexPath.row != ((NSIndexPath*)[_selectedlocation objectForKey:kTKPDLOCATION_DATAINDEXPATHKEY]).row) {
            ((AddressCell*)cell).imageview.hidden = YES;
        }
        else
            ((AddressCell*)cell).imageview.hidden = NO;
        
        //if (indexPath.row>_locationnames.count) {
            ((AddressCell*)cell).data = @{kTKPDLOCATION_DATAINDEXPATHKEY: indexPath, kTKPDLOCATION_DATALOCATIONNAMEKEY: _locationnames[indexPath.row]};
        //}
        
	} else {
		static NSString *CellIdentifier = kTKPDLOCATION_STANDARDTABLEVIEWCELLIDENTIFIER;
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
        
		cell.textLabel.text = kTKPDLOCATION_NODATACELLTITLE;
		cell.detailTextLabel.text = kTKPDLOCATION_NODATACELLDESCS;
	}
	
	return cell;
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_isnodata) {
		cell.backgroundColor = [UIColor whiteColor];
	}
}

#pragma mark - Cell Delegate
-(void)AddressCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [_selectedlocation setObject:indexpath forKey:kTKPDLOCATION_DATAINDEXPATHKEY];
    [_table reloadData];
}

@end
