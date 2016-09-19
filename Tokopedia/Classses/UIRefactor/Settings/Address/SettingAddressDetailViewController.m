//
//  SettingAddressDetailViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "profile.h"
#import "AddressFormList.h"
#import "SettingAddressDetailViewController.h"
#import "SettingAddressEditViewController.h"
#import "SettingAddressViewController.h"

#import "NavigateViewController.h"
#import "Tokopedia-Swift.h"


#pragma mark - Setting Address Detail View Controller
@interface SettingAddressDetailViewController ()
<
    UITableViewDelegate,
    UIScrollViewDelegate,
    UIAlertViewDelegate,
    SettingAddressEditViewControllerDelegate
>
{
    UIImage *_captureMap;
    AddressFormList *_address;
}

@property (weak, nonatomic) IBOutlet UILabel *labelreceivername;
@property (weak, nonatomic) IBOutlet UILabel *labeladdressname;
@property (weak, nonatomic) IBOutlet UILabel *labeladdress;
@property (weak, nonatomic) IBOutlet UILabel *labelpostcode;
@property (weak, nonatomic) IBOutlet UILabel *labeldistrict;
@property (weak, nonatomic) IBOutlet UILabel *labelcity;
@property (weak, nonatomic) IBOutlet UILabel *labelprovince;
@property (weak, nonatomic) IBOutlet UILabel *labelphonenumber;
@property (weak, nonatomic) IBOutlet UIView *viewdefault;
@property (weak, nonatomic) IBOutlet UIView *viewsetasdefault;
@property (weak, nonatomic) IBOutlet TKPMapView *mapview;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *mapViewHeight;


@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section0Cells;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section1Cells;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section2Cells;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section3Cells;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section4Cells;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SettingAddressDetailViewController
#pragma  mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

#pragma mark - View Action
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedRowHeight = 44;
    
    _section2Cells = [NSArray sortViewsWithTagInArray:_section2Cells];
    [self setDefaultData:_data];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:nil];
    self.navigationItem.backBarButtonItem = backBarButton;

    UIBarButtonItem *editBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(tap:)];
    
    editBarButton.tag = 11;
    self.navigationItem.rightBarButtonItem = editBarButton;
    
    backBarButton.tag = 10;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    _tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, 1)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)mapPosition
{
    _mapview.selectedMarker.position = CLLocationCoordinate2DMake([_address.latitude doubleValue], [_address.longitude doubleValue]);
    _mapview.settings.scrollGestures = NO;
    [_mapview updateIsShowMarker:YES];
    [_mapview updateCameraPosition:_mapview.selectedMarker.position];
    [_mapview showButtonCurrentLocation:NO];
    
    //(latitude = -6.1859237834858769, longitude = 106.799499168992)
    
//    [self performSelector:@selector(setCaptureMap) withObject:nil afterDelay:1.0f];
}

