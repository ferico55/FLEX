//
//  InboxResolutionCenterOpenViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/27/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterDetailViewController.h"
#import "ResolutionCenterInputViewController.h"
#import "TxOrderStatusViewController.h"
#import "InboxResolutionCenterOpenViewController.h"
#import "string_inbox_resolution_center.h"
#import "detail.h"
#import "TransactionAction.h"

#import "RequestUploadImage.h"
#import "UploadImage.h"
#import "GenerateHost.h"
#import "camera.h"

#import "GeneralTableViewController.h"
#import "UserAuthentificationManager.h"
#import "StickyAlertView.h"

#import "requestGenerateHost.h"
#import "TKPDPhotoPicker.h"

#import "RequestResolutionCenter.h"

#define TITLE_APPEAL @"Naik Banding"
#define TITLE_CHANGE_SOLUTION @"Ubah Solusi"
#define TITLE_OPEN_COMPLAIN @"Buka Komplain"

@interface InboxResolutionCenterOpenViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UITextFieldDelegate,
    UITextViewDelegate,
    GeneralTableViewControllerDelegate,
    InboxResolutionCenterOpenViewControllerDelegate,
    GenerateHostDelegate,
    RequestUploadImageDelegate,
    SyncroDelegate,
    TKPDPhotoPickerDelegate,
    TokopediaNetworkManagerDelegate,
    RequestResolutionCenterDelegate
>
{
    BOOL _isNodata;
    NSString *_URINext;
    NSMutableDictionary *_dataInput;
    NSMutableArray *_photos;
    
    UITextField *_activeTextField;
    UITextView *_activeTextView;
    
    NSMutableArray *_uploadingPhotos;
    
    NSOperationQueue *_operationQueue;
    
    __weak RKObjectManager *_objectManagerUploadPhoto;
    NSURLRequest *_requestActionUploadPhoto;
    
    BOOL _isFinishUploadingImage;

    TKPDPhotoPicker *_photoPicker;
    
    NSString *_serverID;
    NSString *_uploadHost;
    NSInteger _userID;
    
    RequestResolutionCenter *_requestResolutionCenter;
    
    GeneratedHost *_generatedHost;
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
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cancelButtons;
@property (weak, nonatomic) IBOutlet UIImageView *rightArrowImageView;

@end
#define TAG_REQUEST_OPEN_COMPLAIN 10

@implementation InboxResolutionCenterOpenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataInput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    _generatehost = [GenerateHost new];
    _photos = (_photos)?_photos:[[NSMutableArray alloc]initWithObjects:@"",@"",@"",@"",@"", nil];
    _uploadingPhotos = [NSMutableArray new];
    
    _cancelButtons = [NSArray sortViewsWithTagInArray:_cancelButtons];
    _uploadedImages = [NSArray sortViewsWithTagInArray:_uploadedImages];
    _uploadButtons = [NSArray sortViewsWithTagInArray:_uploadButtons];
    for(UIButton *btn in _cancelButtons) {
//        [_cancelButtons makeObjectsPerformSelector:@selector(setHidden:)withObject:@(YES)];
        btn.hidden = YES;
    }
//    [_cancelButtons makeObjectsPerformSelector:@selector(setHidden:)withObject:@(YES)];
    
    
    [self setData];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
    
    _isFinishUploadingImage = YES;
    
    if (_generatehost.result == nil && _indexPage !=1) {
        RequestGenerateHost *requestHost = [RequestGenerateHost new];
        [requestHost configureRestkitGenerateHost];
        [requestHost requestGenerateHost];
        requestHost.delegate = self;
    }

    [self adjustNavigationTitle];
    
    _generatedHost = [GeneratedHost new];
    _generatedHost.upload_host = _uploadHost;
    _generatedHost.server_id = _serverID;
    _generatedHost.user_id = _userID;
}

-(void)setGeneratehost:(GenerateHost *)generatehost
{
    _generatehost = generatehost;
    _serverID = generatehost.result.generated_host.server_id;
    _uploadHost = generatehost.result.generated_host.upload_host;
    _userID = generatehost.result.generated_host.user_id;
}

