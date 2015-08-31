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
    TokopediaNetworkManagerDelegate,
    CameraAlbumListDelegate,
    CameraCollectionViewControllerDelegate,
    GenerateHostDelegate,
    RequestUploadImageDelegate,
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

@property (strong, nonatomic) NSMutableArray *uploadedPhotos;
@property (strong, nonatomic) NSMutableArray *uploadedPhotosURL;

@property (strong, nonatomic) NSMutableArray *selectedImagesCameraController;
@property (strong, nonatomic) NSMutableArray *selectedIndexPathCameraController;

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
            [self openPhotoGallery];
        }
    } else if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = sender;
        if (button.tag <= 5) {
            NSInteger index = button.tag-1;
            if (_uploadedPhotos.count >= button.tag) {
                [_uploadedPhotos removeObjectAtIndex:index];
            }
            if (_uploadedPhotosURL.count >= button.tag) {
                [_uploadedPhotosURL removeObjectAtIndex:index];
            }
            if (_selectedImagesCameraController.count >= button.tag) {
                [_selectedImagesCameraController removeObjectAtIndex:index];
            }
            if (_selectedIndexPathCameraController.count >= button.tag) {
                [_selectedIndexPathCameraController removeObjectAtIndex:index];
            }
            UIImageView *imageView = [self.photoImageViews objectAtIndex:index];
            imageView.image = [UIImage imageNamed:@"icon_upload_image.png"];
            imageView.userInteractionEnabled = YES;
            UIButton *button = [self.photoDeleteButtons objectAtIndex:index];
            button.hidden = YES;
        }
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

#pragma mark - Photo gallery

- (void)openPhotoGallery {
    
    CameraAlbumListViewController *albumVC = [CameraAlbumListViewController new];
    albumVC.title = @"Album";
    albumVC.delegate = self;
    CameraCollectionViewController *photoVC = [CameraCollectionViewController new];
    photoVC.title = @"All Picture";
    photoVC.delegate = self;
    NSMutableArray *selectedImage = [NSMutableArray new];
    for (NSIndexPath *selected in _selectedImagesCameraController) {
        if (![selected isEqual:@""]) {
            [selectedImage addObject: selected];
        }
    }
    photoVC.selectedImagesArray = [selectedImage copy];
    NSMutableArray *selectedIndexPath = [NSMutableArray new];
    for (NSIndexPath *selected in _selectedIndexPathCameraController) {
        if (![selected isEqual:@""]) {
            [selectedIndexPath addObject: selected];
        }
    }
    photoVC.selectedIndexPath = selectedIndexPath;
    UINavigationController *nav = [[UINavigationController alloc]init];
    nav.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.tintColor = [UIColor whiteColor];
    NSArray *controllers = @[albumVC,photoVC];
    [nav setViewControllers:controllers];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

-(void)didDismissController:(CameraCollectionViewController *)controller withUserInfo:(NSDictionary *)userinfo
{
    NSArray *selectedImages = [userinfo objectForKey:@"selected_images"];
    NSArray *selectedIndexPaths = [userinfo objectForKey:@"selected_indexpath"];
    
    _selectedImagesCameraController = [selectedImages mutableCopy];
    _selectedIndexPathCameraController = [selectedIndexPaths mutableCopy];
    
    [_uploadedPhotos removeAllObjects];
    [_uploadedPhotosURL removeAllObjects];
    
    NSInteger maxIndex = selectedImages.count;
    for (int i = 0; i < self.photoImageViews.count; i++) {
        UIImageView *imageView = [self.photoImageViews objectAtIndex:i];
        if (i < maxIndex) {
            NSDictionary *photo = [[selectedImages objectAtIndex:i] objectForKey:@"photo"];
            UIImage *image = [photo objectForKey:@"photo"];
            imageView.image = image;
            imageView.userInteractionEnabled = NO;
            UIButton *button = [self.photoDeleteButtons objectAtIndex:i];
            button.hidden = NO;
        }
    }
    
//    if (_generateHost) {
//        for (NSDictionary *photo in _selectedImagesCameraController) {
//            [self requestUploadImage:@{DATA_SELECTED_PHOTO_KEY : photo}];
//        }
//    } else {
//        [_requestHost requestGenerateHost];
//    }
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

#pragma mark - Tokopedia network manager delegate

- (NSString *)getPath:(int)tag {
    return @"";
}

- (NSDictionary *)getParameter:(int)tag {
    return @{};
}

- (id)getObjectManager:(int)tag {
    return nil;
}

- (NSString *)getRequestStatus:(RKMappingResult *)mappingResult withTag:(int)tag {
    ContactUsActionResponse *response = [mappingResult.dictionary objectForKey:@""];
    return response.status;
}

- (void)actionAfterRequest:(RKMappingResult *)mappingResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
    
}

@end
