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
#import "StickyAlertView.h"

@interface ResolutionInputReceiptViewController ()<GeneralTableViewControllerDelegate>
{
    NSMutableArray *_list;
    NSOperationQueue *_operationQueue;
    
    __weak RKObjectManager *_objectManagerShipment;
    __weak RKManagedObjectRequestOperation *_requestShipment;
    
}

@property (weak, nonatomic) IBOutlet UITextField *nomorReceiptTextField;
@property (weak, nonatomic) IBOutlet UILabel *shipmentLabel;

@end

@implementation ResolutionInputReceiptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _operationQueue = [NSOperationQueue new];
    _list = [NSMutableArray new];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [backBarButtonItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Selesai" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [doneBarButtonItem setTintColor:[UIColor whiteColor]];
    doneBarButtonItem.tag = 11;
    self.navigationItem.rightBarButtonItem = doneBarButtonItem;
    
    _nomorReceiptTextField.text = _conversation.input_resi?:@"";
    _shipmentLabel.text = _selectedShipment.shipment_name?:@"Pilih Kurir Agent";
    
    [self configureRestKitShipment];
    [self requestShipment];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)tap:(id)sender {
    [_nomorReceiptTextField resignFirstResponder];
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        [_delegate receiptNumber:_nomorReceiptTextField.text withShipmentAgent:_selectedShipment withAction:_action conversation:_conversation];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
        if (tap.view.tag == 10) {
            [_nomorReceiptTextField becomeFirstResponder];
        }
        else if (tap.view.tag == 11)
        {
            if (!_requestShipment.isExecuting)
            {
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
}

-(void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath
{
    ShipmentCourier *selectedShipment = object;
    _selectedShipment = selectedShipment;
    _shipmentLabel.text = selectedShipment.shipment_name;
}

#pragma mark - Request Shipment
-(void)cancelShipment
{
    [_requestShipment cancel];
    _requestShipment = nil;
    [_objectManagerShipment.operationQueue cancelAllOperations];
    _objectManagerShipment = nil;
}

-(void)configureRestKitShipment
{
    _objectManagerShipment = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ShipmentOrder class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ShipmentResult class]];
    
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[ShipmentCourier class]];
    [listMapping addAttributeMappingsFromArray:@[API_SHIPMENT_ID_KEY,
                                                 API_SHIPMENT_NAME_KEY
                                                ]];
    
    RKRelationshipMapping *resultRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                   toKeyPath:kTKPD_APIRESULTKEY
                                                                                 withMapping:resultMapping];
    
    RKRelationshipMapping *listRel =[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY
                                                                                toKeyPath:API_SHIPMENT_KEY
                                                                              withMapping:listMapping];
    
    
    [statusMapping addPropertyMapping:resultRel];
    [resultMapping addPropertyMapping:listRel];
 
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:API_PATH_INBOX_RESOLUTION_CENTER
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerShipment addResponseDescriptor:responseDescriptor];
    
}

-(void)requestShipment
{
    if (_requestShipment.isExecuting) return;
    NSTimer *timer;
    
    _shipmentLabel.text = @"Processing...";
    
    NSDictionary* param = @{API_ACTION_KEY : ACTION_GET_SHIPMENT_LIST};
 
    
#if DEBUG
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary* auth = [secureStorage keychainDictionary];
    
    NSString *userID = [auth objectForKey:kTKPD_USERIDKEY];
    
    NSMutableDictionary *paramDictionary = [NSMutableDictionary new];
    [paramDictionary addEntriesFromDictionary:param];
    [paramDictionary setObject:@"off" forKey:@"enc_dec"];
    [paramDictionary setObject:userID forKey:kTKPD_USERIDKEY];
    
    _requestShipment = [_objectManagerShipment appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:API_PATH_INBOX_RESOLUTION_CENTER parameters:paramDictionary];
#else
    _requestShipment = [_objectManagerShipment appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_PATH_INBOX_RESOLUTION_CENTER parameters:[param encrypt]];
#endif
    
    [_requestShipment setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessShipment:mappingResult withOperation:operation];
        [timer invalidate];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureShipmentErrorMessage:@[error.localizedDescription]];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestShipment];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutShipment) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessShipment:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    ShipmentOrder *order = stat;
    BOOL status = [order.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if(order.message_error)
        {
            [self requestFailureShipmentErrorMessage:order.message_error];
        }
        else{
            [_list addObjectsFromArray:order.result.shipment];
            _shipmentLabel.text = _selectedShipment.shipment_name?:@"Pilih Kurir Agent";
        }
    }
    else
    {
        [self requestFailureShipmentErrorMessage:@[order.status]];
    }
}

-(void)requestFailureShipmentErrorMessage:(NSArray*)errorMessage
{
    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessage delegate:self];
    [alert show];
}

-(void)requestProcessShipment
{

}

-(void)requestTimeoutShipment
{
    [self cancelShipment];
}

@end
