//
//  InboxResolutionCenterOpenViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/27/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxResolutionCenterOpenViewController.h"
#import "string_inbox_resolution_center.h"
#import "detail.h"
#import "TransactionAction.h"

#import "UploadImage.h"
#import "GenerateHost.h"
#import "camera.h"
#import "CameraController.h"

#import "GeneralTableViewController.h"

#import "StickyAlertView.h"

#define DATA_PHOTO_UPLOADING @"data_photo_uploading"
#define DATA_IMAGEVIEW_UPLOADING @"data_imageview_uploading"

@interface InboxResolutionCenterOpenViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, GeneralTableViewControllerDelegate, CameraControllerDelegate, InboxResolutionCenterOpenViewControllerDelegate>
{
    BOOL _isNodata;
    NSString *_URINext;
    NSMutableDictionary *_dataInput;
    NSMutableArray *_photos;
    NSString *_selectedSolution;
    NSString *_totalRefund;
    NSString *_remark;
    
    UITextField *_activeTextField;
    UITextView *_activeTextView;
    
    NSMutableArray *_uploadingPhotos;
    
    NSOperationQueue *_operationQueue;
    
    __weak RKObjectManager *_objectManagerComplain;
    __weak RKManagedObjectRequestOperation *_requestComplain;
    __weak RKObjectManager *_objectManagerUploadPhoto;
    NSURLRequest *_requestActionUploadPhoto;
    __weak RKObjectManager *_objectManagerGenerateHost;
    __weak RKManagedObjectRequestOperation *_requestGenerateHost;
    
    BOOL _isFinishUploadingImage;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewUploadPhoto;
@property (weak, nonatomic) IBOutlet UIView *contentViewUploadPhoto;
@property (weak, nonatomic) IBOutlet UILabel *fromTotalDescription;

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *invoiceLabel;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *shopImageView;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellRefundAmount;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellSolution;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellNote;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellUploadPhotos;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *totalInvoiceLabel;
@property (weak, nonatomic) IBOutlet UITextField *totalRefundTextField;

@property (weak, nonatomic) IBOutlet UILabel *problemSolutionHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *problemSolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *choosenProblemSolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteHeaderLabel;
@property (weak, nonatomic) IBOutlet UITextView *noteTextView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *uploadButtons;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *uploadedImages;

@end

@implementation InboxResolutionCenterOpenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataInput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    _generatehost = [GenerateHost new];
    _photos = [NSMutableArray new];
    _uploadingPhotos = [NSMutableArray new];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:(_indexPage==0&&_isGotTheOrder)?@"Lanjut":@"Komplain" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [backBarButtonItem setTintColor:[UIColor whiteColor]];
    backBarButtonItem.tag = 11;
    self.navigationItem.rightBarButtonItem = backBarButtonItem;
    
    [self setData];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
    
    [self configureRestkitGenerateHost];
    [self requestGenerateHost];
}

