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
#import <QuartzCore/QuartzCore.h>
#import "UIView+HVDLayout.h"
#import "ReviewImageAttachment.h"
#import "UIImageView+AFNetworking.h"

@interface ProductAddCaptionViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    CameraCollectionViewControllerDelegate,
    UIScrollViewDelegate,
    UITextFieldDelegate
>
{
    NavigateViewController *_navigate;
    
    UITextField *_activeTextField;
    
    NSMutableArray *_uploadedImages;
    NSMutableArray *_attachedImageURLs;
    NSMutableArray *_selectedImagesCameraController;
    NSMutableArray *_selectedIndexPathCameraController;
    NSMutableArray *_attachedImagesCaptions;
    NSMutableArray *_productReviewPhotoObjectsArray;
    NSMutableArray *_productReviewPhotoObjectKeys;
    
    NSMutableDictionary *_productReviewPhotoObjects;
    NSMutableDictionary *_imagesToUpload;
    
    UIImageView *_selectedImageIcon;
    
    BOOL _isFinishedUploadingImage;
    BOOL _isAttachedImageModified;
    
    NSInteger _scrollViewPageAmount;
    NSInteger _maxSelected;
    
    NSString *_uniqueID;
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
    _isAttachedImageModified = NO;
    
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
    
    _uploadedImages = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", nil];
    _selectedImagesCameraController = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", nil];
    _selectedIndexPathCameraController = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", nil];
    _attachedImageURLs = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", nil];
    _attachedImagesCaptions = _imagesCaptions?[_imagesCaptions mutableCopy]:[[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", nil];
    _productReviewPhotoObjectsArray = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", nil];
    _productReviewPhotoObjectKeys = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", nil];
    
    _attachedImages = [NSArray sortViewsWithTagInArray:_attachedImages];
    
    _productReviewPhotoObjects = [NSMutableDictionary new];
    _imagesToUpload = [NSMutableDictionary new];
    
    _numberOfUploadedImages = 0;
    _scrollViewPageAmount = 0;
    _maxSelected = 5;
    
    _imageCaptionTextField.delegate = self;
    
    if (_review.review_image_attachment.count > 0) {
        _numberOfUploadedImages = _review.review_image_attachment.count;
        _scrollViewPageAmount = _numberOfUploadedImages;
        _maxSelected = 5 - _numberOfUploadedImages;
        
        for (NSInteger ii = 0; ii < _review.review_image_attachment.count; ii++) {
            ReviewImageAttachment *imageAttachment = _review.review_image_attachment[ii];
            
            [_uploadedImages replaceObjectAtIndex:ii
                                       withObject:imageAttachment];
            
            NSMutableDictionary *photoObject = [NSMutableDictionary new];
            
            [photoObject setObject:imageAttachment.desc?:@""
                             forKey:@"file_desc"];
            [photoObject setObject:imageAttachment.attachment_id?:@""
                             forKey:@"attachment_id"];
            [photoObject setObject:@(0)
                             forKey:@"is_deleted"];
            
            [_productReviewPhotoObjects setObject:photoObject forKey:imageAttachment.attachment_id];
            
            NSDictionary *tempDict = [[NSDictionary alloc] initWithObjectsAndKeys:photoObject, imageAttachment.attachment_id, nil];
            [_productReviewPhotoObjectsArray replaceObjectAtIndex:ii withObject:tempDict];
            [_productReviewPhotoObjectKeys replaceObjectAtIndex:ii withObject:imageAttachment.attachment_id];
            
            NSInteger tag = ii + 20;
            
            for (UIImageView *imageView in _attachedImages) {
                if (imageView.tag == tag) {
                    imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageAttachment.uri_large]]];
                }
                
                if (imageView.tag == tag + 1) {
                    if (imageView.image == nil) {
                        imageView.image = [UIImage imageNamed:@"icon_upload_image.png"];
                        imageView.userInteractionEnabled = YES;
                        imageView.hidden = NO;
                    }
                }
            }
        }
        
        [self setScrollViewImages];
    }
    
    [self didReceiveImageWithSelectedImages:_selectedImages
                         selectedIndexPaths:_selectedIndexPaths
                     attachedImagesCaptions:_attachedImagesCaptions];
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
                NSMutableDictionary *userInfo = [NSMutableDictionary new];
                [userInfo setObject:_attachedImagesCaptions forKey:@"images-captions"];
                [userInfo setObject:_uploadedImages forKey:@"uploaded-images"];
                [userInfo setObject:_selectedIndexPaths forKey:@"selected_indexpath"];
                [userInfo setObject:_selectedImages forKey:@"selected_images"];
                [userInfo setObject:_productReviewPhotoObjects forKey:@"product-review-photo-objects"];
                [userInfo setObject:[_productReviewPhotoObjects allKeys] forKey:@"all-image-ids"];
                [userInfo setObject:_imagesToUpload forKey:@"images-to-upload"];
                [_delegate didDismissController:self withUserInfo:userInfo];
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


