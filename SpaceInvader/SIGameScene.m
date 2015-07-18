//
//  SIMyScene.m
//  SpaceInvader
//
//  Created by GeeksDoByte on 21/02/14.
//  Copyright (c) 2014 GeeksDoByte. All rights reserved.
//

#import "SIGameScene.h"

@implementation SIGameScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        SKTexture *backgroundTexture = [SKTexture textureWithImageNamed:@"Background"];
        self.background = [SKSpriteNode spriteNodeWithTexture:backgroundTexture size:size];
        self.background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        self.background.zPosition = -1000.0f;
        [self addChild:self.background];
        
        self.projectilesFriendly = [[NSMutableArray alloc] init];
        self.projectilesEnemy = [[NSMutableArray alloc] init];
        self.invaders = [[NSMutableArray alloc] init];
        
        gameStartedAt = 0.0;
    }
    return self;
}

- (void)handleFireTimer:(NSTimer*)firedTimer {
    
    if (self.invaders.count) {
        int randomIndex = arc4random() % self.invaders.count;
        SKSpriteNode *invader = self.invaders[randomIndex];
        SKSpriteNode *projectile = [SKSpriteNode spriteNodeWithColor:[SKColor yellowColor] size:CGSizeMake(5.0f, 10.0f)];
        [projectile runAction:[SKAction playSoundFileNamed:@"LaserShotBad.wav" waitForCompletion:NO]];
        projectile.zPosition = -3.0f;
        projectile.position = invader.position;
        double moveDuration = 0.75;
        moveDuration -= moveDuration *SISpeedIncreasePerLevel *level;
        SKAction *fireAction = [SKAction moveToY:(CGRectGetMinY(self.view.frame) -10.0f) duration:moveDuration];
        [self.projectilesEnemy addObject:projectile];
        [self addChild:projectile];
        [projectile runAction:fireAction completion:^{
            [projectile removeFromParent];
            [self.projectilesEnemy removeObjectIdenticalTo:projectile];
        }];
    }
}

- (void)moveSpaceshipSidewaysByAngle:(double)angleInDegrees {
    
    if (gameRunning) {
        [self.spaceship removeActionForKey:@"moveLeftAction"];
        [self.spaceship removeActionForKey:@"moveRightAction"];
        if (angleInDegrees < 0.0) {
            if (CGRectGetMinX(self.spaceship.frame) > 45.0f) {
                SKAction *moveLeftAction = [SKAction moveByX:-2.0f +angleInDegrees y:0.0f duration:0.0999];
                moveLeftAction.timingMode = SKActionTimingEaseInEaseOut;
                [self.spaceship runAction:moveLeftAction withKey:@"moveLeftAction"];
            }
        } else {
            if (CGRectGetMaxX(self.spaceship.frame) < CGRectGetMaxX(self.frame) -45.0f) {
                SKAction *moveRightAction = [SKAction moveByX:+2.0f +angleInDegrees y:0.0f duration:0.0999];
                moveRightAction.timingMode = SKActionTimingEaseInEaseOut;
                [self.spaceship runAction:moveRightAction withKey:@"moveRightAction"];
            }
        }
    }
}

//Called when a touch begins to fire projectile if possible
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (self.projectilesFriendly.count < SIMaxNumberOfFriendlyProjectiles) {
        SKSpriteNode *projectile = [SKSpriteNode spriteNodeWithColor:[SKColor greenColor] size:CGSizeMake(5.0f, 10.0f)];
        [projectile runAction:[SKAction playSoundFileNamed:@"LaserShotNice.wav" waitForCompletion:NO]];
        projectile.zPosition = -2.0f;
        projectile.position = self.spaceship.position;
        SKAction *fireAction = [SKAction moveToY:CGRectGetMaxY(self.view.frame) duration:0.4];
        [self.projectilesFriendly addObject:projectile];
        [self addChild:projectile];
        [projectile runAction:fireAction completion:^{
            [projectile removeFromParent];
            [self.projectilesFriendly removeObjectIdenticalTo:projectile];
        }];
    }
}

//Creates new enemy sprites and moves them in scene
- (void)crateAndPositionInvaders {
    
    ++level;
    float requiredWidth = (SIMaxNumberOfInvaderCollumns *25) + (SIMaxNumberOfInvaderCollumns -1) *15;
    float requiredHeight = (SIMaxNumberOfInvaderRows *20) + (SIMaxNumberOfInvaderRows -1) *10;
    float screenWidth = CGRectGetWidth(self.view.frame);
    float screenHeight = CGRectGetHeight(self.view.frame);
    float originX = screenWidth/2 -requiredWidth/4;
    float originY = screenHeight +requiredHeight;
    for (int i = 0; i < SIMaxNumberOfInvaderRows; i++) {
        for (int j = 0; j < SIMaxNumberOfInvaderCollumns; j++) {
            SKSpriteNode *invader = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"Invader%d", i+1]];
            invader.zPosition = -2.0f;
            [self addChild:invader];
            [self.invaders addObject:invader];
            invader.position = CGPointMake((originX +j *40) -CGRectGetWidth(invader.frame)/2, (originY -i *30) -CGRectGetHeight(invader.frame)/2 +20.0f);
            SKAction *moveIn = [SKAction moveToY:invader.position.y -requiredHeight -60.0f duration:0.2];
            [invader runAction:moveIn completion:^{
                double moveDuration = 0.03;
                moveDuration -= moveDuration *SISpeedIncreasePerLevel *level;
                SKAction *moveRight = [SKAction moveByX:2.0f y:0.0f duration:moveDuration];
                moveRight = [SKAction repeatActionForever:moveRight];
                [invader runAction:moveRight withKey:@"moveRight"];
            }];
        }
    }
}