-(void)setControllerTitle:(NSString *)controllerTitle
{
    _controllerTitle = controllerTitle;
    [self adjustNavigationTitle];
}

-(RequestResolutionCenter*)requestResolutionCenter
{
    if (!_requestResolutionCenter) {
        _requestResolutionCenter = [RequestResolutionCenter new];
        _requestResolutionCenter.delegate = self;
    }
    return _requestResolutionCenter;
}

-(void)adjustNavigationTitle
{
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Batal" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [backBarButtonItem setTintColor:[UIColor whiteColor]];
    backBarButtonItem.tag = 10;
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    label.numberOfLines = 2;
    label.font = [UIFont systemFontOfSize: 11.0f];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    
    NSString *status = _isGotTheOrder?@"Sudah Terima Barang":@"Tidak Terima Barang";
    
    NSString *title = [NSString stringWithFormat:@"%@\nStatus: %@", _controllerTitle,status];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:title];
    [attributedText addAttribute:NSFontAttributeName
                           value:[UIFont boldSystemFontOfSize: 16.0f]
                           range:NSMakeRange(0, [_controllerTitle length])];
    
    label.attributedText = attributedText;

    self.navigationItem.titleView = label;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = _controllerTitle;
    
    NSString *titleSecondPage = @"";
    if ([_controllerTitle isEqualToString:TITLE_APPEAL]) {
        titleSecondPage = @"Konfirmasi";
    }
    else if ([_controllerTitle isEqualToString:TITLE_OPEN_COMPLAIN])
    {
        titleSecondPage = @"Komplain";
    }
    else if ([_controllerTitle isEqualToString:TITLE_CHANGE_SOLUTION])
    {
        titleSecondPage = @"Ubah";
    }
    else
        titleSecondPage = @"Selesai";
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:(_indexPage==0&&_isGotTheOrder)?@"Lanjut":titleSecondPage style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [backBarButtonItem setTintColor:[UIColor whiteColor]];
    backBarButtonItem.tag = 11;
    self.navigationItem.rightBarButtonItem = backBarButtonItem;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.title = @"";
    
    if ([_syncroDelegate respondsToSelector:@selector(syncroImages:message:refundAmount:)]) {
        [_syncroDelegate syncroImages:[_photos copy]?:@[] message:_noteTextView.text?:@"" refundAmount:_totalRefundTextField.text?:@""];
    }
}

-(void)updateDataSolution:(NSString *)selectedSolution refundAmount:(NSString *)refund remark:(NSString *)note
{
    _selectedSolution = selectedSolution;
    _totalRefund = refund;
    _note = note;
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)dealloc
{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View Action

- (void)photoPicker:(TKPDPhotoPicker *)picker didDismissCameraControllerWithUserInfo:(NSDictionary *)userInfo
{
    UIImageView *imageView;
    for (UIImageView *image in _uploadedImages) {
        if (image.tag == picker.tag) {
            imageView = image;
        }
    }
    
    if (userInfo != nil && imageView != nil) {
        NSDictionary *object = @{
                                 DATA_SELECTED_PHOTO_KEY : userInfo,
                                 DATA_SELECTED_IMAGE_VIEW_KEY : imageView
                                 };
        
        UIImage *image = [[userInfo objectForKey:kTKPDCAMERA_DATAPHOTOKEY] objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
        
        for (UIButton *button in _uploadButtons) {
            if (button.tag == picker.tag) {
                button.enabled = NO;
                button.hidden = YES;
            } else if (button.tag == picker.tag+1 && ((UIImageView*)_uploadedImages[(picker.tag+1)-10]).image == nil) {
                button.enabled = YES;
                button.hidden = NO;
            }
        }
        
        imageView.image = image;
        imageView.hidden = NO;
        imageView.alpha = 0.5f;
        
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [imageView setClipsToBounds:YES];
        
        [self actionUploadImage:object];   
    }
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
    _note = _noteTextView.text;
    _activeTextView = nil;
    
    if ([sender isKindOfClass:[UIButton class]]) {
        _photoPicker = [[TKPDPhotoPicker alloc] initWithParentViewController:self
                                                      pickerTransistionStyle:UIModalTransitionStyleCoverVertical];
        _photoPicker.delegate = self;
        _photoPicker.tag = [sender tag];
    }
    else
    {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        if (button.tag == 10) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            if (_indexPage==0)
            {
                if (!_isFinishUploadingImage) {
                    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:@[@"Anda belum selesai mengunggah gambar."] delegate:self];
                    [alert show];
                }
                else if(!_isGotTheOrder)
                    [self didTapDoneBarButtonItem];
                else
                    [self goToSecondPage];
            }
            else
                [self didTapDoneBarButtonItem];
        }
    }
}
- (IBAction)tapRemoveImage:(UIButton*)sender {
    [_photos replaceObjectAtIndex:sender.tag-10 withObject:@""];
    
    for (UIImageView *imageView in _uploadedImages) {
        if (imageView.tag == sender.tag) {
            imageView.image = nil;
        }
    }
    
    for (UIButton *button in _uploadButtons) {
        if (button.tag == sender.tag) {
            button.hidden = NO;
            button.enabled = YES;
        }
    }
    
    for (UIButton *button in _cancelButtons) {
        if (button.tag == sender.tag) {
            button.hidden = YES;
        }
    }
}

