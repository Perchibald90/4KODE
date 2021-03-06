//
//  ViewController.m
//  4KODE
//
//  Created by Ruslan on 7/24/14.
//  Copyright (c) 2014 Ruslan. All rights reserved.
//

#import "ViewController.h"
#import "InstagramKit.h"
#import "MBProgressHUD.h"
#import "CollageComposer.h"

@interface ViewController () <UITextFieldDelegate, UIPrintInteractionControllerDelegate>{
    float maxX;
    float maxY;

}

@property (atomic) InstagramEngine *engine;
@property (nonatomic, strong) NSArray *media;
@property (nonatomic, strong) NSArray *images;

@property (nonatomic, weak) IBOutlet UIScrollView *content;
@property (nonatomic, weak) IBOutlet UIImageView *collage;
@property (nonatomic, weak) IBOutlet UITextField *usernameTextField;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *print;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.hud hide:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = @"Loading";
    self.engine = [InstagramEngine sharedEngine];
    self.collage.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)viewDidAppear:(BOOL)animated {}

-(void)setMedia:(NSArray *)media {
    _media = media;
    if (media.count == 0)
        return;
    [self showLoadingProgresHud];
    self.hud.labelText = @"Images downloading...";
    __block NSUInteger mediaSize = _media.count;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSMutableArray *temp = [NSMutableArray new];
        for (int i = 0; i < mediaSize; i++) {
            InstagramMedia *m = _media[i];
            [temp addObject:[UIImage imageWithData:[NSData dataWithContentsOfURL:m.standardResolutionImageURL]]];
            self.hud.labelText = [NSString stringWithFormat:@"Images downloading %u/%u ", i, mediaSize];
        }
        self.images = temp;
        [self hideLoadingProgressHud];
    });
}

-(void)setImages:(NSMutableArray *)images {
    _images = images;
    self.hud.labelText = @"Collage creating...";
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *collageImage = [CollageComposer getCollageForImages:_images];
        [self.collage setImage:collageImage];

    });
}

- (IBAction)fullSize:(id)sender {
    self.content.contentSize =CGSizeMake(self.collage.image.size.width, self.collage.image.size.height);
    self.collage.frame = CGRectMake(0., 0., self.collage.image.size.width, self.collage.image.size.height);
}

- (IBAction)fittedSize:(id)sender {
    self.content.contentSize =CGSizeMake(self.content.frame.size.width, self.content.frame.size.height);
    self.collage.frame = CGRectMake(0., 0., self.content.frame.size.width, self.content.frame.size.height);
}

- (void)hideLoadingProgressHud {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.hud hide:YES];
    });
}

- (void)showLoadingProgresHud {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.hud show:YES];
    });
}
- (IBAction)giveMeCollage:(id)sender {
    if (self.usernameTextField.text.length > 0) {
        [self showLoadingProgresHud];
        self.hud.labelText = [NSString stringWithFormat:@"Search %@", self.usernameTextField.text];
        [self.engine searchUsersWithString:self.usernameTextField.text withSuccess:^(NSArray *users, InstagramPaginationInfo *paginationInfo) {
            InstagramUser *user = users.firstObject;
            [self.engine getMediaForUser:user.Id withSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
                self.media = media;
            } failure:^(NSError *error) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@ user did not uploaded any photos", self.usernameTextField.text] delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles: nil] show];
                [self hideLoadingProgressHud];
            }];
        } failure:^(NSError *error) {
            [self hideLoadingProgressHud];
        }];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Sorry, you should provide username." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)printContent:(id)sender {
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    if  (pic && [UIPrintInteractionController canPrintData: UIImagePNGRepresentation(self.collage.image)] ) {
        pic.delegate = self;

        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        printInfo.outputType = UIPrintInfoOutputPhoto;
        printInfo.jobName = @"Collage printing";
        printInfo.duplex = UIPrintInfoDuplexLongEdge;
        pic.printInfo = printInfo;
        pic.showsPageRange = YES;
        pic.printingItem = self.collage.image;  

        void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
        ^(UIPrintInteractionController *pic, BOOL completed, NSError *error) {
            if (!completed && error)
                NSLog(@"FAILED! due to error in domain %@ with error code %u",
                      error.domain, error.code);
        };
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [pic presentFromBarButtonItem:self.print animated:YES
                        completionHandler:completionHandler];
        } else {
            [pic presentAnimated:YES completionHandler:completionHandler];
        }
    }
}

@end
