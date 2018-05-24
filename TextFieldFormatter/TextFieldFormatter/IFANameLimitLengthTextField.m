//
//  IFANameLimitLengthTextField.m
//  TextFieldFormatter
//
//  Created by fx on 2018/5/24.
//  Copyright © 2018年 fx. All rights reserved.
//

#import "IFANameLimitLengthTextField.h"
#import "MessageInterceptor.h"

@interface IFANameLimitLengthTextField()<UITextFieldDelegate>
{
    MessageInterceptor * delegateInterceptor;
}

@end

@implementation IFANameLimitLengthTextField
/** 拦截器 */
- (id)delegate
{
    return delegateInterceptor.receiver;
}

- (void)setDelegate:(id<UITextFieldDelegate>)delegate
{
    if(delegateInterceptor) {
        super.delegate = nil;
        delegateInterceptor.receiver = delegate;
        super.delegate = (id)delegateInterceptor;
    }else {
        super.delegate = delegate;
    }
}


- (void)dealloc {
    self.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initPro];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self initPro];
}

- (void)initPro{
    /* Message interceptor to intercept scrollView delegate messages */
    delegateInterceptor = [[MessageInterceptor alloc] initWithInterceptedProtocol:@protocol(UITextFieldDelegate)];
    delegateInterceptor.middleMan = self;
    delegateInterceptor.receiver = self.delegate;
    super.delegate = (id)delegateInterceptor;
    
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.keyboardType = UIKeyboardTypeNamePhonePad;
    self.maxLength = 20;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification" object:self];
}

#pragma mark - Notification Method
-(void)textFieldEditChanged:(NSNotification *)obj
{
    UITextField *textField = (UITextField *)obj.object;
    NSString *text = textField.text;
    NSString *lang = [textField.textInputMode primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"]){
        UITextRange *markRange = [textField markedTextRange]; // 获取高亮部分
        UITextPosition *position = markRange.start;
        if (!position){
            if (text.length > _maxLength){
                NSRange rangeIndex = [text rangeOfComposedCharacterSequenceAtIndex:_maxLength];
                if (rangeIndex.length == 1){
                    textField.text = [text substringToIndex:_maxLength];
                }else{ // 多个编码单元
                    NSRange rangeRange = [text rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, _maxLength)];
                    textField.text = [text substringWithRange:rangeRange];
                }
            }
        }
    }else{ // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        if (text.length > _maxLength){
            NSRange rangeIndex = [text rangeOfComposedCharacterSequenceAtIndex:_maxLength];
            if (rangeIndex.length == 1){
                textField.text = [text substringToIndex:_maxLength];
            }else{
                NSRange rangeRange = [text rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, _maxLength)];
                textField.text = [text substringWithRange:rangeRange];
            }
        }
    }
}




@end
