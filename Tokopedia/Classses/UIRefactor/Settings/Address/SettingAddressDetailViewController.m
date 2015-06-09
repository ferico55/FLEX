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
    
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    CGRect frame = _contentView.frame;
    frame.size.width = screenWidth;
    _contentView.frame = frame;
    
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
    
    [self.scrollView addSubview:_contentView];
    self.scrollView.delegate = self;
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width,
                                               self.contentView.frame.size.height)];
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
                _viewdefault.hidden = NO;
                _viewsetasdefault.hidden = YES;
                [_delegate DidTapButton:btn withdata:_data];
                break;
            }
            case 11:
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hapus Alamat"
                                                                message:@"Apakah Anda yakin ingin menghapus alamat ini?"
                                                               delegate:self
                                                      cancelButtonTitle:@"Tidak"
                                                      otherButtonTitles:@"Ya", nil];
                [alert show];
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
        
        NSString *postalcode = list.postal_code?[NSString stringWithFormat:@"%zd",list.postal_code]:@"";
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
        //delete address
        [_delegate DidTapButton:_deleteButton withdata:_data];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
