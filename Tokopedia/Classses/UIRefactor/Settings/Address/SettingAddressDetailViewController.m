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
#import "PlacePickerViewController.h"

#import "NavigateViewController.h"

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
    GMSMarker *_marker;
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
@property (weak, nonatomic) IBOutlet GMSMapView *mapview;


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
    
    _section2Cells = [NSArray sortViewsWithTagInArray:_section2Cells];
    [self setDefaultData:_data];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(tap:)];
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
    AddressFormList *list = _address;

    _marker.position = CLLocationCoordinate2DMake([list.latitude doubleValue], [list.longitude doubleValue]);
    _marker.map = _mapview;
    _marker.infoWindowAnchor = CGPointMake(0.44f, 0.45f);
    
    _mapview.selectedMarker = _marker;
    _mapview.mapType = kGMSTypeNormal;
    
    [PlacePickerViewController focusMap:_mapview toMarker:_marker];
    
    [self performSelector:@selector(setCaptureMap) withObject:nil afterDelay:1.0f];
}

-(void)setCaptureMap
{
    _captureMap = [PlacePickerViewController captureScreen:_mapview];

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
                if (![address.longitude isEqualToString:@""] && ![address.latitude isEqualToString:@""]) {
                    vc.imageMap = _captureMap?:[PlacePickerViewController captureScreen:_mapview];
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

- (IBAction)tapMap:(id)sender {

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
        
        //TODO:: Uncomment for showing map address
        if (![list.longitude isEqualToString:@""] && ![list.latitude isEqualToString:@""]) {
            _marker = [[GMSMarker alloc] init];
            [self mapPosition];
        }
        //
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

    switch (indexPath.section) {
        case 0:
            return [_section0Cells[indexPath.row] frame].size.height;
            break;
        case 1:
            return [_section1Cells[indexPath.row] frame].size.height;
            break;
        case 2:
            if (indexPath.row == 1) {
                //TODO:: Uncomment for showing map address
                if (([address.longitude isEqualToString:@""] || !address.longitude) && ([address.latitude isEqualToString:@""] || !address.latitude)) {
                    return 0;
                }
                //
            }
            if (indexPath.row == 2) {
                NSString *string = address.address_street;
                
                //Calculate the expected size based on the font and linebreak mode of your label
                CGSize maximumLabelSize = CGSizeMake(190,9999);
                CGSize expectedLabelSize = [string sizeWithFont:FONT_GOTHAM_BOOK_16
                                              constrainedToSize:maximumLabelSize
                                                  lineBreakMode:NSLineBreakByTruncatingTail];
                return 40+expectedLabelSize.height;
            }
            return [_section2Cells[indexPath.row] frame].size.height;
            break;
        case 3:
            return [_section3Cells[indexPath.row] frame].size.height;
            break;
        case 4:
            return [_section4Cells[indexPath.row] frame].size.height;
            break;
        default:
            break;
    }
    return 0;
}

//TODO:: Uncomment for showing map address
- (IBAction)tapMapDetail:(id)sender {
    AddressFormList *list = _address;
    [NavigateViewController navigateToMap:CLLocationCoordinate2DMake([list.latitude doubleValue], [list.longitude doubleValue]) FromViewController:self];
}
//

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
    
    //TODO:: Uncomment for showing map address
    if (![address.longitude isEqualToString:@""] && ![address.latitude isEqualToString:@""]) {
        [self mapPosition];
    }
    //
    _address = address;
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
