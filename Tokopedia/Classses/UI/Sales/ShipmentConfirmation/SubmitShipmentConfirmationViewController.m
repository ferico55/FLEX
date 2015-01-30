//
//  SubmitShipmentConfirmationViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "SubmitShipmentConfirmationViewController.h"
#import "AlertPickerView.h"

@interface SubmitShipmentConfirmationViewController () <TKPDAlertViewDelegate>

@property BOOL changeCourier;
@property NSString *_receiptNumber;
@property (weak, nonatomic) IBOutlet UILabel *changeCourierLabel;
@property (weak, nonatomic) IBOutlet UITextField *receiptNumberTextField;

@end

@implementation SubmitShipmentConfirmationViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    self.title = @"Konfirmasi";

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(tap:)];
    cancelButton.tag = 1;
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Selesai"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(tap:)];
    doneButton.tag = 2;
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        if (button.tag == 1) {
            AlertPickerView *picker = [AlertPickerView new];
            picker.delegate = self;
            picker.pickerData = @[@{DATA_NAME_KEY: @"Tidak", DATA_VALUE_KEY: @"Tidak"},
                                  @{DATA_NAME_KEY: @"Ya", DATA_VALUE_KEY: @"Ya"}];
            picker.tag = 2;
            [picker show];
        }
    } else if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem *)sender;
        if (button.tag == 1) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
        if (button.tag == 2) {
            [self.delegate didFinishConfirmation];
        }
    }
}

- (void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger index = [[alertView.data objectForKey:DATA_INDEX_KEY] integerValue];
    if (index == 0) {
        _changeCourierLabel.text = @"Tidak";
    } else if (index == 1) {
        _changeCourierLabel.text = @"Ya";
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_receiptNumberTextField resignFirstResponder];
}

@end