//
//  ScrollingSpriteNode.m
//  MonkeySwing
//
//  Created by James Paul Mason on 8/24/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import "ScrollingSpriteNode.h"

@interface ScrollingSpriteNode ()

@property (nonatomic, strong) NSArray *backgrounds;
@property (nonatomic, strong) NSMutableArray *scrollingSpeeds;
@property (nonatomic) float currentSpeed;
@property (nonatomic) NSUInteger numberOfBackgrounds;
@property (nonatomic) ParallaxBackgroundDirection direction;
@property (nonatomic) CGSize sizeOfBackgroundSet;

@end

@implementation ScrollingSpriteNode

- (id)initWithBackgrounds:(NSArray *)backgrounds size:(CGSize)size direction:(ParallaxBackgroundDirection)direction fastestSpeed:(CGFloat)speed andSpeedDecrease:(CGFloat)differential
{
    for (id backgroundObject in backgrounds) {
        
        // determine the type of background
        SKSpriteNode * node = [SKSpriteNode alloc];
    
        if ([backgroundObject isKindOfClass:[UIImage class]]) {
            node = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImage:(UIImage *) backgroundObject]];
        } else if ([backgroundObject isKindOfClass:[NSString class]])  {
            node = [[SKSpriteNode alloc] initWithImageNamed:(NSString *) backgroundObject];
            node.name = @"bla!";
        } else if ([backgroundObject isKindOfClass:[SKTexture class]]) {
            node = [[SKSpriteNode alloc] initWithTexture:(SKTexture *) backgroundObject];
        } else if ([backgroundObject isKindOfClass:[SKSpriteNode class]]) {
            node = (SKSpriteNode *) backgroundObject;
        } else continue;
        
        // add the velocity for this node and adjust the next current velocity
        [self.scrollingSpeeds addObject:[NSNumber numberWithFloat:self.currentSpeed]];
        self.currentSpeed = self.currentSpeed / (1 + differential);
        
        self = node;
    }
    return self;
}

- (void)update:(NSTimeInterval)currentTime
{
    for (NSUInteger i = 0; i < self.numberOfBackgrounds; i++) {
        // determine the speed of each node
        CGFloat speed = [[self.scrollingSpeeds objectAtIndex:i] floatValue];
        
        // adjust positions
        SKSpriteNode * bg = [self.backgrounds objectAtIndex:i];
        CGFloat newBgX = bg.position.x, newBgY = bg.position.y;
        // position depends on direction.
        switch (self.direction) {
            case kPBParallaxBackgroundDirectionUp:
                newBgY += speed;
                if (newBgY >= (bg.size.height * 2)) newBgY = -(bg.size.height * 2);
                break;
                
            case kPBParallaxBackgroundDirectionDown:
                newBgY -= speed;
                if (newBgY <= 0) newBgY += (bg.size.height * 2);
                break;
                
            case kPBParallaxBackgroundDirectionRight:
                newBgX += speed;
                if (newBgX >= bg.size.width) newBgX -= 2*bg.size.width;
                break;
                
            case kPBParallaxBackgroundDirectionLeft:
                newBgX -= speed;
                if (newBgX <= -bg.size.width) newBgX += 2*bg.size.width;
                break;
            default:
                break;
        }
        
        // update positions with the right coordinates.
        bg.position = CGPointMake(newBgX, newBgY);
    }
}

@end