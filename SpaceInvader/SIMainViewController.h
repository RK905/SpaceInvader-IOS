//
//  SIMainViewController.h
//  SpaceInvader
//
//  Created by GeeksDoByte on 21/02/14.
//  Copyright (c) 2014 GeeksDoByte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SIGameViewController.h"

@interface SIMainViewController : UIViewController <UITableViewDataSource, UITextFieldDelegate, SIGameViewControllerDelegate> {
}

@property (strong, nonatomic) IBOutlet UITextField *textFieldPlayerName;
@property (strong, nonatomic) IBOutlet UITableView *tableViewHighscores;
@property (strong, nonatomic) SIGameViewController *viewControllerGame;

- (IBAction)buttonStartGameTouchUpInside:(id)sender;

@end
