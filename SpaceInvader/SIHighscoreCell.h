//
//  SIHighscoreCell.h
//  SpaceInvader
//
//  Created by GeeksDoByte on 25/02/14.
//  Copyright (c) 2014 GeeksDoByte. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SIHighscoreCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelPlace;
@property (strong, nonatomic) IBOutlet UILabel *labelPlayerName;
@property (strong, nonatomic) IBOutlet UILabel *labelPlayerScore;

@end
