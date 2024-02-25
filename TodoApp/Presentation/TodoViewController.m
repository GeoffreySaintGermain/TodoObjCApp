//
//  ViewController.m
//  TodoApp
//
//  Created by Saint Germain, Geoffrey (uif57971) on 25/02/2024.
//

#import "TodoViewController.h"

@interface TodoViewController ()

@property (nonatomic) NSMutableArray *items;

@end

@implementation TodoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.items = @[
        @{@"name": @"Do something", @"category": @"Home"},
        @{@"name": @"Do another thing", @"category": @"Home"}
    ].mutableCopy;
    
    self.navigationItem.title = @"Todo List";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem:)];
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
        NSDictionary *itemToAdd = @{ @"name": itemNameTextField, @"category": @"Home" };
        
        [self.items addObject:itemToAdd];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.items.count - 1 inSection:0]]
                              withRowAnimation: UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Table View DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"TodoItemRow";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier forIndexPath:indexPath];
    
    NSDictionary *item = self.items[indexPath.row];
    cell.textLabel.text = item[@"name"];
    
    if ([item[@"completed"] boolValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *item = [self.items[indexPath.row] mutableCopy];
    BOOL completed = [item[@"completed"] boolValue];
    item[@"completed"] = @(!completed);
    
    self.items[indexPath.row] = item;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = ([item[@"completed"] boolValue]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
