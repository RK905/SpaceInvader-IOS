//
//  SIMyScene.h
//  SpaceInvader
//

//  Copyright (c) 2014 GeeksDoByte. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#define SIMaxNumberOfInvaderRows 3
#define SIMaxNumberOfInvaderCollumns 8
#define SIMaxNumberOfFriendlyProjectiles 1

#define SISpeedIncreasePerLevel 0.1

@protocol SIGameSceneDelegate <NSObject>

- (void)resetGameUI;
- (void)increaseScore;
- (void)decreaseLife;

@end

@interface SIGameScene : SKScene {
    BOOL gameRunning;
    double gameStartedAt;
    NSTimer *timer;
    int lifes;
    int level;
}

@property (strong, nonatomic) SKSpriteNode *background;
@property (strong, nonatomic) SKSpriteNode *spaceship;
@property (strong, nonatomic) NSMutableArray *projectilesFriendly;
@property (strong, nonatomic) NSMutableArray *projectilesEnemy;
@property (strong, nonatomic) NSMutableArray *invaders;

@property (weak, nonatomic) id <SIGameSceneDelegate> delegate;

- (void)startGame;
- (void)pauseGame;
- (void)stopGame;
- (void)moveSpaceshipSidewaysByAngle:(double)angleInDegrees;

@end
