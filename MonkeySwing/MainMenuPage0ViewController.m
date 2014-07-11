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

@synthesize continueButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self->_index = 0;
        
        // TODO: Don't show continue button if player hasn't beaten any levels
        if (1 > 2) {
            continueButton.hidden = YES;
        }
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

- (IBAction)levelsButtonTapped:(UIButton *)sender
{
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:@"levelsButtonTapped" object:self userInfo:nil];
}

- (IBAction)continueButtonTapped:(UIButton *)sender
{
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
        [notificationCenter postNotificationName:@"continueButtonTapped" object:self userInfo:nil];
        
        
        // TODO: Move game center stuff to main ViewController.m instead of only after tapping this button. 
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
