//
//  ChangeReceiptNumberViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/30/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ChangeReceiptNumberViewController.h"
#import "StickyAlertView.h"

@interface ChangeReceiptNumberViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *currentReceiptNumberLabel;

@end

@implementation ChangeReceiptNumberViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"Ubah Nomor Resi";

    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(tap:)];
    cancelButton.tag = 1;
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Simpan"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(tap:)];
    doneButton.tag = 2;
    self.navigationItem.rightBarButtonItem = doneButton;

    _currentReceiptNumberLabel.text = _order.order_detail.detail_ship_ref_num;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AnalyticsManager trackScreenName:@"Change Receipt Number Page"];
    [self.textField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.textField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem *)sender;
        if (button.tag == 1) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else if (button.tag == 2) {
            if (_textField.text.length >=7 && _textField.text.length <=17) {
                if ([self.delegate respondsToSelector:@selector(changeReceiptNumber:orderHistory:)]) {
                    [AnalyticsManager trackEventName:@"clickStatus" category:GA_EVENT_CATEGORY_ORDER_STATUS action:GA_EVENT_ACTION_EDIT label:@"Tracking Number"];
                    NSString *historyComments = [NSString stringWithFormat:@"Ubah dari %@ menjadi %@",
                                                 self.order.order_detail.detail_ship_ref_num,
                                                 _textField.text];
                    
                    NSDate *now = [NSDate date];

                    NSDateFormatter *dateFormatFull = [[NSDateFormatter alloc] init];
                    [dateFormatFull setDateFormat:@"d MM yyyy HH:mm"];
                    
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    [dateFormat setDateFormat:@"d/MM/yyyy HH:mm"];

                    OrderHistory *history = [OrderHistory new];
                    history.history_status_date = [dateFormat stringFromDate:now];
                    history.history_status_date_full = [dateFormatFull stringFromDate:now];
                    history.history_order_status = @"530";
                    history.history_comments = historyComments;
                    history.history_action_by = @"Seller";
                    history.history_buyer_status = @"Perubahan nomor resi pengiriman";
                    history.history_seller_status = @"Perubahan nomor resi pengiriman";
                    
                    [self.delegate changeReceiptNumber:_textField.text orderHistory:history];
                }
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            } else {
                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Nomor resi antara 7 - 17 karakter"]
                                                                               delegate:self];
                [alert show];
            }
        }
    }
}

@end
