//
//  GalleryPhotoView.m
//  FGallery
//
//  Created by Grant Davis on 5/19/10.
//  Copyright 2011 Grant Davis Interactive, LLC. All rights reserved.
//

#import "GalleryPhotoView.h"

@interface GalleryPhotoView (Private)
- (UIImage*)createHighlightImageWithFrame:(CGRect)rect;
@end



@implementation GalleryPhotoView
@synthesize imageView;


- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	self.userInteractionEnabled = YES;
	self.clipsToBounds = YES;
	self.delegate = self;
	self.contentMode = UIViewContentModeCenter;
	self.maximumZoomScale = 3.0;
	self.minimumZoomScale = 1.0;
	self.decelerationRate = .85;
	self.contentSize = CGSizeMake(frame.size.width, frame.size.height);
	
	// create the image view
	imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	[self addSubview:imageView];
	
	return self;
}


- (id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action
{
	self = [self initWithFrame:frame];
	
	// fit them images!
	imageView.contentMode = UIViewContentModeScaleAspectFill;
	
	// disable zooming
	self.minimumZoomScale = 1.0;
	self.maximumZoomScale = 1.0;
	
	// allow buttons to be clicked
	[self setUserInteractionEnabled:YES];
	
	// but don't allow zooming/panning
	self.scrollEnabled = NO;
	
	// create outline
	[self.layer setBorderWidth:1.0];
	[self.layer setBorderColor:[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:.25] CGColor]];
	
	return self;
}

- (void)resetZoom
{
	_isZoomed = NO;
	[self setZoomScale:self.minimumZoomScale animated:NO];
	[self zoomToRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height ) animated:NO];
	self.contentSize = CGSizeMake(self.frame.size.width * self.zoomScale, self.frame.size.height * self.zoomScale );
}

- (void)setFrame:(CGRect)theFrame
{
	// store position of the image view if we're scaled or panned so we can stay at that point
	CGPoint imagePoint = imageView.frame.origin;
	
	[super setFrame:theFrame];
	
	// update content size
	self.contentSize = CGSizeMake(theFrame.size.width * self.zoomScale, theFrame.size.height * self.zoomScale );
	
	// resize image view and keep it proportional to the current zoom scale
	imageView.frame = CGRectMake( imagePoint.x, imagePoint.y, theFrame.size.width * self.zoomScale, theFrame.size.height * self.zoomScale);
}


- (UIImage*)createHighlightImageWithFrame:(CGRect)rect
{
	if( rect.size.width == 0 || rect.size.height == 0 ) return nil;
	
	// create a tint layer for the selected state of the button
	UIGraphicsBeginImageContext(CGSizeMake(rect.size.width, rect.size.height));
	CALayer *blankLayer = [CALayer layer];
	[blankLayer setFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
	[blankLayer setBackgroundColor:[[UIColor colorWithRed:0 green:0 blue:0 alpha:.4] CGColor]];
	[blankLayer renderInContext: UIGraphicsGetCurrentContext()];
	UIImage *clearImg = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return clearImg;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	
	if (touch.tapCount == 2) {
		if( _isZoomed )
		{
			_isZoomed = NO;
			[self setZoomScale:self.minimumZoomScale animated:YES];
		}
		else {
			
			_isZoomed = YES;
			
			// define a rect to zoom to. 
			CGPoint touchCenter = [touch locationInView:self];
			CGSize zoomRectSize = CGSizeMake(self.frame.size.width / self.maximumZoomScale, self.frame.size.height / self.maximumZoomScale );
			CGRect zoomRect = CGRectMake( touchCenter.x - zoomRectSize.width * .5, touchCenter.y - zoomRectSize.height * .5, zoomRectSize.width, zoomRectSize.height );
			
			// correct too far left
			if( zoomRect.origin.x < 0 )
				zoomRect = CGRectMake(0, zoomRect.origin.y, zoomRect.size.width, zoomRect.size.height );
			
			// correct too far up
			if( zoomRect.origin.y < 0 )
				zoomRect = CGRectMake(zoomRect.origin.x, 0, zoomRect.size.width, zoomRect.size.height );
			
			// correct too far right
			if( zoomRect.origin.x + zoomRect.size.width > self.frame.size.width )
				zoomRect = CGRectMake(self.frame.size.width - zoomRect.size.width, zoomRect.origin.y, zoomRect.size.width, zoomRect.size.height );
			
			// correct too far down
			if( zoomRect.origin.y + zoomRect.size.height > self.frame.size.height )
				zoomRect = CGRectMake( zoomRect.origin.x, self.frame.size.height - zoomRect.size.height, zoomRect.size.width, zoomRect.size.height );
			
			// zoom to it.
			[self zoomToRect:zoomRect animated:YES];
		}
	}
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)handleTap
{
	// tell the controller
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
	if( self.zoomScale == self.minimumZoomScale ) _isZoomed = NO;
	else _isZoomed = YES;
}


- (void)dealloc {
	imageView = nil;
	
}


@end
