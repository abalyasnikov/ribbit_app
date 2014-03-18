//
//  EditFriendsViewController.h
//  Ribbit
//
//  Created by Андрей Балясников on 08/02/14.
//  Copyright (c) 2014 Andrey Balyasnikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface EditFriendsViewController : UITableViewController


@property (nonatomic, strong) NSArray *allUsers;
@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) NSMutableArray *friends;

- (BOOL) isFriend: (PFUser *) user;

@end
