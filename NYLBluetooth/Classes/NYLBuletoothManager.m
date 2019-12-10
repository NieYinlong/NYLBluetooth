//
//  NYLBuletoothManager.m
//  NYLBluetooth_Example
//
//  Created by 聂银龙 on 2019/12/9.
//  Copyright © 2019 Nieyinlong. All rights reserved.
//

#import "NYLBuletoothManager.h"


@interface NYLBuletoothManager()<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong, nullable) NSArray<CBUUID *> *serviceUUIDs;

@property (nonatomic, copy) NSString  *peripheralName;
@property (nonatomic, strong) NSMutableArray <CBPeripheral *>* peripheralArr;
@property (nonatomic, copy) NSString *readUUID;
@property (nonatomic, copy) NSString *writeUUID;
/// 是否自动连接
@property (nonatomic, assign) BOOL isAutoConnect;
/// 写数据特征
@property (nonatomic, strong)  CBCharacteristic *writeCharacteristic;
/// 读数据特征
@property (nonatomic, strong)  CBCharacteristic *readCharacteristic;
// ------- //


@end

@implementation NYLBuletoothManager

- (instancetype)init {
    return [self initWithQueue:nil];
}

- (instancetype)initWithQueue:(dispatch_queue_t)queue {
    if (self = [super init]) {
        [self initBluetoothWithQueue:queue];
    }
    return self;
}

- (instancetype)initWithPeripheralName:(NSString *)name readUUID:(NSString *)readUUID writeUUID:(NSString *)writeUUID isAutoConnect:(BOOL)isAutoConnect {
    _peripheralName = name;
    _readUUID = readUUID;
    _writeUUID = writeUUID;
    _isAutoConnect = isAutoConnect;
    return [self initWithQueue:nil];
}

- (void)initBluetoothWithQueue:(dispatch_queue_t)queue {
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:queue];
}

- (void)scanPeripherals {
    [self scanForPeripheralsWithServices:nil options:nil];
}

- (void)scanForPeripheralsWithServices:(nullable NSArray<CBUUID *> *)serviceUUIDs options:(nullable NSDictionary<NSString *, id> *)options {
    [self stopScanPeripherals];
    self.serviceUUIDs = serviceUUIDs;
    [_centralManager scanForPeripheralsWithServices:serviceUUIDs options:options];
}

- (void)stopScanPeripherals{
    [_centralManager stopScan];
}

- (void)connect {
    if (self.peripheral) {
        [self.centralManager connectPeripheral:self.peripheral options:nil];
    }
}

- (void)connectWithPeripheral:(nonnull CBPeripheral *)peripheral {
    self.peripheral = peripheral;
    [self.centralManager connectPeripheral:peripheral options:nil];
}

- (void)disConnectByManual {
    if (self.peripheral) {
        [self.centralManager cancelPeripheralConnection:self.peripheral];
    }
    _isConnected = NO;
    self.peripheral = nil;
}




- (void)writeDataWithoutResponse:(NSData *)data {
    if (self.peripheral && self.readCharacteristic) {
        [self.peripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
    }
}

- (void)writeDataWithResponse:(NSData *)data {
    if (self.peripheral && self.readCharacteristic) {
        [self.peripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

// 读数据
- (void)readDataFromPeripheral {
    if (self.peripheral && self.readCharacteristic) {
        [self.peripheral readValueForCharacteristic:self.readCharacteristic];
    }
}

#pragma mark - CBCentralManagerDelegate

/// 蓝牙开启状态更新
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBCentralManagerStatePoweredOn) {
        // 蓝牙已经开启
        _isBluetoothOpened = YES;
    }
    else {
        _isBluetoothOpened = NO;
    }
    
    if (self.bluetoothIsOpenedBlock) {
        self.bluetoothIsOpenedBlock(_isBluetoothOpened);
    }
}

/**
 扫描到外设
 @param central 管理者
 @param peripheral 外设
 @param advertisementData 外设相关数据表示
 @param RSSI 信号强度
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(nonnull CBPeripheral *)peripheral advertisementData:(nonnull NSDictionary<NSString *,id> *)advertisementData RSSI:(nonnull NSNumber *)RSSI
{
    
    if ([peripheral.name hasPrefix:self.peripheralName]) {
        __block BOOL isExist = NO;
        // 遍历数组, 防止重复add
        [self.peripheralArr enumerateObjectsUsingBlock:^(CBPeripheral *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.name isEqualToString:peripheral.name]) {
                isExist = YES;
                *stop = YES;
            }
        }];
        if (!isExist) {
            [self.peripheralArr addObject:peripheral];
        }
        
        if (self.bluetoothScanResultBlock) {
            self.bluetoothScanResultBlock(self.peripheralArr);
        }
        // 处理是否自动连接
        if (_isAutoConnect) {
            [self stopScanPeripherals];
            [self connectWithPeripheral:peripheral];
        }
    }
}
/// 连接到外设之后的回调
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(nonnull CBPeripheral *)peripheral {
    self.peripheral = peripheral; // 引用
    self.peripheral.delegate = self;
    [peripheral discoverServices:self.serviceUUIDs];
    [self stopScanPeripherals];
    _isConnected = YES;
    if (self.bluetoothIsConnectedBlock) {
        self.bluetoothIsConnectedBlock(YES);
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    _isConnected = NO;
    NSLog(@"didFailToConnectPeripheral : %@, error : %@", peripheral.name, [error description]);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"didDisconnectPeripheral : %@, error : %@", peripheral.name, [error description]);
    
    if (self.peripheral) {
        [self.centralManager cancelPeripheralConnection:self.peripheral];
    }
    _isConnected = NO;
    self.peripheral = nil;
    if (self.bluetoothIsConnectedBlock) {
        self.bluetoothIsConnectedBlock(NO);
    }
}

#pragma mark - CBPeripheralDelegate

/// 发现外设里面的服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) return;
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}


//扫描到特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)return;
    NSLog(@"service.characteristics = %@",service.characteristics);
    // 获取Characteristic的值
    for (CBCharacteristic *characteristic in service.characteristics){
        NSString *chaUUid = characteristic.UUID.UUIDString;
        if ([chaUUid hasPrefix:_readUUID]) { // 某外设读数据的uuid
            [peripheral readValueForCharacteristic:characteristic];
            // 我订阅
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            self.readCharacteristic = characteristic;
        }
        
        if ([chaUUid isEqualToString:_writeUUID]) { // 某外设写数据的uuid
            self.writeCharacteristic = characteristic; // 写数据的特征
        }
    }
}

/// 获取外设发来的数据，不论是read和notify,获取数据都是从这个方法中读取。
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) return;
    NSData *data = characteristic.value;
    if (self.bluetoothReceivedValueBlock) {
        self.bluetoothReceivedValueBlock(data);
    }
}

/// 写数据的回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"write failed : %@", [error description]);
    } else {
        NSLog(@"数据写入成功");
    }
    if (self.bluetoothWriteValueBlock) {
        self.bluetoothWriteValueBlock(error, peripheral, characteristic);
    }
}


- (NSMutableArray *)peripheralArr {
    if (!_peripheralArr) {
        _peripheralArr = [NSMutableArray array];
    }
    return _peripheralArr;
}

@end

