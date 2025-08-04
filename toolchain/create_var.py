import re
import base64
from pathlib import Path
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad
import argparse

# 修正为32字节的密钥（数下面这行字符正好32个）
KEY = b'32bytes-long-secret-key-12345678'  # 32字符（32字节）
# 修正IV为16字节（数下面字符正好16个）
IV = b'16bytes-iv-strin'  # 16字节（注意去掉最后的g）

def encrypt_string(plaintext: str) -> str:
    cipher = AES.new(KEY, AES.MODE_CBC, IV)
    padded_data = pad(plaintext.encode('utf-8'), AES.block_size)
    ciphertext = cipher.encrypt(padded_data)
    return base64.b64encode(ciphertext).decode('utf-8')

def generate_security_constants(prefix='security'):
    input_file = Path('scan_result_var.txt')
    
    if not input_file.exists():
        print(f"错误：未找到输入文件 {input_file}")
        return

    content = input_file.read_text(encoding='utf-8')
    lines = [line.strip("'\" \n") for line in content.splitlines() if line.strip()]
    
    var_pattern = re.compile(r'^[a-zA-Z_][a-zA-Z0-9_]*$')
    seen = set()
    valid_vars = []
    
    for var in lines:
        cleaned = var.strip("'\" \n")
        if var_pattern.match(cleaned) and cleaned not in seen:
            seen.add(cleaned)
            valid_vars.append((cleaned, encrypt_string(cleaned)))  # 存储变量名和加密值

    if not valid_vars:
        print("警告：输入文件中没有有效的变量名")
        return

    # 生成Dart代码部分修改变量名
    dart_code = [
        'import \'package:encrypt/encrypt.dart\';\n',
        '/// 安全相关字符串常量（运行时解密）',
        'abstract final class Security {',
        '  Security._();\n',
        f'  static final _aesKey = Key.fromUtf8("{KEY.decode()}");',
        f'  static final _iv = IV.fromUtf8("{IV.decode()}");\n',
        '  static String _decrypt(String encrypted) {',
        '    final cipher = AES(_aesKey, mode: AESMode.cbc);',
        '    final encrypter = Encrypter(cipher);',
        '    return encrypter.decrypt64(encrypted, iv: _iv);',
        '  }\n',
        *[f'  static late final String {prefix}_{var} = _decrypt(\'{encrypted}\');' 
          for var, encrypted in valid_vars],
        '}\n'
    ]
    
    # 新增路径构建逻辑
    script_dir = Path(__file__).parent
    target_dir = script_dir / 'pods' / 'modules' / 'lib' / 'base' / 'crypt'
    target_dir.mkdir(parents=True, exist_ok=True)  # 自动创建目录
    output_file = target_dir / 'security.dart'
    
    output_file.write_text('\n'.join(dart_code), encoding='utf-8')
    print(f"生成成功：{output_file.absolute()}")  # 显示完整路径
    print("请执行以下操作：")
    print("1. 在pubspec.yaml添加依赖：encrypt: ^5.0.1")
    print("2. 安装加密库：flutter pub get")

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--prefix', default='security', 
                       help='变量名前缀，默认为security')
    args = parser.parse_args()
    
    generate_security_constants(args.prefix)