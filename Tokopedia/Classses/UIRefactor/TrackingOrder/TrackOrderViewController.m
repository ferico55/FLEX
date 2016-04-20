//
//  TrackOrderViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "string_track_order.h"

#import "TrackOrderViewController.h"
#import "TrackOrderHistoryCell.h"
#import "RequestTrack.h"

@interface TrackOrderViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate
>
{
    TrackOrder *_trackingOrder;
    Track *_track;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *headerViewComplete;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *invalidStatusTitle;
@property (strong, nonatomic) IBOutlet UIView *headerHistoryView;

@property (weak, nonatomic) IBOutlet UILabel *invalidStatusDescLabel;
@property (strong, nonatomic) IBOutlet UIView *invalidHeaderView;
@property (strong, nonatomic) IBOutlet UIView *headerWithReceiver;

@end

@implementation TrackOrderViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"Lacak Pengiriman";

    if (_isShippingTracking) {
        [self doTrackingReso];
    } else {
        [self doTrackingOrder];
    }
    
    _tableView.tableFooterView = _footerView;
    [_activityIndicator startAnimating];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    style.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName            : [UIFont fontWithName:@"GothamMedium" size:14],
                                 NSParagraphStyleAttributeName  : style,
                                 NSForegroundColorAttributeName : [UIColor colorWithRed:10.0/255.0 green:126.0/255.0 blue:7.0/255.0 alpha:1],
                                 };
    
    NSString *invalidTitle = @"Belum ada update status pengiriman dari kurir";
    _invalidStatusTitle.attributedText = [[NSAttributedString alloc] initWithString:invalidTitle
                                                                         attributes:attributes];
    
    //TODO:: Invalid Detail Text
    NSString *invalidDetail = @"Apabila sudah lewat 3x24 jam masih tidak ada update status pengiriman, ada beberapa kemungkinan:\n\n\u25CF Penjual keliru menginput nomor resi atau tanggal pengiriman.\n\u25CF Penjual menggunakan kurir yang berbeda dari pilihan pembeli.\n\n\nPembeli disarankan menghubungi penjual bersangkutan untuk informasi lebih lanjut.\n\nNamun tidak perlu khawatir karena staff kami selalu melakukan pengecekan.";
    _invalidStatusDescLabel.text = invalidDetail;
    [_invalidStatusDescLabel setCustomAttributedText:invalidDetail];
    [_invalidStatusTitle setCustomAttributedText:invalidTitle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (_track) {
        if ([_track.result.track_order.order_status integerValue] == ORDER_DELIVERED &&
            [self.delegate respondsToSelector:@selector(shouldRefreshRequest)]) {
            [_delegate shouldRefreshRequest];
        }
        if ([_track.result.track_order.order_status integerValue] == ORDER_DELIVERED &&
            [self.delegate respondsToSelector:@selector(updateDeliveredOrder:)]) {
            [self.delegate updateDeliveredOrder:_trackingOrder.receiver_name?:@""];
        }
    }
}


-(void)doTrackingReso{
    [RequestTrack fetchTrackResoAWB:_shippingRef?:@""
                         shipmentID:_shipmentID?:@""
                            success:^(TrackOrderResult *data) {
                                
                                _trackingOrder = data.track_order;
                                
                                _trackingOrder.detail = [TrackOrderDetail new];
                                _trackingOrder.detail.receiver_name = _trackingOrder.receiver_name;
                                _trackingOrder.order_status = ([_trackingOrder.delivered integerValue] == 1)?[NSString stringWithFormat:@"%zd",ORDER_DELIVERED]:@"-1";
                                
                                [self didSuccessTrack];
                                
                            } failed:^(NSError *error) {
                                _tableView.tableHeaderView = _invalidHeaderView;
                                
                                [_activityIndicator stopAnimating];
                                _tableView.tableFooterView = nil;
                            }];
}

