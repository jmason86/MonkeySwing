//
//  PhysicsParameters.m
//  MonkeySwing
//
//  Created by James Paul Mason on 1/24/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import "PhysicsParameters.h"

@implementation PhysicsParameters

@synthesize gravity;
@synthesize ropeDensity, ropeRestitution, ropeLinearDamping, ropeAngularDamping, ropeRotationLimit;
@synthesize monkeyMass, monkeyRestitution, monkeyLinearDamping, monkeyAngularDamping, monkeyInitialVelocity, monkeyJumpImpulse;
@synthesize fireRiseRate, fireNodeXSize, fireTimerRate;
@synthesize swipeToXVelocityConversion, swipeToYVelocityConversion;

- (id)init
{
    // World parameters
    gravity = CGVectorMake(0, -2); // SI, default = (0, -9.8)
    
    // Rope parameters
    ropeDensity = 3.0;            // SI, default = 1.0
    ropeRestitution = 0.2;        // range = 0-1, default = 0.2
    ropeLinearDamping = 0.8;      // range = 0-1, default = 0.1
    ropeAngularDamping = 0.1;     // range = 0-1, default = 0.1
    ropeRotationLimit = M_PI/12;  // Rope allowed to swing +/- this value
    
    // Monkey parameters
    monkeyMass = 10.0;            // SI, default = size * default density (1.0)
    monkeyRestitution = 0.2;      // range = 0-1, default = 0.2
    monkeyLinearDamping = 0.1;    // range = 0-1, default = 0.1
    monkeyAngularDamping = 0.1;   // range = 0-1, default = 0.1
    monkeyInitialVelocity = CGVectorMake(100, 0);
    monkeyJumpImpulse = CGVectorMake(1000, 500);
    
    // Fire parameters
    fireRiseRate = 1.0;
    fireNodeXSize = 50.0;
    fireTimerRate = 0.75;
    
    // Touch parameters
    swipeToXVelocityConversion = 0.8;
    swipeToYVelocityConversion = 0.4;
    
    return self;
}

@end
