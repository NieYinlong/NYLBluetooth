//
//  NYLBuletoothManager.h
//  NYLBluetooth_Example
//
//  Created by 聂银龙 on 2019/12/9.
//  Copyright © 2019 Nieyinlong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface NYLBuletoothManager : NSObject

/// 蓝牙是否开启
@property (nonatomic, assign, readonly) BOOL isBluetoothOpened;

/// 设备是否连接
@property (nonatomic, assign, readonly) BOOL isConnected;

/// 扫描到的外设数组
@property (nonatomic, strong, readonly) NSMutableArray <CBPeripheral *>* peripheralArr;


/* ------------------------------- block回调 ----------------------------------- */
/// 蓝牙是否开启, 实时回调
@property (nonatomic, copy) void(^bluetoothIsOpenedBlock)(BOOL isOpened);

/// 蓝牙扫描到的外设, 实时回调
@property (nonatomic, copy) void(^bluetoothScanResultBlock)(NSArray <CBPeripheral *>* peripheralArr);

/// 设备是否连接成功, 实时回调
@property (nonatomic, copy) void(^bluetoothIsConnectedBlock)(BOOL isConnected);

/// 收到外设发来的数据回调, 实时回调
@property (nonatomic, copy) void(^bluetoothReceivedValueBlock)(NSData *value);

/// 写入数据是否成功的回调
@property (nonatomic, copy) void(^bluetoothWriteValueBlock)(NSError *err, CBPeripheral *peripheral, CBCharacteristic *characteristic);
/* ------------------------------------------------------------------ */



/// 初始化蓝牙
/// @param name 外设名称 (可以是前缀, 一般同一种设备前缀是一样的, 后面有区分)
/// @param readUUID 写数据的标识
/// @param writeUUID 读取数据的标识
/// @param isAutoConnect 是否根据指定的设备名字主动连接(默认NO)
- (instancetype)initWithPeripheralName:(NSString *)name readUUID:(NSString *)readUUID writeUUID:(NSString *)writeUUID isAutoConnect:(BOOL)isAutoConnect;

/// 扫描全部外设
- (void)scanPeripherals;

/// 根据serviceUUIDs和options扫描外设
/// @param serviceUUIDs 服务UUIDs (可为空)
/// @param options   An optional dictionary specifying options for the scan. (可为空)
- (void)scanForPeripheralsWithServices:(nullable NSArray<CBUUID *> *)serviceUUIDs options:(nullable NSDictionary<NSString *, id> *)options;

/// 连接外设
- (void)connect;

/// 连接外设
/// @param peripheral 根据指定的外设连接
- (void)connectWithPeripheral:(nonnull CBPeripheral *)peripheral;

/// 主动断开连接
- (void)disConnectByManual;

/// 写数据 (无回调)
- (void)writeDataWithoutResponse:(NSData *)data;

/// 写数据 (有回调)
- (void)writeDataWithResponse:(NSData *)data;

// 读数据
- (void)readDataFromPeripheral;

@end

NS_ASSUME_NONNULL_END
