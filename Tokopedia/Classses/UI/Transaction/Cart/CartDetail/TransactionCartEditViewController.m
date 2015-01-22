//
//  TransactionCartEditViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/14/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "string_transaction.h"
#import "string_product.h"
#import "detail.h"
#import "ProductDetail.h"
#import "TransactionAction.h"
#import "TransactionCartEditViewController.h"

@interface TransactionCartEditViewController ()<UITextViewDelegate>
{
    NSMutableDictionary *_dataInput;
    NSOperationQueue *_operationQueue;
    UIBarButtonItem *_barButtonSave;
    UITextView *_activeTextView;
    
    __weak RKObjectManager *_objectManagerActionEditProductCart;
    __weak RKManagedObjectRequestOperation *_requestActionEditProductCart;
}

@property (weak, nonatomic) IBOutlet UIImageView *productThumbImageView;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UIStepper *quantityStepper;
@property (weak, nonatomic) IBOutlet UITextView *remarkTextView;

-(void)cancelActionEditProductCartRequest;
-(void)configureRestKitActionEditProductCart;
-(void)requestActionEditProductCart:(id)object;
-(void)requestSuccessActionEditProductCart:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailureActionEditProductCart:(id)object;
-(void)requestProcessActionEditProductCart:(id)object;
-(void)requestTimeoutActionEditProductCart;

@end

@implementation TransactionCartEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    _dataInput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [cancelBarButtonItem setTintColor:[UIColor whiteColor]];
    cancelBarButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_BACK;
    self.navigationItem.rightBarButtonItem = cancelBarButtonItem;
    
    _barButtonSave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [_barButtonSave setTintColor:[UIColor blackColor]];
    _barButtonSave.tag = TAG_BAR_BUTTON_TRANSACTION_DONE;
    self.navigationItem.rightBarButtonItem = _barButtonSave;
    
    [self setDefaultData:_data];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    [_activeTextView resignFirstResponder];
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        switch (button.tag) {
            case TAG_BAR_BUTTON_TRANSACTION_BACK:
                [self.navigationController popViewControllerAnimated:YES];
                break;
            case TAG_BAR_BUTTON_TRANSACTION_DONE:
                [self configureRestKitActionEditProductCart];
                [self requestActionEditProductCart:_dataInput];
                break;
            default:
                break;
        }
    }
    if ([sender isKindOfClass:[UIStepper class]]) {
        UIStepper *stepper = (UIStepper*)sender;
        _quantityLabel.text = [NSString stringWithFormat:@"%zd",(NSInteger)stepper.value];
        [_dataInput setObject:_quantityLabel.text forKey:API_PRODUCT_QUANTITY_KEY];
    }
}

#pragma mark - Request Cancel Cart
-(void)cancelActionEditProductCartRequest
{
    [_requestActionEditProductCart cancel];
    _requestActionEditProductCart = nil;
    [_objectManagerActionEditProductCart.operationQueue cancelAllOperations];
    _objectManagerActionEditProductCart = nil;
}

-(void)configureRestKitActionEditProductCart
{
    _objectManagerActionEditProductCart = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionActionResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{API_IS_SUCCESS_KEY:API_IS_SUCCESS_KEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:API_ACTION_TRANSACTION_PATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerActionEditProductCart addResponseDescriptor:responseDescriptor];

    
}

//# sub edit_product example URL
//# www.tkpdevel-pg.ekarisky/ws/action/tx-cart.pl?action=edit_product&
//# product_cart_id=&
//# product_notes=&
//# product_quantity=
-(void)requestActionEditProductCart:(id)object
{
    if (_requestActionEditProductCart.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userInfo = (NSDictionary*)object;
    
    ProductDetail *product = [_data objectForKey:DATA_CART_PRODUCT_KEY];
    
    NSInteger productCartID = [product.product_cart_id integerValue];
    NSString *productNotes = [userInfo objectForKey:API_CART_PRODUCT_NOTES_KEY]?:@""?:product.product_notes;
    NSInteger productQty = [[userInfo objectForKey:API_PRODUCT_QUANTITY_KEY]integerValue]?:product.product_quantity;
    
    NSDictionary* param = @{API_ACTION_KEY :ACTION_EDIT_PRODUCT_CART,
                            API_PRODUCT_CART_ID_KEY : @(productCartID),
                            API_CART_PRODUCT_NOTES_KEY:productNotes,
                            API_PRODUCT_QUANTITY_KEY:@(productQty)
                            };
    _barButtonSave.enabled = NO;
    _requestActionEditProductCart = [_objectManagerActionEditProductCart appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_ACTION_TRANSACTION_PATH parameters:[param encrypt]];
    [_requestActionEditProductCart setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionEditProductCart:mappingResult withOperation:operation];
        [timer invalidate];
        _barButtonSave.enabled = YES;
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionEditProductCart:error];
        [timer invalidate];
        _barButtonSave.enabled = YES;
    }];
    
    [_operationQueue addOperation:_requestActionEditProductCart];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutActionEditProductCart) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessActionEditProductCart:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TransactionAction *action = stat;
    BOOL status = [action.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionEditProductCart:object];
    }
}

-(void)requestFailureActionEditProductCart:(id)object
{
    [self requestProcessActionEditProductCart:object];
}

-(void)requestProcessActionEditProductCart:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            TransactionAction *action = stat;
            BOOL status = [action.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(action.message_error)
                {
                    NSArray *array = action.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
                else{
                    if (action.result.is_success == 1) {
                        NSArray *array = action.message_status?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY, nil];
                        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
                        [[NSNotificationCenter defaultCenter] postNotificationName:EDIT_CART_POST_NOTIFICATION_NAME object:nil userInfo:nil];
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
            }
        }
        else{
            
            [self cancelActionEditProductCartRequest];
            NSError *error = object;
            if ([error code] != NSURLErrorCancelled) {
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeoutActionEditProductCart
{
    [self cancelActionEditProductCartRequest];
}

#pragma mark - TextView Delegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    _activeTextView = textView;
    
    return YES;
}


-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (textView == _remarkTextView) {
        [_dataInput setObject:textView.text forKey:API_CART_PRODUCT_NOTES_KEY];
    }
    return YES;
}

#pragma mark - Methods
-(void)setDefaultData:(NSDictionary*)data
{
    _data = data;
    if (data) {
        ProductDetail *product = [_data objectForKey:DATA_CART_PRODUCT_KEY];
        _productNameLabel.text = product.product_name;
        _productPriceLabel.text = product.product_price_idr;
        _quantityLabel.text = [NSString stringWithFormat:@"%zd",product.product_quantity];
        _quantityStepper.minimumValue= product.product_min_order;
        _quantityStepper.value = product.product_quantity;
        _remarkTextView.text = product.product_notes;
        
        NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:product.product_pic] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        
        UIImageView *thumb = _productThumbImageView;
        thumb.image = nil;
        [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            [thumb setImage:image animated:YES];
#pragma clang diagnosti c pop
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        }];
    }
}

@end
