//
//  GeneralList1GestureCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/4/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "generalcell.h"
#import "GeneralList1GestureCell.h"

@implementation GeneralList1GestureCell

#pragma mark - Factory methods
+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"GeneralList1GestureCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    float desiredWidth = 20;
    float w=self.imageView.frame.size.width;
    if (w>desiredWidth) {
        float widthSub = w - desiredWidth;
        self.imageView.frame = CGRectMake(self.imageView.frame.origin.x,self.imageView.frame.origin.y,desiredWidth,self.imageView.frame.size.height);
        self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x-widthSub,self.textLabel.frame.origin.y,self.textLabel.frame.size.width+widthSub,self.textLabel.frame.size.height);
        self.detailTextLabel.frame = CGRectMake(self.detailTextLabel.frame.origin.x-widthSub,self.detailTextLabel.frame.origin.y,self.detailTextLabel.frame.size.width+widthSub,self.detailTextLabel.frame.size.height);
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
}

@end
