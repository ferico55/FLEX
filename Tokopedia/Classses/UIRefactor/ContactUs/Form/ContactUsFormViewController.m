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

#import "TKPDTextView.h"

#import "camera.h"
#import "CameraAlbumListViewController.h"
#import "CameraCollectionViewController.h"

#import "UploadImage.h"
#import "UploadImageParams.h"
#import "RequestUploadImage.h"

#import "ContactUsActionResponse.h"

@interface ContactUsFormViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UITextViewDelegate
>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *typeCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *problemCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *problemDetailCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *invoiceInputCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *messageCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *uploadPhotoCell;
@property (strong, nonatomic) IBOutlet UIView *uploadPhotoCellSubview;

@property (weak, nonatomic) IBOutlet UILabel *problemLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailProblemLabel;
@property (weak, nonatomic) IBOutlet UITextField *invoiceTextField;
@property (weak, nonatomic) IBOutlet TKPDTextView *messageTextView;

@property (strong, nonatomic) IBOutlet UIScrollView *uploadPhotoScrollView;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *photoImageViews;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *photoDeleteButtons;

@end

@implementation ContactUsFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Hubungi Kami";

    self.messageTextView.placeholder = @"Keterangan Masalah Anda";

    self.typeLabel.text = _contactUsType.ticket_category_name;
    self.problemLabel.text = _problem.ticket_category_name;
    self.detailProblemLabel.text = _detailProblem.ticket_category_name;
    
    [self.uploadPhotoScrollView addSubview:_uploadPhotoCellSubview];
    self.uploadPhotoScrollView.contentSize = _uploadPhotoCellSubview.frame.size;
    
    self.photoImageViews = [NSArray sortViewsWithTagInArray:_photoImageViews];
    self.photoDeleteButtons = [NSArray sortViewsWithTagInArray:_photoDeleteButtons];
    
    [self showSaveButton];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows;
    if (section == 0) {
        rows = 3;
    } else if (section == 1) {
        rows = 1;
    } else if (section == 2) {
        rows = 1;
    } else if (section == 3) {
        rows = 1;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = _typeCell;
        } else if (indexPath.row == 1) {
            cell = _problemCell;
        } else if (indexPath.row == 2) {
            cell = _problemDetailCell;
        }
    } else if (indexPath.section == 1) {
        cell = _invoiceInputCell;
    } else if (indexPath.section == 2) {
        cell = _uploadPhotoCell;
    } else if (indexPath.section == 3) {
        cell = _messageCell;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height;
    if (indexPath.section == 0) {
        height = _problemCell.frame.size.height;
    } else if (indexPath.section == 1) {
        height = _invoiceInputCell.frame.size.height;
    } else if (indexPath.section == 2) {
        height = _uploadPhotoCell.frame.size.height;
    } else if (indexPath.section == 3) {
        height = _messageCell.frame.size.height;
    }
    return height;
}

#pragma mark - Actions

- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tap = sender;
        if ([tap.view isKindOfClass:[UIImageView class]]) {
        }
    } else if ([sender isKindOfClass:[UIButton class]]) {
    }
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
}

- (void)showSaveButton {
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Kirim Pesan"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(tap:)];
    self.navigationItem.rightBarButtonItem = saveButton;
}

#pragma mark - Text view delegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    CGPoint point = CGPointMake(0, self.tableView.contentOffset.y+self.tableView.contentInset.bottom);
    [self.tableView setContentOffset:point animated:YES];
}

@end
