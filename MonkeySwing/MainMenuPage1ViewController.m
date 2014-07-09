//
//  MainMenuPage1ViewController.m
//  MonkeySwing
//
//  Created by James Paul Mason on 7/2/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import "MainMenuPage1ViewController.h"

@interface MainMenuPage1ViewController ()

@end

@implementation MainMenuPage1ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self->_index = 1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)musicSwitchChanged:(UISwitch *)sender {
}

- (IBAction)soundSwitchChanged:(UISwitch *)sender {
}

- (IBAction)resetButtonTapped:(UIButton *)sender {
}
@end
