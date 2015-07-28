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
@interface AddressViewController () <UITableViewDelegate,UITableViewDataSource>
{
    NSInteger _type;
    NSDictionary *_selectedlocation;
    
    BOOL _isnodata;
    
    NSMutableArray *_listLocation;
}

@property (weak, nonatomic) IBOutlet UITableView *table;

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
    
    _listLocation = [NSMutableArray new];
    
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Pilih"
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(tap:)];
    doneBarButton.tag = 11;
    self.navigationItem.rightBarButtonItem = doneBarButton;
    
    _type =[[_data objectForKey:kTKPDLOCATION_DATALOCATIONTYPEKEY] integerValue];
    switch (_type) {
        case kTKPDLOCATION_DATATYPEPROVINCEKEY:
        {
            NSArray *listLocation = [[DBManager getSharedInstance]LoadDataQueryLocationNameAndID:[NSString stringWithFormat:@"select province_name,province_id from ws_province order by province_name"]];
                                                                                            
            [_listLocation addObjectsFromArray:listLocation];
             break;
        }
        case kTKPDLOCATION_DATATYPEREGIONKEY:
        {
            self.title = @"Pilih Kota";
            NSInteger provid = [[_data objectForKey:kTKPDLOCATION_DATAPROVINCEIDKEY]integerValue];
            
            NSArray *listLocation = [[DBManager getSharedInstance]LoadDataQueryLocationNameAndID:[NSString stringWithFormat:@"select city_name,city_id from ws_city d WHERE province_id = %zd order by city_name",provid]];
            [_listLocation addObjectsFromArray:listLocation];
            
            break;
        }
        case kTKPDLOCATION_DATATYPEDISTICTKEY:
        {
            self.title = @"Pilih Kecamatan";
            NSInteger provid = [[_data objectForKey:kTKPDLOCATION_DATAPROVINCEIDKEY]integerValue];
            NSInteger cityid = [[_data objectForKey:kTKPDLOCATION_DATACITYIDKEY]integerValue];
            
            NSArray *listLocation = [[DBManager getSharedInstance]LoadDataQueryLocationNameAndID:[NSString stringWithFormat:@"select district_name,district_id from ws_district d WHERE province_id = %zd and city_id=%zd order by district_name",provid,cityid]];
            [_listLocation addObjectsFromArray:listLocation];
            
            break;
        }
        default:
            break;
    }
    
    
    _selectedlocation = [_data objectForKey:DATA_SELECTED_LOCATION_KEY]?:@{};
    
    if (_listLocation.count > 0) {
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
                switch (_type) {
                    case kTKPDLOCATION_DATATYPEPROVINCEKEY:
                    {
                        data = @{
                                 kTKPDLOCATION_DATALOCATIONTYPEKEY : @(_type),
                                 DATA_SELECTED_LOCATION_KEY : _selectedlocation
                                 };
                        break;
                    }
                    case kTKPDLOCATION_DATATYPEREGIONKEY:
                    {
                        data = @{
                                 kTKPDLOCATION_DATALOCATIONTYPEKEY : @(_type),
                                 DATA_SELECTED_LOCATION_KEY : _selectedlocation
                                 };
                        break;
                    }
                    case kTKPDLOCATION_DATATYPEDISTICTKEY:
                    {
                        data = @{
                                 kTKPDLOCATION_DATALOCATIONTYPEKEY : @(_type),
                                 DATA_SELECTED_LOCATION_KEY : _selectedlocation
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
    return _listLocation.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    NSString *cellid = ADDRRESS_CELL_IDENTIFIER;

    cell = (AddressCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [AddressCell newcell];
    }
    ((AddressCell*)cell).data = _listLocation[indexPath.row];
    ((AddressCell*)cell).imageview.hidden = !([_listLocation[indexPath.row][@"ID"] integerValue] == [_selectedlocation[@"ID"] integerValue]);
	
	return cell;
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];

}

#pragma mark - Cell Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedlocation = _listLocation [indexPath.row];
    [_table reloadData];
}

@end
