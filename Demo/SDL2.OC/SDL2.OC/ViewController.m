//
//  ViewController.m
//  SDL2.OC
//
//  Created by Dream on 2021/7/10.
//

#import "ViewController.h"

#import <SDL2/SDL2.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    SDL_Init(SDL_INIT_AUDIO);
    SDL_version version;
    NSLog(@"%hhu.%hhu.%hhu", version.major, version.minor, version.patch);
    SDL_GetVersion(&version);
    NSLog(@"%hhu.%hhu.%hhu", version.major, version.minor, version.patch);
}


@end