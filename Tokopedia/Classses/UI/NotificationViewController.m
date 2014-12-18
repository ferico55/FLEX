//
//  NotificationViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 12/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "NotificationViewController.h"

@interface NotificationViewController ()

@property (weak, nonatomic) IBOutlet UILabel *messageCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *discussionCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceNotificationCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *customerCareCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *resolutionCenterCountLabel;

@property (weak, nonatomic) IBOutlet UILabel *salesOrderLabel;
@property (weak, nonatomic) IBOutlet UILabel *shippingConfirmationCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *shippingStatusCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *salesListCountLabel;

@property (weak, nonatomic) IBOutlet UILabel *paymentConfirmationLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderStatusCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *receiveConfirmationCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *paymentListCountLabel;


@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Inbox section
    
    if ([_notification.result.inbox.inbox_message integerValue] > 0) {
        _messageCountLabel.text = _notification.result.inbox.inbox_message;
        [self updateLabelAppearance:_messageCountLabel];
    }
    
    if ([_notification.result.inbox.inbox_talk integerValue] > 0) {
        _discussionCountLabel.text = _notification.result.inbox.inbox_talk;
        [self updateLabelAppearance:_discussionCountLabel];
    }
    
    if ([_notification.result.inbox.inbox_review integerValue] > 0) {
        _reviewCountLabel.text = _notification.result.inbox.inbox_review;
        [self updateLabelAppearance:_reviewCountLabel];
    }

    if ([_notification.result.resolution integerValue] > 0) {
        _resolutionCenterCountLabel.text = [_notification.result.resolution stringValue];
        [self updateLabelAppearance:_resolutionCenterCountLabel];
    }
    
    // Payment section
    
    _salesOrderLabel.text = _notification.result.sales.sales_new_order;
    _shippingConfirmationCountLabel.text = _notification.result.sales.sales_shipping_confirm;
    _shippingStatusCountLabel.text = _notification.result.sales.sales_shipping_status;

    // Purchase section
    
    _paymentConfirmationLabel.text = _notification.result.purchase.purchase_payment_confirm;
    _orderStatusCountLabel.text = _notification.result.purchase.purchase_order_status;
    _receiveConfirmationCountLabel.text = _notification.result.purchase.purchase_delivery_confirm;
    _paymentListCountLabel.text = _notification.result.purchase.purchase_order_status;
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    switch (section) {
        case 0:
            numberOfRows = 6;
            break;
            
        case 1:
            numberOfRows = 4;
            break;
            
        case 2:
            numberOfRows = 4;
            break;
            
        default:
            break;
    }
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 34;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 4, self.view.frame.size.width, 30)];
    titleLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
    titleLabel.textColor = [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1];
    if (section == 0) titleLabel.text = @"Kotak Masuk";
    else if (section == 1) titleLabel.text = @"Penjualan";
    else if (section == 2) titleLabel.text = @"Pembelian";

    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0, 33, self.view.frame.size.width, 1)];
    borderView.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:0.5f];

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 34)];
    headerView.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1];
    [headerView addSubview:titleLabel];
    [headerView addSubview:borderView];
    
    return headerView;
}

#pragma mark - Methods

- (void)updateLabelAppearance:(UILabel *)label {
    
    CGRect messageFrame = label.frame;
    messageFrame.origin.x -= 18;
    label.frame = messageFrame;

    UIView *redCircle = [[UIView alloc] initWithFrame:CGRectMake(82, 17, 8, 8)];
    redCircle.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:28.0/255.0 blue:35.0/255.0 alpha:1];
    redCircle.layer.cornerRadius = 4;
    redCircle.clipsToBounds = YES;
    [label addSubview:redCircle];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
