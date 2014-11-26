//
//  SettingLocationDetailViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "profile.h"
#import "SettingLocations.h"
#import "SettingLocationDetailViewController.h"
#import "SettingLocationEditViewController.h"

#pragma mark - Setting Location Detail View Controller
@interface SettingLocationDetailViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labeladdressname;
@property (weak, nonatomic) IBOutlet UILabel *labeladdress;
@property (weak, nonatomic) IBOutlet UILabel *labelemail;
@property (weak, nonatomic) IBOutlet UILabel *labeldistrict;
@property (weak, nonatomic) IBOutlet UILabel *labelcity;
@property (weak, nonatomic) IBOutlet UILabel *labelprovince;
@property (weak, nonatomic) IBOutlet UILabel *labelphonenumber;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation SettingLocationDetailViewController
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
    
    NSBundle* bundle = [NSBundle mainBundle];
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONBACK ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    }
    else
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
	[barbutton1 setTag:10];
    self.navigationItem.leftBarButtonItem = barbutton1;
    
    barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barbutton1 setTintColor:[UIColor whiteColor]];
    barbutton1.tag = 11;
    self.navigationItem.rightBarButtonItem = barbutton1;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.scrollView.delegate = self;
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.contentView.frame.size.height)];
    
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
            case 10:
            {
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            case 11:
            {   //Edit
                SettingLocationEditViewController *vc = [SettingLocationEditViewController new];
                vc.data = @{kTKPDPROFILE_DATAADDRESSKEY : [_data objectForKey:kTKPDPROFILE_DATAADDRESSKEY],
                            kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY],
                            kTKPDPROFILE_DATAEDITTYPEKEY : @(kTKPDPROFILESETTINGEDIT_DATATYPEEDITVIEWKEY),
                            kTKPDPROFILE_DATAINDEXPATHKEY : [_data objectForKey:kTKPDPROFILE_DATAINDEXPATHKEY]
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
        SettingLocations *list = [_data objectForKey:kTKPDPROFILE_DATAADDRESSKEY];
        
        _labeladdressname.text = list.location_addr_name;
        _labeladdress.text = [NSString stringWithFormat:@"%@\n%@",list.location_address,list.location_area];
        _labelcity.text = list.location_city_name;
        _labeldistrict.text = list.location_district_name;
        _labelphonenumber.text = list.location_phone;
        _labelprovince.text = list.location_province_name;
        NSString *email = [list.location_email isEqualToString:@"0"]?@"-":list.location_email;
        _labelemail.text = email;
    }
}

@end
