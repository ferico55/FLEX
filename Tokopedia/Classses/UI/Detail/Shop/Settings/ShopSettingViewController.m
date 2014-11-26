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
    
    _shop = [_data objectForKey:kTKPDDETAIL_DATAINFOSHOPSKEY];
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
                    vc.data = @{kTKPDDETAIL_APISHOPIDKEY : @(_shop.info.shop_id), kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]};
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
                    vc.data = @{kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]};
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
                }
                case 13:
                {
                    //Shipment
                    SettingShipmentViewController *vc = [SettingShipmentViewController new];
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
                }
                case 14:
                {
                    //Payment
                    SettingPaymentViewController *vc = [SettingPaymentViewController new];
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
                }
                case 15:
                {
                    //Notes
                    SettingNoteViewController *vc = [SettingNoteViewController new];
                    vc.data = @{kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]};
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
@end
