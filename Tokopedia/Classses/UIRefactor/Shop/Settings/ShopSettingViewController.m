//
//  ShopSettingViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/14/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "DetailShopResult.h"
#import "ShopSettingViewController.h"
#import "MyShopEtalaseViewController.h"
#import "MyShopPaymentViewController.h"
#import "MyShopNoteViewController.h"
#import "MyShopAddressViewController.h"
#import "ProductListMyShopViewController.h"
#import "MyShopShipmentTableViewController.h"

@interface ShopSettingViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate
>
{
    DetailShopResult *_shop;
    NSArray *_listMenu;
    BOOL _isnodata;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;

- (IBAction)gesture:(id)sender;

@end

@implementation ShopSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.hidesBottomBarWhenPushed = YES;
    if (self) {
        _isnodata = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBarHidden = NO;
    self.title = @"Pengaturan Toko";
    
    _shop = [_data objectForKey:kTKPDDETAIL_DATAINFOSHOPSKEY];

    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(tap:)];
    
    
    self.navigationItem.backBarButtonItem = barButtonItem;
    
    _listMenu = ARRAY_SHOP_SETTING_MENU;
    _isnodata = NO;
    
    [self.scrollView addSubview:_contentView];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width,
                                             self.view.frame.size.height - 63);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View Action
- (IBAction)gesture:(id)sender {
    UITapGestureRecognizer* gesture = (UITapGestureRecognizer*)sender;
    
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            switch (gesture.view.tag) {
                case 10:
                {
                    //Etalase
                    MyShopEtalaseViewController *vc = [MyShopEtalaseViewController new];
                    vc.data = @{kTKPDDETAIL_APISHOPIDKEY : _shop.info.shop_id?:@"", kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
                }
                case 11:
                {
                    //Product
                    ProductListMyShopViewController *vc = [ProductListMyShopViewController new];
                    vc.data = @{kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
                }
                case 12:
                {
                    //Location
                    MyShopAddressViewController *vc = [MyShopAddressViewController new];
                    vc.data = @{kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
                }
                case 13:
                {
                    MyShopShipmentTableViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MyShopShipmentTableViewController"];
                    [self.navigationController pushViewController:controller animated:YES];
                    break;
                }
                case 14:
                {
                    //Payment
                    MyShopPaymentViewController *vc = [MyShopPaymentViewController new];
                    vc.data = @{kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
                }
                case 15:
                {
                    //Notes
                    MyShopNoteViewController *vc = [MyShopNoteViewController new];
                    vc.data = @{kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

-(IBAction)tap:(id)sender
{
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 10:
            [self.navigationController popViewControllerAnimated:YES];
            break;
            
        default:
            break;
    }
}

#pragma - TableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _listMenu.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = kTKPDDETAIL_STANDARDTABLEVIEWCELLIDENTIFIER;
    UITableViewCell* cell = nil;

    if (!_isnodata) {
        if (indexPath.row<_listMenu.count) {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            cell.textLabel.font = FONT_DEFAULT_CELL_TKPD;
            cell.textLabel.text = _listMenu[indexPath.row];
        }
    }

    return cell;
}

#pragma mark - TableView Delegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
        {
            //Etalase
            MyShopEtalaseViewController *vc = [MyShopEtalaseViewController new];
            vc.data = @{kTKPDDETAIL_APISHOPIDKEY : _shop.info.shop_id?:@"", kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 1:
        {
            //Product
            ProductListMyShopViewController *vc = [ProductListMyShopViewController new];
            vc.data = @{kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 2:
        {
            //Location
            MyShopAddressViewController *vc = [MyShopAddressViewController new];
            vc.data = @{kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 3:
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MyShopShipmentTableViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"MyShopShipmentTableViewController"];
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 4:
        {
            //Payment
            MyShopPaymentViewController *vc = [MyShopPaymentViewController new];
            vc.data = @{kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 5:
        {
            //Notes
            MyShopNoteViewController *vc = [MyShopNoteViewController new];
            vc.data = @{kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        default:
            break;
    }
}

@end
