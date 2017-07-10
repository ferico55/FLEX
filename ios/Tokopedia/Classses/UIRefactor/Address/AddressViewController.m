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
#import "RequestAddress.h"

#pragma mark - SettingAddress Location View Controller
@interface AddressViewController () <UITableViewDelegate,UITableViewDataSource, RequestAddressDelegate>
{
    NSInteger _type;
    NSDictionary *_selectedlocation;
    
    BOOL _isnodata;
    
    AddressObj *_addressObj;
    
    RequestAddress *_requestAddress;
    UIBarButtonItem *_doneBarButton;
}
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

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
    _table.tableFooterView = _footer;
    [_act startAnimating];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    _doneBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Pilih"
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(tap:)];
    _doneBarButton.tag = 11;
    _doneBarButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = _doneBarButton;
    
    _type =[[_data objectForKey:kTKPDLOCATION_DATALOCATIONTYPEKEY] integerValue];
    switch (_type) {
        case kTKPDLOCATION_DATATYPEPROVINCEKEY:
        {
            self.title = @"Pilih Provinsi";
            RequestAddress *request =[self requestAddress];
            request.tag = 10;
            [request doRequestProvinces];
             break;
        }
        case kTKPDLOCATION_DATATYPEREGIONKEY:
        {
            self.title = @"Pilih Kota";
            
            NSNumber *provid = [_data objectForKey:kTKPDLOCATION_DATAPROVINCEIDKEY];

            RequestAddress *request =[self requestAddress];
            request.tag = 11;
            request.provinceID = provid;
            [request doRequestCities];
            
            break;
        }
        case kTKPDLOCATION_DATATYPEDISTICTKEY:
        {
            self.title = @"Pilih Kecamatan";
            NSNumber *provid = [_data objectForKey:kTKPDLOCATION_DATAPROVINCEIDKEY];
            NSNumber *cityid = [_data objectForKey:kTKPDLOCATION_DATACITYIDKEY];
            
            RequestAddress *request =[self requestAddress];
            request.tag = 12;
            request.provinceID = provid;
            request.cityID = cityid;
            [request doRequestDistricts];
            
            break;
        }
        default:
            break;
    }

    _selectedlocation = [_data objectForKey:DATA_SELECTED_LOCATION_KEY]?:@{};
}

-(void)successRequestAddress:(RequestAddress *)request withResultObj:(AddressObj *)addressObj
{
    _addressObj = addressObj;
    _table.tableFooterView = nil;
    [_act stopAnimating];
    [_table reloadData];
}

-(void)failedRequestAddress:(NSArray *)errorMessages
{
    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessages delegate:self];
    [alert show];
}


-(RequestAddress*)requestAddress
{
    if (!_requestAddress) {
        _requestAddress = [RequestAddress new];
        _requestAddress.delegate = self;
    }
    
    return _requestAddress;
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
    switch (_type) {
        case kTKPDLOCATION_DATATYPEPROVINCEKEY:
        {
            return _addressObj.data.provinces.count;
            break;
        }
        case kTKPDLOCATION_DATATYPEREGIONKEY:
        {
            return _addressObj.data.cities.count;
            break;
        }
        case kTKPDLOCATION_DATATYPEDISTICTKEY:
        {
            return _addressObj.data.districts.count;
            break;
        }
        default:
            break;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    NSString *cellid = ADDRRESS_CELL_IDENTIFIER;

    cell = (AddressCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [AddressCell newcell];
    }
    
    NSDictionary *dataCell;
    BOOL isHiddenCeckmark;
    switch (_type) {
        case kTKPDLOCATION_DATATYPEPROVINCEKEY:
        {
            AddressProvince *province = _addressObj.data.provinces[indexPath.row];
            dataCell = @{@"name":province.province_name,
                         @"ID" :province.province_id};
            isHiddenCeckmark = ([province.province_id integerValue] == [_selectedlocation[@"ID"] integerValue])?NO:YES;
            break;
        }
        case kTKPDLOCATION_DATATYPEREGIONKEY:
        {
            AddressCity *city = _addressObj.data.cities[indexPath.row];
            dataCell = @{@"name":city.city_name,
                         @"ID" :city.city_id};
            isHiddenCeckmark = ([city.city_id integerValue] == [_selectedlocation[@"ID"] integerValue])?NO:YES;
            break;
        }
        case kTKPDLOCATION_DATATYPEDISTICTKEY:
        {
            AddressDistrict *district = _addressObj.data.districts[indexPath.row];
            dataCell = @{@"name":district.district_name,
                         @"ID" :district.district_id};
            isHiddenCeckmark = ([district.district_id integerValue] == [_selectedlocation[@"ID"] integerValue])?NO:YES;
            break;
        }
        default:
            break;
    }
    ((AddressCell*)cell).data = dataCell;
    ((AddressCell*)cell).imageview.hidden = isHiddenCeckmark;

	
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
    _doneBarButton.enabled = YES;
    AddressCell *cell = (AddressCell*)[tableView cellForRowAtIndexPath:indexPath];
    _selectedlocation = cell.data;
    [_table reloadData];
}

@end
