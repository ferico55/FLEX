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

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section0Cells;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section1Cells;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section2Cells;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section3Cells;
@property (weak, nonatomic) IBOutlet UILabel *labeladdressname;
@property (weak, nonatomic) IBOutlet UILabel *labeladdress;
@property (weak, nonatomic) IBOutlet UILabel *labelemail;
@property (weak, nonatomic) IBOutlet UILabel *faxLabel;
@property (weak, nonatomic) IBOutlet UILabel *labeldistrict;
@property (weak, nonatomic) IBOutlet UILabel *labelcity;
@property (weak, nonatomic) IBOutlet UILabel *labelprovince;
@property (weak, nonatomic) IBOutlet UILabel *labelphonenumber;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section4Cells;

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
    
    _section1Cells = [NSArray sortViewsWithTagInArray:_section1Cells];
    _section3Cells = [NSArray sortViewsWithTagInArray:_section3Cells];
    
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

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    
    _labelphonenumber.text = [address.location_phone isEqualToString:@"0"]?@"-":address.location_phone;
    _faxLabel.text = [address.location_fax isEqualToString:@"0"]?@"-":address.location_fax;
    
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
