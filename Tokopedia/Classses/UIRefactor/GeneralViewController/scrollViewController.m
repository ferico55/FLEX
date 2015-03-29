//
//  scrollViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 3/17/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "scrollViewController.h"

@interface scrollViewController ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation scrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_imageURLString?:@""]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    UIImageView *thumb = _imageView;
    thumb.image = [UIImage imageNamed:@"icon_toped_loading_grey-02.png"];
    [thumb setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [thumb setImage:image];
#pragma clang diagnosti c pop
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
    [_scrollView addSubview:_imageView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setImageURLString:(NSString *)imageURLString
{
    _imageURLString = imageURLString;

}

-(void)viewDidLayoutSubviews
{
    _scrollView.contentSize = self.view.frame.size;
}

- (IBAction)tap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (scrollView.zoomBouncing) {
        if (scrollView.zoomScale == scrollView.maximumZoomScale) {
            NSLog(@"Bouncing back from maximum zoom");
        }
        else
            if (scrollView.zoomScale == scrollView.minimumZoomScale) {
                NSLog(@"Bouncing back from minimum zoom");
            }
    }
}
@end