//Restarts the game
- (void)restartGame {
    
    [self stopGame];
    [self startGame];
}

//Starts a game by positioning initial sprites and animations
- (void)startGame {
    
    if (self.spaceship) {
        gameRunning = YES;
        [self sendInvadersRight];
    } else {
        level = -1;
        lifes = 3;
        double delayInSeconds = 0.151;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            self.spaceship = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
            self.spaceship.position = CGPointMake(CGRectGetMidX(self.frame), 0.0f -CGRectGetHeight(self.spaceship.frame)/2);
            [self addChild:self.spaceship];
            
            CGPoint center = CGPointMake(CGRectGetMidX(self.frame), 20.0f + CGRectGetHeight(self.spaceship.frame));
            SKAction *flyToCenterAction = [SKAction moveTo:center duration:0.2];
            
            [self.spaceship runAction:flyToCenterAction completion:^{
                gameRunning = YES;
                [self crateAndPositionInvaders];
            }];
        });
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(handleFireTimer:) userInfo:nil repeats:YES];
}

//Pauses the game by removing all animations
- (void)pauseGame {
    
    gameRunning = NO;
    [timer invalidate];
    timer = nil;
    [self.spaceship removeAllActions];
    [self.invaders makeObjectsPerformSelector:@selector(removeAllActions)];
    [self.projectilesEnemy makeObjectsPerformSelector:@selector(removeAllActions)];
    [self.projectilesEnemy makeObjectsPerformSelector:@selector(removeFromParent)];
    [self.projectilesEnemy removeAllObjects];
    [self.projectilesFriendly makeObjectsPerformSelector:@selector(removeAllActions)];
    [self.projectilesFriendly makeObjectsPerformSelector:@selector(removeFromParent)];
    [self.projectilesFriendly removeAllObjects];
}

//Stops the game by removing all animations and sprites on scene
- (void)stopGame {
    
    gameStartedAt = 0.0;
    gameRunning = NO;
    [timer invalidate];
    timer = nil;
    [self.spaceship removeAllActions];
    [self.spaceship removeFromParent];
    self.spaceship = nil;
    [self.invaders makeObjectsPerformSelector:@selector(removeAllActions)];
    [self.invaders makeObjectsPerformSelector:@selector(removeFromParent)];
    [self.invaders removeAllObjects];
    [self.projectilesEnemy makeObjectsPerformSelector:@selector(removeAllActions)];
    [self.projectilesEnemy makeObjectsPerformSelector:@selector(removeFromParent)];
    [self.projectilesEnemy removeAllObjects];
    [self.projectilesFriendly makeObjectsPerformSelector:@selector(removeAllActions)];
    [self.projectilesFriendly makeObjectsPerformSelector:@selector(removeFromParent)];
    [self.projectilesFriendly removeAllObjects];
    [self.delegate resetGameUI];
    self.view.alpha = 0.0f;
}

//Starts move left animation for enemy sprites
- (void)sendInvadersLeft {
    
    double moveDuration = 0.03;
    moveDuration -= moveDuration *SISpeedIncreasePerLevel *level;
    SKAction *moveLeft = [SKAction moveByX:-2.0f y:0.0f duration:moveDuration];
    moveLeft = [SKAction repeatActionForever:moveLeft];
    for (int i = 0; i < self.invaders.count; i++) {
        SKSpriteNode *invader = self.invaders[i];
        if (![invader hasActions]) {
            [invader runAction:moveLeft withKey:@"moveLeft"];
        }
    }
}

//Starts move right animation for enemy sprites
- (void)sendInvadersRight {
    
    double moveDuration = 0.03;
    moveDuration -= moveDuration *SISpeedIncreasePerLevel *level;
    SKAction *moveRight = [SKAction moveByX:+2.0f y:0.0f duration:moveDuration];
    moveRight = [SKAction repeatActionForever:moveRight];
    for (int i = 0; i < self.invaders.count; i++) {
        SKSpriteNode *invader = self.invaders[i];
        if (![invader hasActions]) {
            [invader runAction:moveRight withKey:@"moveRight"];
        }
    }
}

//Stops spaceship sprite if it reached edge of the screen
- (void)stopSpaceshipIfNeeded {
    
    if (CGRectGetMinX(self.spaceship.frame) < 45.0f) {
        [self.spaceship removeActionForKey:@"moveLeftAction"];
    } else if (CGRectGetMaxX(self.spaceship.frame) > CGRectGetMaxX(self.frame) -45.0f) {
        [self.spaceship removeActionForKey:@"moveRightAction"];
    }
}

