//
//  PlayerLevelRunData.h
//  MonkeySwing
//
//  Created by James Paul Mason on 3/19/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlayerLevelRunData : NSObject

@property (nonatomic) NSInteger totalPoints;
@property (nonatomic) NSInteger numberOfApples;
@property (nonatomic) NSInteger totalNumberOfApplesInLevel;
@property (nonatomic) NSInteger numberOfTimesDied;
@property (nonatomic) NSInteger numberOfRapidRopes;
@property (nonatomic) NSInteger levelNumber;

@end