#pragma mark - Camera Collection Delegate
- (void)didReceiveImageWithSelectedImages:(NSArray *)selectedImages
                       selectedIndexPaths:(NSArray *)selectedIndexPaths
                   attachedImagesCaptions:(NSArray *)attachedImagesCaptions {
    _selectedImages = selectedImages;
    _selectedIndexPaths = selectedIndexPaths;
    _attachedImagesCaptions = [attachedImagesCaptions mutableCopy];
    
    [_imageCaptionTextField setText:_attachedImagesCaptions[0]];
    
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
                [_selectedImagesCameraController replaceObjectAtIndex:index
                                                           withObject:selected];
                NSMutableDictionary *data = [NSMutableDictionary new];
                [data addEntriesFromDictionary:selected];
                NSUInteger indexIndexPath = [_selectedImagesCameraController indexOfObject:selected];
                [data setObject:_selectedIndexPaths[indexIndexPath]
                         forKey:@"selected_indexpath"];
                [self setImageData:[data copy] tag:index];
                j++;
            }
        }
    }
    
}

- (void)setImageData:(NSDictionary*)data
                 tag:(NSInteger)tag {
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
            image.alpha = 1.0;
            image.userInteractionEnabled = YES;
            [image.layer setBorderColor:(_selectedImageTag == tagView)?[[UIColor colorWithRed:18.0/255 green:199.0/255 blue:0.0 alpha:1] CGColor]:[[UIColor colorWithRed:200.0/255 green:199.0/255 blue:204.0/255 alpha:1] CGColor]];
            [image.layer setBorderWidth:(_selectedImageTag == tagView)?2.0:1.0];
            if (_selectedImageTag == tagView) {
                [_imagesScrollView setContentOffset:CGPointMake((tagView  - 20) * _imagesScrollView.frame.size.width, 0) animated:YES];
            }
            
            _uniqueID = [self getUnixTime];
            _uniqueID = [_uniqueID stringByAppendingString:[NSString stringWithFormat:@"%zd", tagView]];
            
            NSMutableDictionary *photoObject = [NSMutableDictionary new];
            
            [photoObject setObject:@""
                             forKey:@"file_desc"];
            [photoObject setObject:@(0)
                             forKey:@"attachment_id"];
            [photoObject setObject:@(0)
                             forKey:@"is_deleted"];
            
            [_productReviewPhotoObjects setObject:photoObject forKey:_uniqueID];
            
            NSDictionary *tempDict = [[NSDictionary alloc] initWithObjectsAndKeys:photoObject, _uniqueID, nil];
            [_productReviewPhotoObjectsArray replaceObjectAtIndex:tag withObject:tempDict];
            [_productReviewPhotoObjectKeys replaceObjectAtIndex:tag withObject:_uniqueID];
            [_imagesToUpload setObject:photo forKey:_uniqueID];
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
    NSString *imageCaption = textField.text;
    [_attachedImagesCaptions replaceObjectAtIndex:_selectedImageTag withObject:imageCaption];
    
    NSString *key = _productReviewPhotoObjectKeys[_selectedImageTag];
    NSDictionary *tempPhotoObject = [_productReviewPhotoObjectsArray[_selectedImageTag] objectForKey:key];
    
    [tempPhotoObject setValue:imageCaption forKey:@"file_desc"];
    
    NSDictionary *dict = @{key : tempPhotoObject};
    
    [_productReviewPhotoObjectsArray replaceObjectAtIndex:_selectedImageTag withObject:dict];
    [_productReviewPhotoObjects setObject:tempPhotoObject forKey:key];
    
    return YES;
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
    
    photoVC.maxSelected = _maxSelected;
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
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGRect frame = _imagesScrollView.frame;
        frame.size.width = screenRect.size.width;
        _imagesScrollView.frame = frame;
        
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
            
            float widthRatio = newImageView.frame.size.width / newImageView.image.size.width;
            float heightRatio = newImageView.frame.size.height / newImageView.image.size.height;
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
    [_attachedImagesCaptions replaceObjectAtIndex:index withObject:@""];
    
    if ([_uploadedImages[index] isKindOfClass:[NSString class]]) {
        [_productReviewPhotoObjectsArray replaceObjectAtIndex:index withObject:@""];
        [_productReviewPhotoObjectKeys replaceObjectAtIndex:index withObject:@""];
    } else {
        NSString *key = _productReviewPhotoObjectKeys[index];
        NSMutableDictionary *photoObject = [_productReviewPhotoObjects objectForKey:key];
        [photoObject setObject:@(1)
                        forKey:@"is_deleted"];
        
        [_productReviewPhotoObjects setObject:photoObject forKey:key];
        [_productReviewPhotoObjectsArray replaceObjectAtIndex:index withObject:@""];
        [_productReviewPhotoObjectKeys replaceObjectAtIndex:index withObject:@""];
    }
    
    [_uploadedImages replaceObjectAtIndex:index withObject:@""];
    _activeTextField.text = @"";
    
    for (UIImageView *image in _attachedImages) {
        if (image.tag-20 == index) {
            image.image = [UIImage imageNamed:@"icon_upload_image.png"];
            image.userInteractionEnabled = YES;
        }
    }
    
    [self setScrollViewImages];
    _numberOfUploadedImages--;
}

- (NSString*)getUnixTime {
    int unixTime = (int)[[NSDate date] timeIntervalSince1970];
    
    return [NSString stringWithFormat:@"%d", unixTime];
}

@end
