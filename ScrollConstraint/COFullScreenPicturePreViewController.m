//
//  COFullScreenPicturePreViewController.m
//  ScrollConstraint
//
//  Created by leonid lo on 8/1/16.
//  Copyright © 2016 horns & hoofs. All rights reserved.
//


//TODO: update copyright & BOM

#import "COFullScreenPicturePreViewController.h"
#import "CODisplayView.h"

static const NSTimeInterval AnimationDuration = 0.25;
static const CGFloat ValueHalfOne = 0.5;

@interface COFullScreenPicturePreViewController () <UIScrollViewDelegate>
@property (nonatomic, weak) IBOutlet CODisplayView* imageView;
@property (nonatomic, weak) IBOutlet UIScrollView* scrollView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView* spinner;
@property (nonatomic, assign) IBInspectable CGSize placeholderImageSize;
@property (nonatomic, assign) BOOL isPresenting;
@property (nonatomic, assign) BOOL isPresentingOn;
@property (nonatomic, assign) BOOL imageDidUpdate;
@end

@implementation COFullScreenPicturePreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // debug stuff
    if (1)
    {
        self.imageView.layer.cornerRadius = 20;
        self.imageView.layer.borderColor = [UIColor yellowColor].CGColor;
        self.imageView.layer.borderWidth = 1;
    }

    if (1)
    {
        self.scrollView.layer.cornerRadius = 30;
        self.scrollView.layer.borderColor = [UIColor greenColor].CGColor;
        self.scrollView.layer.borderWidth = 1;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self installBackgroundViewIfAny];
    

    const BOOL noImage = (nil == self.image);
    self.imageView.image = noImage ? self.placeholderImage : self.image;
    [self setProgressAnimating:noImage];
    [self adjustViewerSize];
    self.imageView.alpha = 0;
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self centerImageAnimated:NO];
}

#pragma mark - View controller's

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>context)
     {
         NSLog(@"rotation");
         [self adjustViewerSize];
         [self centerImageAnimated:NO];
     }
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext>context)
     {
         NSLog(@"did rotate");
         NSLog(@"%@-->%@-->%@",
               NSStringFromCGRect(self.view.bounds),
               NSStringFromCGRect(self.scrollView.frame),
               NSStringFromCGSize(self.imageView.frame.size));
     }];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerImageAnimated:NO];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale {
    [self centerImageAnimated:YES];
}

#pragma mark - Resize & Zoom Logic

- (void)adjustViewerSize
{
    const CGSize viewerSize = self.scrollView.frame.size;
    const CGFloat viewerRatio = (COImageResizeThreshold < viewerSize.width) && (COImageResizeThreshold < viewerSize.height) ? viewerSize.width / viewerSize.height : 0;

    if (viewerRatio > 0)
    {
        //TODO: default preview size when no image available (placeholder ?) or hide it
        const CGSize pictureSize = (nil == self.imageView.image) ? self.placeholderImageSize : self.imageView.image.size;
        const CGFloat pictureRatio = pictureSize.width / pictureSize.height;
        CGSize displaySize = viewerSize;

        if (viewerRatio > pictureRatio)
        {
            displaySize.width = floor(displaySize.height * pictureRatio);
        }
        else
        {
            displaySize.height = floor(displaySize.width / pictureRatio);
        }

        self.imageView.intrinsicContentSize = displaySize;
    }
    else
    {
        NSLog(@"wrong viewer size %@", NSStringFromCGSize(viewerSize));
    }
}

- (void)centerImageAnimated:(BOOL)animated
{
    const CGSize imageSize = self.imageView.frame.size;
    const CGRect viewFrame = self.scrollView.frame;
    UIEdgeInsets insets = {0};

    if ((COImageResizeThreshold < imageSize.width) && (COImageResizeThreshold < imageSize.height))
    {
        insets.left = MAX(0, (ValueHalfOne * (viewFrame.size.width  - imageSize.width)));
        insets.top  = MAX(0, (ValueHalfOne * (viewFrame.size.height - imageSize.height)));
    }

    void (^centerBlock)(void) = ^
    {
        self.scrollView.contentInset = insets;
    };

    animated ? [UIView animateWithDuration:AnimationDuration animations:centerBlock] : centerBlock();
}

#pragma mark - Private logic

- (void)installBackgroundViewIfAny
{
    if (nil != self.backgroundView)
    {
        self.backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view insertSubview:self.backgroundView belowSubview:self.scrollView];

        [self.view.topAnchor constraintEqualToAnchor:self.backgroundView.topAnchor].active = YES;
        [self.view.bottomAnchor constraintEqualToAnchor:self.backgroundView.bottomAnchor].active = YES;
        [self.view.leadingAnchor constraintEqualToAnchor:self.backgroundView.leadingAnchor].active = YES;
        [self.view.trailingAnchor constraintEqualToAnchor:self.backgroundView.trailingAnchor].active = YES;
    }
}

- (void)setProgressAnimating:(BOOL)animating
{
    animating ? [self.spinner startAnimating] : [self.spinner stopAnimating];
}

