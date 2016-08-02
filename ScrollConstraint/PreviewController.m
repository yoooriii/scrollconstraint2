//
//  PreviewController
//
//  Created by leonid lo on 7/29/16.
//  Copyright © 2016 horns & hoofs. All rights reserved.
//

#import "PreviewController.h"

@interface FrameConstraints : NSObject
@property (nonatomic) NSLayoutConstraint* constraintOriginX;
@property (nonatomic) NSLayoutConstraint* constraintOriginY;
@property (nonatomic) NSLayoutConstraint* constraintWidth;
@property (nonatomic) NSLayoutConstraint* constraintHeight;
@property (nonatomic, assign) CGRect targetRect;
@property (nonatomic, assign) BOOL readyToAnimate;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, weak) UIView* view;
@property (nonatomic, copy) void (^animationBlock)(void);
- (void)setActive:(BOOL)flag;
- (void)updateConstraintsToTargetRect;
- (void)animateIfReady;
@end

@implementation FrameConstraints

- (void)setActive:(BOOL)flag
{
    self.constraintOriginX.active = flag;
    self.constraintOriginY.active = flag;
    self.constraintWidth.active = flag;
    self.constraintHeight.active = flag;
}

- (void)updateConstraintsToTargetRect
{
    self.constraintOriginX.constant = self.targetRect.origin.x;
    self.constraintOriginY.constant = self.targetRect.origin.y;
    self.constraintWidth.constant = self.targetRect.size.width;
    self.constraintHeight.constant = self.targetRect.size.height;
}

- (void)animateIfReady
{
    if (self.readyToAnimate)
    {
        self.readyToAnimate = NO;

        [self performAnimation];
    }
}

- (void)performAnimation
{
    if (self.animationBlock)
    {
        [UIView animateWithDuration:self.duration animations:self.animationBlock];
    }
    else
    {
        [self updateConstraintsToTargetRect];
        [self.view.superview setNeedsUpdateConstraints];

        [UIView animateWithDuration:self.duration animations:^
        {
            [self.view.superview layoutSubviews];
        }];
    }
}

@end


@interface PreviewController () <UIScrollViewDelegate>
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
//@property (nonatomic, weak) UIButton * dismissButton;

@property (strong, nonatomic) FrameConstraints* frameConstraints;
@end

@implementation PreviewController

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSDictionary *viewsDictionary;

    // Create the scroll view and the image view.
    _scrollView  = [UIScrollView new];
    _imageView = [UIImageView new];

    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 0.2;
    self.scrollView.maximumZoomScale = 2;


    // Add an image to the image view.
//    [self.imageView setImage:[UIImage imageNamed:self.imageName]];//"MyReallyBigImage"]];

    // Add the scroll view to our view.
    [self.view addSubview:self.scrollView];
    [self.view sendSubviewToBack:self.scrollView];

    // Add the image view to the scroll view.
    [self.scrollView addSubview:self.imageView];

    // Set the translatesAutoresizingMaskIntoConstraints to NO so that the views autoresizing mask is not translated into auto layout constraints.
    self.scrollView.translatesAutoresizingMaskIntoConstraints  = NO;
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;

    // Set the constraints for the scroll view and the image view.
    viewsDictionary = NSDictionaryOfVariableBindings(_scrollView, _imageView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_imageView]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_imageView]|" options:0 metrics: 0 views:viewsDictionary]];

    self.view.backgroundColor = [UIColor clearColor];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.imageView.backgroundColor = [UIColor clearColor];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    NSLog(@"%s", __PRETTY_FUNCTION__);

    self.imageView.image = [UIImage imageNamed:self.imageName];
    self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
//    [self centerImageAnimated:NO];


//    if (!self.backgroundView)
//    {
//        self.backgroundView = [UIView new];
//        self.backgroundView.backgroundColor = [UIColor blackColor];
//
//        self.backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
//        [self.view addSubview:self.backgroundView];
//        [self.view sendSubviewToBack:self.backgroundView];
//
//        [self.view.topAnchor constraintEqualToAnchor:self.backgroundView.topAnchor].active = YES;
//        [self.view.bottomAnchor constraintEqualToAnchor:self.backgroundView.bottomAnchor].active = YES;
//        [self.view.leadingAnchor constraintEqualToAnchor:self.backgroundView.leadingAnchor].active = YES;
//        [self.view.trailingAnchor constraintEqualToAnchor:self.backgroundView.trailingAnchor].active = YES;
//    }


//    CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    anim.fromValue = @(0);
//    anim.toValue = @(1);
//    anim.duration = 0.2;
//    [self.backgroundView.layer addAnimation:anim forKey:@"qqq"];


    [self performSelector:@selector(center) withObject:nil afterDelay:0];

//    [UIView animateWithDuration:0.5 animations:^{
//        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
//    }];
}

- (void)setBackgroundView:(UIView *)backgroundView
{
    if (_backgroundView != backgroundView)
    {
        _backgroundView = backgroundView;
    }

    if (self.backgroundView)
    {
        self.backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:self.backgroundView];
        [self.view sendSubviewToBack:self.backgroundView];

        [self.view.topAnchor constraintEqualToAnchor:self.backgroundView.topAnchor].active = YES;
        [self.view.bottomAnchor constraintEqualToAnchor:self.backgroundView.bottomAnchor].active = YES;
        [self.view.leadingAnchor constraintEqualToAnchor:self.backgroundView.leadingAnchor].active = YES;
        [self.view.trailingAnchor constraintEqualToAnchor:self.backgroundView.trailingAnchor].active = YES;
    }
}

- (void)center
{
    [self centerImageAnimated:NO];
}

