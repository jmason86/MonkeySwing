//
//  PageContentViewController.h
//  MonkeySwing
//
//  Created by James Paul Mason on 7/15/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainMenuContentViewController : UIViewController

@property NSUInteger pageIndex;
@property NSString *backgroundImage;
@property BOOL isContinueButtonAvailable;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end