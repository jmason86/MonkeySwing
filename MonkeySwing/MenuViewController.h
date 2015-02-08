//
//  ViewController.h
//  MonkeySwing
//

//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

@interface MenuViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageImages;

@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

@end