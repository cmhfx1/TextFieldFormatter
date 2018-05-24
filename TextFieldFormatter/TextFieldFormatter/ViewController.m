//
//  ViewController.m
//  TextFieldFormatter
//
//  Created by fx on 2018/5/24.
//  Copyright © 2018年 fx. All rights reserved.
//

#import "ViewController.h"
#import "IFAFormatterTextField.h"
#import "IFANameLimitLengthTextField.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    IFAFormatterTextField *_textBankNumber = [[IFAFormatterTextField alloc] initWithFrame:CGRectMake(50, 100, 250, 30)];
    _textBankNumber.backgroundColor = [UIColor whiteColor];
    _textBankNumber.borderStyle = UITextBorderStyleRoundedRect;
    _textBankNumber.placeholder = @"请输入~~";
    _textBankNumber.formaterType = IFAFormatterTextFieldFormatterTypePhone;
    [self.view addSubview:_textBankNumber];
    
    
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(50, 160, 250, 30)];
    tf.backgroundColor = [UIColor whiteColor];
    tf.borderStyle = UITextBorderStyleRoundedRect;
    tf.placeholder = @"请输入~~";
    tf.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:tf];
    
    
    IFANameLimitLengthTextField *namef = [[IFANameLimitLengthTextField alloc] initWithFrame:CGRectMake(50, 220, 250, 30)];
    namef.backgroundColor = [UIColor whiteColor];
    namef.borderStyle = UITextBorderStyleRoundedRect;
    namef.placeholder = @"请输入~~";
    namef.maxLength = 10;
    [self.view addSubview:namef];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


@end
