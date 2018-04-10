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
@import NativeNavigation;

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
    _menus = @[@"Informasi", @"Etalase", @"Produk", @"Lokasi", @"Pengiriman", @"Catatan"];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:nil];
    self.navigationItem.backBarButtonItem = backBarButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AnalyticsManager trackScreenName:@"Shop Settings Page"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
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
            [AnalyticsManager trackEventName:@"clickManageShop"
                                    category:GA_EVENT_CATEGORY_MANAGE_SHOP
                                      action:GA_EVENT_ACTION_CLICK
                                       label:@"Shop Info"];
            EditShopViewController *controller = [EditShopViewController new];
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 1:
        {
            UserAuthentificationManager *authenticationManager = [UserAuthentificationManager new];
            [AnalyticsManager trackEventName:@"clickManageShop"
                                    category:GA_EVENT_CATEGORY_MANAGE_SHOP
                                      action:GA_EVENT_ACTION_CLICK
                                       label:@"Etalase"];
            ReactViewController *addProductViewController = [[ReactViewController alloc] initWithModuleName:@"ManageShowcaseScreen"
                                                                                                   props: @{
                                                                                                            @"authInfo": [authenticationManager getUserLoginData],
                                                                                                            @"action": @"manage"
                                                                                                            }];
            addProductViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:addProductViewController animated:YES];
            break;
        }
        case 2:
        {
            //Product
            [AnalyticsManager trackEventName:@"clickManageShop"
                                    category:GA_EVENT_CATEGORY_MANAGE_SHOP
                                      action:GA_EVENT_ACTION_CLICK
                                       label:@"Product"];
            ProductListMyShopViewController *vc = [ProductListMyShopViewController new];
            vc.data = @{kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 3:
        {
            //Location
            [AnalyticsManager trackEventName:@"clickManageShop"
                                    category:GA_EVENT_CATEGORY_MANAGE_SHOP
                                      action:GA_EVENT_ACTION_CLICK
                                       label:@"Location"];
            MyShopAddressViewController *vc = [MyShopAddressViewController new];
            vc.data = @{kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 4:
        {
            [AnalyticsManager trackEventName:@"clickManageShop"
                                    category:GA_EVENT_CATEGORY_MANAGE_SHOP
                                      action:GA_EVENT_ACTION_CLICK
                                       label:@"Shipping"];
            ShipmentViewController *controller = [[ShipmentViewController alloc] initWithShipmentType:ShipmentTypeSettings];
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 5:
        {
            //Notes
            [AnalyticsManager trackEventName:@"clickManageShop"
                                    category:GA_EVENT_CATEGORY_MANAGE_SHOP
                                      action:GA_EVENT_ACTION_CLICK
                                       label:@"Notes"];
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