-(void)updateDataSolution:(NSString *)selectedSolution refundAmount:(NSString *)refund remark:(NSString *)note
{
    _selectedSolution = selectedSolution;
    _totalRefund = refund;
    _remark = note;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (_indexPage == 1) {
        [_delegate updateDataSolution:_selectedSolution refundAmount:_totalRefund remark:_remark];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Action

-(void)didDismissCameraController:(CameraController *)controller withUserInfo:(NSDictionary *)userinfo
{
    NSMutableDictionary *object = [NSMutableDictionary new];
    [object setObject:userinfo forKey:DATA_PHOTO_UPLOADING];
    UIImageView *imageView;
    for (UIImageView *image in _uploadedImages) {
        if (image.tag == controller.tag)
        {
            imageView = image;
        }
    }
    [object setObject:imageView forKey:DATA_IMAGEVIEW_UPLOADING];
    
    NSDictionary* photo = [userinfo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    
    UIImage* image = [photo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    UIGraphicsBeginImageContextWithOptions(kTKPDCAMERA_UPLOADEDIMAGESIZE, NO, image.scale);
    [image drawInRect:kTKPDCAMERA_UPLOADEDIMAGERECT];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //[_uploadButtons makeObjectsPerformSelector:@selector(setEnabled:) withObject:@(NO)];
    //[_uploadButtons makeObjectsPerformSelector:@selector(setHidden:) withObject:@(YES)];
    
    for (UIButton *button in _uploadButtons) {
        if (button.tag == controller.tag) {
            button.enabled = NO;
            button.hidden = YES;
        }
        if (button.tag == controller.tag+1)
        {
            button.enabled = YES;
            button.hidden = NO;
        }
    }
    
    imageView.image = image;
    imageView.hidden = NO;
    imageView.alpha = 0.5f;
    
    [self configureRestkitUploadPhoto];
    [self requestActionUploadPhoto:object];
}


-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    _scrollViewUploadPhoto.contentSize = _contentViewUploadPhoto.frame.size;
}

-(IBAction)tap:(id)sender
{
    [_activeTextView resignFirstResponder];
    [_noteTextView resignFirstResponder];
    _remark = _noteTextView.text;
    _activeTextView = nil;
    
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton*)sender;
        CameraController* c = [CameraController new];
        [c snap];
        c.delegate = self;
        c.tag = button.tag;
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:c];
        nav.wantsFullScreenLayout = YES;
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
    else
    {
        if (_indexPage==0)
        {
            if (!_isFinishUploadingImage) {
                StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:@[@"Belum selesai meng-upload image"] delegate:self];
                [alert show];
            }
            else
            {
                InboxResolutionCenterOpenViewController *vc = [InboxResolutionCenterOpenViewController new];
                vc.indexPage = 1;
                vc.selectedProblem = _selectedProblem;
                vc.isGotTheOrder = _isGotTheOrder;
                vc.order = _order;
                vc.uploadedPhotos = _photos;
                vc.generatehost = _generatehost;
                vc.delegate = self;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
        else
        {
            if ([self isValidInput]) {
                [self configureRestKitComplain];
                [self requestComplain];
            }
            
        }
    }

}

-(BOOL)isValidInput
{
    BOOL isValid = YES;
    NSMutableArray *errorMessage = [NSMutableArray new];
    
    if ([_remark isEqualToString:@""] || !(_remark)) {
        isValid = NO;
        [errorMessage addObject:ERRORMESSAGE_NULL_REMARK];
    }
    
    if ([_selectedSolution isEqualToString:ARRAY_SOLUTION_PRODUCT_NOT_SAME_AS_DESCRIPTION[0]]||
        [_selectedSolution isEqualToString:ARRAY_SOLUTION_PRODUCT_NOT_SAME_AS_DESCRIPTION[2]]||
        [_selectedSolution isEqualToString:ARRAY_SOLUTION_DIFFERENT_QTY[0]]||
        [_selectedSolution isEqualToString:ARRAY_SOLUTION_DIFFERENT_QTY[2]])
    {
        if ([_totalRefund isEqualToString:@""]||!(_totalRefund)) {
            isValid = NO;
            [errorMessage addObject:ERRORMESSAGE_NULL_REFUND];
        }
        NSString *totalAmount = [_order.order_detail.detail_open_amount stringByReplacingOccurrencesOfString:@"." withString:@""];
        totalAmount = [totalAmount stringByReplacingOccurrencesOfString:@",-" withString:@""];
        if ([_totalRefund integerValue] > [totalAmount integerValue]) {
            isValid = NO;
            [errorMessage addObject:[NSString stringWithFormat:ERRORMESSAGE_INVALID_REFUND,_order.order_detail.detail_open_amount_idr]];
        }
    }
    
    if (!isValid) {
        StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessage delegate:self];
        [alert show];
    }
    return isValid;
}

#pragma mark - Table View Data Source
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isGotTheOrder) {
        if (indexPath.section == 0)
            return [self cellGotTheOrderSection0].frame.size.height;
        if (indexPath.section == 1)
            return [self cellGotTheOrderSection1].frame.size.height;
        else if (indexPath.section == 2)
            return _cellNote.frame.size.height;
    }
    else
    {
        if (indexPath.section == 0)
            return _cellRefundAmount.frame.size.height;
        else
            return _cellNote.frame.size.height;
    }
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_isGotTheOrder)
        return ([self isNeed3Section])?3:2;
    else
        return 2;
    return 0;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
   
    if (_isGotTheOrder) {
        cell = [self cellGotTheOrderAtIndexPath:indexPath];
    }
    else
    {
        if (indexPath.section == 0)
            cell = _cellRefundAmount;
        else
            cell = _cellNote;
    }
    [self adjustDataCellAtIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [_activeTextField resignFirstResponder];
    [_activeTextView resignFirstResponder];
    [_noteTextView resignFirstResponder];
}

