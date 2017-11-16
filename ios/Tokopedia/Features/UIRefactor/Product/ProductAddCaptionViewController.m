//
//  ProductAddCaptionViewController.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 1/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ProductAddCaptionViewController.h"
#import "NavigateViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+HVDLayout.h"
#import "ReviewImageAttachment.h"
#import "AttachedPicture.h"
#import "Tokopedia-Swift.h"

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
    
    NSMutableArray<AttachedPicture*> *_uploadedPicts;
    
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
    }
    
    return self;
}

- (instancetype)initWithSelectedAssets:(NSMutableArray<DKAsset*>*)selectedAssets isEdit:(BOOL)isEdit uploadedPicture:(NSMutableArray<AttachedPicture*>*)uploadedPicture selectedImageIndex:(int)selectedImageIndex delegate:(id<ProductAddCaptionDelegate>)delegate{
    
    self = [super init];
    if (self) {
        _selectedAssets = [[NSMutableArray alloc] initWithArray:[selectedAssets copy]];
        _isEdit = isEdit;
        _uploadedPicts = [[NSMutableArray alloc] initWithArray:[uploadedPicture copy]];
        _selectedImageTag = selectedImageIndex;
        _delegate = delegate;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _isEdit?@"Ubah Gambar":@"Tambah Gambar";
    _isAttachedImageModified = NO;
    
    _addCaptionCells = [NSArray sortViewsWithTagInArray:_addCaptionCells];
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(tap:)];
    leftBarButtonItem.tag = 10;
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Simpan"
                                                                           style:UIBarButtonItemStylePlain
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
        
    [self adjustImageViews];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [AnalyticsManager trackScreenName:@"Give Review Attachments Caption Page"];
}

-(void)adjustImageViews{
    for (UIImageView *imageView in _attachedImages) {
        imageView.hidden = YES;
        imageView.image = [UIImage imageNamed:@"icon_upload_image"];
    }
    
    
    int i = 0;
    for (AttachedPicture *pic in [self attachedImageWithoutDeletedImage]) {
        if (![pic.isDeleted isEqualToString:@"1"] && i<_attachedImages.count) {
            ((UIImageView*)_attachedImages[i]).hidden = NO;
            ((UIImageView*)_attachedImages[i]).image = [self attachedImageWithoutDeletedImage][i].image;
            i++;
        }
    }
    
    if ([self attachedImageWithoutDeletedImage].count < _attachedImages.count) {
        UIImageView *uploadedButton = _attachedImages[[self attachedImageWithoutDeletedImage].count];
        uploadedButton.hidden = NO;
    }
    
    if (_imagesScrollView) {
        [self setScrollViewImages];
    }
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
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
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
                [_delegate updateSelectedAssets:self.selectedAssets
                               uploadedPictures:_uploadedPicts];
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            default:
                break;
        }
    }
}

-(NSArray<AttachedPicture *> *)attachedImageWithoutDeletedImage{
    NSMutableArray *attached = [NSMutableArray new];
    
    for (AttachedPicture *pict in _uploadedPicts) {
        if (![pict.isDeleted isEqualToString:@"1"]) {
            [attached addObject:pict];
        }
    }
    
    return [attached copy];
}

- (IBAction)gestureBackground:(UITapGestureRecognizer*)sender {
    [_activeTextField resignFirstResponder];
}

- (IBAction)gesture:(UITapGestureRecognizer*)sender {
    [_activeTextField resignFirstResponder];
    if (sender.view.tag == [self attachedImageWithoutDeletedImage].count) {
        __weak typeof(self) wself = self;
        [TKPImagePickerController showImagePicker:self
                                     assetType:DKImagePickerControllerAssetTypeAllPhotos
                           allowMultipleSelect:YES
                                    showCancel:YES
                                    showCamera:YES
                                   maxSelected:5 - ([self attachedImageWithoutDeletedImage].count-self.selectedAssets.count)
                                selectedAssets:self.selectedAssets
                                    completion:^(NSArray<DKAsset *> *asset) {
                                        dispatch_async (dispatch_get_main_queue(), ^{
                                            [wself setSelectedAsset:asset];
                                            [wself addImageFromAsset];
                                        });
                                    }];
    } else {
        AttachedPicture *selectedPict = [self attachedImageWithoutDeletedImage][sender.view.tag];
        
        _selectedImageTag = sender.view.tag;
        _selectedImageIcon = ((UIImageView*)self.attachedImages[sender.view.tag]);
        [_selectedImageIcon.layer setBorderColor:[[UIColor colorWithRed:18.0/255 green:199.0/255 blue:0.0 alpha:1] CGColor]];
        [_selectedImageIcon.layer setBorderWidth:2.0];
        
        for (UIImageView *image in _attachedImages) {
            if (image.tag != _selectedImageIcon.tag) {
                [image.layer setBorderColor:[[UIColor colorWithRed:200.0/255 green:199.0/255 blue:204.0/255 alpha:1] CGColor]];
                [image.layer setBorderWidth:0];
            }
        }
        
        [_imagesScrollView setContentOffset:CGPointMake((sender.view.tag) * _imagesScrollView.frame.size.width, 0) animated:NO];
        
        [_imageCaptionTextField setText:selectedPict.imageDescription];
    }
}

