import argparse
import re
import shutil
from pathlib import Path
import json

# 白名单配置（新增）
REPLACE_CONFIG = {
    'variables': {
        'pattern': r"(['\"])({})\\1",
        'replacement': 'Security.security_{}',
        'import': 'security'
    },
    'apis': {
        'pattern': r"(ApiRequest\()\s*['\"]({})['\"]\s*(?=,|\s*\))",
        'replacement': r'\1Apis.security_{}',
        'import': 'apis'
    }
}

def replace_security_strings(enable_backup=False):
    script_dir = Path(__file__).parent
    
    # 读取JSON文件
    input_file = script_dir / 'scan_result.json'
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # 从variables.items提取加密字符串
    # security_strings = [
    #     item.strip("'\"")  # 直接处理字符串元素
    #     for item in data['variables']['items']  # 原始字符串数组
    # ]

    # # 按长度降序排序
    # security_strings.sort(key=lambda x: -len(x))
    
    # 构建正则表达式模式
    # 处理白名单键值（修改）
    patterns = []
    import_statements = set()

    for key in ['variables', 'apis']:  # 白名单控制
        config = REPLACE_CONFIG[key]
        items = data[key]['items']

        # 生成对应规则
        for s in sorted(items, key=lambda x: -len(x)):
            patterns.append((
                re.compile(config['pattern'].format(re.escape(s))),
                config['replacement'].format(s)
            ))
        import_statements.add(f"import 'package:modules/base/crypt/{config['import']}.dart';")

    # 配置工程目录（根据实际项目结构调整）
    project_dir = Path(__file__).parent.parent / "modules"
    total_replacements = 0
    
    # 需要排除的文件列表
    excluded_files = {'security.dart'}
    
    # 遍历所有Dart文件
    for dart_file in project_dir.rglob('*.dart'):
        # 跳过需要忽略的文件
        if dart_file.name in excluded_files:
            continue
            
        content = dart_file.read_text(encoding='utf-8')
        original_content = content
        file_replacements = 0
        
        # 新增：检查是否需要添加导入语句
        need_import = False
        
        # 执行所有替换规则
        for pattern, replacement in patterns:
            content, count = pattern.subn(replacement, content)
            file_replacements += count
            if count > 0:
                need_import = True
        
        # 新增：在修改过的文件中添加导入语句
        if need_import:
            import_statement = f"import 'package:modules/base/crypt/{config['import']}.dart';\n"
            # 避免重复导入
            if import_statement not in content:
                content = import_statement + content
        
        if file_replacements > 0:
            # 仅在启用备份时创建备份
            if enable_backup:
                backup_path = dart_file.with_suffix(f'{dart_file.suffix}.bak')
                if not backup_path.exists():
                    shutil.copy2(dart_file, backup_path)
            
            # 写入修改后的内容（无论是否备份都执行）
            dart_file.write_text(content, encoding='utf-8')
            print(f'✅ 已更新 {dart_file} ({file_replacements} 处替换)')
            total_replacements += file_replacements

    print(f'\n替换完成！共在 {total_replacements} 处完成替换')
    print('安全提示：请检查所有.bak备份文件后手动删除')

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--backup', action='store_true',
                       help='启用文件备份功能（生成.bak文件）')
    args = parser.parse_args()
    
    replace_security_strings(args.backup)