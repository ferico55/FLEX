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
            if (_textField.text.length >=8 && _textField.text.length <=17) {
                [self.delegate changeReceiptNumber:_textField.text];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            } else {
                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Nomor resi antara 8 - 17 karakter"]
                                                                               delegate:self];
                [alert show];
            }
        }
    }
}

@end
