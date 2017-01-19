//
//  MenuViewController
//  MonkeySwing
//
//  Created by James Paul Mason on 1/1/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import "MenuViewController.h"
#import "GamePlayScene.h"
#import "GameKitHelper.h"
#import "LevelSelectionContentViewController.h"
#import "MainMenuContentViewController.h"

@implementation MenuViewController
{
    SKView *skViewToPresent;
    SKScene *sceneToPresent;
    BOOL isLevelScreen;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupMenuViews:@"mainMenu"];
    
    // Subscribe to notifations
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(levelsButtonTappedNotification) name:@"levelsButtonTapped" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(continueButtonTappedNotification) name:@"continueButtonTapped" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuButtonTappedNotification:) name:@"levelEndedUserSelection" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAuthenticationViewController) name:PresentAuthenticationViewController object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissAuthenticationViewController) name:GameCenterViewControllerDismissed object:nil];
    
    // Game center
    [[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
}

- (void)setupMenuViews:(NSString *)mainMenuOrLevelSelection
{
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    // Prepare content views for the page view controller
    NSArray *viewControllers;
    if ([mainMenuOrLevelSelection isEqualToString:@"mainMenu"]) {
        isLevelScreen = NO;
        _pageImages = @[@"MainMenuBackground.png", @"MainMenuSettingsBackground.png"];
        MainMenuContentViewController *startingViewController = (MainMenuContentViewController *)[self viewControllerAtIndex:0];
        viewControllers = @[startingViewController];
        
        // Extend the view controller to the bottom of the screen
        self.pageViewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height + 40);
    } else if ([mainMenuOrLevelSelection isEqualToString:@"levelSelection"]) {
        // Clear away all the stuff from the main menu view
        self.pageViewController = nil;
        self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
        self.pageViewController.dataSource = self;
        self.pageViewController.delegate = self;
        
        // Make the stuff for the level selection view
        isLevelScreen = YES;
        _pageImages = @[@"Level1SelectionScreen.png", @"Level2SelectionScreen.png", @"Level3SelectionScreen.png"];
        LevelSelectionContentViewController *startingViewController = (LevelSelectionContentViewController *)[self viewControllerAtIndex:0];
        viewControllers = nil;
        viewControllers = @[startingViewController];
        
        // Extend the view controller to the bottom of the screen
        self.pageViewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height + 40);
    }
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    // Add view controller and views
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    // Add an additional page control indicator
    for (UIView *view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIPageControl class]]) {
            UIPageControl *pageControl = (UIPageControl *)view;
            pageControl.pageIndicatorTintColor = [UIColor redColor];
            pageControl.backgroundColor = [UIColor clearColor];
            
            // Autolayout for page control
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:pageControl attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0 constant:-16]];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:pageControl attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1.0 constant:16]];
        }
    }
    
    // Tell page indicator how many pages there are
    self.pageControl.numberOfPages = self.pageImages.count;
    self.pageControl.tag = 1;
    
    // Add the page indicator
    [self.view addSubview:_pageControl.viewForBaselineLayout];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations
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
    [self.pageViewController.view removeFromSuperview];
    
    [self setupMenuViews:@"levelSelection"];
}

- (void)continueButtonTappedNotification
{
    [self.pageViewController.view removeFromSuperview];
    [self.pageControl removeFromSuperview];
    skViewToPresent = (SKView *)self.view;
    skViewToPresent.showsPhysics = YES; // DEBUG
    skViewToPresent.showsFPS = YES; // DEBUG
    
    // Create and configure the scene
    sceneToPresent = [GamePlayScene sceneWithSize:skViewToPresent.bounds.size];
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
        [self setupMenuViews:@"mainMenu"];
    }
}

#pragma mark - Game Center

- (void)showAuthenticationViewController
{
    [sceneToPresent.scene.view setPaused:YES];
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    [self presentViewController:gameKitHelper.authenticationViewController animated:YES completion:nil];
}

- (void)dismissAuthenticationViewController
{
    
    [sceneToPresent.scene.view setPaused:NO];
    
}

#pragma mark - Scroll View

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = 0;
    if ([viewController isKindOfClass:[MainMenuContentViewController class]]) {
        index = ((MainMenuContentViewController *) viewController).pageIndex;
    } else if ([viewController isKindOfClass:[LevelSelectionContentViewController class]]) {
        index = ((LevelSelectionContentViewController *) viewController).pageIndex;
    }
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = 0;
    if ([viewController isKindOfClass:[MainMenuContentViewController class]]) {
        index = ((MainMenuContentViewController *) viewController).pageIndex;
    } else if ([viewController isKindOfClass:[LevelSelectionContentViewController class]]) {
        index = ((LevelSelectionContentViewController *) viewController).pageIndex;
    }
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageImages count]) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageImages count] == 0) || (index >= [self.pageImages count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    if (!isLevelScreen) {
        MainMenuContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
        pageContentViewController.backgroundImage = self.pageImages[index];
        pageContentViewController.pageIndex = index;
        return pageContentViewController;
    } else {
        LevelSelectionContentViewController *levelSelectionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LevelSelectionViewController"];
        levelSelectionViewController.backgroundImage = self.pageImages[index];
        levelSelectionViewController.pageIndex = index;
        return levelSelectionViewController;
    }
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return 2;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        if ([[self.pageViewController.viewControllers firstObject] isKindOfClass:[MainMenuContentViewController class]]) {
            MainMenuContentViewController *currentContentViewController = [self.pageViewController.viewControllers firstObject];
            self.pageControl.currentPage = currentContentViewController.pageIndex;
            
        }
        if ([[self.pageViewController.viewControllers firstObject] isKindOfClass:[LevelSelectionContentViewController class]]) {
            LevelSelectionContentViewController *currentContentViewController = [self.pageViewController.viewControllers firstObject];
            self.pageControl.currentPage = currentContentViewController.pageIndex;
        }
    }
}

@end
