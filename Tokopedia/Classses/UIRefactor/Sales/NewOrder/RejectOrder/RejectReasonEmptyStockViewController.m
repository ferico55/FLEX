//
//  RejectReasonEmptyStockViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 6/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RejectReasonEmptyStockViewController.h"
#import "RejectReasonEmptyStockCell.h"
#import "RejectOrderRequest.h"
#import <BlocksKit/BlocksKit.h>

@interface RejectReasonEmptyStockViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *confirmButton;
@property (strong, nonatomic) RejectOrderRequest *rejectOrderRequest;
@end

@implementation RejectReasonEmptyStockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.allowsMultipleSelection = YES;
    
    _rejectOrderRequest = [RejectOrderRequest new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillDisappear:(BOOL)animated{
    [_order.order_products bk_each:^(id obj) {
        OrderProduct *currentProduct = (OrderProduct*)obj;
        currentProduct.emptyStock = NO;
    }];
}

#pragma mark - Table View
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _order.order_products.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifer = @"RejectReasonEmptyStockCell";
    
    RejectReasonEmptyStockCell *cell = (RejectReasonEmptyStockCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellIdentifer
                                                                 owner:self
                                                               options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    OrderProduct *currentProduct = [_order.order_products objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setViewModel:currentProduct.viewModel];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
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
    OrderProduct *selected = [_order.order_products objectAtIndex:indexPath.row];
    if(selected.emptyStock){
        selected.emptyStock = NO;
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else{
        selected.emptyStock = YES;
    }
}

- (IBAction)confirmButtonTapped:(id)sender {
    if([self validate]){
        [_rejectOrderRequest requestActionRejectOrderWithOrderId:_order.order_detail.detail_order_id
                                                   emptyProducts:_order.order_products
                                                      reasonCode:_reasonCode
                                                       onSuccess:^(GeneralAction *result) {
                                                           if([result.data.is_success boolValue]){
                                                               [[NSNotificationCenter defaultCenter] postNotificationName:@"applyRejectOperation" object:nil];
                                                               [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                                           }else{
                                                               StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:result.message_error delegate:self];
                                                               [alert show];
                                                           }
                                                       } onFailure:^(NSError *error) {
                                                           StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Kendala koneksi internet"] delegate:self];
                                                           [alert show];
                                                       }];
    }else{
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Anda belum memilih stok barang yang kosong"] delegate:self];
        [alert show];
    }
}
-(BOOL)validate{
    BOOL noEmptyStock = YES;
    for(OrderProduct *product in _order.order_products){
        if(product.emptyStock){
            noEmptyStock = NO;
        }
    }
    return !noEmptyStock;
}

@end
