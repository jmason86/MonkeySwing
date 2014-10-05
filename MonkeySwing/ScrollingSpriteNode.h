//
//  ScrollingSpriteNode.h
//  MonkeySwing
//
//  Created by James Paul Mason on 8/24/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ScrollingSpriteNode : SKSpriteNode

typedef enum {
    kPBParallaxBackgroundDirectionUp = 0,
    kPBParallaxBackgroundDirectionDown,
    kPBParallaxBackgroundDirectionRight,
    kPBParallaxBackgroundDirectionLeft
} ParallaxBackgroundDirection;

- (id)initWithBackgrounds:(NSArray *)backgrounds size:(CGSize)size direction:(ParallaxBackgroundDirection)direction fastestSpeed:(CGFloat)speed andSpeedDecrease:(CGFloat)differential;
- (void)update:(NSTimeInterval)currentTime;

@end