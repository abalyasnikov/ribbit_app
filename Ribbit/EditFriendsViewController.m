//
//  EditFriendsViewController.m
//  Ribbit
//
//  Created by Андрей Балясников on 08/02/14.
//  Copyright (c) 2014 Andrey Balyasnikov. All rights reserved.
//

#import "EditFriendsViewController.h"
#import "MSCellAccessory.h"

@interface EditFriendsViewController ()

@end

@implementation EditFriendsViewController

UIColor *desclosureColor;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // создаем обращение к БД parse.com
    PFQuery *query = [PFUser query];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        else {
            self.allUsers = objects;
            // когда мы получаем данные мы говорим об этом табличке и обновляем ее
            [self.tableView reloadData];
        }
    }];

    self.currentUser = [PFUser currentUser];
    
    desclosureColor = [UIColor colorWithRed:0.553 green:0.439 blue:0.718 alpha:1];
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
    return [self.allUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellEditFriends";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    PFUser *user = [self.allUsers objectAtIndex:indexPath.row];
    cell.textLabel.text = user.username;
    
    
    
    
    // делаем проверка на чекбоксы
    if ([self isFriend:user]) {
        cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_CHECKMARK color:desclosureColor];
    }
    else {
        // если нет - то без галки
        cell.accessoryView = nil;
    }

    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // копирнули из cellForIndexPath, так как нужен экземпляр класса pfuser, чтобы проверить наличие друзей
    PFUser *user = [self.allUsers objectAtIndex:indexPath.row];
    PFRelation *friendsRelations = [self.currentUser relationForKey:@"friendsRelations"];
    
    // создаем связи, чтобы список друзей можно было редактировать
    if ([self isFriend:user]) {
        // удаляем друга
        // 1 - сначала удалить чекбокс
        // 2 - удалить из массива
        // 3 - удалить из БД
        cell.accessoryView = nil;
        
        for (PFUser *friend in self.friends) {
            if ([friend.objectId isEqualToString:user.objectId]) {
                [self.friends removeObject:friend];
                break; // после того как удалили, останавливаем луп
            }
        }
    
        [friendsRelations removeObject:user];
        
    }
    else {
        // добавляем друга
        cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_CHECKMARK color:desclosureColor];
        [self.friends addObject:user];
        [friendsRelations addObject:user];
        
    }
    
    // сохраняем в backend
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"error: %@ %@", error, [error userInfo]);
        }
    }];
    
}


#pragma mark - additional methods


// проверяем является ли юзер другом
- (BOOL) isFriend:(PFUser *)user
{
    for (PFUser *friend in self.friends) {
        if ([friend.objectId isEqualToString:user.objectId]) {
            return YES;
        }
    }
    return NO;
}


/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