-(void)doTrackingOrder{
    NSString *orderID = _order.order_detail.detail_order_id?:[NSString stringWithFormat:@"%zd",_orderID]?:@"";
    [RequestTrack fetchTrackOrderID:orderID
                            success:^(TrackOrderResult *data) {
                                
                                _trackingOrder = data.track_order;
                                [self didSuccessTrack];
                            } failed:^(NSError *error) {
                                _tableView.tableHeaderView = _invalidHeaderView;
                                
                                [_activityIndicator stopAnimating];
                                _tableView.tableFooterView = nil;
                            }];
}

-(void)didSuccessTrack{
    _tableView.contentInset = UIEdgeInsetsMake(22, 0, 0, 0);
    [_tableView reloadData];
    
    if (_trackingOrder.detail.receiver_name) {
        if (_isShippingTracking)
            _tableView.tableHeaderView = _headerWithReceiver;
        else
            _tableView.tableHeaderView = _headerViewComplete;
    }
    else
        _tableView.tableHeaderView = _headerView;
    
    UILabel *receiptNumberLabel = (UILabel *)[_tableView.tableHeaderView viewWithTag:1];
    receiptNumberLabel.text = _trackingOrder.shipping_ref_num;
    
    UILabel *sendDateLabel = (UILabel *)[_tableView.tableHeaderView viewWithTag:2];
    sendDateLabel.text = _trackingOrder.detail.send_date;
    
    UILabel *serviceCodeLabel = (UILabel *)[_tableView.tableHeaderView viewWithTag:3];
    serviceCodeLabel.text = _trackingOrder.detail.service_code;
    
    UILabel *statusLabel = (UILabel *)[_tableView.tableHeaderView viewWithTag:4];
    if ([_trackingOrder.order_status integerValue] == ORDER_SHIPPING_REF_NUM_EDITED) {
        statusLabel.text = @"Nomor Resi diganti oleh penjual";
    } else if ([_trackingOrder.order_status integerValue] == ORDER_DELIVERED) {
        statusLabel.text = @"Delivered";
    } else {
        statusLabel.text = @"On Process";
    }
    
    UILabel *receiverNameLabel = (UILabel *)[_tableView.tableHeaderView viewWithTag:6];
    receiverNameLabel.text = _trackingOrder.detail.receiver_name?:@"";
    
    if ([_trackingOrder.order_status integerValue] == ORDER_SHIPPING_TRACKER_INVALID) {
        _tableView.tableHeaderView = _invalidHeaderView;
    }
    
    [_activityIndicator stopAnimating];
    _tableView.tableFooterView = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if ([_trackingOrder.order_status integerValue] == ORDER_SHIPPING_TRACKER_INVALID) {
        return 0;
    }
    
    NSInteger sections = 0;
    if (_trackingOrder.detail.shipper_name) {
        sections += 2;    
    }
    if ([_trackingOrder.track_history count] > 0) {
        sections++;
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([_trackingOrder.order_status integerValue] == ORDER_SHIPPING_TRACKER_INVALID) {
        return 0;
    }
    
    NSInteger rows = 0;
    if (_trackingOrder.detail.shipper_name && [_trackingOrder.track_history count] > 0) {
        if (section == 0 || section == 1) rows = 2;
        if (section == 2) rows = [_trackingOrder.track_history count];
    } else if (_trackingOrder.detail.shipper_name && [_trackingOrder.track_history count] == 0) {
        rows = 2;
    } else if (!_trackingOrder.detail.shipper_name && [_trackingOrder.track_history count] > 0) {
        rows = [_trackingOrder.track_history count];
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        if (_trackingOrder.detail.shipper_name && [_trackingOrder.track_history count] > 0) {
            if (indexPath.section < 2){
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            } else {
                cell = [self cellHistoryAtIndexPath:indexPath];
            }
        } else if (_trackingOrder.detail.shipper_name && [_trackingOrder.track_history count] == 0) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        } else if (!_trackingOrder.detail.shipper_name && [_trackingOrder.track_history count] > 0) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        }
    }

    cell.textLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
    cell.detailTextLabel.font = [UIFont fontWithName:@"GothamBook" size:13];
    cell.detailTextLabel.textColor = [UIColor grayColor];

    if (_trackingOrder.detail.shipper_name && [_trackingOrder.track_history count] > 0) {
        if (indexPath.section < 2) {
            [self configureTrackingDetailCell:cell indexPath:indexPath];
        } else {
            cell = [self cellHistoryAtIndexPath:indexPath];
        }
    } else if (_trackingOrder.detail.shipper_name && [_trackingOrder.track_history count] == 0) {
        [self configureTrackingDetailCell:cell indexPath:indexPath];
    } else if (!_trackingOrder.detail.shipper_name && [_trackingOrder.track_history count] > 0) {
        cell = [self cellHistoryAtIndexPath:indexPath];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(UITableViewCell*)cellHistoryAtIndexPath:(NSIndexPath*)indexPath
{
    TrackOrderHistoryCell *cell;
    NSString *cellID = TRACK_ORDER_HISTORY_CELL_IDENTIFIER;
    
    cell = (TrackOrderHistoryCell*)[_tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [TrackOrderHistoryCell newCell];
    }
    
    TrackOrderHistory *trackHistory = _trackingOrder.track_history[indexPath.row];
    
    cell.dateHistoryLabel.text = trackHistory.date;
    cell.statusLabel.text = trackHistory.status;
    cell.cityLabel.text = trackHistory.city;
    
    return cell;
}

- (void)configureTrackingDetailCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Nama Pengirim";
            cell.detailTextLabel.text = _trackingOrder.detail.shipper_name;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Kota Pengirim";
            cell.detailTextLabel.text = _trackingOrder.detail.shipper_city;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Nama Penerima";
            cell.detailTextLabel.text = _trackingOrder.detail.receiver_name;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Kota Penerima";
            cell.detailTextLabel.text = _trackingOrder.detail.receiver_city;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_trackingOrder.order_status integerValue] == ORDER_SHIPPING_TRACKER_INVALID) {
        return 0;
    }
    
    if (_trackingOrder.detail.shipper_name && [_trackingOrder.track_history count] > 0) {
        if (indexPath.section < 2) {
            return 44;
        } else {
            return 90;
        }
    } else if (!_trackingOrder.detail.shipper_name && [_trackingOrder.track_history count] > 0) {
        return 90;
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([_trackingOrder.order_status integerValue] == ORDER_SHIPPING_TRACKER_INVALID) {
        return 0;
    }
    
    if (_trackingOrder.detail.shipper_name && [_trackingOrder.track_history count] > 0) {
        if (section < 2) {
            return 41;
        } else {
            return 88;
        }
    } else if (_trackingOrder.detail.shipper_name && [_trackingOrder.track_history count] == 0) {
        return 41;
    } else if (!_trackingOrder.detail.shipper_name && [_trackingOrder.track_history count] > 0) {
        return 88;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([_trackingOrder.order_status integerValue] == ORDER_SHIPPING_TRACKER_INVALID) {
        return nil;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 41)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, self.view.frame.size.width-15, 41)];
    label.font = [UIFont fontWithName:@"GothamBook" size:14];
    label.textColor = [UIColor colorWithRed:66.0/255.0 green:66.0/255.0 blue:66.0/255.0 alpha:1];

    if (_trackingOrder.detail.shipper_name && [_trackingOrder.track_history count] > 0) {
        if (section == 0){
            label.text = @"PENGIRIM";
        } else if (section == 1) {
            label.text = @"PENERIMA";
        } else {
            return _headerHistoryView;
        }
    } else if (_trackingOrder.detail.shipper_name && [_trackingOrder.track_history count] == 0) {
        if (section == 0){
            label.text = @"PENGIRIM";
        } else if (section == 1) {
            label.text = @"PENERIMA";
        }
    } else if (!_trackingOrder.detail.shipper_name && [_trackingOrder.track_history count] > 0) {
        return _headerHistoryView;
    }

    [view addSubview:label];
    
    return view;
}

- (void)configureTrackingHistoryCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    TrackOrderHistory *history = [_trackingOrder.track_history objectAtIndex:indexPath.row];
    cell.textLabel.text = history.status;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", history.city, history.date];
}

@end
