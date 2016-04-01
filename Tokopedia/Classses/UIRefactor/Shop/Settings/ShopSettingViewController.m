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
#import "MyShopEtalaseViewController.h"
#import "ProductListMyShopViewController.h"
#import "MyShopAddressViewController.h"
#import "MyShopPaymentViewController.h"
#import "MyShopShipmentTableViewController.h"
#import "MyShopNoteViewController.h"
#import "EditShopViewController.h"

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
                                                                      style:UIBarButtonItemStyleBordered
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
    cell.textLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
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
//            ShopEditViewController *vc = [ShopEditViewController new];
//            vc.data = @{
//                        kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY]?:@{},
//                        kTKPDDETAIL_DATASHOPSKEY : _shop?:@{}
//                        };
//            [self.navigationController pushViewController:vc animated:YES];
//
//            break;
        }
        case 1:
        {
            //Etalase
            MyShopEtalaseViewController *vc = [MyShopEtalaseViewController new];
            vc.data = @{kTKPDDETAIL_APISHOPIDKEY : _shop.info.shop_id?:@"", kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
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
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MyShopShipmentTableViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"MyShopShipmentTableViewController"];
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 5:
        {
            //Payment
            MyShopPaymentViewController *vc = [MyShopPaymentViewController new];
            vc.data = @{kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
            [self.navigationController pushViewController:vc animated:YES];
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