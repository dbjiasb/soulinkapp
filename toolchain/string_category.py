import json
import re
from pathlib import Path
import argparse

def extract_dart_strings():
    # 原路径（已失效）
    # root_dir = Path("pods/modules")
    
    # 新路径配置
    root_dir = Path(__file__).parent.parent / "modules"
    
    # 添加路径验证
    if not root_dir.exists():
        raise FileNotFoundError(f"Modules目录未找到: {root_dir}")
    unique_strings = set()
    excluded_files = {"security.dart"}
    
    # 优化后的正则表达式（移除三引号匹配，简化匹配逻辑）
    string_pattern = re.compile(
        r'''r?(["'])((?:\\\1|.)*?)\1''',
        re.DOTALL
    )
    
    # 新增三个文件句柄（移动到过滤条件之后）
    output_dir = Path(__file__).parent
    
    # 修改所有文件打开语句
    # asset_file = open(output_dir/'scan_result_assets.txt', 'w', encoding='utf-8')
    # text_file = open(output_dir/'scan_result_product_text.txt', 'w', encoding='utf-8')
    # code_file = open(output_dir/'scan_result_other.txt', 'w', encoding='utf-8')
    
    # 新增API请求正则表达式
    api_request_pattern = re.compile(
        r'ApiRequest\(\s*([\'"])(.*?)\1',
        re.DOTALL
    )
    
    for file_path in root_dir.rglob("*.dart"):
        if file_path.name in excluded_files:
            continue
        
        with open(file_path, "r", encoding="utf-8") as f:
            # 新增注释行过滤逻辑
            content_lines = []
            for line in f:
                stripped_line = line.lstrip()  # 移除行首空白
                if not stripped_line.startswith('//'):  # 过滤以//开头的行
                    content_lines.append(line)
            content = ''.join(content_lines)
            
            filtered_content = re.sub(r'debugPrint\(.*?\);', '', content)
            matches = string_pattern.findall(filtered_content)
    
            # 新增API请求扫描
            api_matches = api_request_pattern.findall(content)
            for quote, api_str in api_matches:
                stripped_api = api_str.strip()
                if len(stripped_api) > 0:
                    unique_strings.add(('', stripped_api))  # 特殊标记API字符串

            if matches:
                for _, (quote, text) in enumerate(matches, 1):  # 移除文件头打印
                    stripped = text.strip()
                    if len(stripped) > 1 \
                       and not stripped.isspace() \
                       and not (text.lstrip().startswith(('package:', 'import')) or
                               stripped.startswith(('../'))) \
                       and not ('$' in stripped) \
                       and not (stripped.startswith('dart') or
                               stripped.endswith('.dart')):
                        unique_strings.add((quote, stripped))  # 存储元组用于分类

    # 删除原有的文件初始化操作
    category_map = {
        'assets': set(),
        'product_text': set(),
        'links': set(),
        'routes': set(),
        'apis': set(),
        'variables': set(),
        'other': set()
    }

    # 在最终分类部分添加变量名正则匹配
    dart_var_pattern = re.compile(r'^[a-zA-Z_][a-zA-Z0-9_]*$')  # 新增变量名匹配规则

    # 在最终分类部分修改条件判断
    # with open(output_dir/'scan_result_assets.txt', 'w', encoding='utf-8') as asset_file, \
    #      open(output_dir/'scan_result_product_text.txt', 'w', encoding='utf-8') as text_file, \
    #      open(output_dir/'scan_result_link.txt', 'w', encoding='utf-8') as link_file, \
    #      open(output_dir/'scan_result_route.txt', 'w', encoding='utf-8') as route_file, \
    #      open(output_dir/'scan_result_api.txt', 'w', encoding='utf-8') as api_file, \
    #      open(output_dir/'scan_result_var.txt', 'w', encoding='utf-8') as var_file, \
    #      open(output_dir/'scan_result_other.txt', 'w', encoding='utf-8') as code_file:

        # 收集所有API字符串
    api_strings = {s for quote, s in unique_strings if quote == ''}
        
        # 写入API文件
        # for s in sorted(api_strings):
        #     api_file.write(f"'{s}'\n")
        
        # 处理其他字符串（排除API字符串）
    for quote, s in sorted(unique_strings):
            if quote == '':
                continue
            if s in api_strings:
                category_map['apis'].add(s)
                continue
            if s.startswith("packages") or s.lower().endswith(('.png', '.webp')):
                # 修改后直接存储原始字符串
                category_map['assets'].add(s)
            elif ' ' in s or s.endswith('...'):
                category_map['product_text'].add(s)
            elif '://' in s:
                category_map['links'].add(s)
            elif s.startswith('/'):
                category_map['routes'].add(s)
            else:
                if dart_var_pattern.match(s):
                    category_map['variables'].add(s)
                else:
                    category_map['other'].add(s)

    # 最终JSON输出
    output_dir = Path(__file__).parent
    with open(output_dir/'scan_result.json', 'w', encoding='utf-8') as f:
        json_data = {
            category: {
                'count': len(values),
                'items': sorted(list(values))
            } for category, values in category_map.items()
        }
        json.dump(json_data, f, indent=2, ensure_ascii=False)

    print("结果已保存至 scan_result.json")

if __name__ == "__main__":
    extract_dart_strings()
    print("结果已分类保存至 scan_result_*.txt 文件")
    print("结果已保存至 scan_strings_result.txt")