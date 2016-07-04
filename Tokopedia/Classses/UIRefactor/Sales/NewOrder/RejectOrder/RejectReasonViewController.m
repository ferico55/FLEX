//
//  RejectReasonViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 6/6/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RejectReasonViewController.h"
#import "RejectOrderRequest.h"
#import "OrderRejectExplanationViewController.h"
#import "RejectReasonEmptyStockViewController.h"
#import "RejectReasonEmptyVariantViewController.h"
#import "RejectReasonWrongPriceViewController.h"
#import "RejectOrderRequest.h"
#import "RejectReasonCloseShopViewController.h"

@interface RejectReasonViewController ()<UITableViewDelegate, UIScrollViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray* rejectReasons;
@property (strong, nonatomic) RejectReason* selectedReason;
@end

@implementation RejectReasonViewController{
    RejectOrderRequest *rejectOrderRequest;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Tolak Pesanan";
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle : @"Batal"
                                                             style : UIBarButtonItemStyleDone
                                                            target : self
                                                            action : @selector(didTapBackButton)];
    self.navigationItem.leftBarButtonItem = back;
    
    rejectOrderRequest = [RejectOrderRequest new];
    [self requestRejectReasons];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - TableView Delegate and DataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RejectReason *reason = [_rejectReasons objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.font = [UIFont fontWithName:@"GothamBook" size:13];
    cell.textLabel.text = reason.reason_text;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _rejectReasons.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString *sectionTitle = @"Pilih alasan penolakan:";
    
    // Create label with section title
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(8, 0, 280, 40);
    label.textColor = [UIColor blackColor];
    label.font = [UIFont fontWithName:@"GothamMedium" size:14];
    label.text = sectionTitle;
    label.backgroundColor = [UIColor clearColor];
    
    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.window.frame.size.width, 100)];
    [view addSubview:label];
    
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _selectedReason = [_rejectReasons objectAtIndex:indexPath.row];
    
    if([_selectedReason.reason_code isEqualToString:EMPTY_STOCK]){
        RejectReasonEmptyStockViewController *vc = [[RejectReasonEmptyStockViewController alloc]init];
        vc.order = self.order;
        vc.reasonCode = EMPTY_STOCK;
        vc.title = _selectedReason.reason_text;
        [self.navigationController pushViewController:vc animated:YES];
    }else if([_selectedReason.reason_code isEqualToString:EMPTY_VARIANT]){
        RejectReasonEmptyVariantViewController *vc = [[RejectReasonEmptyVariantViewController alloc]init];
        vc.order = self.order;
        vc.title = _selectedReason.reason_text;
        [self.navigationController pushViewController:vc animated:YES];
    }else if([_selectedReason.reason_code isEqualToString:WRONG_PRICE_WEIGHT]){
        RejectReasonWrongPriceViewController *vc = [[RejectReasonWrongPriceViewController alloc] init];
        vc.order = self.order;
        vc.title = _selectedReason.reason_text;
        [self.navigationController pushViewController:vc animated:YES];
    }else if([_selectedReason.reason_code isEqualToString:SHOP_IS_CLOSED]){
        RejectReasonCloseShopViewController *vc = [[RejectReasonCloseShopViewController alloc] init];
        vc.order = self.order;
        vc.reasonCode = _selectedReason.reason_code;
        vc.title = _selectedReason.reason_text;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        OrderRejectExplanationViewController *controller = [[OrderRejectExplanationViewController alloc] init];
        controller.title = _selectedReason.reason_text;
        controller.reasonCode = _selectedReason.reason_code;
        controller.order = self.order;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - Request
-(void)requestRejectReasons{
    [rejectOrderRequest requestForOrderRejectionReasonOnSuccess:^(NSArray *result) {
        _rejectReasons = result;
        [_tableView reloadData];
    } onFailure:^(NSError *error) {
        StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:@[@"Kendala koneksi internet"] delegate:self];
        [alert show];
    }];
}

-(void)didTapBackButton{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
