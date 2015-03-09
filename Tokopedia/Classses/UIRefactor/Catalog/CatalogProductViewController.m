//
//  CatalogProductViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "CatalogProductViewController.h"
#import "DetailProductViewController.h"

#import "CatalogProductCell.h"

#import "ProductList.h"

#import "detail.h"

@interface CatalogProductViewController ()

@end

@implementation CatalogProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    ProductList *product = [_product_list objectAtIndex:indexPath.row];
    cell.productNameLabel.text = product.product_name;
    cell.productPriceLabel.text = product.product_price;
    cell.productConditionLabel.text = product.product_condition;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DetailProductViewController *controller = [DetailProductViewController new];
    ProductList *product = [_product_list objectAtIndex:0];
    controller.data = @{kTKPDDETAIL_APIPRODUCTIDKEY:product.product_id};
    [self.navigationController pushViewController:controller animated:YES];

}

@end
