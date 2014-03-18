//
//  FriendsViewController.m
//  Ribbit
//
//  Created by Андрей Балясников on 09/02/14.
//  Copyright (c) 2014 Andrey Balyasnikov. All rights reserved.
//

#import "FriendsViewController.h"
#import "EditFriendsViewController.h"
#import "GravatarUrlBuilder.h"

@interface FriendsViewController ()

@end



@implementation FriendsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // получаем связь для текущего юзера
    self.friendsRelation = [[PFUser currentUser] objectForKey:@"friendsRelations"];
    
}

- (void) viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    // создаем запрос по этой связи
    PFQuery *query = [self.friendsRelation query];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        else {
            self.friends = objects;
            [self.tableView reloadData];
        }
        
    }];
}



 #pragma mark - Navigation

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     if ([segue.identifier isEqualToString:@"showEditFriends"]) {
         EditFriendsViewController *viewController = (EditFriendsViewController *) segue.destinationViewController;
         viewController.friends = [NSMutableArray arrayWithArray:self.friends];
         
     }
     
     
     
 }
 


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellFriends";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    // создаем экземляр класска пфюзера и тащим из массива юзеров в каждую ячейку по индексу
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    cell.textLabel.text = user.username;
    
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        // 1. тащим emails
        NSString *emails = [user objectForKey:@"email"];
        
        // 2. create m5 hash
        NSURL *gravatarURL = [GravatarUrlBuilder getGravatarUrl:emails];
        
        // 3. request the image from gravatar.com
        NSData *imageData = [NSData dataWithContentsOfURL:gravatarURL];
        
        if (imageData != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 4. set image in the cell
                cell.imageView.image = [UIImage imageWithData:imageData];
                
                // говорим ячейки перерисовать себя
                [cell setNeedsLayout];
            });
        }
        
        
    });
    cell.imageView.image = [UIImage imageNamed:@"icon_person"];

    return cell;
}







@end