//Stop enemy sprites if they reached edge of the screen
//Redirect enemy sprites to go in opposite side
- (void)stopInvadersIfNeededAndRedirect {
    
    for (int i = 0; i < self.invaders.count; i++) {
        SKSpriteNode *invader = self.invaders[i];
        if (CGRectGetMinX(invader.frame) < 45.0f) {
            [self.invaders makeObjectsPerformSelector:@selector(removeActionForKey:) withObject:@"moveLeft"];
            [self sendInvadersRight];
            break;
        } else if (CGRectGetMaxX(invader.frame) > CGRectGetMaxX(self.frame) -45.0f) {
            [self.invaders makeObjectsPerformSelector:@selector(removeActionForKey:) withObject:@"moveRight"];
            [self sendInvadersLeft];
            break;
        }
    }
}

//Checks if any of visible projectiles intersected with it's target
//If hit happens appropriate calls to update screen are made
- (void)checkForProjectileHit {
    
    //Check if enemy sprite is hit
    SKSpriteNode *projectileToRemove = nil;
    SKSpriteNode *spacecraftToRemove = nil;
    for (int i = 0; i < self.projectilesFriendly.count; i++) {
        SKSpriteNode *projectile = self.projectilesFriendly[i];
        for (int j = 0; j < self.invaders.count; j++) {
            SKSpriteNode *invader = self.invaders[j];
            CGRect intersect = CGRectIntersection(invader.frame, projectile.frame);
            if (intersect.size.width || intersect.size.height) {
                projectileToRemove = projectile;
                spacecraftToRemove = invader;
                break;
            }
        }
    }
    
    if (projectileToRemove && spacecraftToRemove) {
        
        [self.spaceship runAction:[SKAction playSoundFileNamed:@"ExplosionEnemy.wav" waitForCompletion:NO]];
        
        NSString *explosionPath = [[NSBundle mainBundle] pathForResource:@"Explosion" ofType:@"sks"];
        SKEmitterNode *explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:explosionPath];
        explosion.position = projectileToRemove.position;
        [self addChild:explosion];
        
        double delayInSeconds = 0.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [explosion removeFromParent];
        });
        
        [spacecraftToRemove removeAllActions];
        [spacecraftToRemove removeFromParent];
        [self.invaders removeObjectIdenticalTo:spacecraftToRemove];
        [projectileToRemove removeAllActions];
        [projectileToRemove removeFromParent];
        [self.projectilesFriendly removeObjectIdenticalTo:projectileToRemove];
        [self.delegate increaseScore];
        
        if (self.invaders.count == 0) {
            [self crateAndPositionInvaders];
        }
    }
    
    //Check if spacecraft sprite is hit
    projectileToRemove = nil;
    spacecraftToRemove = nil;
    
    for (int i = 0; i < self.projectilesEnemy.count; i++) {
        SKSpriteNode *projectile = self.projectilesEnemy[i];
        CGRect intersect = CGRectIntersection(self.spaceship.frame, projectile.frame);
        if (intersect.size.width || intersect.size.height) {
            projectileToRemove = projectile;
            spacecraftToRemove = self.spaceship;
            break;
        }
    }
    
    if (projectileToRemove && spacecraftToRemove) {
        --lifes;
        [self.delegate decreaseLife];
        
        if (!lifes) {
            [self.spaceship removeAllActions];
            [self.spaceship runAction:[SKAction playSoundFileNamed:@"ExplosionSpaceship.wav" waitForCompletion:NO]];
            NSString *explosionPath = [[NSBundle mainBundle] pathForResource:@"ExplosionBig" ofType:@"sks"];
            SKEmitterNode *explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:explosionPath];
            explosion.position = projectileToRemove.position;
            [self addChild:explosion];
            
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [explosion removeFromParent];
                [spacecraftToRemove removeFromParent];
                [self stopGame];
            });
        } else {
            [self.spaceship runAction:[SKAction playSoundFileNamed:@"ExplosionSmall.wav" waitForCompletion:NO]];
            NSString *explosionPath = [[NSBundle mainBundle] pathForResource:@"ExplosionSmall" ofType:@"sks"];
            SKEmitterNode *explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:explosionPath];
            explosion.position = projectileToRemove.position;
            [self addChild:explosion];
            
            double delayInSeconds = 0.2;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [explosion removeFromParent];
            });
        }
        [projectileToRemove removeAllActions];
        [projectileToRemove removeFromParent];
        [self.projectilesEnemy removeObjectIdenticalTo:projectileToRemove];
    }
}

// Called before each frame is rendered
- (void)update:(CFTimeInterval)currentTime {
    
    if (gameRunning) {
        if (gameStartedAt == 0.0f) {
            gameStartedAt = currentTime;
        }
        
        [self stopSpaceshipIfNeeded];
        [self stopInvadersIfNeededAndRedirect];
        [self checkForProjectileHit];
    }
}

@end
