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
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actDelete;


@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section0Cells;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section1Cells;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section2Cells;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section3Cells;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section4Cells;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

typedef void (^SuccessSetDefaultAddress)(AddressFormList* address);
@property (copy, nonatomic) SuccessSetDefaultAddress successSetDefaultAddress;

typedef void (^SuccessDeleteAddress)(AddressFormList* address);
@property (copy, nonatomic) SuccessDeleteAddress successDeleteAddress;

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
    
    [self setAddress:_address];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:nil];
    self.navigationItem.backBarButtonItem = backBarButton;

    UIBarButtonItem *editBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(tapEditAddress:)];
    
    editBarButton.tag = 11;
    self.navigationItem.rightBarButtonItem = editBarButton;
    
    backBarButton.tag = 10;
    
    [self setDetailAddress:_address];

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
}

#pragma mark - View Action
-(void)tapEditAddress:(UIBarButtonItem*)sender{
    SettingAddressEditViewController *vc = [SettingAddressEditViewController new];
    vc.data = @{kTKPDPROFILE_DATAADDRESSKEY : _address,
                kTKPDPROFILE_DATAEDITTYPEKEY : @(TYPE_ADD_EDIT_PROFILE_EDIT),
                };
    vc.delegate = self;
    AddressFormList *address = _address;
    if ([_address.longitude integerValue] != 0 && [address.latitude integerValue] != 0 ) {
        vc.imageMap = [UIImage imageNamed:@"map_gokil.png"];
        vc.longitude = address.longitude;
        vc.latitude = address.latitude;
    }
    
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBar.translucent = NO;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (IBAction)tapSetDefaultAddress:(UIButton*)sender {
    
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Ganti Alamat Utama"
                                  message:@"Apakah Anda yakin ingin menggunakan alamat ini sebagai alamat utama Anda?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) wself = self;
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Ya"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [wself requestSetDefaultAddress:_address button:(UIButton*)sender];
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Tidak"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];

}

- (IBAction)tapDeleteAddress:(UIButton*)sender {
    
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Hapus Alamat ini?"
                                  message:@""
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) wself = self;
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Hapus"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [wself requestDeleteAddress:_address button:sender];
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Batal"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)requestSetDefaultAddress:(AddressFormList*)address button:(UIButton*)sender{
    
    sender.enabled = NO;
    
    _act.hidden = NO;
    [_act startAnimating];
    _viewdefault.hidden = YES;
    _viewsetasdefault.hidden = YES;
    
    [AddressRequest fetchSetDefaultAddressID:address.address_id onSuccess:^(ProfileSettingsResult * data) {
        
        _viewdefault.hidden = NO;
        _viewsetasdefault.hidden = YES;
        sender.enabled = YES;
        
        if( self.successSetDefaultAddress ){
            self.successSetDefaultAddress(address);
        }
        
    } onFailure:^{
        
        _viewdefault.hidden = YES;
        _viewsetasdefault.hidden = NO;
        sender.enabled = YES;
        [_act stopAnimating];
        
    }];
}

-(void)requestDeleteAddress:(AddressFormList*)address button:(UIButton*)sender{
    
    sender.enabled = NO;
    
    _actDelete.hidden = NO;
    [_actDelete startAnimating];
    
    [AddressRequest fetchDeleteAddressID:address.address_id onSuccess:^(ProfileSettingsResult * data) {
        
        sender.enabled = YES;
        [_actDelete stopAnimating];
        if (self.successDeleteAddress){
            self.successDeleteAddress(address);
        }
        [self.navigationController popViewControllerAnimated:YES];
        
    } onFailure:^{
        
        sender.enabled = YES;
        [_actDelete stopAnimating];

    }];
}


#pragma mark - Methods
-(void)setDetailAddress:(AddressFormList*)address
{
    if (address) {
        self.title = address.receiver_name?:TITLE_DETAIL_ADDRESS_DEFAULT;
        _labelreceivername.text = address.receiver_name?:@"";
        _labeladdressname.text = address.address_name?:@"";
        [_labeladdress setCustomAttributedText:[NSString convertHTML:address.address_street]];
        
        NSString *postalcode = address.postal_code?address.postal_code:@"";
        _labelpostcode.text = postalcode;
        _labelcity.text = address.city_name?:@"";
        _labelprovince.text = address.province_name?:@"";
        _labeldistrict.text = address.district_name?:@"";
        _labelphonenumber.text = address.receiver_phone?:@"";
        _viewdefault.hidden = !address.isDefaultAddress;
        _viewsetasdefault.hidden = address.isDefaultAddress;
        
        if (![address.longitude isEqualToString:@""] && ![address.latitude isEqualToString:@""]) {
            [self mapPosition];
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddressFormList *address = _address;

    if (indexPath.section == 2 && indexPath.row == 1) {
        if (([address.longitude isEqualToString:@""] || !address.longitude) && ([address.latitude isEqualToString:@""] || !address.latitude)) {
            return 0;
        } else {
            return 194;
        }
    }
    return UITableViewAutomaticDimension;
}

- (IBAction)tapMapDetail:(id)sender {
    [NavigateViewController navigateToMap:_mapview.selectedMarker.position type:1 infoAddress:_address.viewModel fromViewController:self];
}

#pragma mark - Edit address delegate

- (void)successEditAddress:(AddressFormList *)address
{
    
    self.labeladdressname.text = address.address_name;
    self.labelreceivername.text = address.receiver_name;

    [self.labeladdress setCustomAttributedText:address.address_street];
    
    self.labelpostcode.text = address.postal_code;
    self.labelprovince.text = address.province_name;
    self.labelcity.text = address.city_name;
    self.labeldistrict.text = address.district_name;
    self.labelphonenumber.text = address.receiver_phone;
    
    if (!([address.longitude integerValue] == 0 && [address.latitude integerValue] == 0)) {
            [self performSelector:@selector(mapPosition) withObject:nil afterDelay:0.6f];
    }
    
    _address = address;
    [_tableView reloadData];
}

-(void)getSuccessSetDefaultAddress:(void (^)(AddressFormList *))onSuccess{
    _successSetDefaultAddress = onSuccess;
}

-(void)getSuccessDeleteAddress:(void (^)(AddressFormList *))onSuccess{
    _successDeleteAddress = onSuccess;
}

@end
