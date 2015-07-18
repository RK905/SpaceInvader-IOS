//
//  SIDataManager.h
//  SpaceInvader
//
//  Created by GeeksDoByte on 25/02/14.
//  Copyright (c) 2014 GeeksDoByte. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SIDataManager : NSObject

+ (SIDataManager*)sharedManager;
- (NSMutableArray*)highscores;
- (BOOL)checkAndAddScore:(NSNumber*)newScore;
- (NSString*)currentPlayer;
- (void)setCurrentPlayer:(NSString*)newPlayer;

@end
