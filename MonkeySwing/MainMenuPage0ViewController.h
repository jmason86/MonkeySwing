//
//  MainMenuPage0ViewController.h
//  MonkeySwing
//
//  Created by James Paul Mason on 7/2/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

@interface MainMenuPage0ViewController : UIViewController

@property (readonly, nonatomic) NSInteger index;
@property (strong, nonatomic) IBOutlet UIButton *continueButton;

- (IBAction)levelsButtonTapped:(UIButton *)sender;
- (IBAction)continueButtonTapped:(UIButton *)sender;

@end
