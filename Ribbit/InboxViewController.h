//
//  InboxViewController.h
//  Ribbit
//
//  Created by Андрей Балясников on 08/02/14.
//  Copyright (c) 2014 Andrey Balyasnikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MediaPlayer/MediaPlayer.h>

@interface InboxViewController : UITableViewController


@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, strong) PFObject *selectedMessage;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic, strong) UIRefreshControl *refreshControl;


- (IBAction)logout:(id)sender;


@end
