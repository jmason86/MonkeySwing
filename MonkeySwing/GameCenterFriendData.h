//
//  GameCenterFriendData.h
//  MonkeySwing
//
//  Created by James Paul Mason on 5/1/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import <GameKit/GameKit.h>

@interface GameCenterFriendData : GKScore

@property (nonatomic, strong) UIImage *playerPhoto;
@property (nonatomic, strong) NSString *playerName;
@property (nonatomic, strong) GKScore *score;

@end
