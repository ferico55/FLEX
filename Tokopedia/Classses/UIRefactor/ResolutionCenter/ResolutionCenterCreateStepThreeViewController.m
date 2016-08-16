//
//  ResolutionCenterCreateStepThreeViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 8/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterCreateStepThreeViewController.h"
#import "Tokopedia-Swift.h"

@interface ResolutionCenterCreateStepThreeViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *solutionCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *refundCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *photoCell;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *uploadButtons;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cancelButtons;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewUploadPhoto;

@end

@implementation ResolutionCenterCreateStepThreeViewController{
    NSMutableArray <DKAsset *>*_selectedImages;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _cancelButtons = [NSArray sortViewsWithTagInArray:_cancelButtons];
    _uploadButtons = [NSArray sortViewsWithTagInArray:_uploadButtons];
    _selectedImages = [NSMutableArray new];
    
    for(UIButton *btn in _cancelButtons) {
        btn.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            return _solutionCell;
        }else{
            return _refundCell;
        }
    }else{
        return _photoCell;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 2;
    }else{
        return 1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            return _solutionCell.frame.size.height;
        }else{
            return _refundCell.frame.size.height;
        }
    }else{
        return _photoCell.frame.size.height;
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *header = nil;
    if(section == 0){
        header = [[UIView alloc]initWithFrame:CGRectMake(16, 28, 320, 40)];
        header.backgroundColor = [UIColor clearColor];
        
        UILabel *lbl = [[UILabel alloc]initWithFrame:header.frame];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.text = @"Masalah pada barang yang Anda terima";
        lbl.textAlignment = NSTextAlignmentLeft;
        lbl.font = [UIFont fontWithName:@"Gotham Book" size:12.0];
        [lbl setNumberOfLines:0];
        [lbl sizeToFit];
        [header addSubview:lbl];
    }
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 50;
    }
    return 0;
}

#pragma mark - Methods
- (IBAction)uploadButtonTapped:(id)sender {
    [self navigateToPhotoPicker];
}

-(void)navigateToPhotoPicker{
    __weak typeof(self) wself = self;
    [ImagePickerController showImagePicker:self
                                 assetType:DKImagePickerControllerAssetTypeallPhotos
                       allowMultipleSelect:YES
                                showCancel:YES
                                showCamera:YES
                               maxSelected:5
                            selectedAssets:_selectedImages completion:^(NSArray<DKAsset *> * images) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (wself != nil) {
                                        typeof(self) sself = wself;
                                        [sself->_selectedImages removeAllObjects];
                                        [sself->_selectedImages addObjectsFromArray:images];
                                        [sself setSelectedImages];
                                    }
                                });
                            }];
}

-(void)setSelectedImages{
    for (UIButton *button in _uploadButtons) {
        button.hidden = YES;
        [button setBackgroundImage:[UIImage imageNamed:@"icon_upload_image.png"] forState:UIControlStateNormal];
    }
    for (UIButton *button in _cancelButtons) { button.hidden = YES; }
    for (int i = 0; i<_selectedImages.count; i++) {
        ((UIButton*)_uploadButtons[i]).hidden = NO;
        ((UIButton*)_cancelButtons[i]).hidden = NO;
        [_uploadButtons[i] setBackgroundImage:_selectedImages[i].thumbnailImage forState:UIControlStateNormal];
    }
    if (_selectedImages.count<_uploadButtons.count) {
        UIButton *uploadedButton = (UIButton*)_uploadButtons[_selectedImages.count];
        uploadedButton.hidden = NO;
        _scrollViewUploadPhoto.contentSize = CGSizeMake(uploadedButton.frame.origin.x+uploadedButton.frame.size.width*_selectedImages.count, 0);
    }
}
- (IBAction)cancelButtonTapped:(id)sender {
    UIButton* button = (UIButton*)sender;
    [_selectedImages removeObjectAtIndex:button.tag];
    [self setSelectedImages];
}
@end
