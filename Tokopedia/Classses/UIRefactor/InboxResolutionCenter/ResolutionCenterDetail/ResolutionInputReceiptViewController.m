//
//  ResolutionInputResiViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 3/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ResolutionInputReceiptViewController.h"
#import "GeneralTableViewController.h"
#import "ShipmentOrder.h"
#import "string_shipment.h"
#import "string_inbox_resolution_center.h"
#import "RequestResolutionData.h"
#import "StickyAlertView.h"

@interface ResolutionInputReceiptViewController ()<GeneralTableViewControllerDelegate>
{
    NSMutableArray *_list;
}

@property (weak, nonatomic) IBOutlet UITextField *nomorReceiptTextField;
@property (weak, nonatomic) IBOutlet UILabel *shipmentLabel;

@end

@implementation ResolutionInputReceiptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _list = [NSMutableArray new];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:(self) action:nil];
    [backBarButtonItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Selesai" style:UIBarButtonItemStylePlain target:(self) action:@selector(tapDone:)];
    [doneBarButtonItem setTintColor:[UIColor whiteColor]];
    doneBarButtonItem.tag = 11;
    self.navigationItem.rightBarButtonItem = doneBarButtonItem;
    
    _nomorReceiptTextField.text = _conversation.input_resi?:@"";
    _selectedShipment.shipment_id = _conversation.input_kurir?:@"";
    _shipmentLabel.text = _selectedShipment.shipment_name?:@"Pilih Agen Kurir";
    
    [self doRequestListCourier];
}

-(void)tapDone:(UIBarButtonItem*)sender{
    [_nomorReceiptTextField resignFirstResponder];
    if ([self isValidInput]) {
        if (_isInputResi) {
            [self doRequestInputResiWithButton:sender];
        } else {
            [self doRequestEditResiWithButton:sender];
        }
    }
}

- (IBAction)tap:(id)sender {
    [_nomorReceiptTextField resignFirstResponder];
    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
    if (tap.view.tag == 10) {
        [_nomorReceiptTextField becomeFirstResponder];
    }
    else if (tap.view.tag == 11)
    {
        if (_list.count >0) {
            for (ShipmentCourier *shipment in _list) {
                if ([shipment.shipment_name isEqualToString:_selectedShipment.shipment_name]) {
                    _selectedShipment = shipment;
                }
            }
            GeneralTableViewController *vc = [GeneralTableViewController new];
            vc.objects = _list;
            vc.selectedObject = _selectedShipment?:_list[0];
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        }

    }
}

-(void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath
{
    ShipmentCourier *selectedShipment = object;
    _selectedShipment = selectedShipment;
    _shipmentLabel.text = selectedShipment.shipment_name;
}

-(BOOL)isValidInput
{
    BOOL isValid = YES;
    NSMutableArray *errorMessages = [NSMutableArray new];
    
    if ([_nomorReceiptTextField.text isEqualToString:@""]) {
        isValid = NO;
        [errorMessages addObject:@"Nomor resi belum diisi"];
    }
    else
    {
        if ([_nomorReceiptTextField.text isAllNonNumber]) {
            isValid = NO;
            [errorMessages addObject:@"Nomor resi tidak valid"];
        }
        
        if (_nomorReceiptTextField.text.length < 7 || _nomorReceiptTextField.text.length > 17) {
            [errorMessages addObject:@"Nomor resi antara 7 - 17 karakter"];
        }
    }
    
    if ([_selectedShipment.shipment_id integerValue] == 0) {
        isValid = NO;
        [errorMessages addObject:@"Agen kurir harus dipilih"];
    }
    
    if (!isValid) {
        StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessages delegate:self];
        [alert show];
    }
    
    return isValid;
}

#pragma mark - Request Shipment
-(void)doRequestListCourier{
    [RequestResolutionData fetchListCourierSuccess:^(NSArray<ShipmentCourier *> *shipments) {
        [_list addObjectsFromArray:shipments];
        for (ShipmentCourier *shipment in _list) {
            if ([shipment.shipment_id integerValue] == [_selectedShipment.shipment_id integerValue]) {
                _selectedShipment = shipment;
            }
        }
        _shipmentLabel.text = _selectedShipment.shipment_name?:@"Pilih Agen Kurir";
    } failure:^(NSError *error) {
        
    }];
}

-(void)doRequestInputResiWithButton:(UIBarButtonItem*)button{
    button.enabled = NO;
    [RequestResolutionAction fetchInputResiResolutionID:_resolutionID
                                             shipmentID:_selectedShipment.shipment_id
                                            shippingRef:_nomorReceiptTextField.text
                                                success:^(ResolutionActionResult *data) {
        button.enabled = YES;
        if ([_delegate respondsToSelector:@selector(addResolutionLast:conversationLast:replyEnable:)]){
            [_delegate addResolutionLast:data.solution_last conversationLast:data.conversation_last[0] replyEnable:YES];
        }
        [self.navigationController popViewControllerAnimated:YES];
        
    } failure:^(NSError *error) {
        button.enabled = YES;
    }];
}

-(void)doRequestEditResiWithButton:(UIBarButtonItem*)button{
    button.enabled = NO;
    [RequestResolutionAction fetchEditResiResolutionID:_resolutionID
                                        conversationID:_conversationID
                                            shipmentID:_selectedShipment.shipment_id
                                           shippingRef:_nomorReceiptTextField.text
                                               success:^(ResolutionActionResult *data) {
        button.enabled = YES;
        if ([_delegate respondsToSelector:@selector(addResolutionLast:conversationLast:replyEnable:)]){
            [_delegate addResolutionLast:data.solution_last conversationLast:data.conversation_last[0] replyEnable:YES];
        }
        [self.navigationController popViewControllerAnimated:YES];
        
    } failure:^(NSError *error) {
        button.enabled = YES;
    }];
}

@end
