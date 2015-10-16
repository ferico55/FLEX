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
#import "InboxTicketDetailViewController.h"

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

@property (strong, nonatomic) IBOutlet UIView *tableHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionActionLabel;

@property BOOL invoiceTextFieldIsVisible;
@property BOOL photoPickerIsVisible;

@end

@implementation ContactUsFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Hubungi Kami";
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:nil];
    self.navigationItem.backBarButtonItem = backBarButton;
    
    self.messageTextView.placeholder = @"Keterangan Masalah Anda";
    
    [self.uploadPhotoScrollView addSubview:_uploadPhotoCellSubview];
    self.uploadPhotoScrollView.contentSize = _uploadPhotoCellSubview.frame.size;
    
    self.photoImageViews = [NSArray sortViewsWithTagInArray:_photoImageViews];
    self.photoDeleteButtons = [NSArray sortViewsWithTagInArray:_photoDeleteButtons];
    
    _photos = [NSMutableArray new];
    
    _invoiceTextFieldIsVisible = NO;
    _photoPickerIsVisible = NO;
    
    self.invoiceTextField.text = @"";
    self.messageTextView.text = @"";
    
    TicketCategory *lastCategory = _subCategories[_subCategories.count - 1];
    [self.eventHandler showFormWithCategory:lastCategory];
        
    [self showSubmitButton];
    
    [self showHeaderView];

    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    
    [notification addObserver:self
                     selector:@selector(keyboardWillShow:)
                         name:UIKeyboardWillShowNotification
                       object:nil];
    
    [notification addObserver:self
                     selector:@selector(keyboardWillHide:)
                         name:UIKeyboardWillHideNotification
                       object:nil];
    
    [notification addObserver:self
                     selector:@selector(showMessageAlert:)
                         name:kTKPD_SETUSERSTICKYERRORMESSAGEKEY
                       object:nil];
    
    [self.eventHandler resetData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)showHeaderView {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    
    UIColor *textColor = [UIColor colorWithRed:126.0/255.0
                                         green:126.0/255.0
                                          blue:126.0/255.0
                                         alpha:1];
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName            : [UIFont fontWithName:@"GothamBook" size:12],
                                 NSParagraphStyleAttributeName  : style,
                                 NSForegroundColorAttributeName : textColor,
                                 };
    
    NSString *title = @"Customer Care Tokopedia akan menjawab pesan kamu dalam waktu maksimal 1x24 jam.";
    NSString *subTitle = @"Silahkan cek layanan pengguna";
    
    UIColor *buttonColor = [UIColor blueColor];

    NSMutableAttributedString *titleAttributedString = [[NSMutableAttributedString alloc] initWithString:title
                                                                                              attributes:attributes];
    
    self.descriptionLabel.attributedText = titleAttributedString;
    [self.descriptionLabel sizeToFit];
    
    NSMutableAttributedString *subtitleAttributedString = [[NSMutableAttributedString alloc] initWithString:subTitle
                                                                                                 attributes:attributes];
    [subtitleAttributedString addAttribute:NSForegroundColorAttributeName value:buttonColor
                                     range:NSMakeRange(13, 16)];

    self.descriptionActionLabel.attributedText = subtitleAttributedString;
    
    CGFloat width = self.view.frame.size.width;
    CGRect rect = [titleAttributedString boundingRectWithSize:CGSizeMake(width, 10000)
                                                      options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                      context:nil];

    CGFloat height = rect.size.height + self.descriptionActionLabel.frame.size.height + 50;
    self.tableHeaderView.frame = CGRectMake(0, 0, rect.size.width, height);
    
    self.tableView.tableHeaderView = _tableHeaderView;
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
            
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineSpacing = 4.0;
            
            NSDictionary *attributes = @{
                NSFontAttributeName            : [UIFont fontWithName:@"GothamBook" size:14],
                NSParagraphStyleAttributeName  : style,
            };
            
            NSString *text = [_subCategories[indexPath.row - 1] ticket_category_name];
            
            NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text
                                                                                   attributes:attributes];

            ((ContactUsFormCategoryCell *)cell).categoryNameLabel.attributedText = attributedString;
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
        height = 35;
        NSString *text;
        if (indexPath.row == 0) {
            text = _mainCategory.ticket_category_name;
        } else {
            text = [_subCategories[indexPath.row - 1] ticket_category_name];
        }
        CGSize maximumLabelSize = CGSizeMake(220, CGFLOAT_MAX);
        CGSize expectedLabelSize = [text sizeWithFont:FONT_GOTHAM_BOOK_14
                                    constrainedToSize:maximumLabelSize
                                        lineBreakMode:NSLineBreakByWordWrapping];
        height = height + expectedLabelSize.height; // add margin
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
    TicketCategory *lastCategory = _subCategories[_subCategories.count - 1];
    [self.eventHandler submitTicketMessage:_messageTextView.text
                                   invoice:_invoiceTextField.text
                               attachments:_photos
                            ticketCategory:lastCategory];
}

- (IBAction)didTapInboxTicketButton:(id)sender {
    [self.eventHandler showInboxTicketFromNavigation:self.navigationController];
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
    self.navigationItem.rightBarButtonItem = indicatorBarButton;
    [self hideDeletePhotoButton];
}

- (void)showSubmitButton {
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Kirim Pesan"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(didTapSubmitButton)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [self refreshPhotos];
}

#pragma mark - Text view delegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    CGPoint localPoint = [textView bounds].origin;
    CGPoint basePoint = [textView convertPoint:localPoint toView:nil];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:basePoint];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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
    self.photos = [NSMutableArray arrayWithArray:photos];
    [self refreshPhotos];
}

- (void)refreshPhotos {
    for (int i = 0; i < 5; i++) {
        UIImageView *imageView = [self.photoImageViews objectAtIndex:i];
        UIButton *deleteButton = [self.photoDeleteButtons objectAtIndex:i];
        if (i < self.photos.count) {
            imageView.alpha =1;
            imageView.image = [self.photos objectAtIndex:i];
            deleteButton.hidden = NO;
        } else {
            imageView.alpha = 1;
            imageView.image = [UIImage imageNamed:@"icon_upload_image.png"];
            deleteButton.hidden = YES;
        }
    }
}

- (void)hideDeletePhotoButton {
    for (int i = 0; i < 5; i++) {
        UIImageView *imageView = [self.photoImageViews objectAtIndex:i];
        UIButton *deleteButton = [self.photoDeleteButtons objectAtIndex:i];
        if (i < self.photos.count) {
            imageView.alpha = 0.5;
            deleteButton.hidden = YES;
        }
    }
}

- (void)redirectToInboxTicketDetail {
    NSArray *successMessages = @[@"Pesan Anda telah terkirim!"];
    StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:successMessages delegate:self];
    [alert show];
    [self.eventHandler showInboxTicketDetailFromNavigation:self.navigationController];
}

- (void)showUploadedPhoto:(UIImage *)image {
    
}

- (void)removeFailUploadPhoto:(UIImage *)image {
    [self.photos removeObject:image];
    [self refreshPhotos];
}

#pragma mark - Notification

- (void)showMessageAlert:(NSNotification *)notification {
    NSArray *messages = [[notification userInfo] valueForKey:kTKPD_SETUSERSTICKYERRORMESSAGEKEY];
    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:messages delegate:self];
    [alert show];
}

@end
