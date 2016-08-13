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

NS_ASSUME_NONNULL_BEGIN

@interface COFullScreenPicturePreviewController : UIViewController

+ (instancetype)previewController;

/// the picture to show
@property (nonatomic, strong) UIImage* __nullable image;
@property (nonatomic, assign) BOOL shouldFitSmallImageIn;

@property (nonatomic, assign) NSTimeInterval animationDuration;

@property (nonatomic, copy) void (^dismissBlock)();

/// startRect/endRect image position in the window coordinate space; pass CGRectInfinite if rect is invalid;
- (void)runPresentAnimationFromRect:(CGRect)fromRect completion:(void (^__nullable)())completionBlock;
- (void)runDismissAnimationIntoRect:(CGRect)endRect completion:(void (^__nullable)())completionBlock;

@end

NS_ASSUME_NONNULL_END
