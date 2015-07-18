//
//  SIViewController.h
//  SpaceInvader
//

//  Copyright (c) 2014 GeeksDoByte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <CoreMotion/CoreMotion.h>
#import "SIGameScene.h"

@protocol SIGameViewControllerDelegate <NSObject>

- (void)gameEnded;

@end

@interface SIGameViewController : UIViewController <UIAlertViewDelegate, SIGameSceneDelegate> {
    CMMotionManager *motionManager;
}

@property (strong, nonatomic) IBOutlet UILabel *labelScore;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imageViewsLifes;
@property (nonatomic) BOOL pausedByBackground;
@property (weak, nonatomic) id <SIGameViewControllerDelegate> delegate;

- (void)startGame;
- (void)pauseGame;
- (IBAction)buttonBackTouchUpInside:(id)sender;

@end
