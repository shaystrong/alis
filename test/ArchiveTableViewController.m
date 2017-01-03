//
//  TableViewController.m
//  ALIS
//
//  Created by Strong, Shadrian B. on 10/2/14.
//  Copyright (c) 2014 ALIS. All rights reserved.
//

#import "ArchiveTableViewController.h"
#import <Foundation/Foundation.h>
#import "SimpleTableCell.h"


@interface ArchiveTableViewController ()
@end

@implementation ArchiveTableViewController
{
NSMutableArray *recipes;
NSMutableArray *timesData;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    timesData = [NSMutableArray arrayWithObjects:self.timeObs, nil];
    recipes = [NSMutableArray arrayWithObjects:@"Egg Benedict", @"Mushroom Risotto", @"Full Breakfast", @"Hamburger", @"Ham and Egg Sandwich", @"Creme Brelee", @"White Chocolate Donut", @"Starbucks Coffee", @"Vegetable Curry", @"Instant Noodle with Egg", @"Noodle with BBQ Pork", @"Japanese Noodle with Pork", @"Green Tea", @"Thai Shrimp Cake", @"Angry Birds Cake", @"Ham and Cheese Panini", nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [recipes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TableIdentifier = @"TableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableIdentifier];
    }
    
    cell.textLabel.text = [recipes objectAtIndex:indexPath.row];
    //cell.imageView.image = [UIImage imageNamed:@"creme_brelee.jpg"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove the row from data model
    [timesData removeObjectAtIndex:indexPath.row];
    
    // Request table view to reload
  //  [timesData reloadData];
}


@end
