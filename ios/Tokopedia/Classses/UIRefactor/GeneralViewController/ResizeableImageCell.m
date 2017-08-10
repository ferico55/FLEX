//
//  ResizeableImageCell.m
//  Tokopedia
//
//  Created by Renny Runiawati on 10/2/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "ResizeableImageCell.h"

@implementation ResizeableImageCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
//    float desiredWidth = 80;
//    float w=self.imageView.frame.size.width;
//    if (w>desiredWidth) {
//        float widthSub = w - desiredWidth;
//        self.imageView.frame = CGRectMake(self.imageView.frame.origin.x,self.imageView.frame.origin.y,desiredWidth,self.imageView.frame.size.height);
//        self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x-widthSub,self.textLabel.frame.origin.y,self.textLabel.frame.size.width+widthSub,self.textLabel.frame.size.height);
//        self.detailTextLabel.frame = CGRectMake(self.detailTextLabel.frame.origin.x-widthSub,self.detailTextLabel.frame.origin.y,self.detailTextLabel.frame.size.width+widthSub,self.detailTextLabel.frame.size.height);
//        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    }
}

+ (id)newCell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"ResizeableImageCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
