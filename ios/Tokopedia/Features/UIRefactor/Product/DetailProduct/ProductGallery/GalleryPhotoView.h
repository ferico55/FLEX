//
//  GalleryPhotoView.h
//  FGallery
//
//  Created by Grant Davis on 5/19/10.
//  Copyright 2011 Grant Davis Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface GalleryPhotoView : UIScrollView <UIScrollViewDelegate> {
	
	UIImageView *imageView;
	BOOL _isZoomed;
}

- (id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action;
- (void)resetZoom;

@property (nonatomic,readonly) UIImageView *imageView;
@property (nonatomic,readonly) UIButton *button;

@end
