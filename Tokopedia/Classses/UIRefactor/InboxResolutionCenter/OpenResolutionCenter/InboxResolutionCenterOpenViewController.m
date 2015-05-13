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
    TKPDPhotoPickerDelegate
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
    
    __weak RKObjectManager *_objectManagerComplain;
    __weak RKManagedObjectRequestOperation *_requestComplain;
    
    __weak RKObjectManager *_objectManagerUploadPhoto;
    NSURLRequest *_requestActionUploadPhoto;
    
    BOOL _isFinishUploadingImage;

    TKPDPhotoPicker *_photoPicker;
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

@implementation InboxResolutionCenterOpenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataInput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    _generatehost = [GenerateHost new];
    _photos = [[NSMutableArray alloc]initWithObjects:@"",@"",@"",@"",@"", nil];
    _uploadingPhotos = [NSMutableArray new];
    
    _cancelButtons = [NSArray sortViewsWithTagInArray:_cancelButtons];
    _uploadedImages = [NSArray sortViewsWithTagInArray:_uploadedImages];
    _uploadButtons = [NSArray sortViewsWithTagInArray:_uploadButtons];
    [_cancelButtons makeObjectsPerformSelector:@selector(setHidden:)withObject:@(YES)];
    
    
    [self setData];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
    
    _isFinishUploadingImage = YES;
    
    RequestGenerateHost *requestHost = [RequestGenerateHost new];
    [requestHost configureRestkitGenerateHost];
    [requestHost requestGenerateHost];
    requestHost.delegate = self;

}

