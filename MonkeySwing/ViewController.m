//
//  ViewController.m
//  MonkeySwing
//
//  Created by James Paul Mason on 1/1/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"
#import "MainMenuScene.h"
#import "GameKitHelper.h"
#import "MainMenuPage0ViewController.h"
#import "MainMenuPage1ViewController.h"
#import "LevelSelectionViewController.h"
#import "PageContentViewController.h"

@implementation ViewController
{
    SKView *skViewToPresent;
    SKScene *sceneToPresent;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    /*
    SKView *skView = (SKView *)self.view;
    
    if (!skView.scene) {
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(levelsButtonTappedNotification) name:@"levelsButtonTapped" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(continueButtonTappedNotification) name:@"continueButtonTapped" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuButtonTappedNotification:) name:@"levelEndedUserSelection" object:nil];
        
        // Setup page view controller
        self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        self.pageController.dataSource = self;
        [[self.pageController view] setFrame:CGRectMake(0, 0, [[self view] bounds].size.width, [[self view] bounds].size.height + 37)];
        MainMenuPage0ViewController *mainMenuPage0ViewController = (MainMenuPage0ViewController *)[self viewControllerAtIndex:0];
        NSArray *viewControllers = [NSArray arrayWithObject:mainMenuPage0ViewController];
        [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        [self addChildViewController:self.pageController];
        [[self view] addSubview:[self.pageController view]];
        [self.pageController didMoveToParentViewController:self];
    }
     */
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _pageTitles = @[@"Over 200 Tips and Tricks", @"Discover Hidden Features"];
    _pageImages = @[@"MainMenuBackground.png", @"MainMenuSettingsBackground.png"];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    PageContentViewController *startingViewController = (PageContentViewController *)[self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    for (UIView *view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIPageControl class]]) {
            UIPageControl *pageControl = (UIPageControl *)view;
            pageControl.pageIndicatorTintColor = [UIColor redColor];
            pageControl.backgroundColor = [UIColor clearColor];
        }
    }
    
    // Extend the view controller to the bottom of the screen
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+40);
    
    self.pageControl.numberOfPages = self.pageTitles.count;
    [self.view addSubview:_pageControl.viewForBaselineLayout];
    //_pageControl = [UIPageControl appearance];
    //_pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    //_pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    //_pageControl.backgroundColor = [UIColor clearColor];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)levelsButtonTappedNotification
{
    [self.pageController.view removeFromSuperview];
    
    // Create and display LevelSelectionViewController
    LevelSelectionViewController *levelSelectionViewController = [[LevelSelectionViewController alloc] initWithNibName:@"LevelSelectionViewController" bundle:nil];
    [self presentViewController:levelSelectionViewController animated:NO completion:nil];
    
}

- (void)continueButtonTappedNotification
{
    [self.pageController.view removeFromSuperview];
    skViewToPresent = (SKView *)self.view;
    
    // Create and configure the scene
    sceneToPresent = [MyScene sceneWithSize:skViewToPresent.bounds.size];
    sceneToPresent.scaleMode = SKSceneScaleModeAspectFill;
    sceneToPresent.anchorPoint = CGPointMake(0.5, 0.5);
    
    // Game Center authentication
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAuthenticationViewController) name:PresentAuthenticationViewController object:nil];
    [[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
    
    // Present scene
    [skViewToPresent presentScene:sceneToPresent];
}

- (void)menuButtonTappedNotification:(NSNotification *)notification
{
    NSString *userSelection = [notification.userInfo objectForKey:@"userSelection"];
    if ([userSelection isEqualToString:@"goToMainMenu"]) {
        for (UIView *view in self.view.subviews) {
            [view removeFromSuperview];
        }
        [skViewToPresent presentScene:nil];
    }
}

#pragma mark - Game Center

- (void)showAuthenticationViewController
{
    [sceneToPresent.scene.view setPaused:YES];
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    [self presentViewController:gameKitHelper.authenticationViewController animated:YES completion:nil];
}

// TODO: Method to unpause after authenticationViewController dismissed

#pragma mark - Scroll View

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    /*NSInteger pageIndex = 0;
    if ([viewController isKindOfClass:[MainMenuPage0ViewController class]]) {
        MainMenuPage0ViewController *mainMenuPage0ViewController = (MainMenuPage0ViewController *)viewController;
        pageIndex = mainMenuPage0ViewController.index;
        pageIndex--;
    } else if ([viewController isKindOfClass:[MainMenuPage1ViewController class]]) {
        MainMenuPage1ViewController *mainMenuPage1ViewController = (MainMenuPage1ViewController *)viewController;
        pageIndex = mainMenuPage1ViewController.index;
        pageIndex--;
    }
    
    if (pageIndex < 0) {
        return nil;
    }
    
    return [self viewControllerAtIndex:pageIndex];
     */
    
    NSUInteger index = ((PageContentViewController *) viewController).pageIndex;
    
    if (self.pageControl.currentPage != 0) {
        self.pageControl.currentPage = 0;
    }
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    
    self.pageControl.currentPage = index;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    /*NSInteger pageIndex = 0;
    if ([viewController isKindOfClass:[MainMenuPage0ViewController class]]) {
        MainMenuPage0ViewController *mainMenuPage0ViewController = (MainMenuPage0ViewController *)viewController;
        pageIndex = mainMenuPage0ViewController.index;
        pageIndex++;
    } else if ([viewController isKindOfClass:[MainMenuPage1ViewController class]]) {
        MainMenuPage1ViewController *mainMenuPage1ViewController = (MainMenuPage1ViewController *)viewController;
        pageIndex = mainMenuPage1ViewController.index;
        pageIndex++;
    }
    
    if (pageIndex == 3) {
        return nil;
    }
    
    return [self viewControllerAtIndex:pageIndex];
     */
    
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if (self.pageControl.currentPage != 1) {
        self.pageControl.currentPage = 1;
    }
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    
    /*switch (index) {
        case 0:
        {
            MainMenuPage0ViewController *mainMenuPage0ViewController = [[MainMenuPage0ViewController alloc] initWithNibName:@"MainMenuPage0ViewController" bundle:nil];
            return mainMenuPage0ViewController;
            break;
        }
        case 1:
        {
            MainMenuPage1ViewController *mainMenuPage1ViewController = [[MainMenuPage1ViewController alloc] initWithNibName:@"MainMenuPage1ViewController" bundle:nil];
            return mainMenuPage1ViewController;
            break;
        }
        default:
        {
            break;
        }
    }
    return nil;
     */
    
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return 2;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (IBAction)startTutorial:(UIButton *)sender {
}
@end