/*
 * Copyright (c) XCDS International Ltd., 2013-2016
 *
 * You can not use the contents of the file in any way without
 * XCDS International Ltd. written permission.
 *
 * To obtain such a permit, you should contact XCDS International Ltd.
 * at http://xcds.com/contact.html
 *
 */

#import <UIKit/UIKit.h>

@interface COFullScreenPicturePreViewController : UIViewController

/// the picture to show
@property (nonatomic, strong) UIImage* image;
@property (nonatomic, strong) UIImage* placeholderImage;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, assign) BOOL shouldFitSmallImageIn;

@property (nonatomic, assign) IBInspectable double animationDuration;

@property (nonatomic, copy) void (^dismissBlock)();

/// startRect/endRect image position in the window coordinate space
- (void)runPresentAnimationFromRect:(CGRect)fromRect completion:(void (^)())completionBlock;
- (void)runDismissAnimationIntoRect:(CGRect)endRect completion:(void (^)())completionBlock;

@end
