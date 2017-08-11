//
//  CancelShipmentViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/1/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "CancelShipmentViewController.h"
#import "TKPDTextView.h"

@interface CancelShipmentViewController ()

@property (weak, nonatomic) IBOutlet TKPDTextView *textView;

@end

@implementation CancelShipmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"";
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Kembali"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(tap:)];
    cancelButton.tag = 1;
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Batalkan order"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(tap:)];
    doneButton.tag = 2;
    self.navigationItem.rightBarButtonItem = doneButton;
    
    [self.textView becomeFirstResponder];
    self.textView.placeholder = @"Tulis keterangan pembatalan order";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem *)sender;
        if (button.tag == 2) {
            [AnalyticsManager trackEventName:@"clickShipping" category:GA_EVENT_CATEGORY_SHIPPING action:GA_EVENT_ACTION_CLICK label:@"Reject Shipment"];
            [self.delegate cancelShipmentWithExplanation:_textView.text];
        }
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
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
