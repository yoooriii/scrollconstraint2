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

#import "COFullScreenPicturePreviewController.h"
#import "COIntrinsicBoxView.h"
#import "COEditorsUtils.h"
#import "COConstraintsFrame.h"

NS_ASSUME_NONNULL_BEGIN

static NSString* const COImageViewerControllerXIB = @"FullScreenPicturePreviewController";
static NSString* const PlaceholderImageName = @"preview_img_placeholder.png";
const static NSTimeInterval CenteringAnimationDuration = 0.2;
const static NSTimeInterval PresentingAnimationDuration = 0.5;
const static CGSize PlaceholderImageSize = {.width = 300.0, .height = 200.0};

@interface COFullScreenPicturePreviewController () <UIScrollViewDelegate>

#pragma mark - Outlets

@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, weak) IBOutlet UIButton* dismissButton;
@property (nonatomic, weak) IBOutlet COIntrinsicBoxView* pictureContainerView;
@property (nonatomic, weak) IBOutlet UIScrollView* scrollView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView* spinner;

#pragma mark -

@property (nonatomic, readonly) BOOL isPresenting;
@property (nonatomic, weak) UIView* viewToZoom;

// swipe to dismiss logic
//TODO: remove comments when done
@property (nonatomic, weak) IBOutlet UIGestureRecognizer* swipeToDismissRecognizer;
@property (nonatomic, weak) IBOutlet UIView* obscureView;   //  black fullscreen
@property (nonatomic, strong) IBOutlet COConstraintsFrame* __nullable imageViewConstraints;
@property (nonatomic, assign) CGPoint swipeDismissStartPoint;
@property (nonatomic, assign) BOOL swipeDismissBegan;

@end

NS_ASSUME_NONNULL_END

@implementation COFullScreenPicturePreviewController

+ (instancetype)previewController
{
    return [[self alloc] initWithNibName:COImageViewerControllerXIB bundle:[COEditorsUtils bundle]];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (nil != self)
    {
        self.animationDuration = PresentingAnimationDuration;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.pictureContainerView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.viewToZoom = self.pictureContainerView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.dismissButton.hidden = YES;
    self.pictureContainerView.alpha = 0;
    const BOOL noImage = (nil == self.image);
    self.imageView.image = noImage ? self.placeholderImage : self.image;
    [self adjustViewerSize];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [self centerImageAnimated:NO];
}

#pragma mark - View controller's

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>context)
     {
         [self adjustViewerSize];
         [self centerImageAnimated:NO];
     }
                                 completion:nil];
}

#pragma mark - UIScrollViewDelegate

- (UIView*)viewForZoomingInScrollView:(UIScrollView*)scrollView
{
    return self.viewToZoom;
}

- (void)scrollViewDidZoom:(UIScrollView*)scrollView
{
    [self centerImageAnimated:NO];
}

- (void)scrollViewDidEndZooming:(UIScrollView*)scrollView withView:(nullable UIView*)view atScale:(CGFloat)scale
{
    [self centerImageAnimated:YES];
}

#pragma mark - Resize & Zoom Logic

- (void)adjustViewerSize
{
    if (nil == self.viewToZoom)
    {
        return;
    }
    const CGSize viewerSize = self.scrollView.frame.size;
    const CGFloat viewerRatio = (COImageResizeThreshold < viewerSize.width) && (COImageResizeThreshold < viewerSize.height) ? viewerSize.width / viewerSize.height : 0;

    if (viewerRatio > 0)
    {
        //TODO: default preview size when no image available (placeholder ?) or hide it
        const CGSize pictureSize = (nil == self.image) ? PlaceholderImageSize : self.image.size;
        const CGFloat pictureRatio = pictureSize.width / pictureSize.height;
        CGSize displaySize = viewerSize;

        if (viewerRatio > pictureRatio)
        {
            if (!self.shouldFitSmallImageIn)
            {
                displaySize.height = MIN(pictureSize.height, viewerSize.height);
            }
            displaySize.width = floor(displaySize.height * pictureRatio);
        }
        else
        {
            if (!self.shouldFitSmallImageIn)
            {
                displaySize.width = MIN(pictureSize.width, viewerSize.width);
            }
            displaySize.height = floor(displaySize.width / pictureRatio);
        }

        self.pictureContainerView.intrinsicContentSize = displaySize;
    }
}

// before centering the image size must be set (with adjustViewerSize or somehow else)
- (void)centerImageAnimated:(BOOL)animated
{
    if (nil == self.viewToZoom)
    {
        return;
    }

    const CGSize imageSize = self.pictureContainerView.frame.size;
    const CGRect viewFrame = self.scrollView.frame;
    UIEdgeInsets insets = {0};

    if ((COImageResizeThreshold < imageSize.width) && (COImageResizeThreshold < imageSize.height))
    {
        insets.left = MAX(0, (0.5 * (viewFrame.size.width - imageSize.width)));
        insets.top  = MAX(0, (0.5 * (viewFrame.size.height - imageSize.height)));
    }

    void (^centerBlock)(void) = ^
    {
        self.scrollView.contentInset = insets;
    };

    if (animated)
    {
        [UIView animateWithDuration:CenteringAnimationDuration animations:centerBlock];
    }
    else
    {
        centerBlock();
    }
}

