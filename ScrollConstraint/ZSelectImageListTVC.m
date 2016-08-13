//
//  ZSelectImageListTVC.m
//  ScrollConstraint
//
//  Created by leonid lo on 7/29/16.
//  Copyright © 2016 horns & hoofs. All rights reserved.
//

#import "ZSelectImageListTVC.h"
#import "PreviewController.h"
#import "COFullScreenPicturePreviewController.h"
#import "ZoomedPhotoViewController.h"

@interface ZMySegue : UIStoryboardSegue

@property (nonatomic, copy) void(^ performSegue)();

@end

@implementation ZMySegue


- (void)perform
{
    if (self.performSegue)
    {
        self.performSegue();
    }
}

@end

@interface ZSelectImageListTVC ()
@property (nonatomic) NSArray * allImageNames;
@property (nonatomic) UIViewController * previewController;
@end

@implementation ZSelectImageListTVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.allImageNames = @[@"01.jpg", @"02.jpg", @"03.jpg", @"04.jpg", @"05.jpg", @"06.jpg", @"01.jpg", @"02.jpg", @"03.jpg", @"04.jpg", @"05.jpg", @"06.jpg", @"01.jpg", @"02.jpg", @"03.jpg", @"04.jpg", @"05.jpg", @"05.jpg", @"07.jpg"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allImageNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basicCellID" forIndexPath:indexPath];
    NSString* imgName = self.allImageNames[indexPath.row];
    cell.textLabel.text = imgName;
    cell.imageView.image = [UIImage imageNamed:imgName];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

//    [self showPhotoView];

            [self testViewOneImage];
    //        [self previewSelected];


    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

///////////////////////////


- (void)testViewOneImage
{
    NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (!cell.imageView || cell.imageView.hidden)
    {
        return;
    }


    UIImageView* imageView = cell.imageView;
    UIImage* theImage = imageView.image;

    COFullScreenPicturePreviewController* ctr = [COFullScreenPicturePreviewController previewController];
    ctr.modalPresentationStyle = UIModalPresentationOverFullScreen;
    ctr.animationDuration = 2;

    if (1)
    {
        [ctr performSelector:@selector(setImage:) withObject:theImage afterDelay:1];
    }
    else
    {
        ctr.image = theImage;
    }

    const CGRect fromRect = (nil == theImage) ? CGRectInfinite : [imageView.superview convertRect:imageView.frame toView:nil];


    __weak COFullScreenPicturePreviewController* weakCtr = ctr;
    UITableView* tableView = self.tableView;
    ctr.dismissBlock = ^
    {
        // may change or disappear when rotating, update the document (table) image frame
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        CGRect endRect = CGRectZero;
        if (cell)
        {
            UIImageView* imageView = cell.imageView;
            endRect = [imageView.superview convertRect:imageView.frame toView:nil];
        }
        COFullScreenPicturePreviewController* strongCtr = weakCtr;
        [strongCtr runDismissAnimationIntoRect:endRect
                              completion:^
        {
            [self dismissViewControllerAnimated:NO completion:^{
                ;
            }];
        }];
    };

//    [self performSelector:@selector(testViewOneImageStart:) withObject:ctr afterDelay:0.3];

    [self presentViewController:ctr animated:YES completion:^
     {
         NSLog(@"start anim");
         [ctr runPresentAnimationFromRect:fromRect completion:nil];
     }];
}

//- (void)testViewOneImageStart:(COFullScreenPicturePreviewController*)ctr
//{
//    [self presentViewController:ctr animated:NO completion:^
//     {
//         NSLog(@"start anim");
//         [ctr startAnimating];
//     }];
//}

- (void)showPhotoView
{
    ZoomedPhotoViewController* ctr = (ZoomedPhotoViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"ZoomedPhotoViewController"];
    NSIndexPath * indexPath = self.tableView.indexPathForSelectedRow;
    NSString* imgName = self.allImageNames[indexPath.row];
    ctr.image = [UIImage imageNamed:imgName];
    [self.navigationController pushViewController:ctr animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"show.scroll"])
    {
        NSIndexPath * indexPath = self.tableView.indexPathForSelectedRow;
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        NSString* imgName = self.allImageNames[indexPath.row];
        NSLog(@"%@", imgName);

        PreviewController* ctr = (PreviewController*)segue.destinationViewController;
        ctr.imageName = imgName;

//        ctr.backgroundView = [self.view.superview snapshotViewAfterScreenUpdates:NO];

        ZMySegue* mySegue = (ZMySegue*)segue;
        UIViewController* containerController = self.navigationController;
        self.previewController = ctr;

        ctr.dismissBlock = ^
        {
            [self.previewController.view removeFromSuperview];
            self.previewController = nil;
        };

        mySegue.performSegue = ^
        {
            UIView* containerView = containerController.view;
            [containerController addChildViewController:ctr];
            
            [containerView addSubview:ctr.view];
            [containerView.topAnchor constraintEqualToAnchor:ctr.view.topAnchor].active = YES;
            [containerView.bottomAnchor constraintEqualToAnchor:ctr.view.bottomAnchor].active = YES;
            [containerView.leadingAnchor constraintEqualToAnchor:ctr.view.leadingAnchor].active = YES;
            [containerView.trailingAnchor constraintEqualToAnchor:ctr.view.trailingAnchor].active = YES;

            [ctr didMoveToParentViewController:self];
            [ctr viewWillAppear:NO];
            [ctr viewDidAppear:NO];
        };
    }
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}


@end
