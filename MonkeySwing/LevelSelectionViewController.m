//
//  LevelSelectionViewController.m
//  MonkeySwing
//
//  Created by James Paul Mason on 7/13/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import "LevelSelectionViewController.h"

@interface LevelSelectionViewController ()

@end

@implementation LevelSelectionViewController

@synthesize numberOfLevels;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Setup page view controller
        self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        self.pageController.dataSource = self;
        [[self.pageController view] setFrame:CGRectMake(0, 0, [[self view] bounds].size.width, [[self view] bounds].size.height + 37)];
        NSArray *viewControllers = [NSArray arrayWithObject:self];
        [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        [self addChildViewController:self.pageController];
        //[self.view addSubview:self.pageController.view];
        [self.pageController didMoveToParentViewController:self];
        
        if (numberOfLevels == 0) {
            numberOfLevels = 3;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%li%@", @"Level", (long)self.index, @"SelectionScreen"]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)menuButtonTapped:(UIButton *)sender {
}

#pragma mark - Scroll View

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger pageIndex = self.index;
    pageIndex--;
    if (pageIndex < 0) {
        return nil;
    }
    return [self viewControllerAtIndex:pageIndex];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger pageIndex = self.index;
    pageIndex++;
    if (pageIndex > numberOfLevels) {
        return nil;
    }
    return [self viewControllerAtIndex:pageIndex];
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    _index = index;
    _pageControl.currentPage = index;
    return self;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return 2;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

@end
