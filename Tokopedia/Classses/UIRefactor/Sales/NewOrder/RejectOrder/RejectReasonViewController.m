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


#define BARANG_HABIS @"1"
#define VARIAN_TIDAK_TERSEDIA @"2"
#define SALAH_HARGA_BERAT @"3"
#define TOKO_SEDANG_TUTUP @"4"

@interface RejectReasonViewController ()<UITableViewDelegate, UIScrollViewDelegate, UITableViewDataSource, RejectExplanationDelegate>
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
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle : @"Back"
                                                             style : UIBarButtonItemStyleDone
                                                            target : self
                                                            action : @selector(didTapBackButton)];
    self.navigationItem.backBarButtonItem = back;
    
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
    
    if([_selectedReason.reason_code isEqualToString:BARANG_HABIS]){
        RejectReasonEmptyStockViewController *vc = [[RejectReasonEmptyStockViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if([_selectedReason.reason_code isEqualToString:VARIAN_TIDAK_TERSEDIA]){
        
    }else if([_selectedReason.reason_code isEqualToString:SALAH_HARGA_BERAT]){
        
    }else if([_selectedReason.reason_code isEqualToString:TOKO_SEDANG_TUTUP]){
        
    }else{
        OrderRejectExplanationViewController *controller = [[OrderRejectExplanationViewController alloc] init];
        controller.delegate = self;
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

-(void)didFinishWritingExplanation:(NSString *)explanation{
    [_delegate didChooseRejectReason:_selectedReason withExplanation:explanation];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)didTapBackButton{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