-(void)setSelectedAsset:(NSArray<DKAsset*>*)selectedAsset{
    [self.selectedAssets removeAllObjects];
    [self.selectedAssets addObjectsFromArray:selectedAsset];
}

-(void)addImageFromAsset{
    
    NSArray <AttachedPicture*> *selectedImagesReview = _uploadedPicts;
    
    NSMutableArray <AttachedPicture*>*selectedImages = [[NSMutableArray alloc]initWithArray:selectedImagesReview];
    
    for (AttachedPicture *selected in selectedImagesReview) {
        if (selected.asset != nil) {
            [selectedImages removeObject:selected];
        }
    }
    for (DKAsset* selectedImage in self.selectedAssets) {
        
        __block AttachedPicture *pict = [AttachedPicture new];
        pict.thumbnailUrl = @"";
        pict.largeUrl = @"";
        pict.imageDescription = @"";
        pict.attachmentID = @"0";
        pict.isDeleted = @"0";
        pict.isPreviouslyUploaded = @"0";
        pict.asset = selectedImage;
        
        [selectedImage fetchOriginalImage:NO completeBlock:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
            pict.image = image;
            NSString *fileName = ((NSURL *)info[@"PHImageFileURLKey"]).lastPathComponent;
            pict.fileName = fileName;
            
            for (AttachedPicture *lastSelected in _uploadedPicts) {
                if ([lastSelected.fileName isEqualToString:fileName]){
                    pict = lastSelected;
                }
            }
            
            [selectedImages addObject:pict];

            _uploadedPicts = [selectedImages mutableCopy];
            _selectedImageTag = [self attachedImageWithoutDeletedImage].count-1;
            
            [self adjustImageViews];
            
        }];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = _imagesScrollView.frame.size.width;
    int page = floor((_imagesScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (page < [self attachedImageWithoutDeletedImage].count) {
        AttachedPicture *selectedPict = [self attachedImageWithoutDeletedImage][page];
        
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
    
    if (_selectedImageTag < 0) {
        _selectedImageTag = 0;
    }
    
    AttachedPicture *selectedPict = [self attachedImageWithoutDeletedImage][_selectedImageTag];
    AttachedPicture *selectedPictCopy = [selectedPict copy];
    selectedPictCopy.imageDescription = imageCaption;

    
    [_uploadedPicts replaceObjectAtIndex:_selectedImageTag withObject:selectedPictCopy];
    
    return YES;
}

//For limiting text field length to 128 characters. Remove the comment if needed.
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    if(range.length + range.location > textField.text.length) {
//        return NO;
//    }
//    
//    NSUInteger newLength = [textField.text length] + [string length] - range.length;
//    return newLength <= 128;
//}

#pragma mark - Methods
- (void)setScrollViewImages {
    [_imagesScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for(int ii = 0; ii < [self attachedImageWithoutDeletedImage].count; ii++) {
        AttachedPicture *pict = [self attachedImageWithoutDeletedImage][ii];
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
    
    _imagesScrollView.contentSize = CGSizeMake(_imagesScrollView.frame.size.width * [self attachedImageWithoutDeletedImage].count, _imagesScrollView.frame.size.height);
    
    [_imagesScrollView setContentOffset:CGPointMake(_selectedImageTag * _imagesScrollView.frame.size.width, 0) animated:NO];
    
    
    if ([self attachedImageWithoutDeletedImage].count > 0){
        if (_selectedImageTag >= _uploadedPicts.count)
            _selectedImageTag = 0;
        _imageCaptionTextField.text = ((AttachedPicture*)[self attachedImageWithoutDeletedImage][_selectedImageTag]).imageDescription?:@"";
    }
}

- (void)deleteImageAtIndex:(NSInteger)index {
    _isAttachedImageModified = YES;
    
    AttachedPicture *deletedPict = [self attachedImageWithoutDeletedImage][index];
    AttachedPicture *deletedPictCopy = [deletedPict copy];
    
    if ([deletedPict.isPreviouslyUploaded isEqualToString:@"1"]) {
        [_uploadedPicts removeObject:deletedPict];
        
        deletedPictCopy.isDeleted = @"1";
        [_uploadedPicts addObject:deletedPictCopy];
        
    } else {
        [self.selectedAssets removeObject:deletedPict.asset];
        [_uploadedPicts removeObject:deletedPict];
    }
    
    [self adjustImageViews];
    
    if ([self attachedImageWithoutDeletedImage].count == 0) {
        [_delegate updateSelectedAssets:self.selectedAssets
                         uploadedPictures:_uploadedPicts];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
