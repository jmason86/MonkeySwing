//
//  LevelSelectionViewController.h
//  MonkeySwing
//
//  Created by James Paul Mason on 7/13/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LevelSelectionContentViewController : UIViewController

@property NSString *bestTimeString;
@property NSString *highScoreString;
@property NSUInteger pageIndex;
@property NSString *backgroundImage;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet UILabel *bestTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *highScoreLabel;

- (IBAction)menuButtonTapped:(UIButton *)sender;
- (IBAction)playButtonTapped:(UIButton *)sender;

@end