#pragma mark - Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_activeTextView resignFirstResponder];
    [_activeTextField resignFirstResponder];
    if (indexPath.section==0 && _isGotTheOrder) {
        if (_indexPage == 0) {
            [self shouldPushGeneralViewControllerTitle:@"Pilih Masalah"
                                               Objects:ARRAY_PROBLEM_COMPLAIN
                                             indexPath:indexPath
                                        selectedObject:_selectedProblem];
        }
        else
        {
            [self shouldPushGeneralViewControllerTitle:@"Pilih Solusi"
                                               Objects:[self solutions]
                                             indexPath:indexPath
                                        selectedObject:_selectedSolution];
        }
    }
}


-(void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0 && _isGotTheOrder) {
        if (_indexPage == 0)
            _selectedProblem = object;
        else
            _selectedSolution = object;
    }
    
    [_tableView reloadData];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isNodata) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    
    if (row == indexPath.row) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        NSLog(@"%ld", (long)row);
        
    }
}

#pragma mark - Cell
-(UITableViewCell*)cellGotTheOrderAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell;
    if (indexPath.section == 0)
        cell = [self cellGotTheOrderSection0];
    else if (indexPath.section == 1)
        cell = [self cellGotTheOrderSection1];
    else if (indexPath.section == 2)
        cell = _cellNote;
    return cell;
}

-(UITableViewCell*)cellGotTheOrderSection0
{
    UITableViewCell* cell;
    if ([_selectedProblem isEqualToString:[ARRAY_PROBLEM_COMPLAIN lastObject]]&&_indexPage == 1)
        cell = _cellRefundAmount;
    else cell = _cellSolution;
    return cell;
}

-(UITableViewCell*)cellGotTheOrderSection1
{
    UITableViewCell* cell;
    if (_indexPage == 0)
        cell = _cellUploadPhotos;
    else if ([_selectedSolution isEqualToString:ARRAY_SOLUTION_PRODUCT_NOT_SAME_AS_DESCRIPTION[0]]||
             [_selectedSolution isEqualToString:ARRAY_SOLUTION_PRODUCT_NOT_SAME_AS_DESCRIPTION[2]]||
             [_selectedSolution isEqualToString:ARRAY_SOLUTION_DIFFERENT_QTY[0]]||
             [_selectedSolution isEqualToString:ARRAY_SOLUTION_DIFFERENT_QTY[2]])
        cell = _cellRefundAmount;
    else
        cell = _cellNote;
    return cell;
}

#pragma mark - Text Field Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [_activeTextView resignFirstResponder];
    _activeTextView = nil;
    _activeTextField = textField;
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == _totalRefundTextField) {
        _totalRefund = textField.text;
    }
    _activeTextField = nil;
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _totalRefundTextField) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        if([string length]==0)
        {
            [formatter setGroupingSeparator:@","];
            [formatter setGroupingSize:4];
            [formatter setUsesGroupingSeparator:YES];
            [formatter setSecondaryGroupingSize:3];
            NSString *num = textField.text ;
            num = [num stringByReplacingOccurrencesOfString:@"," withString:@""];
            NSString *str = [formatter stringFromNumber:[NSNumber numberWithDouble:[num doubleValue]]];
            textField.text = str;
            return YES;
        }
        else {
            [formatter setGroupingSeparator:@","];
            [formatter setGroupingSize:2];
            [formatter setUsesGroupingSeparator:YES];
            [formatter setSecondaryGroupingSize:3];
            NSString *num = textField.text ;
            if(![num isEqualToString:@""])
            {
                num = [num stringByReplacingOccurrencesOfString:@"," withString:@""];
                NSString *str = [formatter stringFromNumber:[NSNumber numberWithDouble:[num doubleValue]]];
                textField.text = str;
            }
            return YES;
        }
    }
    return YES;
}

