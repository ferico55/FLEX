//
//  FilterShipmentConfirmationViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "FilterShipmentConfirmationViewController.h"
#import "AlertDatePickerView.h"
#import "string_alert.h"

@interface FilterShipmentConfirmationViewController () <TKPDAlertViewDelegate> {
    NSString *_invoice;
    NSString *_startDate;
    NSString *_endDate;
}

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *endDateLabel;

@end

@implementation FilterShipmentConfirmationViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    self.title = @"Filter";

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
 
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];

    _startDate = [dateFormatter stringFromDate:[NSDate date]];
    _startDateLabel.text = _startDate;
    
    _endDate = [dateFormatter stringFromDate:[NSDate date]];
    _endDateLabel.text = _endDate;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        
        UIButton *button = (UIButton *)sender;
        if (button.tag == 1) {
            
            AlertDatePickerView *datePicker = [AlertDatePickerView new];
            datePicker.delegate = self;
            datePicker.tag = 1;
            datePicker.startDate = [NSDate date];
            [datePicker show];
            
        } else if (button.tag == 2) {

            AlertDatePickerView *datePicker = [AlertDatePickerView new];
            datePicker.delegate = self;
            datePicker.tag = 2;
            datePicker.startDate = [NSDate date];
            [datePicker show];

        }
        
    } else if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem *)sender;
        if (button.tag == 2) {
            [self.delegate didFilterShipmentConfirmationInvoice:_invoice deadline:_startDate];
        }
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    AlertDatePickerView *datePicker = (AlertDatePickerView *)alertView;
    NSDate *date = [datePicker.data objectForKey:kTKPDALERTVIEW_DATADATEPICKERKEY];
 
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    
    if (datePicker.tag == 1) {
        _startDateLabel.text = [dateFormatter stringFromDate:date];
    } else {
        _endDateLabel.text = [dateFormatter stringFromDate:date];
    }
}

@end
