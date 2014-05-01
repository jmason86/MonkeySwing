//
//  GameKitHelper.h
//  MonkeySwing
//
//  Created by James Paul Mason on 4/26/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

@import GameKit;

extern NSString *const PresentAuthenticationViewController;

@interface GameKitHelper : NSObject

@property (nonatomic, readonly) UIViewController *authenticationViewController;
@property (nonatomic, readonly) NSError *lastError;

+ (instancetype)sharedGameKitHelper;
- (void)authenticateLocalPlayer;
+ (void)reportAchievementIdentifier:(NSString *)identifier percentComplete:(float)percent;
+ (void)reportScore:(Float64)score forIdentifier:(NSString *)identifier;

@end