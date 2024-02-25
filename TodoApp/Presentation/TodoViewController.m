//
//  ViewController.m
//  TodoApp
//
//  Created by Saint Germain, Geoffrey (uif57971) on 25/02/2024.
//

#import "TodoViewController.h"

@interface TodoViewController ()

@property (nonatomic) NSMutableArray *items;
@property (nonatomic) NSArray *categories;

@end

@implementation TodoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.items = @[
        @{@"name": @"Do something", @"category": @"Home"},
        @{@"name": @"Do another thing", @"category": @"Home"},
        @{@"name": @"Learn some new things", @"category": @"Work"},
    ].mutableCopy;
    
    self.categories= @[@"Home", @"Work"];
    
    self.navigationItem.title = @"Todo List";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(toggleEditing:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Editing

- (void)toggleEditing:(UIBarButtonItem *)sender {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    if (self.tableView.editing) {
        sender.title = @"Done";
        sender.style = UIBarButtonItemStyleDone;
    } else {
        sender.title = @"Edit";
        sender.style = UIBarButtonItemStylePlain;
    }
}

#pragma mark - Datasource helper methods

- (NSArray *)itemsInCategory:(NSString *)targetCategory {
    NSPredicate *matchingPredicate = [NSPredicate predicateWithFormat:@"category == %@", targetCategory];
    NSArray *categoryItems = [self.items filteredArrayUsingPredicate:matchingPredicate];
    
    return categoryItems;
}

- (NSInteger)numberOfItemsInCategory:(NSString *)targetCategory {
    return [self itemsInCategory:targetCategory].count;
}

- (NSDictionary *)itemsAtIndexPath:(NSIndexPath *)indexPath {
    NSString *category = self.categories[indexPath.section];
    NSArray *categoryItems = [self itemsInCategory:category];
    NSDictionary *item = categoryItems[indexPath.row];
    
    return item;
}

- (NSInteger)itemIndexForIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = [self itemsAtIndexPath:indexPath];
    NSInteger index = [self.items indexOfObjectIdenticalTo:item];
    
    return index;
}

-(void)removeItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = [self itemIndexForIndexPath:indexPath];
    [self.items removeObjectAtIndex:index];
}

#pragma mark - Adding items

- (void)addNewItem:(UIBarButtonItem *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"New Todo item"
                                                                       message:@"Add a new Todo item"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Enter your new Todo Item";
    }];

    UIAlertAction* cancelAction = [ UIAlertAction actionWithTitle:@"Cancel"
                                                    style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction * action) {}];
    
    UIAlertAction* addItemAction = [UIAlertAction actionWithTitle:@"Add item"
                                                        style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) { [self addItemAction:alertController]; }];
        
    [alertController addAction:addItemAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)addItemAction:(UIAlertController *)alertController {
    NSString *itemNameTextField = alertController.textFields.firstObject.text;
    
    if ([itemNameTextField length] > 0) {
        NSDictionary *itemToAdd = @{@"name": itemNameTextField, @"category": @"Home"};
        
        [self.items addObject:itemToAdd];
        NSInteger numberHomeItems = [self numberOfItemsInCategory:@"Home"];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:numberHomeItems - 1 inSection:0]]
                              withRowAnimation: UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Table View Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.categories.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfItemsInCategory:self.categories[section]];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.categories[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"TodoItemRow";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier forIndexPath:indexPath];
    
    NSDictionary *item = [self itemsAtIndexPath:indexPath];
    cell.textLabel.text = item[@"name"];
    
    if ([item[@"completed"] boolValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = [self itemIndexForIndexPath:indexPath];
    
    NSMutableDictionary *item = [self.items[index] mutableCopy];
    BOOL completed = [item[@"completed"] boolValue];
    item[@"completed"] = @(!completed);
    
    self.items[index] = item;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = ([item[@"completed"] boolValue]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self removeItemAtIndexPath:indexPath];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
