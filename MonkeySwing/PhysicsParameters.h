//
//  PhysicsParameters.h
//  MonkeySwing
//
//  Created by James Paul Mason on 1/24/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhysicsParameters : NSObject

// World parameters
@property (nonatomic) CGVector gravity;

// Rope parameters
@property (nonatomic) CGFloat ropeDensity;
@property (nonatomic) CGFloat ropeRestitution;
@property (nonatomic) CGFloat ropeLinearDamping;
@property (nonatomic) CGFloat ropeAngularDamping;
@property (nonatomic) CGFloat ropeRotationLimit;

// Monkey parameters
@property (nonatomic) CGFloat monkeyMass;
@property (nonatomic) CGFloat monkeyRestitution;
@property (nonatomic) CGFloat monkeyLinearDamping;
@property (nonatomic) CGFloat monkeyAngularDamping;
@property (nonatomic) CGVector monkeyInitialVelocity;
@property (nonatomic) CGVector monkeyJumpImpulse;

// Fire parameters
@property (nonatomic) CGFloat fireRiseRate;
@property (nonatomic) CGFloat fireNodeXSize;
@property (nonatomic) CGFloat fireTimerRate; 


// Touch parameters
@property (nonatomic) CGFloat swipeToXVelocityConversion;
@property (nonatomic) CGFloat swipeToYVelocityConversion;

@end