#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem*)sender;
        switch (btn.tag) {
            case 11:
            {   //Edit
                SettingAddressEditViewController *vc = [SettingAddressEditViewController new];
                vc.data = @{kTKPDPROFILE_DATAADDRESSKEY : _address,
                            kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY],
                            kTKPDPROFILE_DATAEDITTYPEKEY : @(TYPE_ADD_EDIT_PROFILE_EDIT),
                            kTKPDPROFILE_DATAINDEXPATHKEY : [_data objectForKey:kTKPDPROFILE_DATAINDEXPATHKEY]
                            };
                vc.delegate = self;
                AddressFormList *address = _address;
                //TODO:: Uncomment for showing map address
                if ([_address.longitude integerValue] != 0 && [address.latitude integerValue] != 0 ) {
                    vc.imageMap = [UIImage imageNamed:@"map_gokil.png"];
                    vc.longitude = address.longitude;
                    vc.latitude = address.latitude;
                }
                //
                
                vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                nav.navigationBar.translucent = NO;
                [self.navigationController presentViewController:nav animated:YES completion:nil];
                break;
            }
            case 12:
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            default:
                break;
        }
    }
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        switch (btn.tag) {
            case 10:
            {
                //set as default
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ganti Alamat Utama"
                                                                    message:@"Apakah Anda yakin ingin menggunakan alamat ini sebagai alamat utama Anda?"
                                                                   delegate:self
                                                          cancelButtonTitle:@"Tidak"
                                                          otherButtonTitles:@"Ya", nil];
                alertView.tag = 1;
                alertView.delegate = self;
                [alertView show];
                break;
            }
            case 11:
            {
                [_delegate DidTapButton:btn withdata:_data];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Methods
-(void)setDefaultData:(NSDictionary*)data
{
    _data = data;
    if (data) {
        AddressFormList *list = [_data objectForKey:kTKPDPROFILE_DATAADDRESSKEY];
        _address = list;
        self.title = list.receiver_name?:TITLE_DETAIL_ADDRESS_DEFAULT;
        _labelreceivername.text = list.receiver_name?:@"";
        _labeladdressname.text = list.address_name?:@"";
        [_labeladdress setCustomAttributedText:[NSString convertHTML:list.address_street]];
        
        NSString *postalcode = list.postal_code?list.postal_code:@"";
        _labelpostcode.text = postalcode;
        _labelcity.text = list.city_name?:@"";
        _labelprovince.text = list.province_name?:@"";
        _labeldistrict.text = list.district_name?:@"";
        _labelphonenumber.text = list.receiver_phone?:@"";
        BOOL isdefault = [[_data objectForKey:kTKPDPROFILE_DATAISDEFAULTKEY]boolValue];
        _viewdefault.hidden = !isdefault;
        _viewsetasdefault.hidden = isdefault;
        
        if (![list.longitude isEqualToString:@""] && ![list.latitude isEqualToString:@""]) {
            [self mapPosition];
        } else {
            _mapViewHeight.constant = 0;
        }
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return _section0Cells.count;
            break;
        case 1:
            return _section1Cells.count;
            break;
        case 2:
            return _section2Cells.count;
            break;
        case 3:
            return _section3Cells.count;
            break;
        case 4:
            return _section4Cells.count;
            break;
        default:
            break;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell= nil;
    switch (indexPath.section) {
        case 0:
            cell = _section0Cells[indexPath.row];
            break;
        case 1:
            cell = _section1Cells[indexPath.row];
            break;
        case 2:
            cell = _section2Cells[indexPath.row];
            break;
        case 3:
            cell = _section3Cells[indexPath.row];
            break;
        case 4:
            cell = _section4Cells[indexPath.row];
            break;
        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

//TODO:: Uncomment for showing map address
- (IBAction)tapMapDetail:(id)sender {
    [NavigateViewController navigateToMap:_mapview.selectedMarker.position type:1 infoAddress:_address.viewModel fromViewController:self];
}
//

#pragma mark - Edit address delegate

- (void)successEditAddress:(AddressFormList *)address
{
//    address = [AddressFormList new];
//    address.address_name = @"Alamat Kantor";
//    address.address_street = @"Wisma 77 Tower 2 Gang Keluarga 37B-1C blbablablablalbab hahahahah hihihihi \nKemanggisan, Palmerah Kebon Jeruk \nJakarta Barat, Indonesia 12345";
//    address.receiver_name = @"Orang Keren";
//    address.receiver_phone = @"0812345678";
//    address.latitude = @"-6.211544";
//    address.longitude = @"106.845172";
    
    self.labeladdressname.text = address.address_name;
    self.labelreceivername.text = address.receiver_name;

    [self.labeladdress setCustomAttributedText:address.address_street];
    
    self.labelpostcode.text = address.postal_code;
    self.labelprovince.text = address.province_name;
    self.labelcity.text = address.city_name;
    self.labeldistrict.text = address.district_name;
    self.labelphonenumber.text = address.receiver_phone;
    
    //TODO:: Uncomment for showing map address
    if (!([address.longitude integerValue] == 0 && [address.latitude integerValue] == 0)) {
            [self performSelector:@selector(mapPosition) withObject:nil afterDelay:0.6f];
    }
    
    
    _address = address;
    [_tableView reloadData];
}


#pragma mark - Alert delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        //default address
        _viewdefault.hidden = NO;
        _viewsetasdefault.hidden = YES;
        [_delegate setDefaultAddressData:_data];
    }
}

@end
