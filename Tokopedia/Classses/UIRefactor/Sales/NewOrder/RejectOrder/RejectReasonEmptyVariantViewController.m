//
//  RejectReasonEmptyVariantViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 6/16/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RejectReasonEmptyVariantViewController.h"
#import "RejectReasonEmptyVariantCell.h"
#import "RejectReasonProductDescriptionViewController.h"

@interface RejectReasonEmptyVariantViewController ()<UITableViewDelegate, UITableViewDataSource, RejectReasonEmptyVariantDelegate, RejectReasonProductDescriptionDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *confirmButton;

@end

@implementation RejectReasonEmptyVariantViewController{
    NSIndexPath* selectedIndexPath;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.allowsMultipleSelection = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _order.order_products.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifer = @"RejectReasonEmptyVariantCell";
    
    RejectReasonEmptyVariantCell *cell = (RejectReasonEmptyVariantCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellIdentifer
                                                                 owner:self
                                                               options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setSelected:NO animated:NO];
    cell.delegate = self;
    OrderProduct *currentProduct = [_order.order_products objectAtIndex:indexPath.row];
    [cell setViewModel:currentProduct.viewModel];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 130;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString *sectionTitle = @"Atur stok kosong pada produk:";
    
    // Create label with section title
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(8, 0, 280, 40);
    label.textColor = [UIColor blackColor];
    label.font = [UIFont fontWithName:@"GothamMedium" size:14];
    label.text = sectionTitle;
    label.backgroundColor = [UIColor clearColor];
    
    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.window.frame.size.width, 40)];
    [view addSubview:label];
    
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
- (IBAction)confirmButtonTapped:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Cell Delegate
-(void)tableViewCell:(UITableViewCell *)cell changeProductDescriptionAtIndexPath:(NSIndexPath *)indexPath{
    OrderProduct *selectedProduct = [_order.order_products objectAtIndex:indexPath.row];
    selectedIndexPath = indexPath;
    RejectReasonProductDescriptionViewController *vc = [[RejectReasonProductDescriptionViewController alloc] init];
    vc.orderProduct = selectedProduct;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Product Description Delegate

- (void)didChangeProductDescription:(NSString *)description withEmptyStock:(BOOL)emptyStock {
    OrderProduct *product = [self.order.order_products objectAtIndex:selectedIndexPath.row];
    product.product_description = description;
    product.emptyStock = emptyStock;
}

@end

