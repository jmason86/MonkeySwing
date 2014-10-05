//
//  MyScene.h
//  MonkeySwing
//

//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "PhysicsParameters.h"
#import "PBParallaxScrolling.h"

@interface GamePlayScene : SKScene <SKPhysicsContactDelegate>

@property (nonatomic, strong) PhysicsParameters *physicsParameters;
@property (nonatomic) int levelNumber;
@property (nonatomic) PBParallaxBackgroundDirection direction;


@end