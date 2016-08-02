//
//  PreviewController
//
//  Created by leonid lo on 7/29/16.
//  Copyright © 2016 horns & hoofs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreviewController : UIViewController

@property (nonatomic) NSString * imageName;
@property (strong, nonatomic) UIView *backgroundView;
@property (nonatomic, copy) void (^dismissBlock)();

@property (nonatomic, assign) CGRect beginRect;
@property (nonatomic, assign) CGRect endRect;

@property (nonatomic) UIImage * image;

- (void)startAnimatingImage;

@end