#pragma mark - Private logic

- (void)setProgressAnimating:(BOOL)animating
{
    if (animating)
    {
        [self.spinner startAnimating];
        self.pictureContainerView.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        [self.spinner stopAnimating];
        self.pictureContainerView.backgroundColor = [UIColor clearColor];
    }
}

- (UIImage*)placeholderImage
{
    return [UIImage imageNamed:PlaceholderImageName];
}

#pragma mark - Public methods

- (BOOL)isPresenting
{
    return (nil != self.viewToZoom);
}

- (void)runPresentAnimationFromRect:(CGRect)fromRect completion:(void (^)())completionBlock
{
    self.viewToZoom = self.pictureContainerView;
    const BOOL noImage = (nil == self.image);
    // update image or set placeholder
    self.imageView.image = noImage ? self.placeholderImage : self.image;
    [self setProgressAnimating:noImage];

    [self adjustViewerSize];
    [self centerImageAnimated:NO];

    self.pictureContainerView.alpha = 1;
    self.dismissButton.hidden = NO;

    void (^onAnimationComplete)(BOOL) = ^(BOOL finished)
    {
        if (nil != completionBlock)
        {
            completionBlock();
        }
    };

    if (0 < self.animationDuration)
    {
        [self.scrollView layoutIfNeeded];

        self.dismissButton.alpha = 0;

        const BOOL isRect = !CGRectIsInfinite(fromRect);
        const CGRect endRect = [self.view convertRect:self.pictureContainerView.frame fromView:self.pictureContainerView.superview];
        const CGRect startRect = isRect ? [self.view convertRect:fromRect fromView:nil] : endRect;

        if (isRect)
        {
            const CGFloat tx = CGRectGetMidX(startRect) - CGRectGetMidX(endRect);
            const CGFloat ty = CGRectGetMidY(startRect) - CGRectGetMidY(endRect);
            const CGFloat sx = startRect.size.width / endRect.size.width;
            const CGFloat sy = startRect.size.height / endRect.size.height;

            self.pictureContainerView.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(tx, ty), sx, sy);
            self.pictureContainerView.alpha = 1;
        }
        else
        {
            self.pictureContainerView.transform = CGAffineTransformMakeScale(2.0, 2.0);
            self.pictureContainerView.alpha = 0;
        }

        [UIView animateWithDuration:self.animationDuration
                         animations:^
         {
             self.pictureContainerView.transform = CGAffineTransformIdentity;
             self.pictureContainerView.alpha = 1;
             self.dismissButton.alpha = 1;
             self.view.backgroundColor = [UIColor blackColor];
         }
                         completion:onAnimationComplete];
    }
    else
    {
        onAnimationComplete(YES);
    }
}

- (void)runDismissAnimationIntoRect:(CGRect)toRect completion:(void (^)())completionBlock
{
    self.viewToZoom = nil;

    @weakify(self)
    void (^dismissCompletionBlock)(BOOL) = ^(BOOL nouse)
    {
        @strongify(self)

        self.dismissButton.hidden = YES;

        if (nil != completionBlock)
        {
            completionBlock();
        }
    };

    if (0 < self.animationDuration)
    {
        const BOOL isRect = !CGRectIsInfinite(toRect);
        const CGRect endRect = isRect ? [self.view convertRect:toRect fromView:nil] : CGRectZero;
        const CGRect currentRect = [self.view convertRect:self.pictureContainerView.frame fromView:self.pictureContainerView.superview];

        COIntrinsicBoxView* pictureContainer = self.pictureContainerView;
        self.pictureContainerView = nil;

        self.scrollView.hidden = YES;
        [pictureContainer removeFromSuperview];
        pictureContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:pictureContainer];

        const CGRect pictureFrame = isRect ? endRect : currentRect;

        [pictureContainer.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:pictureFrame.origin.x].active = YES;
        [pictureContainer.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:pictureFrame.origin.y].active = YES;
        pictureContainer.intrinsicContentSize = pictureFrame.size;
        [self.view layoutIfNeeded];

        if (isRect)
        {
            const CGFloat tx = CGRectGetMidX(currentRect) - CGRectGetMidX(endRect);
            const CGFloat ty = CGRectGetMidY(currentRect) - CGRectGetMidY(endRect);
            const CGFloat sx = currentRect.size.width / endRect.size.width;
            const CGFloat sy = currentRect.size.height / endRect.size.height;
            pictureContainer.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(tx, ty), sx, sy);
        }
        else
        {
            pictureContainer.transform = CGAffineTransformIdentity;
        }

        [UIView animateWithDuration:self.animationDuration
                         animations:^
         {
             @strongify(self)

             if (isRect)
             {
                 pictureContainer.transform = CGAffineTransformIdentity;
             }
             else
             {
                 pictureContainer.transform = CGAffineTransformMakeScale(2.0, 2.0);
                 pictureContainer.alpha = 0;
             }

             self.dismissButton.alpha = 0;
             self.view.backgroundColor = [UIColor clearColor];
         }
                         completion:dismissCompletionBlock];
    }
    else
    {
        // dismiss picture viewer without animation
        dismissCompletionBlock(YES);
    }
}

