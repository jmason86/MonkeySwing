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
        
        // Create and configure the scene
        sceneToPresent = [MyScene sceneWithSize:skView.bounds.size]; // Change this to MainMenuScene when ready
        sceneToPresent.scaleMode = SKSceneScaleModeAspectFill;
        sceneToPresent.anchorPoint = CGPointMake(0.5, 0.5);
        
        // Game Center authentication
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAuthenticationViewController) name:PresentAuthenticationViewController object:nil];
        [[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
        
        // Present scene
        [skView presentScene:sceneToPresent];
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

#pragma mark - Game Center

- (void)showAuthenticationViewController
{
    [sceneToPresent.scene.view setPaused:YES];
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    [self presentViewController:gameKitHelper.authenticationViewController animated:YES completion:nil];
}

// TODO: Method to unpause after authenticationViewController dismissed

@end