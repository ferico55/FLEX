//
//  ContactUsFormViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 8/13/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ContactUsFormViewController.h"

#import "GenerateHost.h"
#import "RequestGenerateHost.h"
#import "TokopediaNetworkManager.h"
#import "ContactUsFormMainCategoryCell.h"
#import "ContactUsFormCategoryCell.h"

#import "TKPDTextView.h"

#import "ContactUsActionResponse.h"

@interface ContactUsFormViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UITextViewDelegate
>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *invoiceInputCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *messageCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *uploadPhotoCell;
@property (strong, nonatomic) IBOutlet UIView *uploadPhotoCellSubview;

@property (weak, nonatomic) IBOutlet UITextField *invoiceTextField;
@property (weak, nonatomic) IBOutlet TKPDTextView *messageTextView;

@property (strong, nonatomic) IBOutlet UIScrollView *uploadPhotoScrollView;
@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *photoImageViews;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *photoDeleteButtons;

@property BOOL invoiceTextFieldIsVisible;
@property BOOL photoPickerIsVisible;

@end

@implementation ContactUsFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Hubungi Kami";
    
    self.messageTextView.placeholder = @"Keterangan Masalah Anda";
    
    [self.uploadPhotoScrollView addSubview:_uploadPhotoCellSubview];
    self.uploadPhotoScrollView.contentSize = _uploadPhotoCellSubview.frame.size;
    
    self.photoImageViews = [NSArray sortViewsWithTagInArray:_photoImageViews];
    self.photoDeleteButtons = [NSArray sortViewsWithTagInArray:_photoDeleteButtons];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _photos = [NSMutableArray new];

    _invoiceTextFieldIsVisible = NO;
    _photoPickerIsVisible = NO;
    
    TicketCategory *lastCategory = _subCategories[_subCategories.count - 1];
    [self.eventHandler showFormWithCategory:lastCategory];
    
    [self.tableView reloadData];
    
    [self showSaveButton];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = 2;
    if (_invoiceTextFieldIsVisible) sections++;
    if (_photoPickerIsVisible) sections++;
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if (section == 0) {
        rows = _subCategories.count + 1;
    } else {
        rows = 1;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ContactUsFormMainCategoryCell"];
            if (cell == nil) {
                cell = [[ContactUsFormMainCategoryCell alloc] init];
            }
            ((ContactUsFormMainCategoryCell *)cell).categoryNameLabel.text = _mainCategory.ticket_category_name;
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ContactUsFormCategoryCell"];
            if (cell == nil) {
                cell = [[ContactUsFormCategoryCell alloc] init];
            }
            NSString *categoryName = [_subCategories[indexPath.row - 1] ticket_category_name];
            ((ContactUsFormCategoryCell *)cell).categoryNameLabel.text = categoryName;
        }
    } else if (indexPath.section == 1) {
        if (_invoiceTextFieldIsVisible) {
            cell = _invoiceInputCell;
        } else if (_photoPickerIsVisible) {
            cell = _uploadPhotoCell;
        } else {
            cell = _messageCell;
        }
    } else if (indexPath.section == 2) {
        if (_photoPickerIsVisible && _invoiceTextFieldIsVisible) {
            cell = _uploadPhotoCell;
        } else {
            cell = _messageCell;
        }
    } else if (indexPath.section == 3) {
        cell = _messageCell;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height;
    if (indexPath.section == 0) {
        height = 44;
    } else if (indexPath.section == 1) {
        if (_invoiceTextFieldIsVisible) {
            height = _invoiceInputCell.frame.size.height;
        } else if (_photoPickerIsVisible) {
            height = _uploadPhotoCell.frame.size.height;
        } else {
            height = _messageCell.frame.size.height;
        }
    } else if (indexPath.section == 2) {
        if (_photoPickerIsVisible && _invoiceTextFieldIsVisible) {
            height = _uploadPhotoCell.frame.size.height;
        } else {
            height = _messageCell.frame.size.height;
        }
    } else if (indexPath.section == 3) {
        height = _messageCell.frame.size.height;
    }
    return height;
}

#pragma mark - Actions

- (IBAction)didTapDeletePhotoButton:(UIButton *)button {
    [self.photos removeObjectAtIndex:button.tag - 1];
    [self refreshPhotos];
}

- (IBAction)didTapPhoto:(UITapGestureRecognizer *)tap {
    [self.view endEditing:YES];
    [self.eventHandler showPhotoPickerFromNavigation:self.navigationController];
}

- (void)didTapSubmitButton {
//    [self.eventHandler submitTicketMessage:_messageTextView.text
//                                   invoice:_invoiceTextField.text
//                               attachments:_photos
//                            ticketCategory:_detailProblem];
}

#pragma mark - Keyboard Notification

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *keyboardInfo = [notification userInfo];
    NSValue *keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardFrameBeginRect.size.height, 0);
}

- (void)keyboardWillHide:(NSNotification *)info {
    self.tableView.contentInset = UIEdgeInsetsZero;
}


- (void)showLoadingBar {
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [indicatorView startAnimating];
    UIBarButtonItem *indicatorBarButton = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
    self.navigationController.navigationItem.rightBarButtonItem = indicatorBarButton;
}

- (void)showSaveButton {
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Kirim Pesan"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(didTapSubmitButton)];
    self.navigationItem.rightBarButtonItem = saveButton;
}

#pragma mark - Text view delegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
}

#pragma mark - View delegate

- (void)showInvoiceInputTextField {
    _invoiceTextFieldIsVisible = YES;
    [self.tableView reloadData];
}

- (void)showPhotoPicker {
    _photoPickerIsVisible = YES;
    [self.tableView reloadData];
}

- (void)showErrorMessages:(NSArray *)errorMessages {
    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
    [alert show];
}

- (void)showSelectedPhotos:(NSArray *)photos {
    self.photos = [photos mutableCopy];
    [self refreshPhotos];
}

- (void)refreshPhotos {
    for (int i = 0; i < 5; i++) {
        UIImageView *imageView = [self.photoImageViews objectAtIndex:i];
        UIButton *deleteButton = [self.photoDeleteButtons objectAtIndex:i];
        if (i < self.photos.count) {
            imageView.image = [self.photos objectAtIndex:i];
            deleteButton.hidden = NO;
        } else {
            imageView.image = [UIImage imageNamed:@"icon_upload_image.png"];
            deleteButton.hidden = YES;
        }
    }
}

@end
