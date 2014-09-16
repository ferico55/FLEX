//
//  HotListCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "home.h"
#import "HotlistCell.h"

@implementation HotlistCell

//@synthesize delegate = _delegate;

#pragma mark - Factory methods

+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"HotlistCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

#pragma mark - Initialization

- (void)awakeFromNib
{
    _productimageview.multipleTouchEnabled = NO;
    _productimageview.exclusiveTouch = YES;
    
    
//    _viewcontainer.layer.borderColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:0.5f].CGColor;
//    _viewcontainer.layer.borderWidth = 1.0f;
}

#pragma mark - setdata
-(void)setImageUrl:(NSURL *)url
{
    [_act startAnimating];
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:0.3];
    //request.URL = url;
    
    UIImageView *thumb = _productimageview;
    thumb.image = nil;
    //thumb.hidden = YES;	//@prepareforreuse then @reset

    [_act startAnimating];
    
    [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        //NSLOG(@"thumb: %@", thumb);
        [thumb setImage:image];
        
        [_act stopAnimating];
#pragma clang diagnostic pop

    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [_act stopAnimating];
    }];
}

#pragma mark - Methods

-(void)reset
{
    
}

#pragma mark - View Gesture
- (IBAction)gesture:(id)sender {
    
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *gesture = (UITapGestureRecognizer*)sender;
        
        NSIndexPath *indexpath = [_data objectForKey:kTKPDHOME_DATAINDEXPATHKEY];
        [_delegate HotlistCell:self withindexpath:indexpath];
    
    }
    
}

@end