- (void)bgColor
{
//    self.backgroundView.alpha = 0;
    [UIView animateWithDuration:1 animations:^{
//        self.backgroundView.alpha = 0.5;
        self.view.backgroundColor = [UIColor blackColor];
    }];
}

- (void)viewDidLayoutSubviews
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLayoutSubviews];
//    [self centerImageAnimated:NO];

    [self.frameConstraints animateIfReady];
}

- (void)setImageName:(NSString *)imageName
{
    if (_imageName != imageName)
    {
        _imageName = imageName;

        [self imageDidUpdate];
    }
}

- (void)imageDidUpdate
{
    if (!self.isViewLoaded)
    {
        (void)self.view;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    NSLog(@"zoom:%2.2f", scrollView.zoomScale);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    [self printScrollInfo];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSLog(@"%s : %@", __PRETTY_FUNCTION__, NSStringFromCGPoint(scrollView.contentOffset));
}

//- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView;   // called on finger up as we are moving

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"%s : %@", __PRETTY_FUNCTION__, NSStringFromCGPoint(scrollView.contentOffset));
}

 // scale between minimum and maximum. called after any 'bounce' animations
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale {
    [self centerImageAnimated:YES];
}

- (void)centerImageAnimated:(BOOL)animated
{
    const CGSize imageSize = self.imageView.frame.size;
    const CGRect viewFrame = self.scrollView.frame;

    UIEdgeInsets insets = {0};

    if (imageSize.width > 1 && imageSize.height > 1)
    {
        insets.left = MAX(0, ((viewFrame.size.width  - imageSize.width) / 2.0));
        insets.top  = MAX(0, ((viewFrame.size.height - imageSize.height) / 2.0));
    }

    if (animated)
    {
        [UIView animateWithDuration:0.25 animations:^
         {
             self.scrollView.contentInset = insets;
         }];
    }
    else
    {
        self.scrollView.contentInset = insets;
    }
}

- (void)adjustViewerSizeAndZoomAnimated:(BOOL)animated
{
    const CGRect viewerFrame = self.view.bounds;
    const CGFloat viewerRatio = (viewerFrame.size.width > 1 && viewerFrame.size.height > 1) ? viewerFrame.size.width/viewerFrame.size.height : 0;
    
    if (viewerRatio > 0)
    {
        const CGSize pictureSize = nil == self.imageView.image ? CGSizeMake(300, 200) : self.imageView.image.size;
        const CGFloat pictureRatio = pictureSize.width / pictureSize.height;

        CGSize displaySize = {0};
        if (viewerRatio > pictureRatio)
        {
            // use preview height
            displaySize.height = viewerFrame.size.height;
            displaySize.width = displaySize.height * pictureRatio;
        }
        else
        {
            // use preview width
            displaySize.width = viewerFrame.size.width;
            displaySize.height = displaySize.width / pictureRatio;
        }
    }
    else
    {
        NSLog(@"wrong viewer frame %@", NSStringFromCGRect(viewerFrame));
    }
}

- (void)printScrollInfo {
    const UIEdgeInsets insets = self.scrollView.contentInset;
    const CGSize imageSize = self.imageView.frame.size;
    const CGRect viewFrame = self.scrollView.frame;

    printf("W: %2.1f + %2.1f + () --> %2.1f; [%2.1f]\n", insets.left, imageSize.width, viewFrame.size.width, (insets.left * 2.0 + imageSize.width));
    printf("H: %2.1f + %2.1f + () --> %2.1f; [%2.1f]\n", insets.top, imageSize.height, viewFrame.size.height, (insets.top * 2.0 + imageSize.height));
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>context)
     {
         [self centerImageAnimated:NO];
     }
                                 completion:nil];
}


//////////////

- (IBAction)dismissAction:(id)sender {
//    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.dismissBlock)
    {
        self.dismissBlock();
    }
}

- (IBAction)top100 {
    [UIView animateWithDuration:0.5 animations:^
     {
         self.view.backgroundColor = [UIColor redColor];
     }];
}

- (IBAction)left100 {
    [UIView animateWithDuration:0.5 animations:^
     {
         self.view.backgroundColor = [UIColor greenColor];
     }];
}

//////////////////

- (void)startAnimatingImage
{
    if (self.image && !CGRectIsNull(self.beginRect))
    {
        UIImageView* startView = [[UIImageView alloc] initWithImage:self.image];
        startView.frame = [self.view convertRect:self.beginRect fromView:nil];
        startView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view insertSubview:startView aboveSubview:self.scrollView];

        self.scrollView.hidden = YES;

        FrameConstraints* frameConstraints = nil;
        if (1)
        {
            frameConstraints = [FrameConstraints new];
            frameConstraints.view = startView;
            frameConstraints.constraintOriginY = [startView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:self.beginRect.origin.y];
            frameConstraints.constraintOriginX = [startView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:self.beginRect.origin.x];
            frameConstraints.constraintWidth = [startView.widthAnchor constraintEqualToConstant:self.beginRect.size.width];
            frameConstraints.constraintHeight = [startView.heightAnchor constraintEqualToConstant:self.beginRect.size.height];
            [frameConstraints setActive:YES];
            frameConstraints.readyToAnimate = YES;
            frameConstraints.targetRect = CGRectInset(self.view.bounds, 50, 100);
            frameConstraints.duration = 1;

            self.frameConstraints = frameConstraints;
            // this triggers animation in -viewDidLayoutSubviews
            [self.view setNeedsUpdateConstraints];
        }


        if (1)
        {
            startView.layer.cornerRadius = 10;
            startView.layer.borderColor = [UIColor redColor].CGColor;
            startView.layer.borderWidth = 1;
        }
    }
}

- (void)updateViewConstraints
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [super updateViewConstraints];

}

//////////////////
@end
