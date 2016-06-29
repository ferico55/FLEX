//
//  RejectReasonWrongPriceViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 6/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RejectReasonWrongPriceViewController.h"
#import "RejectReasonWrongPriceCell.h"
#import "RejectReasonEditPriceViewController.h"

@interface RejectReasonWrongPriceViewController ()<UITableViewDelegate, UITableViewDataSource, RejectReasonWrongPriceDelegate, RejectReasonEditPriceDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *confirmButton;

@end

@implementation RejectReasonWrongPriceViewController{
    UIRefreshControl *_refreshControl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshList)forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View
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
    [cell setViewModel:currentProduct.viewModel];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 130;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString *sectionTitle = @"Atur harga dan berat pada produk:";
    
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

-(void)tableViewCell:(UITableViewCell *)cell changeProductPriceAtIndexPath:(NSIndexPath *)indexPath{
    RejectReasonEditPriceViewController *vc = [RejectReasonEditPriceViewController new];
    vc.orderProduct = [_order.order_products objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)refreshList{
    [_tableView reloadData];
}

-(void)didChangeProductPriceWeight{
    [self refreshList];
}


@end
