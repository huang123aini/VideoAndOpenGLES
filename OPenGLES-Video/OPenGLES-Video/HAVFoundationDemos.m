//
//  HAVFoundationDemos.m
//  OPenGLES-Video
//
//  Created by huangshiping on 2017/6/19.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HAVFoundationDemos.h"

#import "SlowDownVc.h"
#import "MergeVideoVc.h"
#import "ReverseClipVc.h"
#import "RecordVc.h"
#import "DecoderVc.h"


@interface HAVFoundationDemos ()
{
    NSMutableArray *demoArrays;
}
@end

@implementation HAVFoundationDemos


- (void)viewDidLoad
{
    [super viewDidLoad];
    demoArrays = [NSMutableArray new];
    
    NSString* demo1 = @"视频变速";
    NSString* demo2 = @"合并视频并播放";
    NSString* demo3 = @"视屏逆序播放";
    NSString* demo4 = @"视频录制";
    NSString* demo5 = @"视频解码显示";
    
    [demoArrays addObject:demo1];
    [demoArrays addObject:demo2];
    [demoArrays addObject:demo3];
    [demoArrays addObject:demo4];
    [demoArrays addObject:demo5];
    
}

#pragma mark -------TableViewController-------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [demoArrays count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellTableIdentifier = @"CellTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             CellTableIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellTableIdentifier];
    }
    
    cell.textLabel.text = [demoArrays objectAtIndex:indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController* viewC;
    switch (indexPath.row)
    {
        case 0:
        {
            viewC = [SlowDownVc new];
            break;
        }
        case 1:
        {
            viewC = [MergeVideoVc new];
            break;
        }
        case 2:
        {
            viewC = [ReverseClipVc new];
            break;
        }
        case 3:
        {
            viewC = [RecordVc new];
            break;
        }
        case 4:
        {
            viewC = [DecoderVc new];
            break;
        }
      
            
        default:
            break;
    }
    [self presentViewController:viewC animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}@end
