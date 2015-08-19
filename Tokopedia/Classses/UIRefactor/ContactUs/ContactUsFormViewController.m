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


@interface ContactUsFormViewController ()
<
    TokopediaNetworkManagerDelegate,
    CameraAlbumListDelegate,
    CameraCollectionViewControllerDelegate,
    GenerateHostDelegate,
    RequestUploadImageDelegate,
    UITableViewDataSource,
    UITableViewDelegate
>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
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

@property (weak, nonatomic) IBOutlet UIScrollView *uploadPhotoScrollView;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *photoImageViews;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *photoDeleteButtons;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *photoButtons;

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
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Kirim Pesan"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(sendMessage)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    self.photoImageViews = [NSArray sortViewsWithTagInArray:_photoImageViews];
    self.photoButtons = [NSArray sortViewsWithTagInArray:_photoButtons];
    self.photoDeleteButtons = [NSArray sortViewsWithTagInArray:_photoDeleteButtons];
    
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

#pragma mark - Scroll view delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.view endEditing:YES];
}

#pragma mark - Actions

- (IBAction)tap:(id)sender {

}

#pragma mark - Keyboard Notification

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardFrameBeginRect.size.height+25, 0);
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
    
//    self.photoScrollView.hidden = NO;
//    
//    NSInteger maxIndex = selectedImages.count;
//    for (int i = 0; i < self.photosImageView.count; i++) {
//        UIImageView *imageView = [self.photosImageView objectAtIndex:i];
//        imageView.userInteractionEnabled = NO;
//        if (i < maxIndex) {
//            NSDictionary *photo = [[selectedImages objectAtIndex:i] objectForKey:@"photo"];
//            UIImage *image = [photo objectForKey:@"photo"];
//            imageView.image = image;
//            imageView.hidden = NO;
//            imageView.alpha = 0.7;
//        } else {
//            imageView.hidden = YES;
//        }
//        UIButton *button = [self.removePhotoButton objectAtIndex:i];
//        button.hidden = YES;
//    }
//    
//    if (selectedImages.count < 5) {
//        CGFloat width = (90 * maxIndex) + 90;
//        self.photoScrollView.contentSize = CGSizeMake(width, self.photoScrollView.frame.size.height);
//    } else {
//        CGFloat width = 90 * maxIndex;
//        self.photoScrollView.contentSize = CGSizeMake(width, self.photoScrollView.frame.size.height);
//    }
//    
//    if (_generateHost) {
//        for (NSDictionary *photo in _selectedImagesCameraController) {
//            [self requestUploadImage:@{DATA_SELECTED_PHOTO_KEY : photo}];
//        }
//    } else {
//        [_requestHost requestGenerateHost];
//    }
//    
//    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//    [indicatorView startAnimating];
//    UIBarButtonItem *indicatorBarButton = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
//    self.navigationItem.rightBarButtonItem = indicatorBarButton;
}


@end