#pragma mark - Text View Delegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [_activeTextField resignFirstResponder];
    _activeTextField = nil;
    _activeTextView = textView;
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (textView == _noteTextView) {
        _remark = textView.text;
    }
    _activeTextView = nil;
    return YES;
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _tableView.contentInset = contentInsets;
    _tableView.scrollIndicatorInsets = contentInsets;
    
    if (_activeTextField == _totalRefundTextField) {
        [_tableView scrollToRowAtIndexPath:[_tableView indexPathForCell:_cellRefundAmount] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    if ([_noteTextView becomeFirstResponder]) {
        [_tableView scrollToRowAtIndexPath:[_tableView indexPathForCell:_cellNote] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)info {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _tableView.contentInset = contentInsets;
                         _tableView.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished){
                     }];
}

#pragma mark - methods
-(void)setData
{
    _tableView.tableHeaderView = _headerView;
    _invoiceLabel.text = _order.order_detail.detail_invoice;
    _shopNameLabel.text = _order.order_shop.shop_name;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_order.order_shop.shop_pic]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    UIImageView *thumb = _shopImageView;
    thumb.image = nil;
    [thumb setImageWithURLRequest:request
                 placeholderImage:[UIImage imageNamed:@"icon_default_shop.jpg"]
                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                              [thumb setImage:image animated:YES];
#pragma clang diagnosti c pop
                          } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                          }];
    
    _selectedSolution = _selectedSolution?:[[self solutions] firstObject];
    _selectedProblem = _selectedProblem?:[ARRAY_PROBLEM_COMPLAIN firstObject];
    
    [_noteTextView setPlaceholder:@"Isi alasan Anda disini"];
}

-(void)adjustDataCellAtIndexPath:(NSIndexPath*)indexPath
{
    if (_isGotTheOrder) {
        _problemSolutionHeaderLabel.text = (_indexPage == 0)?@"Masalah pada barang yang Anda terima":@"Solusi yang Anda inginkan untuk masalah ini?";
        _problemSolutionLabel.text = (_indexPage == 0)?@"Masalah":@"Solution";
        _choosenProblemSolutionLabel.text = (_indexPage == 0)?_selectedProblem:_selectedSolution;
        
        _noteHeaderLabel.text = @"Pesan untuk penjual";
    }
    else
    {
        _noteHeaderLabel.text = @"Alasan Anda memilih salah satu solusi diatas";
    }
    
    if ([_selectedProblem isEqualToString:ARRAY_PROBLEM_COMPLAIN[3]]) {
        _fromTotalDescription.text = @"Dari Total Ongkos Kirim";
        _totalInvoiceLabel.text = _order.order_detail.detail_shipping_price_idr;
    }
    else
    {
        _fromTotalDescription.text = @"Dari Total Invoice";
        _totalInvoiceLabel.text = _order.order_detail.detail_open_amount_idr;
    }
}

-(void)shouldPushGeneralViewControllerTitle:(NSString*)title Objects:(NSArray*)objects indexPath:(NSIndexPath*)indexPath selectedObject:(id)selectedObject
{
    GeneralTableViewController *controller = [GeneralTableViewController new];
    controller.delegate = self;
    controller.senderIndexPath = indexPath;
    controller.title =title;
    controller.objects = objects;
    controller.selectedObject = selectedObject;
    [self.navigationController pushViewController:controller animated:YES];
}

-(NSArray*)solutions
{
    NSArray *solutions;
    if ([_selectedProblem isEqualToString:ARRAY_PROBLEM_COMPLAIN[0]])
        solutions = ARRAY_SOLUTION_PRODUCT_NOT_SAME_AS_DESCRIPTION;
    else if ([_selectedProblem isEqualToString:ARRAY_PROBLEM_COMPLAIN[1]])
        solutions = ARRAY_SOLUTION_PRODUCT_IS_BROKEN;
    else if ([_selectedProblem isEqualToString:ARRAY_PROBLEM_COMPLAIN[2]])
        solutions = ARRAY_SOLUTION_DIFFERENT_QTY;
    else
        solutions = ARRAY_SOLUTION_DIFFERENT_SHIPPING_AGENCY;
    return solutions;
}

