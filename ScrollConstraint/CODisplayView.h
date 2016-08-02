//
//  CODisplayView.h
//  ScrollConstraint
//
//  Created by leonid lo on 8/1/16.
//  Copyright © 2016 horns & hoofs. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat COImageResizeThreshold;

@interface CODisplayView : UIImageView

@property (nonatomic, assign) CGSize intrinsicContentSize;

@end

@interface COIntrinsicBoxView : UIView

@property (nonatomic, assign) CGSize intrinsicContentSize;

@end
