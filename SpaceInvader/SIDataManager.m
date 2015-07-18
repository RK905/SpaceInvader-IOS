//
//  SIDataManager.m
//  SpaceInvader
//
//  Created by GeeksDoByte on 25/02/14.
//  Copyright (c) 2014 GeeksDoByte. All rights reserved.
//

#import "SIDataManager.h"

static SIDataManager *sharedManager = nil;
static NSString *currentPlayer = nil;
static NSMutableArray *highscores = nil;

@implementation SIDataManager

+ (SIDataManager*)sharedManager {
    
    if (!sharedManager) {
        sharedManager = [[SIDataManager alloc] init];
    }
    return sharedManager;
}

//Removes all highscores
- (void)resetHighscores {
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"highscores"];
    highscores = [NSMutableArray new];
}

//Returns highscores in form of NSDictionaries
- (NSMutableArray*)highscores {
    
    NSArray *storedHighscores = [[NSUserDefaults standardUserDefaults] arrayForKey:@"highscores"];
    if (storedHighscores.count) {
        highscores = [[NSMutableArray alloc] initWithArray:storedHighscores];
    } else {
        highscores = [NSMutableArray new];
    }
    return highscores;
}

//Adds the score to highscores list if it qualifies, max. 5 highscores
- (BOOL)checkAndAddScore:(NSNumber*)newScore {
    
    if (newScore.intValue == 0) {
        return NO;
    }
    if (!highscores) {
        [self highscores];
    }
    if (!currentPlayer) {
        [self currentPlayer];
    }
    if (currentPlayer.length < 1) {
        return NO;
    }
    
    NSDictionary *newHighscoreRecord = @{@"playerName": currentPlayer, @"score": newScore};
    if (highscores.count == 0) {
        [highscores addObject:newHighscoreRecord];
    } else {
        [highscores addObject:newHighscoreRecord];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"score" ascending:NO];
        [highscores sortUsingDescriptors:@[sortDescriptor]];
        if (highscores.count > 5) {
            [highscores removeLastObject];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:highscores forKey:@"highscores"];
    return YES;
}

//Returns current player name
- (NSString*)currentPlayer {
    
    currentPlayer = [[NSUserDefaults standardUserDefaults] stringForKey:@"currentPlayer"];
    if (!currentPlayer) {
        currentPlayer = [NSString new];
    }
    return currentPlayer;
}

//Sets new current player name
- (void)setCurrentPlayer:(NSString*)newPlayer {
    
    if ([newPlayer isKindOfClass:[NSString class]]) {
        [[NSUserDefaults standardUserDefaults] setObject:newPlayer forKey:@"currentPlayer"];
        currentPlayer = newPlayer;
    }
}


@end
