//
//  NYLViewController.m
//  NYLBluetooth
//
//  Created by Nieyinlong on 12/09/2019.
//  Copyright (c) 2019 Nieyinlong. All rights reserved.
//

#import "NYLViewController.h"
#import <NYLBluetooth/NYLBuletoothManager.h>
#import <UIView+Toast.h>

@interface NYLViewController ()<UITableViewDelegate, UITableViewDataSource>


@property (nonatomic, strong) NYLBuletoothManager *bluetoothMgr;

@property (weak, nonatomic) IBOutlet UILabel *isOpenStatusLB;
@property (weak, nonatomic) IBOutlet UILabel *connectStatusLB;
//@property (weak, nonatomic) IBOutlet UILabel *peripheralNameLB;
@property (weak, nonatomic) IBOutlet UITableView *tableView;



@end

@implementation NYLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self bluetoothTest];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.layer.borderColor = [UIColor yellowColor].CGColor;
    self.tableView.layer.borderWidth = 2;
}

- (void)bluetoothTest {
    
    _bluetoothMgr = [[NYLBuletoothManager alloc] initWithPeripheralName:@"Nox 902B" readUUID:@"FFE4" writeUUID:@"FFE9" isAutoConnect:YES];
    
    __weak typeof(self)weakSelf = self;
    _bluetoothMgr.bluetoothIsOpenedBlock = ^(BOOL isOpened) {
        weakSelf.isOpenStatusLB.text = [NSString stringWithFormat:@"%@", isOpened == YES ? @"开启" : @"关闭"];
        
        [weakSelf.bluetoothMgr scanPeripherals]; // 扫描设备
        
        if (!isOpened) {
            weakSelf.connectStatusLB.text = @"请开启蓝牙";
        }
        NSLog(@"isOpened = %d", isOpened);
    };
    
    
    // 扫描结果
    _bluetoothMgr.bluetoothScanResultBlock = ^(NSArray<CBPeripheral *> * _Nonnull peripheralArr) {
        [weakSelf.tableView reloadData];
    };
    
    // 指定的外设是否连接成功
    _bluetoothMgr.bluetoothIsConnectedBlock = ^(BOOL isConnected) {
      weakSelf.connectStatusLB.text = [NSString stringWithFormat:@"%@", isConnected == YES ? @"已连接" : @"未连接"];
    };
    
    // 收到数据的回调
    _bluetoothMgr.bluetoothReceivedValueBlock = ^(NSData * _Nonnull value) {
        // TODO:  处理收到的数据, 自己业务处理
    };
    
    // 写数据的回调
    _bluetoothMgr.bluetoothWriteValueBlock = ^(NSError * _Nonnull err, CBPeripheral * _Nonnull peripheral, CBCharacteristic * _Nonnull characteristic) {
        // TODO: 自己业务处理
        if (!err) {
            [weakSelf.view makeToast:@"写入数据成功"];
        }
    };
}



- (IBAction)disConnect:(id)sender {
    [_bluetoothMgr disConnectByManual];
}

- (IBAction)readDataClick:(id)sender {
    // 读数据
    [_bluetoothMgr readDataFromPeripheral];
}

- (IBAction)writeDataClick:(id)sender {
    // 写数据
    [_bluetoothMgr writeDataWithResponse:[@"abc" dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _bluetoothMgr.peripheralArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"111"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:@"111"];
    }
    cell.textLabel.text = _bluetoothMgr.peripheralArr[indexPath.row].name;
    cell.detailTextLabel.text = @"点击进行连接>";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!_bluetoothMgr.isBluetoothOpened) {
        [self.view makeToast:@"请先打开蓝牙"];
        return;
    }
    CBPeripheral *per = _bluetoothMgr.peripheralArr[indexPath.row];
    [_bluetoothMgr connectWithPeripheral:per];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
