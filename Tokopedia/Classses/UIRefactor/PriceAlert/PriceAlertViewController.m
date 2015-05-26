//
//  PriceAlertViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 5/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "PriceAlertViewController.h"
#import "string_price_alert.h"

@interface PriceAlertViewController ()

@end

@implementation PriceAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Setup View
- (void)initNavigation
{
    self.navigationController.title = CStringNotificationHarga;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Tambah" style:UIBarButtonItemStylePlain target:self action:@selector(actionTambah:)];
}


#pragma mark - Method
- (void)actionTambah:(id)sender
{
    
}
@end
