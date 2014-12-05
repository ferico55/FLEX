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
#import "Etalase/SettingEtalaseViewController.h"
#import "Shipment/SettingShipmentViewController.h"
#import "ShipmentSettingViewController.h"
#import "Payment/SettingPaymentViewController.h"
#import "Note/SettingNoteViewController.h"
#import "Location/SettingLocationViewController.h"

@interface ShopSettingViewController ()
{
    DetailShopResult *_shop;
}

- (IBAction)gesture:(id)sender;

@end

@implementation ShopSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Pengaturan Toko";
    
    _shop = [_data objectForKey:kTKPDDETAIL_DATAINFOSHOPSKEY];

    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                    SettingEtalaseViewController *vc = [SettingEtalaseViewController new];
                    vc.data = @{kTKPDDETAIL_APISHOPIDKEY : @(_shop.info.shop_id)?:@(0), kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
                }
                case 11:
                {
                    //Product
                    break;
                }
                case 12:
                {
                    //Location
                    SettingLocationViewController *vc = [SettingLocationViewController new];
                    vc.data = @{kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
                }
                case 13:
                {
                    //Shipment
//                    SettingShipmentViewController *vc = [SettingShipmentViewController new];
//                    vc.data = @{kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{},
//                                };
//                    [self.navigationController pushViewController:vc animated:YES];
                    
                    ShipmentSettingViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ShipmentSettingViewController"];
                    vc.data = @{kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{},};
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
                }
                case 14:
                {
                    //Payment
                    SettingPaymentViewController *vc = [SettingPaymentViewController new];
                    vc.data = @{kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
                }
                case 15:
                {
                    //Notes
                    SettingNoteViewController *vc = [SettingNoteViewController new];
                    vc.data = @{kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
                }
                case 16:
                {
                    //Admin
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

@end
