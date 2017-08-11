//
//  RejectReasonWrongPriceViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 6/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <BlocksKit/BlocksKit.h>
#import "NSArray+BlocksKit.h"
#import "RejectReasonWrongPriceViewController.h"
#import "RejectReasonWrongPriceCell.h"
#import "RejectReasonEditPriceViewController.h"
#import "RejectOrderRequest.h"
#import "string_product.h"
#import "NSNumberFormatter+IDRFormater.h"

@interface RejectReasonWrongPriceViewController ()<UITableViewDelegate, UITableViewDataSource, RejectReasonWrongPriceDelegate, RejectReasonEditPriceDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *confirmButton;

@end

@implementation RejectReasonWrongPriceViewController{
    RejectOrderRequest *_rejectOrderRequest;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView reloadData];
    
    _rejectOrderRequest = [RejectOrderRequest new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_tableView reloadData];
    [AnalyticsManager trackScreenName:@"Reject Reason Wrong Price Page"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(self.isMovingFromParentViewController){
        [_order.order_products bk_each:^(id obj) {
            OrderProduct *currentProduct = (OrderProduct*)obj;
            currentProduct.emptyStock = NO;
        }];
    }
}

#pragma mark - Table View
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _order.order_products.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifer = @"RejectReasonWrongPriceCell";
    
    RejectReasonWrongPriceCell *cell = (RejectReasonWrongPriceCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellIdentifer
                                                                 owner:self
                                                               options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setSelected:NO animated:NO];
    cell.delegate = self;
    cell.indexPath = indexPath;
    OrderProduct *currentProduct = [_order.order_products objectAtIndex:indexPath.row];
    NSInteger weightIndex = [currentProduct.product_weight_unit integerValue];
    NSString *weightName = [ARRAY_WEIGHT_UNIT[weightIndex-1] objectForKey:DATA_NAME_KEY];
    currentProduct.product_weight = [currentProduct.product_current_weight stringByAppendingString:[@" " stringByAppendingString:weightName]];   
    
    [cell setViewModel:currentProduct.viewModel];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString *sectionTitle = @"Atur harga dan berat pada produk:";
    
    // Create label with section title
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(8, 0, 280, 40);
    label.textColor = [UIColor blackColor];
    label.font = [UIFont largeThemeMedium];
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
}

-(void)tableViewCell:(UITableViewCell *)cell changeProductPriceAtIndexPath:(NSIndexPath *)indexPath{
    RejectReasonEditPriceViewController *vc = [RejectReasonEditPriceViewController new];
    OrderProduct *currentProduct = [_order.order_products objectAtIndex:indexPath.row];
    vc.orderProduct = currentProduct;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)didChangeProductPriceWeight:(OrderProduct *)orderProduct{
    [_order.order_products bk_each:^(id obj) {
        OrderProduct* selected = obj;
        if([selected.product_id isEqualToString:orderProduct.product_id]){
            NSInteger tempWeight = [orderProduct.product_current_weight integerValue];
            NSInteger tempPrice = [orderProduct.product_normal_price integerValue];
            
            selected.product_current_weight = [NSString stringWithFormat:@"%ld", (long)tempWeight];
            selected.product_normal_price = [NSString stringWithFormat:@"%ld", (long)tempPrice];
            selected.product_weight_unit = orderProduct.product_weight_unit;
            selected.product_price_currency = orderProduct.product_price_currency;
            selected.emptyStock = orderProduct.emptyStock;
        }
    }];
    [_tableView reloadData];
}


@end
