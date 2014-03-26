//
//  LevelEndView.h
//  MonkeySwing
//
//  Created by James Paul Mason on 2/18/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerLevelRunData.h"

@interface LevelEndView : UIView

@property (nonatomic, strong) PlayerLevelRunData *playerLevelRunData;

- (id)initWithFrame:(CGRect)frame forOutcome:(NSString *)outcome withRunData:(PlayerLevelRunData *)playerLevelRunData;

@end