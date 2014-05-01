//
//  GameKitHelper.m
//  MonkeySwing
//
//  Created by James Paul Mason on 4/26/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import "GameKitHelper.h"

NSString *const PresentAuthenticationViewController = @"present_authentication_view_controller";

@implementation GameKitHelper
{
    BOOL enableGameCenter;
    NSString *leaderboardIdentifier;
}

+ (instancetype)sharedGameKitHelper
{
    static GameKitHelper *sharedGameKitHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGameKitHelper = [[GameKitHelper alloc] init];
    });
    return sharedGameKitHelper;
}

- (id)init
{
    self = [super init];
    if (self) {
        enableGameCenter = YES;
    }
    return self;
}

#pragma mark - Player authentication

- (void)authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
        // Store errors
        [self setLastError:error];
        
        if (viewController != nil) {
            // User not logged in so get view controller for login
            [self setAuthenticationViewController:viewController];
        } else if ([GKLocalPlayer localPlayer].isAuthenticated) {
            // User is already logged in
            enableGameCenter = YES;
            
            // Get default leaderboard identifier
            [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifierInput, NSError *error) {
                
                if (error != nil) {
                    NSLog(@"%@", [error localizedDescription]);
                }
                else{
                    leaderboardIdentifier = leaderboardIdentifierInput;
                }
            }];
        } else {
            // Not logged in for whatever reason
            enableGameCenter = NO;
        }
    };
}

- (void)setAuthenticationViewController:(UIViewController *)authenticationViewController
{
    if (authenticationViewController != nil) {
        _authenticationViewController = authenticationViewController;
        [[NSNotificationCenter defaultCenter] postNotificationName:PresentAuthenticationViewController object:self];
    }
}

// TODO: Add method NSNotification for authenticationViewController being dismissed

- (void)setLastError:(NSError *)lastError
{
    _lastError = [lastError copy];
    if (_lastError) {
        NSLog(@"GameKitHelper ERROR: %@", [[_lastError userInfo] description]);
    }
}

#pragma mark - Leaderboard and achievements

+ (void)reportAchievementIdentifier:(NSString *)identifier percentComplete:(float)percent
{
    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
    if (achievement)
    {
        achievement.percentComplete = percent;
        achievement.showsCompletionBanner = YES;
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:identifier]) {
            // Tell analytics if you want to
        }
        
        NSArray *achievements = @[achievement];
        [GKAchievement reportAchievements:achievements withCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"Error in reporting achievements: %@", error);
            } else {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:identifier];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }];
    }
}

+ (void)reportScore:(Float64)score forIdentifier:(NSString *)identifier
{
    GKScore *highScore = [[GKScore alloc] initWithLeaderboardIdentifier:identifier];
    highScore.value = score;
    [GKScore reportScores:@[highScore] withCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Error in reporting scores: %@", error);
        }
    }];
}

@end