-(BOOL)isNeed3Section
{
    if ([_selectedSolution isEqualToString:ARRAY_SOLUTION_PRODUCT_NOT_SAME_AS_DESCRIPTION[0]]||
        [_selectedSolution isEqualToString:ARRAY_SOLUTION_PRODUCT_NOT_SAME_AS_DESCRIPTION[2]]||
        [_selectedSolution isEqualToString:ARRAY_SOLUTION_DIFFERENT_QTY[0]]||
        [_selectedSolution isEqualToString:ARRAY_SOLUTION_DIFFERENT_QTY[2]])
    {
        return YES;
    }
    return NO;
}

#pragma mark - Request Get Transaction Order Payment Confirmation
-(void)cancelComplain
{
    [_requestComplain cancel];
    _requestComplain = nil;
    [_objectManagerComplain.operationQueue cancelAllOperations];
    _objectManagerComplain = nil;
}

-(void)configureRestKitComplain
{
    _objectManagerComplain = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionActionResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPD_APIISSUCCESSKEY:kTKPD_APIISSUCCESSKEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:API_PATH_ACTION_RESOLUTION_CENTER keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerComplain addResponseDescriptor:responseDescriptor];
    
}

//TROUBLE_DIFF_DESCRIPTION    => 1,
//TROUBLE_BROKEN              => 2,
//TROUBLE_DIFF_QUANTITY       => 3,
//TROUBLE_DIFF_CARRIER        => 4,
//TROUBLE_PRODUCT_NOT_RECEIVED=> 5
//
//SOLUTION_REFUND         => 1,
//SOLUTION_RETUR          => 2,
//SOLUTION_RETUR_REFUND   => 3,
//SOLUTION_SELLER_WIN     => 4,
//SOLUTION_SEND_REMAINING => 5

-(NSString *)troubleType
{
    NSString *troubleType;
    if ([_selectedProblem isEqualToString:ARRAY_PROBLEM_COMPLAIN[0]]) {
        troubleType = @"1";
    }
    else if ([_selectedProblem isEqualToString:ARRAY_PROBLEM_COMPLAIN[1]]) {
        troubleType = @"2";
    }
    else if ([_selectedProblem isEqualToString:ARRAY_PROBLEM_COMPLAIN[2]]) {
        troubleType = @"3";
    }
    else if ([_selectedProblem isEqualToString:ARRAY_PROBLEM_COMPLAIN[3]]) {
        troubleType = @"4";
    }
    return troubleType;
}

-(NSString*)solutionType
{
    NSString *solutionType;
    if ([_selectedSolution isEqualToString:ARRAY_SOLUTION_PRODUCT_NOT_SAME_AS_DESCRIPTION[0]]) {
        solutionType = @"1";
    }
    else if ([_selectedSolution isEqualToString:ARRAY_SOLUTION_PRODUCT_NOT_SAME_AS_DESCRIPTION[1]]) {
        solutionType = @"2";
    }
    else if ([_selectedSolution isEqualToString:ARRAY_SOLUTION_PRODUCT_NOT_SAME_AS_DESCRIPTION[2]]) {
        solutionType = @"3";
    }
    else if ([_selectedSolution isEqualToString:ARRAY_SOLUTION_DIFFERENT_QTY[2]]) {
        solutionType = @"5";
    }
    return solutionType;
}

-(void)requestComplain
{
    if (_requestComplain.isExecuting) return;
    NSTimer *timer;
    
    NSString *troubleType = [self troubleType]?:@"";
    NSString *solutionType = [self solutionType]?:@"";
    
    NSMutableArray *fileThumbImage = [NSMutableArray new];
    for (UploadImageResult *image in _uploadedPhotos) {
        [fileThumbImage addObject:image.file_th];
    }
    NSString *photos = [[fileThumbImage valueForKey:@"description"] componentsJoinedByString:@"~"]?:@"";
    
    NSDictionary* param = @{API_ACTION_KEY : ACTION_CREATE_RESOLUTION,
                            API_ORDER_ID_KEY : _order.order_detail.detail_order_id?:@"",
                            API_FLAG_RECIEVED_KEY : @(_isGotTheOrder),
                            API_TROUBLE_TYPE_KEY: troubleType,
                            API_SOLUTION_KEY : solutionType,
                            API_REFUND_AMOUNT_KEY : _totalRefund?:@"",
                            API_REMARK_KEY : _remark?:@"",
                            API_PHOTOS_KEY : photos,
                            API_SERVER_ID_KEY : _generatehost.result.generated_host.server_id?:@"0"
                            };
    
#if DEBUG
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary* auth = [secureStorage keychainDictionary];
    
    NSString *userID = [auth objectForKey:kTKPD_USERIDKEY];
    
    NSMutableDictionary *paramDictionary = [NSMutableDictionary new];
    [paramDictionary addEntriesFromDictionary:param];
    [paramDictionary setObject:@"off" forKey:@"enc_dec"];
    [paramDictionary setObject:userID?:@"" forKey:kTKPD_USERIDKEY];
    
    _requestComplain = [_objectManagerComplain appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:API_PATH_ACTION_RESOLUTION_CENTER parameters:paramDictionary];
#else
    _requestComplain = [_objectManagerComplain appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_PATH_ACTION_RESOLUTION_CENTER parameters:[param encrypt]];
#endif
    
    [_requestComplain setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessComplain:mappingResult withOperation:operation];
        [timer invalidate];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureComplain:error];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestComplain];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutComplain) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessComplain:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TransactionAction *order = stat;
    BOOL status = [order.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessComplain:object];
    }
}

