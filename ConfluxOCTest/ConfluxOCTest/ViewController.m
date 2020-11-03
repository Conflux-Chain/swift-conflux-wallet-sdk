//
//  ViewController.m
//  ConfluxOCTest
//
//  Created by 区块链 on 2020/2/18.
//  Copyright © 2020 com.blockchain.dappbirds. All rights reserved.
//

#import "ViewController.h"
#import <ConfluxSDK/ConfluxSDK-Swift.h>

@interface ViewController ()
@property(nonatomic, strong) ConfluxWalletManager * manager;
@property(nonatomic, strong) NSString * privateKeyStr;
@property(nonatomic, strong) NSString * fromAddress;
@property(nonatomic, strong) NSString * toAddress;
@property(nonatomic, strong) NSString * FCContractAddress;
@property(nonatomic, strong) NSString * hasFCAddress;
@property(nonatomic, strong) NSString * fcPrivateKey;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor darkGrayColor];
    // Do any additional setup after loading the view.
    self.privateKeyStr = @"8DC44AC70E9AED9991ED441945F3FEA29AA9015C5ED2629181EE388C502F473C";
    self.fromAddress = @"0x1cAf3Ef2F05BD59350297eE43aE8b31e19478C33";
    self.FCContractAddress = @"0x85b693011c05197f4acbb4246830be8fbd4e904f";
    self.toAddress = @"0x1D9C2FfFeBcAFadb76da7A8d8f5a485368E557Fa";
    self.hasFCAddress = @"0x1E9Df1b31c720C893C651de98caDCA6959015496";
    self.fcPrivateKey = @"dd7e6331983d72b65d0e93849ec531b453a18a898d9e8bb397eba86e7f377036";
    
    // netName: mainnet or testnet
    self.manager = [[ConfluxWalletManager alloc] initWithNetName:@"testnet" chainId:0 nodePoint:@"http://testnet-jsonrpc.conflux-chain.org:12537" isDebug:true];
    
    // 1. create new walet
    // [self createOrImportWalletByMnemonic];
    
    // 2. import wallet by privateKey
    // [self importWalletByPrivate];
    
    // 3. getBalance
//     [self getBalance];
    
    // 4. send cfx
    // [self sendCfxToAddress];
    
    // 5. getGasPrice
    // [self getGasPrice];
    
    // 6. getEstimateGas
    // [self getEstimateGas];
    
    // 7. getTokenBalance
//    [self getTokenBalance: self.hasFCAddress];
//    [self getTokenBalance: self.toAddress];
    
    // 8. get TokenDecimal
//     [self getTokenDecimal];
    
    // 9. send Token
//     [self sendToken];
    
    // 11. signTypedMsg
    // [self signTypedMessage];
    
    // 12. signPersonalMessage
    // [self signPersonalMessage];
    
    // 13. getEpochNumber
    // [self getEpochNumber];
    
    // 14. getPrivateKeyByKeystore
    // [self getPrivateKeyByKeystore];
}

- (void)getPrivateKeyByKeystore {
    NSString *keystoreJson = @"{\"version\":3,\"id\":\"59d9ee74-e94c-4c4d-82a1-af95c7a71d6c\",\"address\":\"be4907a0157a11202f57fdf5d2ceb4021e4f2640\",\"crypto\":{\"ciphertext\":\"42c75c75f676b40379e863ac11dab8e3091abd95a1a8567723d4f79db95946fc\",\"cipherparams\":{\"iv\":\"4960eeb8b125fc2ae95ae5a83917033d\"},\"cipher\":\"aes-128-ctr\",\"kdf\":\"scrypt\",\"kdfparams\":{\"dklen\":32,\"salt\":\"4809a7b96900a47a388251d95451059a25f1fbafd15a76d01855cb3a17e24a3b\",\"n\":8192,\"r\":8,\"p\":1},\"mac\":\"eec19957f96312943eaf125d250134ecee95f6bd3d1b700eed18311abc015411\"}}";
    NSString * pwd = @"chenyujie123";
    NSString *privateStr = [self.manager getPrivateKeyByKeystoreWithKeystoreJson:keystoreJson password:pwd];
    NSLog(@"%@",privateStr);
}


- (void)getEpochNumber {
    [self.manager getEpochNumberWithCompletion:^(BOOL success, NSNumber * epochHeight) {
        if (success) {
            NSLog(@"%@",epochHeight);
        }
    }];
}


- (void)signPersonalMessage {
    NSString *signedMsg = [self.manager signPersonalMessageWithPrivateKeyStr:self.privateKeyStr msg:@"message"];
    NSLog(@"%@",signedMsg);
}

- (void)createOrImportWalletByMnemonic {
    NSArray<NSString *> *mnemonicArr = [self.manager creatNewMnemonicArrWithIsNormal:YES];
    NSLog(@"%@",mnemonicArr);
    
    NSData *seed = [self.manager createSeedWithMnemonicArr: mnemonicArr];
    [self.manager creatWalletByBy:seed completion:^(BOOL success , NSString * address, NSString * privateKetStr) {
        if (success) {
            NSLog(@"%@",address);
            // 0xD139e478D67C76B3ea22f622714910A7A6Fa51C1
            NSLog(@"%@",privateKetStr);
            // 4e6880a7914e9ccc7b197e2b8de6deecd119a06e6b04e4828e1b36f9361d0116
        }
    }];
}

