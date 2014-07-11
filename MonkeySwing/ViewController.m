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

@implementation ViewController
{
    SKScene *sceneToPresent;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    SKView *skView = (SKView *)self.view;
    
    if (!skView.scene) {
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(levelsButtonTappedNotification) name:@"levelsButtonTapped" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(continueButtonTappedNotification) name:@"continueButtonTapped" object:nil];
        
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
    // TODO: New view controller with xib for level selection
}

- (void)continueButtonTappedNotification
{
    [self.pageController.view removeFromSuperview];
    SKView *skView = (SKView *)self.view;
    // Create and configure the scene
    sceneToPresent = [MyScene sceneWithSize:skView.bounds.size]; // TODO: Change this to a Level Selection screen and button tap + a "continue" button and loading of MyScene
    sceneToPresent.scaleMode = SKSceneScaleModeAspectFill;
    sceneToPresent.anchorPoint = CGPointMake(0.5, 0.5);
    
    // Game Center authentication
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAuthenticationViewController) name:PresentAuthenticationViewController object:nil];
    [[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
    
    // Present scene
    [skView presentScene:sceneToPresent];
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
    NSInteger pageIndex = 0;
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
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger pageIndex = 0;
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
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    
    switch (index) {
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