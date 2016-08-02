//
//  CODisplayView.m
//  ScrollConstraint
//
//  Created by leonid lo on 8/1/16.
//  Copyright © 2016 horns & hoofs. All rights reserved.
//

#import "CODisplayView.h"

const CGFloat COImageResizeThreshold = 0.5;

// in certain cases intrinsicContentSize does not work well and I had to use width & height constraints along with it
@interface CODisplayView ()

#pragma mark - Outlets

@property (nonatomic, weak) IBOutlet NSLayoutConstraint* constraintWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* constraintHeight;

@end

@implementation CODisplayView

- (void)setIntrinsicContentSize:(CGSize)size
{
    const BOOL sizeDidChange = (COImageResizeThreshold < fabs(size.width - self.intrinsicContentSize.width) ||
                                COImageResizeThreshold < fabs(size.height - self.intrinsicContentSize.height));

    if (sizeDidChange)
    {
        _intrinsicContentSize = size;
        self.constraintWidth.constant = size.width;
        self.constraintHeight.constant = size.height;

        [self.superview setNeedsUpdateConstraints];
        [self.superview layoutSubviews];
    }
}

@end


@interface COIntrinsicBoxView ()

#pragma mark - Outlets

@property (nonatomic, weak) IBOutlet NSLayoutConstraint* constraintWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* constraintHeight;

@end

@implementation COIntrinsicBoxView

- (void)setIntrinsicContentSize:(CGSize)size
{
    const BOOL sizeDidChange = (COImageResizeThreshold < fabs(size.width - self.intrinsicContentSize.width) ||
                                COImageResizeThreshold < fabs(size.height - self.intrinsicContentSize.height));

    if (sizeDidChange)
    {
        _intrinsicContentSize = size;
        self.constraintWidth.constant = size.width;
        self.constraintHeight.constant = size.height;

        [self.superview setNeedsUpdateConstraints];
        [self.superview layoutSubviews];
    }
}

@end