-(void)didTapDoneBarButtonItem
{
    if ([self isValidInput]) {
        if (_delegate!= nil && [_delegate respondsToSelector:@selector(setGenerated_host:)]) {
            [_delegate setGenerateHost:_generatedHost];
        }
        NSString *troubleType = [self troubleType]?:@"";
        NSString *solutionType = [self solutionType]?:@"";

        NSString *photos = [[_uploadedPhotos valueForKey:@"description"] componentsJoinedByString:@"~"]?:@"";
       
        NSString *server_id = _generatehost.result.generated_host.server_id?:_serverID?:@"0";
        
        if ([self.title isEqualToString:TITLE_APPEAL]) {

            [_delegate appealSolution:solutionType refundAmount:_totalRefund remark:_note photo:photos serverID:server_id];
            NSArray *viewControllers = self.navigationController.viewControllers;
            UIViewController *destinationVC;
            for (UIViewController *vc in viewControllers) {
                if ([vc isKindOfClass:[_delegate class]]) {
                    destinationVC = vc;
                }
            }
            [self.navigationController popToViewController:destinationVC animated:YES];
        }
        else if([self.title isEqualToString:TITLE_CHANGE_SOLUTION])
        {
            [_delegate changeSolution:solutionType troubleType:troubleType refundAmount:_totalRefund remark:_note photo:photos serverID:_serverID isGotTheOrder:_isGotTheOrder];
            NSArray *viewControllers = self.navigationController.viewControllers;
            UIViewController *destinationVC;
            for (UIViewController *vc in viewControllers) {
                if ([vc isKindOfClass:[_delegate class]]) {
                    destinationVC = vc;
                }
            }
            [self.navigationController popToViewController:destinationVC animated:YES];
        }
        else
        {
            NSString *troubleType = [self troubleType]?:@"";
            NSString *solutionType = [self solutionType]?:@"";
            
            NSString *photos = [[_uploadedPhotos valueForKey:@"description"] componentsJoinedByString:@"~"]?:@"";

            [self requestResolutionCenter].generatedHost = _generatedHost;
            [[self requestResolutionCenter] setParamCreateValidationFromID:_order.order_detail.detail_order_id?:@""
                                                              flagReceived:[@(_isGotTheOrder) stringValue]
                                                               troubleType:troubleType
                                                                  solution:solutionType
                                                              refundAmount:_totalRefund?:@""
                                                                    remark:_note?:@""
                                                                    photos:photos
                                                                   serverID: _generatehost.result.generated_host.server_id?:_serverID?:@"0"];
            [[self requestResolutionCenter] doRequestCreate];
        }
    }
}

