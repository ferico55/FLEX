//
//  HotlistCollectionCell.m
//  Tokopedia
//
//  Created by Renny Runiawati on 6/18/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "HotlistCollectionCell.h"

@interface HotlistCollectionCell ()

@property (weak, nonatomic) IBOutlet UILabel *pricelabel;
@property (weak, nonatomic) IBOutlet UILabel *namelabel;

@end

@implementation HotlistCollectionCell

-(void)setViewModel:(HotlistViewModel *)viewModel
{
    _pricelabel.text = viewModel.price_start;
    _namelabel.text = viewModel.title;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:viewModel.image_url_600] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    UIImageView *thumb = self.productimageview;
    thumb.image = nil;
    [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [thumb setImage:image];
        [thumb setContentMode:UIViewContentModeScaleAspectFill];
#pragma clang diagnosti c pop
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];
}

@end
