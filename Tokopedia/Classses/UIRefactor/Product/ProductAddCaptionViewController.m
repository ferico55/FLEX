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
#import "AttachedPicture.h"
#import "UIImageView+AFNetworking.h"

@interface ProductAddCaptionViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UIScrollViewDelegate,
    UITextFieldDelegate
>
{
    UITextField *_activeTextField;
    UIImageView *_selectedImageIcon;
    BOOL _isAttachedImageModified;
    
    NSMutableArray *_uploadedPicts;
    NSMutableArray *_attachedPicts;
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

- (id)init {
    self = [super init];
    if (self) {
        _attachedImagesArray = [NSMutableArray new];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _isEdit?@"Ubah Gambar":@"Tambah Gambar";
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
    
    _attachedImages = [NSArray sortViewsWithTagInArray:_attachedImages];
    _imageCaptionTextField.delegate = self;
    
    _uploadedPicts = [NSMutableArray new];
    _attachedPicts = [NSMutableArray new];
    
    [_uploadedPicts addObjectsFromArray:_uploadedPictures];
    [_attachedPicts addObjectsFromArray:_attachedPictures];
    
    [self setDataWithImageTag:0];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setDataWithImageTag:(NSInteger)imageTag {
    _imageCaptionTextField.text = ((AttachedPicture*)_attachedPicts[imageTag]).imageDescription;
    
    for (int ii = 0; ii < _attachedPicts.count; ii++) {
        AttachedPicture *pict = _attachedPicts[ii];
        
        for (UIImageView *imageView in _attachedImages) {
            if (imageView.tag == 20 + ii) {
                if (![pict.thumbnailUrl isEqualToString:@""]) {
                    [imageView setImageWithURL:[NSURL URLWithString:pict.thumbnailUrl]
                              placeholderImage:[UIImage imageNamed:@"image_not_loading.png"]];
                } else {
                    imageView.image = pict.image;
                }
            }
            
            if (imageView.tag == 21 + ii) {
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)image:(UIImage*)image1 isEqualTo:(UIImage*)image2 {
    return [UIImagePNGRepresentation(image1) isEqual:UIImagePNGRepresentation(image2)];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
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
                [self.navigationController popViewControllerAnimated:YES];
                break;
            case 11: { // Tombol "Simpan"
                [_delegate updateAttachedPictures:_attachedPicts
                                   selectedAssets:_selectedAssets
                                 uploadedPictures:_uploadedPicts
                             tempUploadedPictures:_tempUploadedPictures];
                [self.navigationController popViewControllerAnimated:YES];
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
            [ImagePickerController showImagePicker:self
                                         assetType:DKImagePickerControllerAssetTypeallPhotos
                               allowMultipleSelect:YES
                                        showCancel:YES
                                        showCamera:YES
                                       maxSelected:(5 - _tempUploadedPictures.count)
                                    selectedAssets:_selectedAssets
                                        completion:^(NSArray<DKAsset *> *asset) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                NSMutableArray *temp = [_tempUploadedPictures mutableCopy];
                                                _selectedAssets = asset;
                                                
                                                for (int ii = 0; ii < asset.count; ii++) {
                                                    DKAsset *dk = asset[ii];
                                                    
                                                    AttachedPicture *pict = [AttachedPicture new];
                                                    pict.image = dk.resizedImage;
                                                    pict.fileName = dk.fileName;
                                                    pict.thumbnailUrl = @"";
                                                    pict.largeUrl = @"";
                                                    pict.imageDescription = @"";
                                                    pict.attachmentID = @"0";
                                                    pict.isDeleted = @"0";
                                                    pict.isPreviouslyUploaded = @"0";
                                                    
                                                    [temp addObject:pict];
                                                }
                                                
                                                _attachedPicts = temp;
                                                
                                                [self setDataWithImageTag:0];

                                            });
                                        }];
        } else {
            AttachedPicture *selectedPict = _attachedPicts[sender.view.tag - 20];
            
            _selectedImageTag = sender.view.tag - 20;
            _selectedImageIcon = ((UIImageView*)self.attachedImages[sender.view.tag - 20]);
            [_selectedImageIcon.layer setBorderColor:[[UIColor colorWithRed:18.0/255 green:199.0/255 blue:0.0 alpha:1] CGColor]];
            [_selectedImageIcon.layer setBorderWidth:2.0];
            
            for (UIImageView *image in _attachedImages) {
                if (image.tag != _selectedImageIcon.tag) {
                    [image.layer setBorderColor:[[UIColor colorWithRed:200.0/255 green:199.0/255 blue:204.0/255 alpha:1] CGColor]];
                    [image.layer setBorderWidth:0];
                }
            }
            
            [_imagesScrollView setContentOffset:CGPointMake((sender.view.tag-20) * _imagesScrollView.frame.size.width, 0) animated:NO];
            
            [_imageCaptionTextField setText:selectedPict.imageDescription];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = _imagesScrollView.frame.size.width;
    int page = floor((_imagesScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (page < _attachedPicts.count) {
        AttachedPicture *selectedPict = _attachedPicts[page];
        
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
        
        [_imageCaptionTextField setText:selectedPict.imageDescription];
        _isAttachedImageModified = YES;
    }
}

- (IBAction)tapToDeleteImage:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        [self deleteImageAtIndex:btn.tag];
    }
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
    
    AttachedPicture *selectedPict = _attachedPicts[_selectedImageTag];
    selectedPict.imageDescription = imageCaption;

    [_attachedPicts replaceObjectAtIndex:_selectedImageTag withObject:selectedPict];
    
    return YES;
}

#pragma mark - Methods
- (void)setScrollViewImages {
    [_imagesScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for(int ii = 0; ii < _attachedPicts.count; ii++) {
        AttachedPicture *pict = _attachedPicts[ii];
        CGRect screenRect;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            screenRect = [[self.navigationController viewControllers] firstObject].view.bounds;
        } else {
            screenRect = [[UIScreen mainScreen] bounds];
        }
        
        CGRect frame = _imagesScrollView.frame;
        frame.size.width = screenRect.size.width;
        _imagesScrollView.frame = frame;
        
        frame.origin.x = _imagesScrollView.frame.size.width * ii;
        frame.origin.y = 0;
        frame.size = _imagesScrollView.frame.size;
        
        UIImageView *newImageView = [UIImageView new];
        
        if ([pict.largeUrl isEqualToString:@""]) {
            newImageView.image = pict.image;
        } else {
            [newImageView setImageWithURL:[NSURL URLWithString:pict.largeUrl]
                         placeholderImage:[UIImage imageNamed:@"attached_image_placeholder.png"]];
        }
        
        
        newImageView.contentMode = UIViewContentModeScaleAspectFit;
        newImageView.frame = frame;
        newImageView.userInteractionEnabled = YES;
        
        [_imagesScrollView addSubview:newImageView];
        
        UIButton *deleteButton = [UIButton new];
        [deleteButton setImage:[UIImage imageNamed:@"icon_delete.png"] forState:UIControlStateNormal];
        [deleteButton.imageView setContentMode:UIViewContentModeCenter];
        [deleteButton HVD_setWidth:40.0];
        [deleteButton HVD_setHeight:40.0];
        
        [newImageView addSubview:deleteButton];
        
        [deleteButton addTarget:self action:@selector(tapToDeleteImage:) forControlEvents:UIControlEventTouchUpInside];
        deleteButton.tag = ii;
        [deleteButton setEnabled:YES];
        [deleteButton setUserInteractionEnabled:YES];
        [deleteButton HVD_pinToTopOfSuperviewWithMargin:8];
        [deleteButton HVD_pinToRightOfSuperviewWithMargin:deleteButton.frame.size.width + 8];
    }
    
    _imagesScrollView.contentSize = CGSizeMake(_imagesScrollView.frame.size.width * _attachedPicts.count, _imagesScrollView.frame.size.height);
}

- (void)deleteImageAtIndex:(NSInteger)index {
    _isAttachedImageModified = YES;
    AttachedPicture *deletedPict = _attachedPicts[index];
    
    if ([deletedPict.isPreviouslyUploaded isEqualToString:@"1"]) {
        deletedPict.isDeleted = @"1";
        
        for (int ii = 0; ii < _uploadedPicts.count; ii++) {
            if ([_uploadedPicts[ii] isEqual:deletedPict]) {
                [_uploadedPicts replaceObjectAtIndex:ii withObject:deletedPict];
            }
        }
        
        [_tempUploadedPictures removeObjectAtIndex:index];
    } else {
        NSMutableArray *tempSelectedPicts = [_selectedAssets mutableCopy];
        [tempSelectedPicts removeObjectAtIndex:(index - _tempUploadedPictures.count)];
        _selectedAssets = tempSelectedPicts;
    }
    
    _imageCaptionTextField.text = @"";
    
    NSInteger temp = _selectedImageTag;
    
    if (temp == _attachedPicts.count - 1) {
        temp--;
    }
    
    [_attachedPicts removeObjectAtIndex:index];
    
    for (int ii = 0; ii < _attachedImages.count; ii++) {
        UIImageView *imageView = _attachedImages[ii];
        imageView.image = nil;
        imageView.userInteractionEnabled = NO;
    }
    
    if (_attachedPicts.count < 5) {
        for (UIImageView *imageView in _attachedImages) {
            if (imageView.tag == 20 + _attachedPicts.count) {
                imageView.image = [UIImage imageNamed:@"icon_upload_image.png"];
                imageView.userInteractionEnabled = YES;
            }
        }
    }
    
    if (_attachedPicts.count == 0) {
        [_delegate updateAttachedPictures:_attachedPicts
                           selectedAssets:_selectedAssets
                         uploadedPictures:_uploadedPicts
                     tempUploadedPictures:_tempUploadedPictures];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self setDataWithImageTag:temp];
    }
}

@end