-(BOOL)isValidInput
{
    BOOL isValid = YES;
    NSMutableArray *errorMessage = [NSMutableArray new];
    
    if ([_note isEqualToString:@""] || !(_note)) {
        isValid = NO;
        [errorMessage addObject:_isChangeSolution?ERRORMESSAGE_NULL_MESSAGE:ERRORMESSAGE_NULL_REMARK];
    }
    
    if ([_selectedSolution isEqualToString:ARRAY_SOLUTION_PRODUCT_NOT_SAME_AS_DESCRIPTION[0]]||
        [_selectedSolution isEqualToString:ARRAY_SOLUTION_PRODUCT_NOT_SAME_AS_DESCRIPTION[2]]||
        [_selectedSolution isEqualToString:ARRAY_SOLUTION_DIFFERENT_QTY[0]]||
        [_selectedSolution isEqualToString:ARRAY_SOLUTION_DIFFERENT_QTY[2]])
    {
        _totalRefund = [_totalRefundTextField.text stringByReplacingOccurrencesOfString:@"." withString:@""];
        if ([_totalRefund isEqualToString:@""]||!(_totalRefund)) {
            isValid = NO;
            [errorMessage addObject:ERRORMESSAGE_NULL_REFUND];
        }
        NSString *totalAmount = [_order.order_detail.detail_open_amount?:_detailOpenAmount stringByReplacingOccurrencesOfString:@"." withString:@""];
        totalAmount = [totalAmount stringByReplacingOccurrencesOfString:@",-" withString:@""];
        if ([_totalRefund integerValue] > [totalAmount integerValue]) {
            isValid = NO;
            [errorMessage addObject:[NSString stringWithFormat:ERRORMESSAGE_INVALID_REFUND,_order.order_detail.detail_open_amount_idr?:_detailOpenAmountIDR]];
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
        else if (indexPath.section == 1)
            return [self cellGotTheOrderSection1].frame.size.height;
        else if (indexPath.section == 2)
            return _cellNote.frame.size.height;
    }
    else
    {
        if (indexPath.section == 0)
            return [self cellNotGotTheOrderSection0].frame.size.height;
        else if (indexPath.section == 1){
            if ([_selectedSolution isEqualToString:ARRAY_SOLUTION_PACKAGE_NOT_RECEIVED[1]]) {
                return 0;
            }
            else
                return 138;
        }
        else
            return _cellNote.frame.size.height;
    }
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_isGotTheOrder && _indexPage == 1)
        return ([self isNeed3Section])?3:2;
    else
        return 3;
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
        cell = [self cellNotGotTheOrderAtIndexPath:indexPath];
    }
    [self adjustDataCellAtIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.clipsToBounds = YES;
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
    if ([tableView cellForRowAtIndexPath:indexPath] == _cellSolution) {
        if (!_isGotTheOrder) {
            [self shouldPushGeneralViewControllerTitle:@"Pilih Solusi"
                                               Objects:[self solutions]
                                             indexPath:indexPath
                                        selectedObject:_selectedSolution];
        }
        else {
            if (_indexPage == 0) {
                if (_isCanEditProblem) {
                    [self shouldPushGeneralViewControllerTitle:@"Pilih Masalah"
                                                       Objects:ARRAY_PROBLEM_COMPLAIN
                                                     indexPath:indexPath
                                                selectedObject:_selectedProblem];
                }
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

#pragma mark - General View Controller Delegate 

-(void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section==0) {
        if (_indexPage == 0  && _isGotTheOrder)
        {
            if ([_selectedProblem isEqual:object]) {
                _selectedSolution = [[self solutions] firstObject];
            }
            _selectedProblem = object;
        }
        else
            _selectedSolution = object;
    }
    
    [_tableView reloadData];
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

-(UITableViewCell*)cellNotGotTheOrderAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell;
    if (indexPath.section == 0)
        cell = [self cellNotGotTheOrderSection0];
    else if (indexPath.section == 1)
        cell = _cellRefundAmount;
    else
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

-(UITableViewCell*)cellNotGotTheOrderSection0
{
    UITableViewCell* cell;
    cell = _cellSolution;
    return cell;
}

-(UITableViewCell*)cellGotTheOrderSection1
{
    UITableViewCell* cell;
    if (_indexPage == 0)
        cell = _cellUploadPhotos;
    else if ([_selectedProblem isEqualToString:ARRAY_PROBLEM_COMPLAIN[3]])
        cell = _cellNote;
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
    [_noteTextView resignFirstResponder];
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
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _totalRefundTextField) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        if([string length]==0)
        {
            [formatter setGroupingSeparator:@"."];
            [formatter setGroupingSize:4];
            [formatter setUsesGroupingSeparator:YES];
            [formatter setSecondaryGroupingSize:3];
            NSString *num = textField.text ;
            num = [num stringByReplacingOccurrencesOfString:@"." withString:@""];
            NSString *str = [formatter stringFromNumber:[NSNumber numberWithDouble:[num doubleValue]]];
            textField.text = str;
            return YES;
        }
        else {
            [formatter setGroupingSeparator:@"."];
            [formatter setGroupingSize:2];
            [formatter setUsesGroupingSeparator:YES];
            [formatter setSecondaryGroupingSize:3];
            NSString *num = textField.text ;
            if(![num isEqualToString:@""])
            {
                num = [num stringByReplacingOccurrencesOfString:@"." withString:@""];
                NSString *str = [formatter stringFromNumber:[NSNumber numberWithDouble:[num doubleValue]]];
                textField.text = str;
            }
            return YES;
        }
    }
    return YES;
}

#pragma mark - Text View Delegate
- (void)textViewDidChange:(UITextView *)textView
{
    UILabel *placeholderLabel = (UILabel *)[textView viewWithTag:1];
    if (textView.text.length > 0) {
        placeholderLabel.hidden = YES;
    } else {
        placeholderLabel.hidden = NO;
    }
}

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
        _note = textView.text;
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
    if (_activeTextView == _noteTextView) {
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
    _invoiceLabel.text = _order.order_detail.detail_invoice?:_invoice?:@"";
    _shopNameLabel.text = _order.order_shop.shop_name?:_shopName?:@"";
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_order.order_shop.shop_pic?:_shopPic?:@""]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    UIImageView *thumb = _shopImageView;
    thumb.image = nil;
    [thumb setImageWithURLRequest:request
                 placeholderImage:[UIImage imageNamed:@"icon_default_shop.jpg"]
                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                              [thumb setImage:image];
#pragma clang diagnosti c pop
                          } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                          }];
    
    _selectedSolution = _selectedSolution?:[[self solutions] firstObject];
    _selectedProblem = _selectedProblem?:[ARRAY_PROBLEM_COMPLAIN firstObject];
    
    if (!_isCanEditProblem && _indexPage == 0) {
        _choosenProblemSolutionLabel.textColor = [UIColor grayColor];
        _rightArrowImageView.hidden = YES;
        CGRect frame = _choosenProblemSolutionLabel.frame;
        frame.origin.x +=15;
        _choosenProblemSolutionLabel.frame = frame;
    }
    
    if (_uploadedPhotos.count>0) {
        for (int i = 0; i<_uploadedPhotos.count; i++) {
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_uploadedPhotos[i]] cachePolicy:
                                     NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            
            UIImageView *thumb = (UIImageView*)_uploadedImages[i];
            thumb.image = nil;
            [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                [thumb setImage:image];
#pragma clang diagnosti c pop
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            }];
            
            [(UIButton*)_cancelButtons[i] setHidden:NO];
            [(UIButton*)_uploadButtons[i] setHidden:YES];
            if (i<_uploadButtons.count-1) {
                [(UIButton*)_uploadButtons[i+1] setHidden:NO];
            }
            [_photos replaceObjectAtIndex:i withObject:_uploadedPhotos[i]];
        }
    }
    
    _noteTextView.text = _note?:@"";
    if ([_noteTextView.text isEqualToString:@""]) {
        [self setPlaceholder];
    }
    
    _totalRefundTextField.text = [_totalRefund isEqualToString:@"0"]?@"":_totalRefund;
}

