import os
import hashlib

def md5_rename_and_generate_dart():
    # 定义路径
    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    img_dir = os.path.join(project_root, 'modules', 'assets', 'soulink')
    dart_file = os.path.join(project_root, 'modules', 'lib', 'base', 'assets', 'image_path.dart')

    # 创建dart文件类结构
    class_header = '''abstract final class ImagePath {
'''
    class_footer = '}'

    # 读取已有dart文件内容
    existing_content = []
    class_closing_index = -1
    if os.path.exists(dart_file):
        with open(dart_file, 'r') as f:
            existing_content = f.readlines()
            # 查找最后一个右括号位置
            class_closing_index = next((i for i in reversed(range(len(existing_content))) if '}' in existing_content[i]), -1)

    # 遍历图片文件
    for filename in os.listdir(img_dir):
        if filename.lower().endswith(('.png', '.jpg', '.jpeg', '.webp', '.svga')):

            # 重命名文件
            name, ext = os.path.splitext(filename)

            if len(name) == 32 and '_' not in name:
                print(f'Skipped processed file: {filename}')
                continue
            # 计算MD5
            with open(os.path.join(img_dir, filename), 'rb') as f:
                md5_hash = hashlib.md5(f.read()).hexdigest()

            # 修改重命名逻辑
            new_name = f'{md5_hash}{ext}'
            os.rename(os.path.join(img_dir, filename),
                      os.path.join(img_dir, new_name))

            # 修改Dart常量生成逻辑
            # 新增常量行
            dart_line = f'  static const String {name} = \'packages/modules/assets/soulink/{new_name}\';\n'

            # 插入到类结束符前
            if dart_line not in existing_content:
                if class_closing_index != -1:
                    existing_content.insert(class_closing_index, dart_line)
                else:
                    existing_content.append(dart_line)

    # 写入dart文件
    with open(dart_file, 'w') as f:
        if class_closing_index == -1:  # 新文件
            f.write(class_header)
        f.writelines(existing_content)
        # 确保类闭合
        if not existing_content[-1].strip().endswith('}'):
            f.write(class_footer)

if __name__ == '__main__':
    md5_rename_and_generate_dart()