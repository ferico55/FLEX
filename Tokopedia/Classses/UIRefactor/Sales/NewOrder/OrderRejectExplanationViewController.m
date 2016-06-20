//
//  OrderRejectExplanationViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "OrderRejectExplanationViewController.h"
#import "UITextView+UITextView_Placeholder.h"
#import "TKPDTextView.h"

@interface OrderRejectExplanationViewController ()

@property (weak, nonatomic) IBOutlet TKPDTextView *textView;

@end

@implementation OrderRejectExplanationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Keterangan";

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(tap:)];
    cancelButton.tag = 1;
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Selesai"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(tap:)];
    doneButton.tag = 2;
    self.navigationItem.rightBarButtonItem = doneButton;

    _textView.placeholder = @"Tulis Keterangan";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (IBAction)tap :(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem *)sender;
        if (button.tag == 1) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else if (button.tag == 2) {
            if (_textView.text.length == 0) {
                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Keterangan harus diisi."] delegate:self];
                [alert show];
            } else {
                [self.delegate didFinishWritingExplanation:_textView.text];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
}

@end
