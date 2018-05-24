//
//  IFAFormatterTextField.h
//  TextFieldFormatter
//
//  Created by fx on 2018/5/24.
//  Copyright © 2018年 fx. All rights reserved.
//
/**
 1 输入检测
 2 长度限制
 3 格式控制
 4 X
 5 支持粘贴，选择 */

#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    IFAFormatterTextFieldTypeNumber = 10, // 数字
    IFAFormatterTextFieldTypeASCII,  // 数字，字母
} IFAFormatterTextFieldType;

typedef enum : NSUInteger {
    IFAFormatterTextFieldFormatterTypeNone = 0,
    IFAFormatterTextFieldFormatterTypePhone,  // 手机号
    IFAFormatterTextFieldFormatterTypeIDCard,  // 身份证
    IFAFormatterTextFieldFormatterTypeBankCard, // 银行卡
} IFAFormatterTextFieldFormatterType;
@interface IFAFormatterTextField : UITextField
/** 必选属性 */
/** 格式类型 */
@property (nonatomic,assign)IFAFormatterTextFieldFormatterType formaterType;

/** 非必选参数 */
/** 最大长度 */
@property (nonatomic,assign)IFAFormatterTextFieldType type;
@property (nonatomic,assign)NSInteger maxLength;


- (NSString *)textWithSpace:(BOOL)space;
@end



@interface UITextField (fx_category)
- (NSRange)selectedRange;
- (void)setSelectedRange:(NSRange) range;
@end

@interface UIImage (fx_catogory)
+ (UIImage *)imageWithColor:(UIColor *)color;
@end


