#!/bin/bash
# 测试环境创建脚本
# 创建一个包含多种文件类型的测试目录

echo "创建测试目录结构..."

# 创建测试源目录和子目录
mkdir -p test_src/subdir

# 创建普通文件
echo "This is file1.txt" > test_src/file1.txt
echo "This is file2.txt" > test_src/file2.txt
echo "This is a file in subdir" > test_src/subdir/sub_file.txt

# 设置不同的权限
chmod 755 test_src/file1.txt
chmod 644 test_src/file2.txt
chmod 600 test_src/subdir/sub_file.txt

# 创建符号链接
cd test_src
ln -sf file1.txt link_to_file1
cd ..

echo "测试目录创建完成！"
echo ""
echo "目录结构："
ls -laR test_src
