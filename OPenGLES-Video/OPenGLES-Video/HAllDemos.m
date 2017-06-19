//
//  HAllDemos.m
//  OPenGLES-Video
//
//  Created by huangshiping on 2017/6/13.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

/**
 *HOPenGLESDemos:OPenGLES例子
 *HRealTimePDemos:实时视频处理例子
 */

#import "HAllDemos.h"
#import "HOPenGLESDemos.h"
#import "HRealTimePDemos.h"
#import "HAVFoundationDemos.h"



@interface HAllDemos ()
{
    NSMutableArray *demoArrays;
}
@end

@implementation HAllDemos


- (void)viewDidLoad
{
    [super viewDidLoad];
    demoArrays = [NSMutableArray new];
    
    NSString* demo1 = @"OPenGLES例子";
    NSString* demo2 = @"实时视频处理例子";
    NSString* demo3 = @"AVFoundation例子";
    
    [demoArrays addObject:demo1];
    [demoArrays addObject:demo2];
    [demoArrays addObject:demo3];
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
            viewC = [HOPenGLESDemos new];
            break;
        }
        case 1:
        {
            viewC = [HRealTimePDemos new];
            break;
        }
        case 2:
        {
            viewC = [HAVFoundationDemos new];
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
