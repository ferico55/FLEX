//
//  DetailPriceAlertViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 5/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "DetailPriceAlertTableViewCell.h"
#import "DetailPriceAlertViewController.h"
#import "PriceAlertCell.h"
#import "string_price_alert.h"
#define CCellIdentifier @"cell"

@interface DetailPriceAlertViewController ()

@end

@implementation DetailPriceAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = CStringNotificationHarga;
    NSArray *arrPriceAlert = [[NSBundle mainBundle] loadNibNamed:CPriceAlertCell owner:nil options:0];
    PriceAlertCell *priceAlertCell = [arrPriceAlert objectAtIndex:0];
    [self.view addSubview:priceAlertCell.getViewContent];
    
    [priceAlertCell.contentView removeConstraint:priceAlertCell.getConstraintTrailling];
    [priceAlertCell.contentView removeConstraint:priceAlertCell.getConstraintBottom];
    [priceAlertCell.contentView removeConstraint:priceAlertCell.getConstraintX];
    [priceAlertCell.contentView removeConstraint:priceAlertCell.getConstraintY];
    
    //Set Header
    UIView *tempViewContent = priceAlertCell.getViewContent;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[tempViewContent]-10-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(tempViewContent)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[tempViewContent]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(tempViewContent)]];
    [priceAlertCell.getBtnClose removeFromSuperview];
    [priceAlertCell setImageProduct:[UIImage imageNamed:@"icon_toped_loading_grey-01.png"]];
    [priceAlertCell setLblDateProduct:[NSDate date]];
    [priceAlertCell setProductName:@"test ya"];
    [priceAlertCell setPriceNotification:@"12000"];
    [priceAlertCell setLowPrice:@"1234000"];
    constraintYLineHeader.constant = tempViewContent.frame.origin.y + tempViewContent.bounds.size.height + 1;
    constraintHeightTable.constant = self.view.bounds.size.height - viewKondisi.frame.origin.y - (viewLineHeader.frame.origin.y+viewLineHeader.bounds.size.height);

    [self.view bringSubviewToFront:viewLineHeader];
    [self.view bringSubviewToFront:viewKondisi];
    tblDetailPriceAlert.delegate = self;
    tblDetailPriceAlert.dataSource = self;
    [self.view layoutIfNeeded];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
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


#pragma mark - Action View
- (void)actionBuy:(id)sender
{
    
}

- (void)actionShowCondition:(id)sender
{
    if(viewKondisi.tag == 0) {//Show View Category
        [UIView animateWithDuration:.5 animations:^{
            viewKondisi.userInteractionEnabled = NO;
            imgUpDownKondisi.transform = CGAffineTransformMakeRotation(degreeToRadian(180));
            constraintVerticalKondisiAndTable.constant = -50;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished){
            viewKondisi.tag = 1;
            viewKondisi.userInteractionEnabled = YES;
        }];
    }
    else {//Hide View Category
        [UIView animateWithDuration:.5 animations:^{
            viewKondisi.userInteractionEnabled = NO;
            imgUpDownKondisi.transform = CGAffineTransformIdentity;
            constraintVerticalKondisiAndTable.constant = 0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished){
            viewKondisi.tag = 0;
            viewKondisi.userInteractionEnabled = YES;
        }];
    }

}

#pragma mark - UITableView Delegate And DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 225.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailPriceAlertTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CCellIdentifier];
    if(cell == nil) {
        NSArray *arrPriceAlert = [[NSBundle mainBundle] loadNibNamed:CDetailPriceAlertTableViewCell owner:nil options:0];
        cell = [arrPriceAlert objectAtIndex:0];
    }
    
    [cell setImgProduct:[UIImage imageNamed:@"icon_toped_loading_grey-01.png"]];
    [cell setImgPerson:[UIImage imageNamed:@"icon_toped_loading_grey-01.png"]];
    [cell setName:@"Andre"];
    [cell setNameProduct:@"Xiao Mi"];
    [cell setKondisiProduct:@"New"];
    [cell setDateProduct:nil];

    return cell;
}
@end