-(void)requestFailureComplain:(id)object
{
    [self requestProcessComplain:object];
}

-(void)requestProcessComplain:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            TransactionAction *order = stat;
            BOOL status = [order.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(order.message_error)
                {
                    NSArray *array = order.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:array delegate:self];
                    [alert show];
                }
                else{
                    [[NSNotificationCenter defaultCenter]postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:self];
                    [[NSNotificationCenter defaultCenter]postNotificationName:REFRESH_TX_ORDER_POST_NOTIFICATION_NAME object:self];
                    //TODO:: detail complain
                    
                }
            }
        }
        else{
            
            [self cancelComplain];
            NSError *error = object;
            if ([error code] != NSURLErrorCancelled) {
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeoutComplain
{
    [self cancelComplain];
}

#pragma mark Request Generate Host
-(void)configureRestkitGenerateHost
{
    _objectManagerGenerateHost =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[GenerateHost class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[GenerateHostResult class]];
    
    RKObjectMapping *generatedhostMapping = [RKObjectMapping mappingForClass:[GeneratedHost class]];
    [generatedhostMapping addAttributeMappingsFromDictionary:@{
                                                               kTKPDGENERATEDHOST_APISERVERIDKEY:kTKPDGENERATEDHOST_APISERVERIDKEY,
                                                               kTKPDGENERATEDHOST_APIUPLOADHOSTKEY:kTKPDGENERATEDHOST_APIUPLOADHOSTKEY,
                                                               kTKPDGENERATEDHOST_APIUSERIDKEY:kTKPDGENERATEDHOST_APIUSERIDKEY
                                                               }];
    // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDGENERATEDHOST_APIGENERATEDHOSTKEY toKeyPath:kTKPDGENERATEDHOST_APIGENERATEDHOSTKEY withMapping:generatedhostMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAIL_UPLOADIMAGEAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerGenerateHost addResponseDescriptor:responseDescriptor];
}

-(void)cancelGenerateHost
{
    [_requestGenerateHost cancel];
    _requestGenerateHost = nil;
    
    [_objectManagerGenerateHost.operationQueue cancelAllOperations];
    _objectManagerGenerateHost = nil;
}

- (void)requestGenerateHost
{
    if(_requestGenerateHost.isExecuting) return;
    
    NSTimer *timer;
    
    NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIUPLOADGENERATEHOSTKEY,
                            };
    
#if DEBUG
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary* auth = [secureStorage keychainDictionary];
    
    NSString *userID = [auth objectForKey:kTKPD_USERIDKEY];
    
    NSMutableDictionary *paramDictionary = [NSMutableDictionary new];
    [paramDictionary addEntriesFromDictionary:param];
    [paramDictionary setObject:@"off" forKey:@"enc_dec"];
    [paramDictionary setObject:userID?:@"" forKey:kTKPD_USERIDKEY];
    
    _requestGenerateHost = [_objectManagerGenerateHost appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDDETAIL_UPLOADIMAGEAPIPATH parameters:paramDictionary];

#else
    _requestGenerateHost = [_objectManagerGenerateHost appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAIL_UPLOADIMAGEAPIPATH parameters:[param encrypt]];

#endif
    
    
    [_requestGenerateHost setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessGenerateHost:mappingResult withOperation:operation];
        [timer invalidate];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFailureGenerateHost:error];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestGenerateHost];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutGenerateHost) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}