#pragma mark - Public methods

//- (void)showPicture:(UIImage*)picture animated:(BOOL)animated ///?????
//{
//    self.imageView.hidden = YES;
//    self.imageView.image = picture;
//    [self adjustViewerSize];
//    [self centerImageAnimated:NO];
//    [self.scrollView layoutIfNeeded];
//}

- (CGAffineTransform)makeTransformFromRect:(CGRect)fromRect toRect:(CGRect)endRect
{
    const BOOL isRect = !CGRectIsNull(fromRect);
    const CGRect startRect = isRect ? [self.view convertRect:fromRect fromView:nil] : endRect;

    const CGFloat tx = CGRectGetMidX(startRect) - CGRectGetMidX(endRect);
    const CGFloat ty = CGRectGetMidY(startRect) - CGRectGetMidY(endRect);
    const CGFloat sx = startRect.size.width / endRect.size.width;
    const CGFloat sy = startRect.size.height / endRect.size.height;

    return isRect ? CGAffineTransformScale(CGAffineTransformMakeTranslation(tx, ty), sx, sy) : CGAffineTransformMakeScale(0, 0);
}

- (void)runPresentAnimationFromRect:(CGRect)fromRect completion:(void (^)())completionBlock
{
    [self adjustViewerSize];
    [self centerImageAnimated:NO];


    NSLog(@"%@-->%@-->%@",
          NSStringFromCGRect(self.view.bounds),
          NSStringFromCGRect(self.scrollView.frame),
          NSStringFromCGSize(self.imageView.frame.size));


    self.imageView.alpha = 1;

    self.isPresenting = YES;

    if (0 < self.animationDuration)
    {
        [self.scrollView layoutIfNeeded];

        self.imageView.transform = [self makeTransformFromRect:fromRect toRect:[self.view convertRect:self.imageView.frame fromView:self.imageView.superview]];

        [UIView animateWithDuration:self.animationDuration
                         animations:^
         {
             self.imageView.transform = CGAffineTransformIdentity;
             self.backgroundView.alpha = 0;
         }
                         completion:^(BOOL finished)
         {
             self.isPresentingOn = YES;
             [self.backgroundView removeFromSuperview];

             if (nil != completionBlock)
             {
                 completionBlock();
             }
         }];
    }
    else
    {
        self.isPresentingOn = YES;
        [self.backgroundView removeFromSuperview];
    }
}

- (void)runDismissAnimationIntoRect:(CGRect)endRect completion:(void (^)())completionBlock
{
    self.isPresenting = NO;

    if (0 < self.animationDuration)
    {
        const CGRect currentRect = [self.imageView.superview convertRect:self.imageView.frame toView:nil];
        //TODO: check transform logic
        const CGAffineTransform transform = CGAffineTransformInvert([self makeTransformFromRect:currentRect toRect:endRect]);

        self.backgroundView.alpha = 0;
        [self installBackgroundViewIfAny];

        [UIView animateWithDuration:self.animationDuration
                         animations:^
         {
             self.imageView.transform = transform;
             self.backgroundView.alpha = 1;
         }
                         completion:^(BOOL finished)
         {
             self.isPresentingOn = NO;

             if (nil != completionBlock)
             {
                 completionBlock();
             }
         }];
    }
    else
    {
        self.isPresentingOn = NO;

        if (nil != completionBlock)
        {
            completionBlock();
        }
    }
}

- (void)setImage:(UIImage *)image
{
    if (_image != image)
    {
        _image = image;

        self.imageDidUpdate = YES;
    }
}

#pragma mark - Actions

- (IBAction)dismissAction:(id)sender
{
    if (nil != self.dismissBlock)
    {
        self.dismissBlock();
    }
}

- (IBAction)doubleTapAction:(UIGestureRecognizer*)sender
{
    if (UIGestureRecognizerStateEnded == sender.state)
    {
        const CGFloat zoomScale = self.scrollView.zoomScale;
        const CGFloat zoomMedian = ValueHalfOne * (self.scrollView.maximumZoomScale + self.scrollView.minimumZoomScale);
        const CGFloat newZoom = (zoomScale < zoomMedian) ? self.scrollView.maximumZoomScale : self.scrollView.minimumZoomScale;
        [self.scrollView setZoomScale:newZoom animated:YES];
    }
}

#pragma mark - Debug

//- (void)printScrollInfo {
//    const UIEdgeInsets insets = self.scrollView.contentInset;
//    const CGSize imageSize = self.imageView.frame.size;
//    const CGRect viewFrame = self.scrollView.frame;
//
//    printf("W: %2.1f + %2.1f + () --> %2.1f; [%2.1f]\n", insets.left, imageSize.width, viewFrame.size.width, (insets.left * 2.0 + imageSize.width));
//    printf("H: %2.1f + %2.1f + () --> %2.1f; [%2.1f]\n", insets.top, imageSize.height, viewFrame.size.height, (insets.top * 2.0 + imageSize.height));
//}

@end
