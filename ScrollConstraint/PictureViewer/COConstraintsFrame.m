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

#import "COConstraintsFrame.h"

@interface COConstraintsFrame ()

// all constraints belong to views that is why they are weak
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* constraintWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* constraintHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* constraintX;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* constraintY;

@end

@implementation COConstraintsFrame

+ (COConstraintsFrame*)constraintsFrameWithView:(UIView*)view containerView:(UIView*)containerView frame:(CGRect)frame
{
    NSParameterAssert(nil != view);
    NSParameterAssert(nil != containerView);

    [view removeConstraints:view.constraints];
    COConstraintsFrame* constraints = [self new];
    constraints.constraintY = [view.topAnchor constraintEqualToAnchor:containerView.topAnchor constant:frame.origin.y];
    constraints.constraintX = [view.leftAnchor constraintEqualToAnchor:containerView.leftAnchor constant:frame.origin.y];
    constraints.constraintWidth = [view.widthAnchor constraintEqualToConstant:frame.size.width];
    constraints.constraintHeight = [view.heightAnchor constraintEqualToConstant:frame.size.height];

    return constraints;
}

- (void)setActive:(BOOL)active
{
    self.constraintWidth.active = active;
    self.constraintHeight.active = active;
    self.constraintX.active = active;
    self.constraintY.active = active;
}

- (void)setOrigin:(CGPoint)origin
{
    self.constraintX.constant = origin.x;
    self.constraintY.constant = origin.y;
}

- (void)setFrame:(CGRect)frame
{
    self.constraintX.constant = frame.origin.x;
    self.constraintY.constant = frame.origin.y;
    self.constraintWidth.constant = frame.size.width;
    self.constraintHeight.constant = frame.size.height;
}

- (NSArray<NSLayoutConstraint*>*)constraints
{
    NSMutableArray* allConstraints = [NSMutableArray arrayWithCapacity:4];

    if (nil != self.constraintX)
    {
        [allConstraints addObject:self.constraintX];
    }

    if (nil != self.constraintY)
    {
        [allConstraints addObject:self.constraintY];
    }

    if (nil != self.constraintWidth)
    {
        [allConstraints addObject:self.constraintWidth];
    }

    if (nil != self.constraintHeight)
    {
        [allConstraints addObject:self.constraintHeight];
    }

    return [allConstraints copy];
}

@end
