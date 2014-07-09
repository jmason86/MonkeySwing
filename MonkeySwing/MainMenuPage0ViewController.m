//
//  MainMenuPage0ViewController.m
//  MonkeySwing
//
//  Created by James Paul Mason on 7/2/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import "MainMenuPage0ViewController.h"
#import "MyScene.h"
#import "GameKitHelper.h"

@interface MainMenuPage0ViewController ()

@end

@implementation MainMenuPage0ViewController
{
    SKScene *sceneToPresent;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self->_index = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startGameTapped:(UIButton *)sender {
    SKView *skView = (SKView *)self.view;
    
    if (!skView.scene)
    {
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
        
        // Create and configure the scene
        sceneToPresent = [MyScene sceneWithSize:skView.bounds.size]; // TOOD: Change this to MainMenuScene when ready
        sceneToPresent.scaleMode = SKSceneScaleModeAspectFill;
        sceneToPresent.anchorPoint = CGPointMake(0.5, 0.5);
        
        NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter postNotificationName:@"startGameTapped" object:self userInfo:nil];
    
        // Game Center authentication
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAuthenticationViewController) name:PresentAuthenticationViewController object:nil];
        [[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
        
    }
}

#pragma mark - Game center

- (void)showAuthenticationViewController
{
    [sceneToPresent.scene.view setPaused:YES];
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    [self presentViewController:gameKitHelper.authenticationViewController animated:YES completion:nil];
}
@end