- (void)setPlaceholder
{
    _noteTextView.delegate = self;
    
    UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.2, -6, _noteTextView.frame.size.width, 40)];
    placeholderLabel.text = _isChangeSolution?@"Isi pesan diskusi di sini...":@"Isi alasan Anda di sini...";
    placeholderLabel.font = [UIFont fontWithName:_noteTextView.font.fontName size:_noteTextView.font.pointSize];
    placeholderLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
    placeholderLabel.tag = 1;
    
    [_noteTextView addSubview:placeholderLabel];
}

-(void)adjustDataCellAtIndexPath:(NSIndexPath*)indexPath
{
    if (_isGotTheOrder) {
        if(_isActionBySeller) _problemSolutionHeaderLabel.text = (_indexPage == 0)?@"Masalah pada barang yang diterima pembeli":@"Solusi yang Anda inginkan untuk masalah ini?";
        else _problemSolutionHeaderLabel.text = (_indexPage == 0)?@"Masalah pada barang yang Anda terima":@"Solusi yang Anda inginkan untuk masalah ini?";
        _problemSolutionLabel.text = (_indexPage == 0)?@"Masalah":@"Solusi";
        _choosenProblemSolutionLabel.text = (_indexPage == 0)?_selectedProblem:_selectedSolution;
        
        _noteHeaderLabel.text = _isChangeSolution?@"Diskusikan permasalahan Anda":@"Pesan untuk penjual";
    }
    else
    {
        _problemSolutionHeaderLabel.text = @"Solusi yang Anda inginkan untuk masalah ini?";
        _problemSolutionLabel.text = @"Solusi";
        _choosenProblemSolutionLabel.text = _selectedSolution;
        _noteHeaderLabel.text = @"Alasan Anda memilih salah satu solusi diatas";
    }
    
    if ([_selectedProblem isEqualToString:ARRAY_PROBLEM_COMPLAIN[3]]) {
        _fromTotalDescription.text = @"Dari Total Ongkos Kirim";
        _totalInvoiceLabel.text = _order.order_detail.detail_shipping_price_idr?:_shippingPriceIDR?:@"";
    }
    else
    {
        _fromTotalDescription.text = @"Dari Total Invoice";
        _totalInvoiceLabel.text = _order.order_detail.detail_open_amount_idr?:_detailOpenAmountIDR?:@"";
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
    
    if (!_isGotTheOrder) {
        if (_isChangeSolution) {
            return ARRAY_SOLUTION_PACKAGE_NOT_RECEIVED_CHANGE_SOLUTION;
        }
        else return ARRAY_SOLUTION_PACKAGE_NOT_RECEIVED;
    }
    
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
    if ([_selectedProblem isEqualToString:ARRAY_PROBLEM_COMPLAIN[3]]) {
        return NO;
    }
    if ([_selectedSolution isEqualToString:ARRAY_SOLUTION_PRODUCT_NOT_SAME_AS_DESCRIPTION[0]]||
        [_selectedSolution isEqualToString:ARRAY_SOLUTION_PRODUCT_NOT_SAME_AS_DESCRIPTION[2]]||
        [_selectedSolution isEqualToString:ARRAY_SOLUTION_DIFFERENT_QTY[0]]||
        [_selectedSolution isEqualToString:ARRAY_SOLUTION_DIFFERENT_QTY[2]])
    {
        return YES;
    }
    return NO;
}

-(void)syncroImages:(NSArray *)images message:(NSString *)message refundAmount:(NSString *)refundAmount
{
    _noteTextView.text = message?:@"";
    _totalRefund = refundAmount?:@"";
}

-(void)goToSecondPage
{
    InboxResolutionCenterOpenViewController *vc = [InboxResolutionCenterOpenViewController new];
    vc.indexPage = 1;
    vc.selectedProblem = _selectedProblem;
    vc.isGotTheOrder = _isGotTheOrder;
    vc.order = _order?:[TxOrderStatusList new];
    vc.uploadedPhotos = (_uploadedPhotos.count>0)?_uploadedPhotos:_photos?:@[];
    vc.delegate = _delegate;
    vc.detailOpenAmount = _detailOpenAmount;
    vc.detailOpenAmountIDR = _detailOpenAmountIDR;
    vc.shippingPriceIDR = _shippingPriceIDR;
    vc.selectedProblem = _selectedProblem;
    vc.selectedSolution = _selectedSolution;
    vc.invoice = _invoice;
    vc.shopName = _shopName;
    vc.shopPic = _shopPic;
    vc.note = _note;
    vc.isChangeSolution = _isChangeSolution;
    vc.totalRefund = _totalRefund;
    vc.syncroDelegate = self;
    vc.controllerTitle = _controllerTitle;
    vc.generatehost = _generatehost;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Request Complaint

-(void)didSuccessCreate
{
    [[NSNotificationCenter defaultCenter]postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:self];
    [[NSNotificationCenter defaultCenter]postNotificationName:REFRESH_TX_ORDER_POST_NOTIFICATION_NAME object:self];
    NSArray *viewControllers = self.navigationController.viewControllers;
    UIViewController *destinationVC;
    for (UIViewController *vc in viewControllers) {
        if ([vc isKindOfClass:[_delegate class]]) {
            destinationVC = vc;
        }
    }
    [self.navigationController popToViewController:destinationVC animated:YES];
}

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
    else if ([_selectedSolution isEqualToString:ARRAY_SOLUTION_DIFFERENT_QTY[1]]) {
        solutionType = @"5";
    }
    else if ([_selectedSolution isEqualToString:ARRAY_SOLUTION_PACKAGE_NOT_RECEIVED[1]])
    {
        solutionType = @"6";
    }
    return solutionType;
}

#pragma mark Request Action Upload Photo
-(void)successGenerateHost:(GenerateHost *)generateHost
{
    _generatehost = generateHost;
    [[_uploadButtons objectAtIndex:0] setEnabled:YES];
    [_dataInput setObject:_generatehost.result.generated_host forKey:@"generated_host"];
}

-(void)actionUploadImage:(id)object
{
    [_uploadingPhotos addObject:object];
    _isFinishUploadingImage = NO;
    RequestUploadImage *uploadImage = [RequestUploadImage new];
    [uploadImage requestActionUploadObject:object
                             generatedHost:_generatehost.result.generated_host
                                    action:ACTION_UPLOAD_CONTACT_IMAGE
                                    newAdd:1
                                 productID:@""
                                 paymentID:@""
                                 fieldName:API_UPLOAD_PRODUCT_IMAGE_DATA_NAME
                                   success:^(id imageObject, UploadImage *image) {
       [self successUploadObject:object withMappingResult:image];
    } failure:^(id imageObject, NSError *error) {
        [self failedUploadObject:object];
    }];
}

-(void)successUploadObject:(id)object withMappingResult:(UploadImage *)uploadImage
{
    UIImageView *imageView = [object objectForKey:DATA_SELECTED_IMAGE_VIEW_KEY];
    imageView.alpha = 1.0;
    [_photos replaceObjectAtIndex:imageView.tag-10 withObject:uploadImage.result.file_th];
    [_uploadingPhotos removeObject:object];
    
    for (UIButton *button in _cancelButtons) {
        if (button.tag == imageView.tag) {
            button.hidden = NO;
        }
    }
    
    [self requestProcessUploadPhoto];
}

-(void)failedUploadObject:(id)object
{
    UIImageView *imageView = [object objectForKey:DATA_SELECTED_IMAGE_VIEW_KEY];
    imageView.image = nil; //TODO::placeholder image
    
    for (UIButton *button in _uploadButtons) {
        if (button.tag == imageView.tag) {
            button.enabled = YES;
            button.hidden = NO;
        }
    }
    [_uploadingPhotos removeObject:object];
    
    [self requestProcessUploadPhoto];
}

-(void)failedUploadErrorMessage:(NSArray *)errorMessage
{
    StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:errorMessage delegate:self];
    [stickyAlertView show];
}

- (void)requestProcessUploadPhoto
{
    if (_uploadingPhotos.count > 0) {
        _isFinishUploadingImage = NO;
    }
    else
    {
        _isFinishUploadingImage = YES;
    }
}

- (void)failedGenerateHost:(NSArray *)errorMessages {
    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessages delegate:self];
    [alert show];
}

@end
