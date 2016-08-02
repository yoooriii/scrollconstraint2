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

#import "COIntrinsicBoxView.h"

const CGFloat COImageResizeThreshold = 0.5;

// in certain cases intrinsicContentSize does not work well and I have to use width & height constraints along with it
@interface COIntrinsicBoxView ()

#pragma mark - Outlets

@property (nonatomic, weak) IBOutlet NSLayoutConstraint* constraintWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* constraintHeight;

#pragma mark -

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
