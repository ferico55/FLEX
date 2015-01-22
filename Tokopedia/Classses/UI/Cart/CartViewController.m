//
//  CartViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "cart.h"
#import "CartViewController.h"
#import "ProductAddEditViewController.h"
#import "ProgressBarView.h"

#import "ProductEditWholesaleViewController.h"

#import "MyShopShipmentViewController.h"

@interface CartViewController ()
@property (weak, nonatomic) IBOutlet ProgressBarView *progress;

@end

@implementation CartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"CartViewController" bundle:nibBundleOrNil];
    if (self) {
        self.title = kTKPDCART_TITLE;
        UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
        [self.navigationItem setTitleView:logo];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    _progress.floatcount = .9f;
    
//    NSInteger navigation = [self.navigationController.viewControllers count];
//	if (navigation > 0) {
//		barbutton1 = [[UIBarButtonItem alloc] initWithImage:[[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:@"navigation-chevron" ofType:@"png"]] style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
//		barbutton1.tag = 10;
//		self.navigationItem.leftBarButtonItem = barbutton1;
//	}
}
- (IBAction)addProduct:(id)sender {
    ProductAddEditViewController *vc = [ProductAddEditViewController new];
    vc.data = @{kTKPD_AUTHKEY: [_data objectForKey:kTKPD_AUTHKEY]?:@{}};
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)addWholesale:(id)sender {
    ProductEditWholesaleViewController *vc = [ProductEditWholesaleViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

-(IBAction)tap:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    switch (btn.tag) {
        case 10:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 100:
        {
            //CameraAlbumListViewController *vc = [CameraAlbumListViewController new];
            //[self.navigationController pushViewController:vc animated:YES];
            //break;
        }
        case 200:
        {
            break;
        }
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
