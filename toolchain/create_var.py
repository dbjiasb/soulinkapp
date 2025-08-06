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
    script_dir = Path(__file__).parent
    # 新增目标目录定义
    target_dir = script_dir.parent / 'modules/lib/base/crypt'
    target_dir.mkdir(parents=True, exist_ok=True)
    input_file = script_dir / 'scan_result.json'
    
    if not input_file.exists():
        print(f"错误：未找到输入文件 {input_file.absolute()}")
        return

    try:
        import json
        with open(input_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
            variables_data = data.get('variables', {}).get('items', [])
            
            # 获取variables分类的字符串列表
            lines = [item for item in variables_data]
    except json.JSONDecodeError:
        print(f"错误：{input_file} 不是有效的JSON文件")
        return
    except Exception as e:
        print(f"读取JSON文件失败: {str(e)}")
        return

    # 白名单配置（新增）
    allowed_keys = ['variables', 'apis']
    target_classes = {
        'variables': ('Security', 'security'),  # (类名, 文件名)
        'apis': ('Apis', 'apis')
    }

    # 处理白名单中的每个分类（修改）
    for category in allowed_keys:
        category_data = data.get(category, {}).get('items', [])
        valid_vars = []
        seen = set()
        
        # 保留变量名校验逻辑
        for var in category_data:
            cleaned = var.strip()
            if re.match(r'^[a-zA-Z_][a-zA-Z0-9_]*$', cleaned) and cleaned not in seen:
                seen.add(cleaned)
                valid_vars.append((cleaned, encrypt_string(cleaned)))

        if not valid_vars:
            continue

        # 动态生成文件路径（修改）
        output_file = target_dir / f'{target_classes[category][1]}.dart'
        class_name = target_classes[category][0]
        
        # 文件存在处理逻辑（保持原有逻辑）
        existing_vars = set()
        if output_file.exists():
            # 读取现有内容并找到最后一个右括号
            existing_content = output_file.read_text(encoding='utf-8').splitlines()
            # 查找最后一个右括号的行
            closing_brace_index = None
            for i in reversed(range(len(existing_content))):
                line = existing_content[i]
                stripped = line.strip()
                if stripped == '}':
                    closing_brace_index = i
                    break
            # 确定header_content
            if closing_brace_index is not None:
                header_content = existing_content[:closing_brace_index]
            else:
                header_content = existing_content
                print("警告：未找到闭合的右括号，可能导致生成的文件格式错误")
            
            # 解析现有变量
            existing_vars = set(re.findall(r'static late final String (\w+) = decrypt', '\n'.join(existing_content)))  # 修改正则表达式
            
            # 新增过滤逻辑
            valid_vars = [(var, encrypted) for var, encrypted in valid_vars if f'{prefix}_{var}' not in existing_vars]
        else:
            valid_vars = valid_vars  # 新文件无需过滤

        # 移除生成new_vars时的重复过滤条件
        new_vars = [
            f'  static late final String {prefix}_{var} = decrypt(\'{encrypted}\');'
            for var, encrypted in valid_vars  # 直接使用已过滤的valid_vars
        ]
        # 写入文件（保持原有逻辑）
        dart_code = header_content + new_vars + ['}']
        output_file.write_text('\n'.join(dart_code), encoding='utf-8')
        print(f"生成成功：{output_file.absolute()}")

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--prefix', default='security', 
                       help='变量名前缀，默认为security')
    args = parser.parse_args()
    
    generate_security_constants(args.prefix)