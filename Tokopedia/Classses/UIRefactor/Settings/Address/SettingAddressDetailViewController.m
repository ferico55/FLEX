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

#pragma mark - Setting Address Detail View Controller
@interface SettingAddressDetailViewController ()
<
    UIScrollViewDelegate,
    UIAlertViewDelegate,
    SettingAddressEditViewControllerDelegate
>

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
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section0Cells;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section1Cells;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section2Cells;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section3Cells;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section4Cells;

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
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillLayoutSubviews
{
    _scrollView.contentSize = _contentView.frame.size;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
                vc.data = @{kTKPDPROFILE_DATAADDRESSKEY : [_data objectForKey:kTKPDPROFILE_DATAADDRESSKEY],
                            kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY],
                            kTKPDPROFILE_DATAEDITTYPEKEY : @(TYPE_ADD_EDIT_PROFILE_EDIT),
                            kTKPDPROFILE_DATAINDEXPATHKEY : [_data objectForKey:kTKPDPROFILE_DATAINDEXPATHKEY]
                            };
                vc.delegate = self;
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
        self.title = list.receiver_name?:TITLE_DETAIL_ADDRESS_DEFAULT;
        _labelreceivername.text = list.receiver_name?:@"";
        _labeladdressname.text = list.address_name?:@"";

        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 4.0;
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName            : [UIFont fontWithName:@"GothamBook" size:14],
                                     NSParagraphStyleAttributeName  : style,
                                     NSForegroundColorAttributeName : [UIColor colorWithRed:66.0/255.0
                                                                                      green:66.0/255.0
                                                                                       blue:66.0/255.0
                                                                                      alpha:1],
                                     };
        
        _labeladdress.attributedText = [[NSAttributedString alloc] initWithString:[NSString convertHTML:list.address_street] attributes:attributes];
        
        NSString *postalcode = list.postal_code?list.postal_code:@"";
        _labelpostcode.text = postalcode;
        _labelcity.text = list.city_name?:@"";
        _labelprovince.text = list.province_name?:@"";
        _labeldistrict.text = list.district_name?:@"";
        _labelphonenumber.text = list.receiver_phone?:@"";
        BOOL isdefault = [[_data objectForKey:kTKPDPROFILE_DATAISDEFAULTKEY]boolValue];
        _viewdefault.hidden = !isdefault;
        _viewsetasdefault.hidden = isdefault;
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
    switch (indexPath.section) {
        case 0:
            return [_section0Cells[indexPath.row] frame].size.height;
            break;
        case 1:
            return [_section1Cells[indexPath.row] frame].size.height;
            break;
        case 2:
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



#pragma mark - Edit address delegate

- (void)successEditAddress:(AddressFormList *)address
{
    self.labeladdressname.text = address.address_name;
    self.labelreceivername.text = address.receiver_name;

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName            : [UIFont fontWithName:@"GothamBook" size:14],
                                 NSParagraphStyleAttributeName  : style,
                                 NSForegroundColorAttributeName : [UIColor colorWithRed:117.0/255.0
                                                                                  green:117.0/255.0
                                                                                   blue:117.0/255.0
                                                                                  alpha:1],
                                 };
    
    self.labeladdress.attributedText = [[NSAttributedString alloc] initWithString:address.address_street
                                                                       attributes:attributes];
    
    self.labelpostcode.text = address.postal_code;
    self.labelprovince.text = address.province_name;
    self.labelcity.text = address.city_name;
    self.labeldistrict.text = address.district_name;
    self.labelphonenumber.text = address.receiver_phone;
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
