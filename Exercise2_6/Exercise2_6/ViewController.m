#import "ViewController.h"
#import "FMDatabase.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *message;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property (weak, nonatomic) IBOutlet UITextView *messageList;
@end

@implementation ViewController

- (BOOL)checkTable {
    NSLog(@"checkTable");
    NSString* docsdir = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* dbpath = [docsdir stringByAppendingPathComponent:@"message.db"];
    
    FMDatabase* db = [FMDatabase databaseWithPath:dbpath];
    [db open];
    
    FMResultSet* rs = [db executeQuery:@"select count(*) as c from sqlite_master where type = 'table' and name = 'Messages'"];
    if ([rs next]) {
        if (0 < [rs[@"c"] intValue]) {
            [db close];
            return TRUE;
        }
    }
    
    [db close];
    return FALSE;
}

- (void)createDatabase {
    NSLog(@"createDatabase");
    if (![self checkTable]) {
        NSString* docsdir = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString* dbpath = [docsdir stringByAppendingPathComponent:@"message.db"];
        
        FMDatabase* db = [FMDatabase databaseWithPath:dbpath];
        [db open];
        
        [db executeUpdate:@"create table Messages (MessageID integer primary key autoincrement, Message varchar(64) not null)"];
        
        [db close];
    }
}

- (void)insertMessage:(NSString*)msg {
    NSLog(@"insertMessage");
    NSString* docsdir = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* dbpath = [docsdir stringByAppendingPathComponent:@"message.db"];
    
    FMDatabase* db = [FMDatabase databaseWithPath:dbpath];
    [db open];
    
    [db executeUpdate:@"insert into Messages (Message) values (?)", msg];
    
    [db close];
    
}

- (int)displayAll {
    int count = 0;
    
    NSString* docsdir = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* dbpath = [docsdir stringByAppendingPathComponent:@"message.db"];
    
    FMDatabase* db = [FMDatabase databaseWithPath:dbpath];
    [db open];
    
    FMResultSet* rs = [db executeQuery:@"select MessageID, Message from Messages order by MessageID desc"];
    self.messageList.text = @"";
    while ([rs next]) {
        NSString* str = [NSString stringWithFormat:@"%@%@\n", self.messageList.text, rs[@"Message"]];
        NSLog(@"%@", str);
        self.messageList.text = str;
        count++;
    }
    
    [db close];
    return count;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    
    [self createDatabase];
    [self displayAll];
}

- (IBAction)actionDidEndOnExit:(id)sender {
    [self doButton:sender];
}

- (IBAction)doButton:(id)sender {
    if (![self.message.text isEqualToString:@""]) {
        NSString *msg = self.message.text;
        [self insertMessage:msg];
        [self displayAll];
        NSLog(@"msg: %@", msg);
        self.message.text = @"";
    }
}

@end
