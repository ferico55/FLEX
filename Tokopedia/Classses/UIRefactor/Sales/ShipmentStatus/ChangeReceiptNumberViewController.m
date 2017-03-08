//
//  ChangeReceiptNumberViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/30/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ChangeReceiptNumberViewController.h"
#import "StickyAlertView.h"
#import "ActionOrder.h"

@interface ChangeReceiptNumberViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *currentReceiptNumberLabel;

@end

@implementation ChangeReceiptNumberViewController{
    UIBarButtonItem *_doneButton;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"Ubah Nomor Resi";

    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(tapDismiss:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    _doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Simpan"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(tapSave:)];
    self.navigationItem.rightBarButtonItem = _doneButton;

    _currentReceiptNumberLabel.text = _receiptNumber;

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

-(void)tapDismiss:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)tapSave:(id)sender{
    [self requestChangeReceiptNumber];
}

- (void)requestChangeReceiptNumber{
    
    [_doneButton setEnabled:NO];
    
    if (!_textField.text || [_textField.text isEqualToString:@""]) {
        [StickyAlertView showErrorMessage:@[@"Nomor Resi belum diisi."]];
        return;
    }
    
    NSDictionary *parameters = @{
                                 @"order_id"            : _orderID,
                                 @"shipping_ref"        : _textField.text,
                                 };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                 path:@"/v4/action/myshop-order/edit_shipping_ref.pl"
                               method:RKRequestMethodPOST
                            parameter:parameters
                              mapping:[ActionOrder mapping]
                            onSuccess:^(RKMappingResult *mappingResult,
                                        RKObjectRequestOperation *operation) {
                                
                                ActionOrder *actionOrder = [mappingResult.dictionary objectForKey:@""];
                                
                                if (actionOrder.message_status.count>0) {
                                    [StickyAlertView showSuccessMessage:actionOrder.message_status];
                                }
                                
                                if (actionOrder.message_error.count > 0) {
                                    [StickyAlertView showErrorMessage:actionOrder.message_error];
                                }
                                
                                if (actionOrder.data.isOrderAccepted) {
                                    if(_didSuccessEditReceipt){
                                        _didSuccessEditReceipt(_textField.text);
                                    }
                                    [self dismissViewControllerAnimated:YES completion:nil];
                                }
                                
                                [_doneButton setEnabled:YES];
                                
                            } onFailure:^(NSError *errorResult) {
                                
                                [_doneButton setEnabled:YES];
                                
                            }];
}

@end
