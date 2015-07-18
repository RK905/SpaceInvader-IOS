//
//  SIViewController.m
//  SpaceInvader
//
//  Created by GeeksDoByte on 21/02/14.
//  Copyright (c) 2014 GeeksDoByte. All rights reserved.
//

#import "SIGameViewController.h"
#import "SIDataManager.h"

#define degrees(x) (180 * x / M_PI)

@implementation SIGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    //skView.showsFPS = YES;
    //skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SIGameScene * scene = [SIGameScene sceneWithSize:skView.bounds.size];
    scene.delegate = self;
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
}

- (void)startGame {
    
    SKView *skView = (SKView *)self.view;
    SIGameScene *scene = (SIGameScene*)skView.scene;
    if (_pausedByBackground) {
        _pausedByBackground = NO;
        skView.alpha = 1.0f;
    }
    [scene startGame];
    [self startGyro];
}

- (void)pauseGame {
    
    [self stopGyro];
    SKView *skView = (SKView *)self.view;
    SIGameScene *scene = (SIGameScene*)skView.scene;
    skView.alpha = 0.0f;
    [scene pauseGame];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

//Shows alert view for user to specify Back action
- (IBAction)buttonBackTouchUpInside:(id)sender {
    
    [self stopGyro];
    [[[UIAlertView alloc] initWithTitle:@"Paused" message:@"Do you want to pause or surrender?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Pause", @"Surrender", nil] show];
    SKView * skView = (SKView *)self.view;
    SIGameScene *scene = (SIGameScene*)skView.scene;
    [scene pauseGame];
}

//Stops and removes motion manager
- (void)stopGyro {
    
    [motionManager stopDeviceMotionUpdates];
    motionManager = nil;
}

//Starts motion manager to monitor for user screen tilts
- (void)startGyro {
    
    [motionManager stopDeviceMotionUpdates];
    motionManager = nil;
    
    motionManager = [[CMMotionManager alloc] init];
    motionManager.deviceMotionUpdateInterval = 0.1;
    
    if ([motionManager isGyroAvailable]) {
        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
            CMAttitude *attitude = motion.attitude;
            SKView *skView = (SKView *)self.view;
            SIGameScene *scene = (SIGameScene*)skView.scene;
            [scene moveSpaceshipSidewaysByAngle:degrees(attitude.pitch)];
        }];
    }
}


#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([alertView.title isEqualToString:@"Paused"]) {
        SKView *skView = (SKView *)self.view;
        SIGameScene *scene = (SIGameScene*)skView.scene;
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Pause"]) {
            skView.alpha = 0.0f;
        } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Surrender"]) {
            skView.alpha = 0.0f;
            [scene stopGame];
        } else {
            [scene startGame];
            [self startGyro];
        }
    }
}


#pragma mark - SIGameSceneDelegate methods

- (void)resetGameUI {
    
    for (int i = 0; i < self.imageViewsLifes.count; i++) {
        UIImageView *imageViewLife = self.imageViewsLifes[i];
        imageViewLife.alpha = 1.0f;
    }
    self.labelScore.text = @"SCORE: 0";
}

- (void)increaseScore {
    
    NSArray *components = [self.labelScore.text componentsSeparatedByString:@" "];
    self.labelScore.text = [NSString stringWithFormat:@"SCORE: %d", [components[1] intValue] +1];
}

- (void)decreaseLife {
    
    for (int i = (int)self.imageViewsLifes.count -1; i >= 0; i--) {
        UIImageView *imageViewLife = self.imageViewsLifes[i];
        if (imageViewLife.alpha) {
            imageViewLife.alpha = 0.0f;
            if (i == 0) {
                NSArray *components = [self.labelScore.text componentsSeparatedByString:@" "];
                [[SIDataManager sharedManager] checkAndAddScore:[NSNumber numberWithInt:[components[1] intValue]]];
                [self.delegate gameEnded];
            }
            break;
        }
    }
}

@end
