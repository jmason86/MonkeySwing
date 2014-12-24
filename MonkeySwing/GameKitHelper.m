//
//  GameKitHelper.m
//  MonkeySwing
//
//  Created by James Paul Mason on 4/26/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import "GameKitHelper.h"

NSString *const PresentAuthenticationViewController = @"present_authentication_view_controller";
NSString *const GameCenterViewControllerDismissed = @"game_center_view_controller_dismissed";
NSString *const CompetitorScoreReceived = @"competitor_score_received";
NSString *const CompetitorDisplayNameSaved = @"competitor_display_name_saved";
NSString *const CompetitorPhotoReceived = @"competitor_photo_received";


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
        _gameCenterFriendData = [[GameCenterFriendData alloc] init];
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

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    if (gameCenterViewController != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GameCenterViewControllerDismissed object:self];
    }
}

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

- (void)getFriendsNextHigherScore:(NSInteger)score forLeaderboardIdentifier:(NSString *)identifier
{
    GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
    
    if (leaderboardRequest != nil) {
        leaderboardRequest.playerScope = GKLeaderboardPlayerScopeFriendsOnly;
        leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
        leaderboardRequest.identifier = identifier;
        leaderboardRequest.range = NSMakeRange(1, 25); // TODO: This is the highest score, want next best score
        
        // Get player score
        [leaderboardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
            if (error != nil) {
                // Handle error
            }
            if (scores != nil) {
                [self setFriendGKScore:[scores objectAtIndex:0]];
            }
        }];
        
        // Pass to another method for adding photo once the player score (including playerID) is obtained
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerScoreReceived) name:CompetitorScoreReceived object:nil];
    }
}

- (void)setFriendGKScore:(GKScore *)scoreData
{
    _gameCenterFriendData.score = scoreData;
    [[NSNotificationCenter defaultCenter] postNotificationName:CompetitorScoreReceived object:self];
}

- (void)playerScoreReceived
{
    // Get player name
    if (_gameCenterFriendData.score.playerID != nil) {
        [GKPlayer loadPlayersForIdentifiers:@[_gameCenterFriendData.score.playerID] withCompletionHandler: ^(NSArray *players, NSError *error) {
            if (error != nil) {
                // Handle error
            }
            if (players != nil) {
                [self setFriendDisplayName:[players objectAtIndex:0]];
            }
        }];
    }
}

- (void)setFriendDisplayName:(GKPlayer *)player
{
    _gameCenterFriendData.playerName = player.displayName;
    [[NSNotificationCenter defaultCenter] postNotificationName:CompetitorDisplayNameSaved object:self];
    
    if (player != nil) {
        [player loadPhotoForSize:GKPhotoSizeSmall withCompletionHandler:^(UIImage *photo, NSError *error) {
            if (error != nil) {
                // Handle error
            }
            if (photo != nil) {
                CGImageRef photoRef = photo.CGImage;
                CGRect photoRect = CGRectMake(0, 0, 50, 50);
                CGContextRef bitmap = CGBitmapContextCreate(NULL, photoRect.size.width, photoRect.size.height, CGImageGetBitsPerComponent(photoRef), 0, CGImageGetColorSpace(photoRef),CGImageGetBitmapInfo(photoRef));
                CGContextDrawImage(bitmap, photoRect, photoRef);
                CGImageRef resizedPhotoRef = CGBitmapContextCreateImage(bitmap);
                UIImage *resizedPhoto = [UIImage imageWithCGImage:resizedPhotoRef];
                
                // Clean up
                CGContextRelease(bitmap);
                CGImageRelease(resizedPhotoRef);
                
                
                [self setFriendPhoto:(UIImage *)resizedPhoto];
            }
        }];
    }
}

- (void)setFriendPhoto:(UIImage *)photo
{
    _gameCenterFriendData.playerPhoto = photo;
    [[NSNotificationCenter defaultCenter] postNotificationName:CompetitorPhotoReceived object:self];
}

@end
