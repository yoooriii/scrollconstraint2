//
//  ZoomedPhotoViewController.m
//  ScrollConstraint
//
//  Created by leonid lo on 8/1/16.
//  Copyright © 2016 horns & hoofs. All rights reserved.
//

#import "ZoomedPhotoViewController.h"

@interface ZoomedPhotoViewController () <UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView* scrollView;
@property (nonatomic, weak) IBOutlet UIImageView* imageView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* imageViewBottomConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* imageViewLeadingConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* imageViewTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* imageViewTrailingConstraint;
@end

@implementation ZoomedPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateMinZoomScaleForSize:self.view.bounds.size];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.imageView.image = self.image;
    [self.view setNeedsLayout];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)updateMinZoomScaleForSize:(CGSize)size {
    const CGFloat widthScale = size.width / self.imageView.bounds.size.width;
    const CGFloat heightScale = size.height / self.imageView.bounds.size.height;
    const CGFloat minScale = MIN(widthScale, heightScale);

    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.zoomScale = minScale;
}

- (void)updateConstraintsForSize:(CGSize)size {

    const CGFloat yOffset = MAX(0, (size.height - self.imageView.frame.size.height) / 2.0);
    self.imageViewTopConstraint.constant = yOffset;
    self.imageViewBottomConstraint.constant = yOffset;

    const CGFloat xOffset = MAX(0, (size.width - self.imageView.frame.size.width) / 2.0);
    self.imageViewLeadingConstraint.constant = xOffset;
    self.imageViewTrailingConstraint.constant = xOffset;

    [self.view layoutIfNeeded];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self updateConstraintsForSize:self.view.bounds.size];
}

@end
