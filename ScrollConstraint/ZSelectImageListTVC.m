//
//  ZSelectImageListTVC.m
//  ScrollConstraint
//
//  Created by leonid lo on 7/29/16.
//  Copyright © 2016 horns & hoofs. All rights reserved.
//

#import "ZSelectImageListTVC.h"
#import "PreviewController.h"
#import "COFullScreenPicturePreViewController.h"
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

- (void)previewSelected
{
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
    if (!cell.imageView || cell.imageView.hidden)
    {
        return;
    }

    NSString* vcID = @"previewController";
    PreviewController* ctr = (PreviewController*)[self.storyboard instantiateViewControllerWithIdentifier:vcID];

    ctr.beginRect = [cell.imageView.superview convertRect:cell.imageView.frame toView:nil];
    ctr.backgroundView = [self.view.window snapshotViewAfterScreenUpdates:NO];
    ctr.image = cell.imageView.image;
    [self presentViewController:ctr animated:NO completion:^
    {
        NSLog(@"presented");

        [ctr startAnimatingImage];
    }];



    ctr.dismissBlock = ^
    {
        [self dismissViewControllerAnimated:NO completion:^
        {
            NSLog(@"dismissed");
        }];
    };
}

- (void)testViewOneImage
{
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
    if (!cell.imageView || cell.imageView.hidden)
    {
        return;
    }

    COFullScreenPicturePreViewController * ctr = (COFullScreenPicturePreViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"COFullScreenPicturePreViewController"];
    UIImageView* imageView = cell.imageView;
    ctr.image = imageView.image;
    ctr.backgroundView = [self.view.superview snapshotViewAfterScreenUpdates:NO];
    const CGRect fromRect = (nil == imageView.image) ? CGRectMake(10, 10, 30, 30) : [imageView.superview convertRect:imageView.frame toView:nil];

    const CGRect endRect = fromRect;

    __weak COFullScreenPicturePreViewController* weakCtr = ctr;
    ctr.dismissBlock = ^
    {
        COFullScreenPicturePreViewController* strongCtr = weakCtr;
        [strongCtr runDismissAnimationIntoRect:endRect
                              completion:^
        {
            [self dismissViewControllerAnimated:NO completion:^{
                ;
            }];
        }];
    };

//    [self performSelector:@selector(testViewOneImageStart:) withObject:ctr afterDelay:0.3];

    [self presentViewController:ctr animated:NO completion:^
     {
         NSLog(@"start anim");
         [ctr runPresentAnimationFromRect:fromRect completion:nil];
     }];
}

//- (void)testViewOneImageStart:(COFullScreenPicturePreViewController*)ctr
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
