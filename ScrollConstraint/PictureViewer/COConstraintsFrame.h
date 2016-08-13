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

@interface COConstraintsFrame : NSObject

+ (COConstraintsFrame*)constraintsFrameWithView:(UIView*)view containerView:(UIView*)containerView frame:(CGRect)frame;

- (void)setFrame:(CGRect)frame;

- (void)setOrigin:(CGPoint)origin;

- (NSArray<NSLayoutConstraint*>*)constraints;

- (void)setActive:(BOOL)active;

@end
