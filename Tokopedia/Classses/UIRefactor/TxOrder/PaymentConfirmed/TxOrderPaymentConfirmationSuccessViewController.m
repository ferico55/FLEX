//
//  TxOrderPaymentConfirmationSuccessViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderPaymentConfirmationSuccessViewController.h"
#import "TxOrderTabViewController.h"
#import "TxOrderStatusViewController.h"

@interface TxOrderPaymentConfirmationSuccessViewController ()
@property (weak, nonatomic) IBOutlet UILabel *totalPaymentLabel;
@property (weak, nonatomic) IBOutlet UILabel *successMessage;
@property (weak, nonatomic) IBOutlet UILabel *totalPaymentValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *info2Label;

@end

@implementation TxOrderPaymentConfirmationSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Selesai" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [doneBarButtonItem setTintColor:[UIColor whiteColor]];
    doneBarButtonItem.tag = 10;
    self.navigationItem.rightBarButtonItem = doneBarButtonItem;
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barButtonItem setTintColor:[UIColor whiteColor]];
    barButtonItem.tag = 11;
    self.navigationItem.leftBarButtonItem = barButtonItem;
    
    [_successMessage setCustomAttributedText:[NSString stringWithFormat:@"Terima kasih, Anda telah berhasil melakukan konfirmasi pembayaran dengan menggunakan %@.",_confirmationPayment]];
    [_infoLabel setCustomAttributedText:_infoLabel.text];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5.0;
    style.alignment = NSTextAlignmentCenter;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]  initWithString:_info2Label.text];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont smallTheme] range:[_info2Label.text rangeOfString:@"Klik disini"]];
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1]
                             range:[_info2Label.text rangeOfString:@"Klik disini"]];
    
    [attributedString addAttribute:NSParagraphStyleAttributeName
                             value:style
                             range:[_info2Label.text rangeOfString:_info2Label.text]];
    
    _info2Label.attributedText = attributedString;
    _totalPaymentValueLabel.text = _totalPaymentValue;
    
}

-(void)viewDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:REFRESH_TX_ORDER_POST_NOTIFICATION_NAME object:self];
}

-(void)dealloc
{
    //[_delegate shouldPopViewController];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = @"Konfirmasi Pembayaran";
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.title = @" ";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        if (button.tag==10) {
            UIViewController *destinationVC;
            for (UIViewController *viewController in self.navigationController.viewControllers) {
                if ([viewController isKindOfClass:[TxOrderTabViewController class]]) {
                    destinationVC = viewController;
                }
            }
            [self.navigationController popToViewController:destinationVC animated:YES];
        }
    }
    else
    {
        TxOrderStatusViewController *vc =[TxOrderStatusViewController new];
        vc.action = @"get_tx_order_status";
        vc.viewControllerTitle = @"Status Pemesanan";
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
