//
//  COFullScreenPicturePreViewController.h
//  ScrollConstraint
//
//  Created by leonid lo on 8/1/16.
//  Copyright © 2016 horns & hoofs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface COFullScreenPicturePreViewController : UIViewController

/// the picture to show
@property (nonatomic, strong) UIImage* image;
@property (nonatomic, strong) UIImage* placeholderImage;
@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, assign) IBInspectable double animationDuration;

@property (nonatomic, copy) void (^dismissBlock)();

/// startRect/endRect image position in the window coordinate space
- (void)runPresentAnimationFromRect:(CGRect)fromRect completion:(void (^)())completionBlock;
- (void)runDismissAnimationIntoRect:(CGRect)endRect completion:(void (^)())completionBlock;

@end
