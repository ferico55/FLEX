//
//  CatalogProductViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "CatalogProductViewController.h"
#import "CatalogProductCell.h"
#import "ProductList.h"
#import "NavigateViewController.h"

#import "SearchAWSProduct.h"
#import "detail.h"

@interface CatalogProductViewController () {
    NavigateViewController *_navigator;
}

@end

@implementation CatalogProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _navigator = [NavigateViewController new];
    
    self.title = @"Daftar Produk";

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _product_list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"CatalogProductCell";
    
    CatalogProductCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CatalogProductCell"
                                                                 owner:self
                                                               options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    SearchAWSProduct *product = [_product_list objectAtIndex:indexPath.row];
    cell.productNameLabel.text = product.product_name;
    cell.productPriceLabel.text = product.product_price;
    if([product.condition isEqualToString:@"1"]){
        cell.productConditionLabel.text = @"Baru";
    }else if([product.condition isEqualToString:@"2"]){
        cell.productConditionLabel.text = @"Bekas";
    }    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SearchAWSProduct *product = [_product_list objectAtIndex:[indexPath row]];
    [NavigateViewController navigateToProductFromViewController:self withProduct:product];
}

@end
