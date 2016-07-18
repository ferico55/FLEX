//
//  ProductGalleryViewController.m
//  Tokopedia
//
//  Created by Tonito Acen on 3/24/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ProductGalleryViewController.h"

#import "ProductImages.h"

@interface ProductGalleryViewController () {
    ProductImages *_image;
    UIImage *_localImage;
}

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation ProductGalleryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [_scrollView addGestureRecognizer:doubleTap];
    [_scrollView setUserInteractionEnabled:YES];
    

    NSArray *images = [_data objectForKey:@"images"];
    _image = images[[[_data objectForKey:@"image_index"] integerValue]];
    [_descriptionLabel setText:_image.image_description];
    [_scrollView setContentSize:CGSizeMake(self.view.bounds.size.width*images.count, _scrollView.bounds.size.height)];
    _scrollView.pagingEnabled = YES;
    [_scrollView scrollRectToVisible:CGRectMake(self.view.bounds.size.width*[[_data objectForKey:@"image_index"] integerValue], 0, _scrollView.bounds.size.width , _scrollView.bounds.size.height) animated:NO];
    
    
    
    for(int i=0;i<images.count;i++) {
        ProductImages *tempImage = [images objectAtIndex:i];
        NSURLRequest* requestImage = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:tempImage.image_src]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        
        UIImageView  *tempProductGallery = [[UIImageView alloc] init];
        
        if(i == [[_data objectForKey:@"image_index"] integerValue])
            _productGallery = tempProductGallery;
            
        tempProductGallery.tag = i;
        [tempProductGallery setImageWithURLRequest:requestImage placeholderImage:[UIImage imageNamed:@"icon_default_shop.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            tempProductGallery.image = image;
            _localImage = image;
            tempProductGallery.frame = CGRectMake(i*self.view.bounds.size.width, ([[UIScreen mainScreen] bounds].size.height - [self getHeightRatio:[image size].width]*[image size].height) / 2, [[UIScreen mainScreen] bounds].size.width, [self getHeightRatio:[image size].width]*[image size].height);
            
            [_scrollView addSubview:tempProductGallery];
            //        _scrollView.contentSize = image.size;
            _scrollView.delegate = self;
            _scrollView.minimumZoomScale = 1.0;
            _scrollView.maximumZoomScale = 50.0;
#pragma clang diagnostic pop
        } failure:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    
}

- (float)getHeightRatio:(float)width {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float ratio = screenRect.size.width/width;
    
    return ratio;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)view:(UIView*)view setCenter:(CGPoint)centerPoint
{
    CGRect vf = view.frame;
    CGPoint co = self.scrollView.contentOffset;
    
    CGFloat x = centerPoint.x - vf.size.width / 2.0;
    CGFloat y = centerPoint.y - vf.size.height / 2.0;
    
    if(x < 0)
    {
        co.x = -x;
        vf.origin.x = 0.0;
    }
    else
    {
        vf.origin.x = x;
    }
    if(y < 0)
    {
        co.y = -y;
        vf.origin.y = 0.0;
    }
    else
    {
        vf.origin.y = y;
    }
    
    view.frame = vf;
    self.scrollView.contentOffset = co;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CGPoint centerPoint = CGPointMake(CGRectGetMidX(self.scrollView.bounds),
                                      CGRectGetMidY(self.scrollView.bounds));
    [self view:_productGallery setCenter:centerPoint];
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _productGallery;
}

- (void)scrollViewDidZoom:(UIScrollView *)sv
{
    UIView* zoomView = [sv.delegate viewForZoomingInScrollView:sv];
    CGRect zvf = zoomView.frame;
    if(zvf.size.width < sv.bounds.size.width)
    {
        zvf.origin.x = (sv.bounds.size.width - zvf.size.width) / 2.0;
    }
    else
    {
        zvf.origin.x = 0.0;
    }
    if(zvf.size.height < sv.bounds.size.height)
    {
        zvf.origin.y = (sv.bounds.size.height - zvf.size.height) / 2.0;
    }
    else
    {
        zvf.origin.y = 0.0;
    }
    zoomView.frame = zvf;
}

-(IBAction)tap:(id)sender {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}


- (IBAction)tapSaveImage:(id)sender {
    // Save it to the camera roll / saved photo album
    UIImageWriteToSavedPhotosAlbum(_localImage, nil, nil, nil);
    
    StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[@"Berhasil mengunduh gambar ini"] delegate:self];
    
    [alert show];
}

- (void)handleDoubleTap:(UITapGestureRecognizer*)gestureRecognizer {
    if(self.scrollView.zoomScale > self.scrollView.minimumZoomScale)
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    else
        [self.scrollView setZoomScale:5 animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float fractionPage = scrollView.contentOffset.x / scrollView.bounds.size.width;
    NSInteger page = lround(fractionPage);
    NSLog(@"TESTTONGTONGTONG - %d", (int)page);
    
    if(page > ((NSArray *) [_data objectForKey:@"images"]).count-1) {
        return;
    }
    
    _image = [_data objectForKey:@"images"][(int)page];
    [_descriptionLabel setText:_image.image_description];
    if([scrollView viewWithTag:page])
        _productGallery = (UIImageView *)[scrollView viewWithTag:page];
}
@end
