#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *tv;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tv.text = @"";

#define which 2
#if which == 1
    /* Accessing to YouTube WebAPI service. */
    NSString* s = @"http://gdata.youtube.com/feeds/api/videos?max-results=5&format=1&q=rakuten";
#else
    /* Accessing to Rakuten WebAPI service. */
    NSString* s = [NSString stringWithFormat:@"https://app.rakuten.co.jp/services/api/IchibaItem/Search/20130805?format=xml&keyword=%@&genreId=559887&shopCode=rakuten24&applicationId=1057574932367554394",
                   [@"楽天" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
#endif

    NSURL* url = [NSURL URLWithString:s];
    NSURLSession* session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask* task = [session downloadTaskWithURL:url completionHandler:^(NSURL *loc, NSURLResponse *response, NSError *error) {
        NSLog(@"%@", @"here");
        if (error) {
            NSLog(@"%@", error);
            return;
        }
        NSInteger status = [(NSHTTPURLResponse*)response statusCode];
        NSLog(@"response status: %i", status);
        if (status != 200) {
            NSLog(@"%@", @"oh well");
            return;
        }
        NSData* d = [NSData dataWithContentsOfURL:loc];
        NSString* body = [NSString stringWithUTF8String:[d bytes]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tv.text = [NSString stringWithFormat:@"HTTP status: %d\nResponse length: %lld\nbody:\n%@\n", status, [(NSHTTPURLResponse*)response expectedContentLength], body];
            NSLog(@"done");
        });
    }];
    [task resume];
}

@end
