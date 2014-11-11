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

#pragma mark - Setting Address Detail View Controller
@interface SettingAddressDetailViewController ()
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
    
    [self setDefaultData:_data];
    
    UIBarButtonItem *barbutton1;
    barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barbutton1 setTintColor:[UIColor blackColor]];
    barbutton1.tag = 11;
    self.navigationItem.rightBarButtonItem = barbutton1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                            kTKPDPROFILE_DATAEDITTYPEKEY : @(kTKPDPROFILESETTINGEDIT_DATATYPEEDITVIEWKEY)
                            };
                [self.navigationController pushViewController:vc animated:YES];
                break;
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
                _viewdefault.hidden = NO;
                _viewsetasdefault.hidden = YES;
                [_delegate DidTapButton:btn withdata:_data];
                break;
            }
            case 11:
            {
                //delete address
                [_delegate DidTapButton:btn withdata:_data];
                [self.navigationController popViewControllerAnimated:YES];
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
        
        _labelreceivername.text = list.receiver_name?:@"";
        _labeladdressname.text = list.address_name?:@"";
        _labeladdress.text = list.address_street?:@"";
        NSString *postalcode = list.postal_code?[NSString stringWithFormat:@"%d",list.postal_code]:@"";
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

@end
