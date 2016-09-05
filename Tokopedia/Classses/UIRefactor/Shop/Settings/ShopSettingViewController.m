//
//  ShopSettingViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/14/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "DetailShopResult.h"
#import "ShopSettingViewController.h"
#import "EtalaseViewController.h"
#import "ProductListMyShopViewController.h"
#import "MyShopAddressViewController.h"
#import "ShipmentViewController.h"
#import "MyShopNoteViewController.h"
#import "EditShopViewController.h"
#import "ShopPaymentViewController.h"

@interface ShopSettingViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate
>
{
    NSArray *_menus;
    DetailShopResult *_shop;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ShopSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Pengaturan Toko";
    _shop = [_data objectForKey:kTKPDDETAIL_DATAINFOSHOPSKEY];
    _menus = @[@"Atur Toko", @"Etalase", @"Produk", @"Lokasi", @"Pengiriman", @"Pembayaran", @"Catatan"];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:nil];
    self.navigationItem.backBarButtonItem = backBarButton;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.font = [UIFont title2Theme];
    cell.textLabel.text = [_menus objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0 : {
            EditShopViewController *controller = [EditShopViewController new];
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 1:
        {
            EtalaseViewController *vc = [EtalaseViewController new];
            vc.isEditable = YES;
            vc.showOtherEtalase = NO;
            [vc setEnableAddEtalase:YES];
            vc.hidesBottomBarWhenPushed = YES;
            
            UserAuthentificationManager *_userAuth = [UserAuthentificationManager new];
            NSString *shopId = [_userAuth getShopId];
            [vc setShopId:shopId];
            
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
            UIColor *backgroundColor = [UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1];
            nav.navigationBar.backgroundColor = [UIColor colorWithCGColor:backgroundColor.CGColor];
            nav.navigationBar.translucent = NO;
            nav.navigationBar.tintColor = [UIColor whiteColor];
            [self.navigationController pushViewController:vc animated:YES];

            break;
        }
        case 2:
        {
            //Product
            ProductListMyShopViewController *vc = [ProductListMyShopViewController new];
            vc.data = @{kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 3:
        {
            //Location
            MyShopAddressViewController *vc = [MyShopAddressViewController new];
            vc.data = @{kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 4:
        {
            ShipmentViewController *controller = [[ShipmentViewController alloc] initWithShipmentType:ShipmentTypeSettings];
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 5:
        {
            //Payment
            ShopPaymentViewController *controller = [ShopPaymentViewController new];
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 6:
        {
            //Notes
            DetailShopResult *shop = [_data objectForKey:kTKPDDETAIL_DATAINFOSHOPSKEY];

            MyShopNoteViewController *vc = [MyShopNoteViewController new];
            vc.data = @{kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY]?:@{},
                        kTKPD_SHOPIDKEY : shop.info.shop_id};
            
            [self.navigationController pushViewController:vc animated:YES];
            
            break;
        }
        default:
            break;
    }
}

@end