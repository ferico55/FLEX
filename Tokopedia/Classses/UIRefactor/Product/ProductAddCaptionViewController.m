//
//  ProductAddCaptionViewController.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 1/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ProductAddCaptionViewController.h"
#import "NavigateViewController.h"
#import "CameraCollectionViewController.h"
#import "CameraAlbumListViewController.h"
#import "RequestGenerateHost.h"
#import "RequestUploadImage.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+HVDLayout.h"

@interface ProductAddCaptionViewController () <UITableViewDataSource, UITableViewDelegate, GenerateHostDelegate, RequestUploadImageDelegate, CameraCollectionViewControllerDelegate, UIScrollViewDelegate, UITextFieldDelegate, TokopediaNetworkManagerDelegate> {
    NavigateViewController *_navigate;
    
    UITextField *_activeTextField;
    
    GenerateHost *_generateHost;
    GeneratedHost *_generatedHost;
    
    NSOperationQueue *_operationQueue;
    NSMutableArray *_uploadedImages;
    NSMutableArray *_uploadingImages;
    NSMutableArray *_attachedImageURLs;
    NSMutableArray *_selectedImagesCameraController;
    NSMutableArray *_selectedIndexPathCameraController;
    NSMutableArray *_attachedImagesCaptions;
    
    UIImageView *_selectedImageIcon;
    
    BOOL _isFinishedUploadingImage;
    
    int _scrollViewPageAmount;
    
    TokopediaNetworkManager *_networkManager;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIView *imagesView;
@property (weak, nonatomic) IBOutlet UIImageView *attachedImageView;
@property (weak, nonatomic) IBOutlet UIImageView *deleteIconImageView;
@property (weak, nonatomic) IBOutlet UITextField *imageCaptionTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *imagesScrollView;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *attachedImages;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *addCaptionCells;

@end

@implementation ProductAddCaptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Tambah Gambar";
    
