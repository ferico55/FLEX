//
//  ResolutionCenterSellerEditViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 7/29/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterSellerEditViewController.h"

@interface ResolutionCenterSellerEditViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *invoiceCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *sellerInfoCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *showAllComplainCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *solutionCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *reasonCell;

@end

@implementation ResolutionCenterSellerEditViewController

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

@end
