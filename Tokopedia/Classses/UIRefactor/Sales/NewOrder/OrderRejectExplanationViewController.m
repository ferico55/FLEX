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
#import "RejectOrderRequest.h"

@interface OrderRejectExplanationViewController ()

@property (weak, nonatomic) IBOutlet TKPDTextView *textView;
@property (strong, nonatomic) RejectOrderRequest* rejectOrderRequest;
@end

@implementation OrderRejectExplanationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Keterangan";
    
    _rejectOrderRequest = [RejectOrderRequest new];
    
    /*
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"Batal" style:UIBarButtonItemStyleBordered handler:^(id sender) {
        [self.navigationController popViewControllerAnimated:YES];
    }];;
     */
    
    __weak typeof(self) welf = self;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"Selesai" style:UIBarButtonItemStyleDone handler:^(id sender) {
        if (_textView.text.length == 0) {
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Keterangan harus diisi."] delegate:self];
            [alert show];
        } else {
            [welf.rejectOrderRequest requestActionRejectOrderWithOrderId:welf.order.order_detail.detail_order_id
                                                                  reason:_textView.text
                                                              reasonCode:welf.reasonCode
                                                               onSuccess:^(GeneralAction *result) {
                                                                   if([result.data.is_success boolValue]){
                                                                       [[NSNotificationCenter defaultCenter] postNotificationName:@"applyRejectOperation" object:nil];
                                                                       [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                                                   }else{
                                                                       StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:result.message_error delegate:welf];
                                                                       [alert show];
                                                                   }
                                                               } onFailure:^(NSError *error) {
                                                                   StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Kendala koneksi internet"] delegate:welf];
                                                                   [alert show];
                                                               }];            
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