    _addCaptionCells = [NSArray sortViewsWithTagInArray:_addCaptionCells];
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(tap:)];
    leftBarButtonItem.tag = 10;
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Simpan"
                                                                           style:UIBarButtonItemStyleBordered
                                                                          target:self
                                                                          action:@selector(tap:)];
    rightBarButtonItem.tag = 11;
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    // Keyboard Notification
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self
                     selector:@selector(keyboardWillShow:)
                         name:UIKeyboardWillShowNotification
                       object:nil];
    [notification addObserver:self
                     selector:@selector(keyboardWillHide:)
                         name:UIKeyboardWillHideNotification
                       object:nil];
    
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    
    _generateHost = [GenerateHost new];
    _generatedHost = [GeneratedHost new];
    _operationQueue = [NSOperationQueue new];
    
    _uploadingImages = [NSMutableArray new];
    _uploadedImages = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", nil];
    _selectedImagesCameraController = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", nil];
    _selectedIndexPathCameraController = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", nil];
    _attachedImageURLs = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", nil];
    _attachedImagesCaptions = [_userInfo objectForKey:@"images-captions"]?:[[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", nil];
    
    _attachedImages = [NSArray sortViewsWithTagInArray:_attachedImages];
    
    _numberOfUploadedImages = 0;
    _scrollViewPageAmount = 0;
    
    _imageCaptionTextField.delegate = self;
    
    RequestGenerateHost *requestHost = [RequestGenerateHost new];
    [requestHost configureRestkitGenerateHost];
    [requestHost requestGenerateHost];
    requestHost.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)totalUploadedAndUploadingImage {
    NSMutableArray *fileThumbImage = [NSMutableArray new];
    for (NSString *image in _uploadedImages) {
        if (![image isEqualToString:@""]) {
            [fileThumbImage addObject:image];
        }
    }
    
    return fileThumbImage.count + _uploadingImages.count;
}

- (BOOL)image:(UIImage*)image1 isEqualTo:(UIImage*)image2 {
    return [UIImagePNGRepresentation(image1) isEqual:UIImagePNGRepresentation(image2)];
}

- (BOOL)array:(NSArray*)arr containsObject:(NSDictionary*)object {
    if (object && [object isKindOfClass:[NSDictionary class]]) {
        for (id objectInArray in arr) {
            if ([objectInArray isKindOfClass:[NSDictionary class]]) {
                NSDictionary *photoObjectInArray = [objectInArray objectForKey:@"photo"];
                NSDictionary *photoObject = [object objectForKey:@"photo"];
                if ([self image:[photoObjectInArray objectForKey:@"photo"] isEqualTo:[photoObject objectForKey:@"photo"]]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}


#pragma mark - Table View Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _addCaptionCells.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *addCaptionCellIdentifier = @"AddCaptionCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:addCaptionCellIdentifier];
    
    if (cell == nil) {
        cell = _addCaptionCells[indexPath.section];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        [cell setBackgroundColor:[UIColor clearColor]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_addCaptionCells[indexPath.section] frame].size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary* userInfo = [notification userInfo];
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    _table.contentInset = contentInsets;
    _table.scrollIndicatorInsets = contentInsets;
    
    if (_activeTextField == _imageCaptionTextField) {
        [_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification*)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _table.contentInset = contentInsets;
                         _table.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished){
                     }];
}

#pragma mark - Action
- (IBAction)tap:(id)sender {
    [_imageCaptionTextField resignFirstResponder];
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        switch (button.tag) {
            case 10: // Tombol "Batal"
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                break;
            case 11: { // Tombol "Simpan"
                NSMutableDictionary *tempUserInfoDict = [_userInfo mutableCopy];
                [tempUserInfoDict setObject:_attachedImagesCaptions forKey:@"images-captions"];
                [tempUserInfoDict setObject:_uploadedImages forKey:@"uploaded-images"];
                _userInfo = [NSDictionary dictionaryWithDictionary:tempUserInfoDict];
                [_delegate didDismissController:self withUserInfo:_userInfo];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                break;
            }
            default:
                break;
        }
    }
}

- (IBAction)gesture:(UITapGestureRecognizer*)sender {
    if (sender.view.tag == 0) {
        [_activeTextField resignFirstResponder];
    } else {
        if ([self image:((UIImageView*)self.attachedImages[sender.view.tag-20]).image isEqualTo:[UIImage imageNamed:@"icon_upload_image.png"]]) {
            [self didTapImage:((UIImageView*)self.attachedImages[sender.view.tag-20])];
        } else {
            _selectedImageTag = sender.view.tag - 20;
            _selectedImageIcon = ((UIImageView*)self.attachedImages[sender.view.tag-20]);
            [_selectedImageIcon.layer setBorderColor:[[UIColor colorWithRed:18.0/255 green:199.0/255 blue:0.0 alpha:1] CGColor]];
            [_selectedImageIcon.layer setBorderWidth:2.0];
            
            for (UIImageView *image in _attachedImages) {
                if (image.tag != _selectedImageIcon.tag) {
                    [image.layer setBorderColor:[[UIColor colorWithRed:200.0/255 green:199.0/255 blue:204.0/255 alpha:1] CGColor]];
                    [image.layer setBorderWidth:0];
                }
            }
            
            [_imagesScrollView setContentOffset:CGPointMake((sender.view.tag-20) * _imagesScrollView.frame.size.width, 0) animated:NO];
            
            [_imageCaptionTextField setText:_attachedImagesCaptions[sender.view.tag-20]];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = _imagesScrollView.frame.size.width;
    int page = floor((_imagesScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    _selectedImageTag = page;
    _selectedImageIcon = ((UIImageView*)self.attachedImages[page]);
    [_selectedImageIcon.layer setBorderColor:[[UIColor colorWithRed:18.0/255 green:199.0/255 blue:0.0 alpha:1] CGColor]];
    [_selectedImageIcon.layer setBorderWidth:2.0];
    
    for (UIImageView *image in _attachedImages) {
        if (image.tag != _selectedImageIcon.tag) {
            [image.layer setBorderColor:[[UIColor colorWithRed:200.0/255 green:199.0/255 blue:204.0/255 alpha:1] CGColor]];
            [image.layer setBorderWidth:0];
        }
    }
    
    [_imageCaptionTextField setText:_attachedImagesCaptions[page]];
}

- (IBAction)tapToDeleteImage:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        [self deleteImageAtIndex:btn.tag];
    }
    
}

#pragma mark - Request Generate Host
- (void)successGenerateHost:(GenerateHost *)generateHost {
    _generateHost = generateHost;
    _generatedHost = _generateHost.result.generated_host;
    [self startUploadingImageWithUserInfo:_userInfo];
}

- (void)failedGenerateHost:(NSArray *)errorMessages {
    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessages delegate:self];
    [alert show];
}


#pragma mark - Camera Collection Delegate
- (void)startUploadingImageWithUserInfo:(NSDictionary*)userInfo {
    _userInfo = userInfo;
    NSArray *selectedImages = [userInfo objectForKey:@"selected_images"];
    NSArray *selectedIndexpaths = [userInfo objectForKey:@"selected_indexpath"];
    
    // Cari Index Image yang kosong
    NSMutableArray *emptyImageIndex = [NSMutableArray new];
    for (UIImageView *image in _attachedImages) {
        if (image.image == nil || [self image:image.image isEqualTo:[UIImage imageNamed:@"icon_upload_image.png"]]) {
            [emptyImageIndex addObject:@(image.tag - 20)];
        }
    }
    
    //Upload Image yg belum diupload tp dipilih
    int j = 0;
    for (NSDictionary *selected in selectedImages) {
        if ([selected isKindOfClass:[NSDictionary class]]) {
            if (j>=emptyImageIndex.count) {
                return;
            }
            if (![self array:[_selectedImagesCameraController copy] containsObject:selected]) {
                NSUInteger index = [emptyImageIndex[j] integerValue];
                [_selectedImagesCameraController replaceObjectAtIndex:index withObject:selected];
                NSMutableDictionary *data = [NSMutableDictionary new];
                [data addEntriesFromDictionary:selected];
                NSUInteger indexIndexPath = [_selectedImagesCameraController indexOfObject:selected];
                [data setObject:selectedIndexpaths[indexIndexPath] forKey:@"selected_indexpath"];
                [self setImageData:[data copy] tag:index];
                j++;
            }
        }
    }
}

-(void)setImageData:(NSDictionary*)data tag:(NSInteger)tag
{
    id selectedIndexpaths = [data objectForKey:@"selected_indexpath"];
    [_selectedIndexPathCameraController replaceObjectAtIndex:tag withObject:selectedIndexpaths?:@""];
    
    NSInteger tagView = tag + 20;
    NSMutableDictionary *object = [NSMutableDictionary new];
    [object setObject:data forKey:@"photo"];
    UIImageView *imageView;
    
    NSDictionary* photo = [data objectForKey:@"photo"];
    
    UIImage* imagePhoto = [photo objectForKey:@"photo"];
    
    for (UIImageView *image in _attachedImages) {
        if (image.tag == tagView) {
            imageView = image;
            image.image = imagePhoto;
            image.hidden = NO;
            image.alpha = _isFromGiveReview?1.0f:0.5f;
            image.userInteractionEnabled = YES;
            [image.layer setBorderColor:(_selectedImageTag == tagView)?[[UIColor colorWithRed:18.0/255 green:199.0/255 blue:0.0 alpha:1] CGColor]:[[UIColor colorWithRed:200.0/255 green:199.0/255 blue:204.0/255 alpha:1] CGColor]];
            [image.layer setBorderWidth:(_selectedImageTag == tagView)?2.0:1.0];
            if (_selectedImageTag == tagView) {
                [_imagesScrollView setContentOffset:CGPointMake((tagView  - 20) * _imagesScrollView.frame.size.width, 0) animated:YES];
            }
        }
        
        if (image.tag == tagView + 1) {
            if (image.image == nil) {
                image.image = [UIImage imageNamed:@"icon_upload_image.png"];
                image.userInteractionEnabled = YES;
                image.hidden = NO;
            }
        }
    }
    
    if (imageView != nil) {
        [object setObject:imageView forKey:@"data_selected_image_view"];
    }
    
    [object setObject:_selectedImagesCameraController[tag] forKey:@"data_selected_photo"];
    [object setObject:_selectedIndexPathCameraController[tag] forKey:@"data_selected_indexpath"];
    
    if (!_isFromGiveReview) {
        [self actionUploadImage:object];
    }
    
    _numberOfUploadedImages++;
    _scrollViewPageAmount = (_scrollViewPageAmount>=_numberOfUploadedImages)?_scrollViewPageAmount:_numberOfUploadedImages;
    [self setScrollViewImages];
}

#pragma mark - Scroll View Delegate
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [_activeTextField resignFirstResponder];
    _activeTextField = nil;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_activeTextField resignFirstResponder];
}

#pragma mark - Text Field Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    _activeTextField = textField;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    NSString *imageCaption = textField.text;    [_attachedImagesCaptions replaceObjectAtIndex:_selectedImageTag withObject:imageCaption];
    return YES;
}

#pragma mark - Request Action Upload Image
- (void)actionUploadImage:(id)object {
    if (![_uploadingImages containsObject:object]) {
        [_uploadingImages addObject:object];
    }
    
    _isFinishedUploadingImage = NO;
    
    RequestUploadImage *uploadImage = [RequestUploadImage new];
    [uploadImage requestActionUploadObject:object
                             generatedHost:_generateHost.result.generated_host
                                    action:@"upload_contact_image"
                                    newAdd:1
                                 productID:@""
                                 paymentID:@""
                                 fieldName:@"fileToUpload"
                                   success:^(id imageObject, UploadImage *image) {
                                       [self successUploadObject:object withMappingResult:image];
                                   } failure:^(id imageObject, NSError *error) {
                                       [self failedUploadObject:imageObject];
                                   }];
    
}

- (void)successUploadObject:(id)object withMappingResult:(UploadImage *)uploadImage {
    UIImageView *imageView = [object objectForKey:DATA_SELECTED_IMAGE_VIEW_KEY];
    imageView.alpha = 1.0;
    
    if (![_uploadedImages containsObject:uploadImage.result.file_th]) {
        [_uploadedImages replaceObjectAtIndex:imageView.tag-20 withObject:uploadImage.result.file_th];
    }
    
    [_uploadingImages removeObject:object];
    _isFinishedUploadingImage = YES;
    
    
}

- (void)failedUploadObject:(id)object {
    
    UIImageView *imageView = [object objectForKey:DATA_SELECTED_IMAGE_VIEW_KEY];
    imageView.image = [UIImage imageNamed:@"icon_upload_image.png"];
    
    for (UIImageView *image in _attachedImages) {
        if (image.tag == imageView.tag) {
            image.image = imageView.image;
            image.hidden = NO;
            image.userInteractionEnabled = YES;
        }
    }
    
    [_uploadingImages removeObject:object];
    NSMutableArray *objectProductPhoto = [NSMutableArray new];
    objectProductPhoto = _uploadedImages;
    for (int i = 0; i<_selectedImagesCameraController.count; i++) {
        if ([_selectedImagesCameraController[i] isEqual:[object objectForKey:DATA_SELECTED_PHOTO_KEY]]) {
            [_selectedImagesCameraController replaceObjectAtIndex:i withObject:@""];
            [_selectedIndexPathCameraController replaceObjectAtIndex:i withObject:@""];
            [objectProductPhoto replaceObjectAtIndex:i withObject:@""];
        }
    }
}

#pragma mark - Go to Camera Collection
- (void)didTapImage:(UIImageView*)sender {
    CameraAlbumListViewController *albumVC = [CameraAlbumListViewController new];
    albumVC.title = @"Album";
    albumVC.delegate = self;
    CameraCollectionViewController *photoVC = [CameraCollectionViewController new];
    photoVC.title = @"All Picture";
    photoVC.delegate = self;
    photoVC.isAddEditProduct = YES;
    photoVC.tag = sender.tag;
    
    NSMutableArray *notEmptyImageIndex = [NSMutableArray new];
    for (UIImageView *image in _attachedImages) {
        if (image.image == nil) {
            [notEmptyImageIndex addObject:@(image.tag - 20)];
        }
    }
    
    NSMutableArray *selectedImage = [NSMutableArray new];
    for (id selected in _selectedImagesCameraController) {
        if (![selected isEqual:@""]) {
            [selectedImage addObject:selected];
        }
    }
    
    NSMutableArray *selectedIndexPath = [NSMutableArray new];
    for (NSIndexPath *selected in _selectedIndexPathCameraController) {
        if (![selected isEqual:@""]) {
            [selectedIndexPath addObject:selected];
        }
    }
    
    photoVC.maxSelected = 5;
    photoVC.selectedImagesArray = selectedImage;
    
    selectedIndexPath = [NSMutableArray new];
    for (NSIndexPath *selected in _selectedIndexPathCameraController) {
        if (![selected isEqual:@""]) {
            [selectedIndexPath addObject:selected];
        }
    }
    
    photoVC.selectedIndexPath = _selectedIndexPathCameraController;
    photoVC.isAddMoreReviewImage = YES;
    
    UINavigationController *nav = [[UINavigationController alloc]init];
    nav.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.tintColor = [UIColor whiteColor];
    NSArray *controllers = @[albumVC,photoVC];
    [nav setViewControllers:controllers];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    
}

#pragma mark - Methods

- (void)setScrollViewImages {
    [_imagesScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for(int ii = 0; ii < _scrollViewPageAmount; ii++) {
        CGRect frame;
        frame.origin.x = _imagesScrollView.frame.size.width * ii;
        frame.origin.y = 0;
        frame.size = _imagesScrollView.frame.size;
        
        UIImageView *newImageView;
        
        if ([self image:((UIImageView*)self.attachedImages[ii]).image isEqualTo:[UIImage imageNamed:@"icon_upload_image.png"]]) {
            newImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"image_not_loading.png"]];
            newImageView.contentMode = UIViewContentModeCenter;
            newImageView.frame = frame;
            [_imagesScrollView addSubview:newImageView];
        } else {
            newImageView = [[UIImageView alloc] initWithImage:((UIImageView*)self.attachedImages[ii]).image];
            newImageView.contentMode = UIViewContentModeScaleAspectFit;
            newImageView.frame = frame;
            newImageView.userInteractionEnabled = YES;
            
            float widthRatio = newImageView.bounds.size.width / newImageView.image.size.width;
            float heightRatio = newImageView.bounds.size.height / newImageView.image.size.height;
            float scale = MIN(widthRatio, heightRatio);
            float imageWidth = scale * newImageView.image.size.width;
            float imageHeight = scale * newImageView.image.size.height;
            
            [_imagesScrollView addSubview:newImageView];
            
            UIButton *deleteButton = [UIButton new];
            [deleteButton setImage:[UIImage imageNamed:@"icon_cancel.png"] forState:UIControlStateNormal];
            [deleteButton.imageView setContentMode:UIViewContentModeCenter];
            [deleteButton HVD_setWidth:40.0];
            [deleteButton HVD_setHeight:40.0];
            
            [newImageView addSubview:deleteButton];
            
            [deleteButton addTarget:self action:@selector(tapToDeleteImage:) forControlEvents:UIControlEventTouchUpInside];
            deleteButton.tag = ii;
            [deleteButton setEnabled:YES];
            [deleteButton setUserInteractionEnabled:YES];
            [deleteButton HVD_pinToTopOfSuperviewWithMargin:(((newImageView.frame.size.height-imageHeight)/2))];
            [deleteButton HVD_pinToRightOfSuperviewWithMargin:(((newImageView.frame.size.width-imageWidth)/2))];
        }
    }
    
    _imagesScrollView.contentSize = CGSizeMake(_imagesScrollView.frame.size.width * _scrollViewPageAmount, _imagesScrollView.frame.size.height);
}

- (void)deleteImageAtIndex:(NSInteger)index {
    [_selectedImagesCameraController replaceObjectAtIndex:index withObject:@""];
    [_selectedIndexPathCameraController replaceObjectAtIndex:index withObject:@""];
    [_uploadedImages replaceObjectAtIndex:index withObject:@""];
    
    for (UIImageView *image in _attachedImages) {
        if (image.tag-20 == index) {
            image.image = [UIImage imageNamed:@"icon_upload_image.png"];
            image.userInteractionEnabled = YES;
        }
    }
    
    [self setScrollViewImages];
    _numberOfUploadedImages--;
}

@end