-(void)requestSuccessGenerateHost:(id)object withOperation:(RKObjectRequestOperation*)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    _generatehost = info;
    NSString *statusstring = _generatehost.status;
    BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessGenerateHost:object];
    }
}

-(void)requestFailureGenerateHost:(id)object
{
    
}

-(void)requestProcessGenerateHost:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id info = [result objectForKey:@""];
            _generatehost = info;
            NSString *statusstring = _generatehost.status;
            BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if ([_generatehost.result.generated_host.server_id integerValue] == 0 || _generatehost.message_error) {
                    [self configureRestkitGenerateHost];
                    [self requestGenerateHost];
                }
                else
                {
                    [[_uploadButtons objectAtIndex:0] setEnabled:YES];
                    [_dataInput setObject:_generatehost.result.generated_host.server_id forKey:API_SERVER_ID_KEY];
                }
                
            }
        }
        else
        {
            NSError *error = object;
            if (!([error code] == NSURLErrorCancelled)){
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeoutGenerateHost
{
    [self cancelGenerateHost];
}


#pragma mark Request Action Upload Photo
-(void)configureRestkitUploadPhoto
{
    _objectManagerUploadPhoto =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[UploadImage class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[UploadImageResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDSHOPEDIT_APIUPLOADFILEPATHKEY:kTKPDSHOPEDIT_APIUPLOADFILEPATHKEY,
                                                        kTKPDSHOPEDIT_APIUPLOADFILETHUMBKEY:kTKPDSHOPEDIT_APIUPLOADFILETHUMBKEY,
                                                        API_UPLOAD_PHOTO_ID_KEY:API_UPLOAD_PHOTO_ID_KEY
                                                        }];
    
    // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAIL_UPLOADIMAGEAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerUploadPhoto addResponseDescriptor:responseDescriptor];
    
    [_objectManagerUploadPhoto setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
    [_objectManagerUploadPhoto setRequestSerializationMIMEType:RKMIMETypeJSON];
}


- (void)cancelActionUploadPhoto
{
    _requestActionUploadPhoto = nil;
    
    [_operationQueue cancelAllOperations];
    _objectManagerUploadPhoto = nil;
}

- (void)requestActionUploadPhoto:(NSDictionary*)object
{
    for (NSObject *object in _uploadingPhotos) {
        if (![object isEqual:object]) {
            [_uploadingPhotos addObject:object];
        }
    }
    
    NSDictionary *uploadingObject = object;
    NSDictionary *imagePhoto = [uploadingObject objectForKey:DATA_PHOTO_UPLOADING];
    UIImageView *imageView = [uploadingObject objectForKey:DATA_IMAGEVIEW_UPLOADING];
    
    NSDictionary *photo = [imagePhoto objectForKey: kTKPDCAMERA_DATAPHOTOKEY];
    NSData* imageData = [photo objectForKey:DATA_CAMERA_IMAGEDATA];
    NSString* imageName = [photo objectForKey:DATA_CAMERA_IMAGENAME];
    NSString *serverID = _generatehost.result.generated_host.server_id?:@"0";
    
    NSDictionary *param = @{ API_ACTION_KEY:ACTION_UPLOAD_CONTACT_IMAGE,
                             kTKPDGENERATEDHOST_APISERVERIDKEY:serverID,
                             };
    
    
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary* auth = [secureStorage keychainDictionary];
    
    NSString *userID = [auth objectForKey:kTKPD_USERIDKEY];
    
    NSMutableDictionary *paramDictionary = [NSMutableDictionary new];
    [paramDictionary addEntriesFromDictionary:param];
    [paramDictionary setObject:@"off" forKey:@"enc_dec"];
    [paramDictionary setObject:userID?:@"" forKey:kTKPD_USERIDKEY];
    
    _requestActionUploadPhoto = [NSMutableURLRequest requestUploadImageData:imageData
                                                                   withName:API_UPLOAD_PRODUCT_IMAGE_DATA_NAME
                                                                andFileName:imageName
                                                      withRequestParameters:paramDictionary
                                 ];


    _isFinishUploadingImage = NO;
    
    NSUInteger index = [[_dataInput objectForKey:kTKPDDETAIL_DATAINDEXKEY] integerValue];
    NSLog(@"Index image %zd", index);
    UIImageView *thumbProductImage = imageView;
    thumbProductImage.alpha = 0.5f;
    
    [NSURLConnection sendAsynchronousRequest:_requestActionUploadPhoto
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                               NSString *responsestring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               if ([httpResponse statusCode] == 200) {
                                   _isFinishUploadingImage = YES;
                                   id parsedData = [RKMIMETypeSerialization objectFromData:data MIMEType:RKMIMETypeJSON error:&error];
                                   if (parsedData == nil && error) {
                                       NSLog(@"parser error");
                                       [self requestFailureUploadPhoto:photo
                                                           atImageView:thumbProductImage
                                                             withError:nil];
                                       [self requestProcessUploadPhoto];
                                       return;
                                   }
                                   
                                   NSMutableDictionary *mappingsDictionary = [[NSMutableDictionary alloc] init];
                                   for (RKResponseDescriptor *descriptor in _objectManagerUploadPhoto.responseDescriptors) {
                                       [mappingsDictionary setObject:descriptor.mapping forKey:descriptor.keyPath];
                                   }
                                   
                                   RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData mappingsDictionary:mappingsDictionary];
                                   NSError *mappingError = nil;
                                   BOOL isMapped = [mapper execute:&mappingError];
                                   if (isMapped && !mappingError) {
                                       NSLog(@"result %@",[mapper mappingResult]);
                                       RKMappingResult *mappingresult = [mapper mappingResult];
                                       NSDictionary *result = mappingresult.dictionary;
                                       id stat = [result objectForKey:@""];
                                       UploadImage *image = stat;
                                       BOOL status = [image.status isEqualToString:kTKPDREQUEST_OKSTATUS];
                                       
                                       if (status) {
                                           
                                           if (!image.message_error) {
                                            
                                               [self requestSuccessUploadPhoto:object
                                                                   atImageView:thumbProductImage
                                                             withMappingResult:mappingresult];
                                           }
                                           else
                                           {
                                               NSArray *array = image.message_error?:[[NSArray alloc] initWithObjects:@"Error", nil];
                                               StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:array delegate:self];
                                               [alert show];
                                               [self requestFailureUploadPhoto:object
                                                                   atImageView:thumbProductImage
                                                                     withError:nil];
                                           }
                                       }
                                       else
                                       {
                                           [self requestFailureUploadPhoto:object
                                                               atImageView:thumbProductImage
                                                                 withError:image.status];
                                       }
                                   }
                                   else
                                   {
                                       [self requestFailureUploadPhoto:object
                                                           atImageView:thumbProductImage
                                                             withError:@"error"];
                                   }
                                   
                               }
                               else
                               {
                                    NSString *errorDescription = error.localizedDescription;
                                   [self requestFailureUploadPhoto:object
                                                       atImageView:thumbProductImage
                                                         withError:errorDescription];
                               }
                               NSLog(@"%@",responsestring);
                               [self requestProcessUploadPhoto];
                           }];
}

- (void)requestSuccessUploadPhoto:(NSDictionary*)object atImageView:(UIImageView*)imageView withMappingResult:(RKMappingResult*)mappingResult
{
    NSDictionary *result = mappingResult.dictionary;
    id stat = [result objectForKey:@""];
    UploadImage *image = stat;
    
    imageView.alpha = 1.0;
    [_photos addObject:image.result];
    [_uploadingPhotos removeObject:object];
}

- (void)requestFailureUploadPhoto:(NSDictionary*)object atImageView:(UIImageView*)imageView withError:(NSString*)error
{
    if (error) {
        UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:error?:@"Error" delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
        [errorAlert show];
    }
    
    imageView.image = nil; //TODO::placeholder image
    
    for (UIButton *button in _uploadButtons) {
        if (button.tag == imageView.tag) {
            button.enabled = YES;
            button.hidden = NO;
        }
    }
    [_uploadingPhotos removeObject:object];
}


- (void)requestProcessUploadPhoto
{
    if (_uploadingPhotos.count > 0) {
        [self configureRestkitUploadPhoto];
        [self requestActionUploadPhoto:[_uploadingPhotos firstObject]];
    }
}



@end
