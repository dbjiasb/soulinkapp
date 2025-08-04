import argparse
import re
import shutil
from pathlib import Path

def replace_security_strings(enable_backup=False):
    # 读取所有需要替换的变量名
    with open('scan_result_var.txt', 'r', encoding='utf-8') as f:
        security_strings = [line.strip().strip("'\"") for line in f.readlines()]
    
    # 按长度降序排序，避免部分匹配
    security_strings.sort(key=lambda x: -len(x))
    
    # 构建正则表达式模式
    patterns = [
        (re.compile(rf'''(['"])({re.escape(s)})\1'''), 
         f'Security.security_{s}')
        for s in security_strings
    ]

    # 配置工程目录（根据实际项目结构调整）
    project_dir = Path(__file__).parent.parent / "modules"
    total_replacements = 0
    
    # 需要排除的文件列表
    excluded_files = {'security.dart', 'constants.dart', 'es_helper.dart'}
    
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
            import_statement = "import 'package:modules/base/crypt/security.dart';\n"
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