- (void)importWalletByPrivate {
    [self.manager importWalletBy: self.privateKeyStr completion:^(BOOL success , NSString * address, NSString * privateKetStr) {
        if (success) {
            NSLog(@"%@",address);
            NSLog(@"%@",privateKetStr);
        }
    }];
}


- (void)getBalance {
    [self.manager getBalanceWithPrivateKey:self.privateKeyStr completion:^(BOOL success, NSString * balance) {
        if (success) {
            NSLog(@"%@",balance);
        }
    }];
}

- (void)sendCfxToAddress {
    // 3 types of send value
    NSString *testValue1 = [Converter dripToCfxStrWithDrip: 1000000000000000000];
    NSString *test2Value2 = [Converter GdripToCfxStrWithGdrip:10000000000];
    
    NSString * sendValue = @"1";
    int gasPrice = 10;
    int gasLimit = 21000;
    [self.manager sendCfxToAddressWithPrivateKey:self.privateKeyStr toAddress:self.toAddress sendValue:sendValue gasPrice:gasPrice gasLimit:gasLimit completion:^(BOOL success, NSString * txID, NSString * message) {
        if (success) {
            NSLog(@"%@",txID);
        } else {
            NSLog(@"%@", message);
        }
    }];
}

- (void)getGasPrice {
    [self.manager getGasPriceWithCompletion:^(BOOL success, NSNumber * gasprice, NSString * message) {
        if (success) {
            NSLog(@"%@", gasprice);
        }
    }];
}

- (void)getEstimateGas {
    NSString * sendValue = @"1"; // 1 cfx
    NSInteger gasPrice = 10 ;
    [self.manager getEstimateGasFromAddress: self.fromAddress toAddress: self.toAddress sendValue: sendValue gasPrice:gasPrice completion:^(BOOL success, NSString * gasUSed, NSString * storageCollateralized, NSString * message) {
        if (success) {
            NSLog(@"gasUSed: %d", [gasUSed intValue]);
            NSLog(@"storageCollateralized: %d", [storageCollateralized intValue]);
        }
    }];
}

- (void)getTokenBalance: (NSString *)address {
    [self.manager getTokenBalanceWithAddress:address contractAdress:self.FCContractAddress decimal:18 completion:^(BOOL success, NSString * hexBalance, NSString * msg) {
        if (success) {
            NSLog(@"%@", hexBalance);
        }
    }];
}

- (void)getTokenDecimal {
    [self.manager getTokenDecimalWithContractAdress: self.FCContractAddress completion:^(BOOL success, NSString * decimal, NSString * message) {
        if (success) {
            NSLog(@"%@", decimal);
        }
    }];
}


- (void)sendToken {
    [self.manager sendTokenWithPrivateKeyStr:self.fcPrivateKey  contractAddress:self.FCContractAddress toAddress:self.toAddress gasPrice: 30 gasLimit: 300000 sendValue: @"6" decimal: 18 completion:^(BOOL success, NSString * hash, NSString * msg) {
        if (success) {
            NSLog(@"%@", hash);
        } else {
            NSLog(@"%@", msg);
        }
    }];
}

- (void)signTypedMessage {
    NSString * msg = @"{\"types\":{\"EIP712Domain\":[{\"name\":\"name\",\"type\":\"string\"},{\"name\":\"version\",\"type\":\"string\"},{\"name\":\"chainId\",\"type\":\"uint256\"},{\"name\":\"verifyingContract\",\"type\":\"address\"}],\"Order\":[{\"name\":\"userAddress\",\"type\":\"address\"},{\"name\":\"amount\",\"type\":\"uint256\"},{\"name\":\"price\",\"type\":\"uint256\"},{\"name\":\"orderType\",\"type\":\"uint256\"},{\"name\":\"side\",\"type\":\"bool\"},{\"name\":\"expirationTimeSeconds\",\"type\":\"uint256\"},{\"name\":\"salt\",\"type\":\"uint256\"},{\"name\":\"baseAssetAddress\",\"type\":\"address\"},{\"name\":\"quoteAssetAddress\",\"type\":\"address\"}]},\"primaryType\":\"Order\",\"domain\":{\"name\":\"Boomflow\",\"version\":\"1.0\",\"chainId\":2,\"verifyingContract\":\"0xaffb844789ed7cc00fe5e16e51483c210e5fea31\"},\"message\":{\"userAddress\":\"0x5feb31c03d814f8d317aeb78510a6846b2a019c9\",\"amount\":\"1000000000000000000\",\"price\":\"5220000000000000000\",\"orderType\":0,\"side\":false,\"expirationTimeSeconds\":10000000000000,\"salt\":1583911078589,\"baseAssetAddress\":\"0x07ebe89e0e2d7e5e057767cd7316e1fd3fbcf83c\",\"quoteAssetAddress\":\"0xf39aea7786fe2cac54fc342e939681220065615c\"}}";
    [self.manager signTypedMessageWithPrivateKeyStr:@"6e52cefd88956c72000bb41b800afbfcbcd06801972959ff9b547614a1863733" jsonString:msg completion:^(BOOL success, NSString * signedMsg, NSString * msg) {
        if (success) {
            NSLog(@"%@",signedMsg);
        } else {
            NSLog(@"%@", msg);
        }
    }];
}





@end
