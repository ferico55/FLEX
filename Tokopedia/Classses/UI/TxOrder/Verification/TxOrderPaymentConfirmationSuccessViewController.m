//
//  TxOrderPaymentConfirmationSuccessViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderPaymentConfirmationSuccessViewController.h"

@interface TxOrderPaymentConfirmationSuccessViewController ()
@property (weak, nonatomic) IBOutlet UILabel *totalPaymentLabel;
@property (weak, nonatomic) IBOutlet UILabel *successMessage;
@property (weak, nonatomic) IBOutlet UILabel *totalPaymentValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *info2Label;
@property (weak, nonatomic) IBOutlet UIButton *tap;

@end

@implementation TxOrderPaymentConfirmationSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_successMessage multipleLineLabel:_successMessage];
    [_infoLabel multipleLineLabel:_infoLabel];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]  initWithString:_info2Label.text];
    [attributedString addAttribute:NSFontAttributeName value:FONT_GOTHAM_BOOK_12 range:[_info2Label.text rangeOfString:@"Klik disini"]];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1] range:[_info2Label.text rangeOfString:@"Klik disini"]];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:style range:[_info2Label.text rangeOfString:_info2Label.text]];
    _info2Label.attributedText = attributedString;
    _totalPaymentValueLabel.text = _totalPaymentValue;
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:REFRESH_TX_ORDER_POST_NOTIFICATION_NAME object:self];
    [_delegate shouldPopViewController];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
