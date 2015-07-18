//
//  SIMainViewController.m
//  SpaceInvader
//
//  Created by GeeksDoByte on 21/02/14.
//  Copyright (c) 2014 GeeksDoByte. All rights reserved.
//

#import "SIMainViewController.h"
#import "SIGameScene.h"
#import "SIDataManager.h"
#import "SIHighscoreCell.h"

@interface SIMainViewController ()

@end

@implementation SIMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.viewControllerGame = [[SIGameViewController alloc] initWithNibName:@"SIGameViewController" bundle:nil];
        self.viewControllerGame.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && !self.viewControllerGame.view.superview) {
        [self.view addSubview:self.viewControllerGame.view];
        self.viewControllerGame.view.alpha = 0.0f;
    }
    
    [self.textFieldPlayerName setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    self.textFieldPlayerName.text = [SIDataManager sharedManager].currentPlayer;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (!self.viewControllerGame.view.superview) {
        [self.view addSubview:self.viewControllerGame.view];
        self.viewControllerGame.view.alpha = 0.0f;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.tableViewHighscores reloadData];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions methods

//Starts the game if player name is available
- (IBAction)buttonStartGameTouchUpInside:(id)sender {
    
    if (self.textFieldPlayerName.text.length) {
        self.viewControllerGame.view.alpha = 1.0f;
        if ([self.textFieldPlayerName isFirstResponder]) {
            [self.textFieldPlayerName resignFirstResponder];
        }
        [self.viewControllerGame startGame];
    } else {
        if (![self.textFieldPlayerName isFirstResponder]) {
            [self.textFieldPlayerName becomeFirstResponder];
        }
    }
}


#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *highscoreRecord = [SIDataManager sharedManager].highscores[indexPath.row];
    SIHighscoreCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SIHighscoreCell"];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"SIHighscoreCell" owner:nil options:nil][0];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    cell.labelPlace.text = [NSString stringWithFormat:@"%d.", (int)indexPath.row +1];
    cell.labelPlayerName.text = [NSString stringWithFormat:@"%@", highscoreRecord[@"playerName"]];
    cell.labelPlayerScore.text = [NSString stringWithFormat:@"%@", highscoreRecord[@"score"]];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [SIDataManager sharedManager].highscores.count;
}


#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    [[SIDataManager sharedManager] setCurrentPlayer:textField.text];
    return YES;
}


#pragma mark - SIGameViewControllerDelegate methods

//Informs view controller that the game has ended and is no longer visible on screen
- (void)gameEnded {
    
    [self.tableViewHighscores reloadData];
}

@end