-(void)setControllerTitle:(NSString *)controllerTitle
{
    _controllerTitle = controllerTitle;
    [self adjustNavigationTitle];
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
    
    [_syncroDelegate syncroImages:[_photos copy] message:_noteTextView.text];
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
    
    NSDictionary *object = @{
                                DATA_SELECTED_PHOTO_KEY : userInfo,
                                DATA_SELECTED_IMAGE_VIEW_KEY : imageView
                            };

    UIImage *image = [[userInfo objectForKey:kTKPDCAMERA_DATAPHOTOKEY] objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    UIGraphicsBeginImageContextWithOptions(kTKPDCAMERA_UPLOADEDIMAGESIZE, NO, image.scale);
    [image drawInRect:kTKPDCAMERA_UPLOADEDIMAGERECT];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    for (UIButton *button in _uploadButtons) {
        if (button.tag == picker.tag) {
            button.enabled = NO;
            button.hidden = YES;
        } else if (button.tag == picker.tag+1) {
            button.enabled = YES;
            button.hidden = NO;
        }
    }
    
    imageView.image = image;
    imageView.hidden = NO;
    imageView.alpha = 0.5f;
    
    [self actionUploadImage:object];
}

//-(void)didDismissCameraController:(CameraController *)controller withUserInfo:(NSDictionary *)userinfo
//{
//    NSMutableDictionary *object = [NSMutableDictionary new];
//    [object setObject:userinfo forKey:DATA_SELECTED_PHOTO_KEY];
//    UIImageView *imageView;
//    for (UIImageView *image in _uploadedImages) {
//        if (image.tag == controller.tag)
//        {
//            imageView = image;
//        }
//    }
//    
//    [object setObject:imageView forKey:DATA_SELECTED_IMAGE_VIEW_KEY];
//    
//    NSDictionary* photo = [userinfo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
//    
//    UIImage* image = [photo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
//    UIGraphicsBeginImageContextWithOptions(kTKPDCAMERA_UPLOADEDIMAGESIZE, NO, image.scale);
//    [image drawInRect:kTKPDCAMERA_UPLOADEDIMAGERECT];
//    image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    for (UIButton *button in _uploadButtons) {
//        if (button.tag == controller.tag) {
//            button.enabled = NO;
//            button.hidden = YES;
//        }
//        if (button.tag == controller.tag+1)
//        {
//            button.enabled = YES;
//            button.hidden = NO;
//        }
//    }
//    
//    imageView.image = image;
//    imageView.hidden = NO;
//    imageView.alpha = 0.5f;
//    
//    [self actionUploadImage:object];
//}


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
                    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:@[@"Belum selesai meng-upload image"] delegate:self];
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
        NSString *troubleType = [self troubleType]?:@"";
        NSString *solutionType = [self solutionType]?:@"";

        NSString *photos = [[_uploadedPhotos valueForKey:@"description"] componentsJoinedByString:@"~"]?:@"";
       
        NSString *serverID = _generatehost.result.generated_host.server_id?:@"0";
        
        if ([self.title isEqualToString:TITLE_APPEAL]) {

            [_delegate appealSolution:solutionType refundAmount:_totalRefund remark:_note photo:photos serverID:serverID];
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
            [_delegate changeSolution:solutionType troubleType:troubleType refundAmount:_totalRefund remark:_note photo:photos serverID:serverID];
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
            [self configureRestKitComplain];
            [self requestComplain];
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
    if (_isGotTheOrder && _indexPage == 1)
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
    
    if (indexPath.section==0 && _isGotTheOrder) {
        if (_indexPage == 0)
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
        _problemSolutionLabel.text = (_indexPage == 0)?@"Masalah":@"Solution";
        _choosenProblemSolutionLabel.text = (_indexPage == 0)?_selectedProblem:_selectedSolution;
        
        _noteHeaderLabel.text = _isChangeSolution?@"Diskusikan permasalahan Anda":@"Pesan untuk penjual";
    }
    else
    {
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

-(void)syncroImages:(NSArray *)images message:(NSString *)message
{
    _noteTextView.text = message;
}

-(void)goToSecondPage
{
    InboxResolutionCenterOpenViewController *vc = [InboxResolutionCenterOpenViewController new];
    vc.indexPage = 1;
    vc.selectedProblem = _selectedProblem;
    vc.isGotTheOrder = _isGotTheOrder;
    vc.order = _order?:[TxOrderStatusList new];
    vc.uploadedPhotos = _uploadedPhotos?:_photos?:@[];
    vc.generatehost = _generatehost;
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
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Request Complaint
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
    else if ([_selectedSolution isEqualToString:ARRAY_SOLUTION_DIFFERENT_QTY[1]]) {
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
    
    NSString *photos = [[_uploadedPhotos valueForKey:@"description"] componentsJoinedByString:@"~"]?:@"";
    
    NSDictionary* param = @{API_ACTION_KEY : ACTION_CREATE_RESOLUTION,
                            API_ORDER_ID_KEY : _order.order_detail.detail_order_id?:@"",
                            API_FLAG_RECIEVED_KEY : @(_isGotTheOrder),
                            API_TROUBLE_TYPE_KEY: troubleType,
                            API_SOLUTION_KEY : solutionType,
                            API_REFUND_AMOUNT_KEY : _totalRefund?:@"",
                            API_REMARK_KEY : _note?:@"",
                            API_PHOTOS_KEY : photos,
                            API_SERVER_ID_KEY : _generatehost.result.generated_host.server_id?:@"0"
                            };
    
//#if DEBUG
//    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
//    NSDictionary* auth = [secureStorage keychainDictionary];
//    
//    NSString *userID = [auth objectForKey:kTKPD_USERIDKEY];
//    
//    NSMutableDictionary *paramDictionary = [NSMutableDictionary new];
//    [paramDictionary addEntriesFromDictionary:param];
//    [paramDictionary setObject:@"off" forKey:@"enc_dec"];
//    [paramDictionary setObject:userID?:@"" forKey:kTKPD_USERIDKEY];
//    
//    _requestComplain = [_objectManagerComplain appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:API_PATH_ACTION_RESOLUTION_CENTER parameters:paramDictionary];
//#else
    _requestComplain = [_objectManagerComplain appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_PATH_ACTION_RESOLUTION_CENTER parameters:[param encrypt]];
//#endif
    
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
                    NSArray *viewControllers = self.navigationController.viewControllers;
                    UIViewController *destinationVC;
                    for (UIViewController *vc in viewControllers) {
                        if ([vc isKindOfClass:[_delegate class]]) {
                            destinationVC = vc;
                        }
                    }
                    [self.navigationController popToViewController:destinationVC animated:YES];
                    
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

#pragma mark Request Action Upload Photo
-(void)successGenerateHost:(GenerateHost *)generateHost
{
    _generatehost = generateHost;
    [[_uploadButtons objectAtIndex:0] setEnabled:YES];
    [_dataInput setObject:_generatehost.result.generated_host.server_id forKey:API_SERVER_ID_KEY];
}

-(void)actionUploadImage:(id)object
{
    [_uploadingPhotos addObject:object];
    _isFinishUploadingImage = NO;
    RequestUploadImage *uploadImage = [RequestUploadImage new];
    uploadImage.imageObject = object;
    uploadImage.delegate = self;
    uploadImage.generateHost = _generatehost;
    uploadImage.action = ACTION_UPLOAD_CONTACT_IMAGE;
    uploadImage.fieldName = API_UPLOAD_PRODUCT_IMAGE_DATA_NAME;
    [uploadImage configureRestkitUploadPhoto];
    [uploadImage requestActionUploadPhoto];
}

-(void)successUploadObject:(id)object withMappingResult:(UploadImage *)uploadImage
{
    _isFinishUploadingImage = YES;
    UIImageView *imageView = [object objectForKey:DATA_SELECTED_IMAGE_VIEW_KEY];
    imageView.alpha = 1.0;
    [_photos replaceObjectAtIndex:imageView.tag-10 withObject:uploadImage.result.file_th];
    [_uploadingPhotos removeObject:object];
    
    for (UIButton *button in _cancelButtons) {
        if (button.tag == imageView.tag) {
            button.hidden = NO;
        }
    }
    
    //[self requestProcessUploadPhoto];
}

-(void)failedUploadObject:(id)object
{
    _isFinishUploadingImage = YES;
    
    UIImageView *imageView = [object objectForKey:DATA_SELECTED_IMAGE_VIEW_KEY];
    imageView.image = nil; //TODO::placeholder image
    
    for (UIButton *button in _uploadButtons) {
        if (button.tag == imageView.tag) {
            button.enabled = YES;
            button.hidden = NO;
        }
    }
    [_uploadingPhotos removeObject:object];
    
    //[self requestProcessUploadPhoto];
}

- (void)requestProcessUploadPhoto
{
    if (_uploadingPhotos.count > 0) {
        [self actionUploadImage:[_uploadingPhotos firstObject]];
    }
}

- (void)failedGenerateHost {
    
}

@end
