//
//  MyShopAddressDetailViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "Address.h"
#import "MyShopAddressDetailViewController.h"
#import "MyShopAddressEditViewController.h"

#pragma mark - Setting Location Detail View Controller
@interface MyShopAddressDetailViewController () <UIScrollViewDelegate, ShopAddressEditViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *labeladdressname;
@property (weak, nonatomic) IBOutlet UILabel *labeladdress;
@property (weak, nonatomic) IBOutlet UILabel *labelemail;
@property (weak, nonatomic) IBOutlet UILabel *faxLabel;
@property (weak, nonatomic) IBOutlet UILabel *labeldistrict;
@property (weak, nonatomic) IBOutlet UILabel *labelcity;
@property (weak, nonatomic) IBOutlet UILabel *labelprovince;
@property (weak, nonatomic) IBOutlet UILabel *labelphonenumber;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation MyShopAddressDetailViewController
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
    
    Address *list = [_data objectForKey:kTKPDDETAIL_DATAADDRESSKEY];
    self.title = list.location_address_name;
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(tap:)];
    self.navigationItem.backBarButtonItem = barButtonItem;
    
    UIBarButtonItem *barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Ubah"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:(self)
                                                                  action:@selector(tap:)];
    barbutton1.tag = 11;
    self.navigationItem.rightBarButtonItem = barbutton1;

    [self.scrollView addSubview:_contentView];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _scrollView.contentSize = _contentView.frame.size;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.scrollView.delegate = self;
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width,
                                               self.contentView.frame.size.height)];
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
                MyShopAddressEditViewController *vc = [MyShopAddressEditViewController new];
                vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                vc.data = @{kTKPDDETAIL_DATAADDRESSKEY : [_data objectForKey:kTKPDDETAIL_DATAADDRESSKEY],
                            kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY],
                            kTKPDDETAIL_DATATYPEKEY : @(kTKPDSETTINGEDIT_DATATYPEEDITVIEWKEY),
                            kTKPDDETAIL_DATAINDEXPATHKEY : [_data objectForKey:kTKPDDETAIL_DATAINDEXPATHKEY]
                            };
                vc.delegate = self;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                nav.navigationBar.translucent = NO;
                
                [self.navigationController presentViewController:nav animated:YES completion:nil];
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
-(void)setDefaultData:(NSMutableDictionary *)data
{
    _data = data;
    if (data) {
        Address *list = [_data objectForKey:kTKPDDETAIL_DATAADDRESSKEY];
        [self setAddress:list];
    }
}

#pragma mark - Edit address delegate

-(void)successEditAddress:(Address *)address
{
    [self.data setObject:address forKey:kTKPDDETAIL_DATAADDRESSKEY];
    [self setAddress:address];
}

-(void)setAddress:(Address *)address
{
    _labeladdressname.text = address.location_address_name;
    
    _labelcity.text = address.location_city_name;
    _labeldistrict.text = address.location_district_name;
    _labelprovince.text = address.location_province_name;

    NSString *email = [address.location_email isEqualToString:@"0"]?@"-":address.location_email;
    _labelemail.text = email;
    
    _labelphonenumber.text = address.location_phone?:@"-";
    _faxLabel.text = address.location_fax;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName            : _labeladdress.font,
                                 NSParagraphStyleAttributeName  : style,
                                 NSForegroundColorAttributeName : _labeladdress.textColor,
                                 };
    
    NSString *addressString = [NSString stringWithFormat:@"%@\n%@",
                         [NSString convertHTML:address.location_address], address.location_area];
    
    _labeladdress.attributedText = [[NSAttributedString alloc] initWithString:addressString attributes:attributes];
}

@end
