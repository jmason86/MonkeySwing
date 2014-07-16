//
//  LevelSelectionViewController.h
//  MonkeySwing
//
//  Created by James Paul Mason on 7/13/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LevelSelectionViewController : UIViewController <UIPageViewControllerDataSource>

@property (readonly, nonatomic) NSInteger index;
@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@property (strong, nonatomic) IBOutlet UILabel *bestTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *highScoreLabel;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) UIPageViewController *pageController;
@property (nonatomic) NSInteger numberOfLevels;

- (IBAction)menuButtonTapped:(UIButton *)sender;
@end