- (void)setImage:(UIImage*)image
{
    if (_image != image)
    {
        _image = image;

        [self setProgressAnimating:(nil == self.image)];
        self.imageView.image = (nil == self.image) ? self.placeholderImage : self.image;
        [self adjustViewerSize];
        [self centerImageAnimated:NO];
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

- (IBAction)doubleTapAction:(UIGestureRecognizer*)recognizer
{
    if (UIGestureRecognizerStateEnded == recognizer.state)
    {
        const CGFloat zoomScale = self.scrollView.zoomScale;
        const CGFloat zoomMedian = 0.5 * (self.scrollView.maximumZoomScale + self.scrollView.minimumZoomScale);
        const CGFloat newZoom = (zoomScale < zoomMedian) ? self.scrollView.maximumZoomScale : self.scrollView.minimumZoomScale;
        [self.scrollView setZoomScale:newZoom animated:YES];
    }
}

CGFloat DistanceBetweenPoints(CGPoint pointA, CGPoint pointB)
{
    const CGFloat dx = pointA.x - pointB.x;
    const CGFloat dy = pointA.y - pointB.y;
    return sqrt(dx * dx + dy * dy);
}

- (IBAction)swipeToDismissAction:(UIPanGestureRecognizer*)recognizer
{

    const CGFloat SwipeDismissThreshold = 50; //??


    switch (recognizer.state)
    {

        case UIGestureRecognizerStateBegan:
        {
            const CGRect imgFrame = self.imageView.frame;
            const CGRect imgInViewFrame = [self.view convertRect:imgFrame fromView:self.imageView.superview];

//            const CGPoint centerPoint = CGPointMake(CGRectGetMidX(self.imageView.frame), CGRectGetMidY(self.imageView.frame));
//            const CGPoint hotPoint = [self.view convertPoint:centerPoint fromView:self.imageView.superview];
//            [recognizer setTranslation:CGPointMake(-imgInViewFrame.size.width/2.0, -imgInViewFrame.size.height/2.0) inView:self.view];

            self.swipeDismissStartPoint = [recognizer locationInView:self.view];

            NSLog(@"Swipe Began: [%2.1f, %2.1f]", self.swipeDismissStartPoint.x, self.swipeDismissStartPoint.y);

            break;
        }

        case UIGestureRecognizerStateChanged:
        {
            CGPoint location = [recognizer locationInView:self.view];
            const CGFloat distance = DistanceBetweenPoints(self.swipeDismissStartPoint, location);
            NSLog(@"Swipe Changed d(%2.0f), [%2.0f, %2.0f]", distance, location.x, location.y);

            if (self.swipeDismissBegan)
            {
                //move image
                CGPoint location = [recognizer locationInView:self.view];
                self.imageView.transform = CGAffineTransformMakeTranslation(location.x, location.y);
//                [self.imageViewConstraints setOrigin:location];
            }
            else
            {
                if (distance > SwipeDismissThreshold)
                {
                    //start!
                    self.swipeDismissBegan = YES;
                    const CGRect currentRect = [self.view convertRect:self.imageView.frame fromView:self.imageView.superview];
                    NSLog(@"Start: %@", NSStringFromCGRect(CGRectIntegral(currentRect)));

                    self.imageView.transform = CGAffineTransformIdentity;
                    self.imageView.layer.anchorPoint = CGPointMake(0.5, 0.5);

                    [self.view addSubview:self.imageView];
                    self.imageViewConstraints = [COConstraintsFrame constraintsFrameWithView:self.imageView containerView:self.view frame:currentRect];
                    [self.imageViewConstraints setActive:YES];
                }
                else
                {
                    //not yet
                }
            }
            break;
        }

        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
            NSLog(@"Swipe failed/cancelled");
            [self resetSwipeDismiss];
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            NSLog(@"Swipe Ended");
        }
            [self resetSwipeDismiss];
            break;

        case UIGestureRecognizerStatePossible:
            break;

    }
}

- (void)resetSwipeDismiss
{
    // invalid point
    self.swipeDismissStartPoint = CGPointMake(-1000, -1000);
    self.swipeDismissBegan = NO;
    self.imageViewConstraints = nil;

    self.imageView.transform = CGAffineTransformIdentity;
    [self.pictureContainerView addAndHugSubview:self.imageView];
}

//////////////////

- (IBAction)setAnchor0:(id)sender
{
    self.imageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    NSLog(@"0.5,0.5");

}

- (IBAction)setAnchor1:(id)sender
{
    self.imageView.layer.anchorPoint = CGPointMake(0, 0);
    NSLog(@"0,0");

}

@end
