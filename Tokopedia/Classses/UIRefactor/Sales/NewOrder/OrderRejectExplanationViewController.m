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
#import <BlocksKit/BlocksKit.h>
#import "UIBarButtonItem+BlocksKit.h"

@interface OrderRejectExplanationViewController ()

@property (weak, nonatomic) IBOutlet TKPDTextView *textView;

@end

@implementation OrderRejectExplanationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Keterangan";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"Batal" style:UIBarButtonItemStyleBordered handler:^(id sender) {
        [self.navigationController popViewControllerAnimated:YES];
    }];;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"Selesai" style:UIBarButtonItemStyleDone handler:^(id sender) {
        if (_textView.text.length == 0) {
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Keterangan harus diisi."] delegate:self];
            [alert show];
        } else {
            [self.delegate didFinishWritingExplanation:_textView.text];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];

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

@end
