#include <iostream>
#include <cstring>
#include <cstdlib>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <dirent.h>
#include <errno.h>

constexpr size_t BUFFER_SIZE = 4096;

std::string join_path(const std::string& dir, const std::string& name) {
    if (dir.empty()) return name;
    return (dir.back() == '/') ? dir + name : dir + "/" + name;
}

int copy_file(const std::string& src, const std::string& dst) {
    struct stat src_stat;
    if (lstat(src.c_str(), &src_stat) == -1) {
        std::cerr << "Error: lstat failed " << src << ": " << strerror(errno) << std::endl;
        return -1;
    }

    int src_fd = open(src.c_str(), O_RDONLY);
    if (src_fd == -1) {
        std::cerr << "Error: open source failed " << src << ": " << strerror(errno) << std::endl;
        return -1;
    }

    // 创建目标文件，权限与源文件保持一致
    int dst_fd = open(dst.c_str(), O_WRONLY | O_CREAT | O_TRUNC, src_stat.st_mode);
    if (dst_fd == -1) {
        std::cerr << "Error: create dest failed " << dst << ": " << strerror(errno) << std::endl;
        close(src_fd);
        return -1;
    }

    char buffer[BUFFER_SIZE];
    ssize_t bytes_read;
    
    while ((bytes_read = read(src_fd, buffer, BUFFER_SIZE)) > 0) {
        if (write(dst_fd, buffer, bytes_read) != bytes_read) {
            std::cerr << "Error: write failed " << dst << ": " << strerror(errno) << std::endl;
            close(src_fd);
            close(dst_fd);
            return -1;
        }
    }

    if (bytes_read == -1) {
        std::cerr << "Error: read failed " << src << ": " << strerror(errno) << std::endl;
    }

    close(src_fd);
    close(dst_fd);
    
    // 再次显式设置权限（避免 umask 影响 open 创建的文件权限）
    chmod(dst.c_str(), src_stat.st_mode);

    return (bytes_read == -1) ? -1 : 0;
}

int copy_symlink(const std::string& src, const std::string& dst) {
    char link_target[PATH_MAX];
    // 读取符号链接本身的内容，而非其指向的目标文件
    ssize_t len = readlink(src.c_str(), link_target, sizeof(link_target) - 1);
    
    if (len == -1) {
        std::cerr << "Error: readlink failed " << src << ": " << strerror(errno) << std::endl;
        return -1;
    }
    
    link_target[len] = '\0';

    // 创建指向相同目标的新符号链接
    if (symlink(link_target, dst.c_str()) == -1) {
        std::cerr << "Error: symlink failed " << dst << ": " << strerror(errno) << std::endl;
        return -1;
    }

    return 0;
}

// 前向声明，用于递归调用
int copy_directory(const std::string& src, const std::string& dst);

int copy_entry(const std::string& src, const std::string& dst, const struct stat& stat_buf) {
    if (S_ISREG(stat_buf.st_mode)) {
        std::cout << "Copying file: " << src << std::endl;
        return copy_file(src, dst);
    } else if (S_ISDIR(stat_buf.st_mode)) {
        std::cout << "Copying dir:  " << src << std::endl;
        return copy_directory(src, dst);
    } else if (S_ISLNK(stat_buf.st_mode)) {
        std::cout << "Copying link: " << src << std::endl;
        return copy_symlink(src, dst);
    }
    
    std::cerr << "Skipping: " << src << " (Unsupported type)" << std::endl;
    return 0;
}

int copy_directory(const std::string& src, const std::string& dst) {
    struct stat src_stat;
    if (lstat(src.c_str(), &src_stat) == -1) {
        std::cerr << "Error: lstat dir failed " << src << ": " << strerror(errno) << std::endl;
        return -1;
    }

    // 创建目标目录
    if (mkdir(dst.c_str(), src_stat.st_mode) == -1 && errno != EEXIST) {
        std::cerr << "Error: mkdir failed " << dst << ": " << strerror(errno) << std::endl;
        return -1;
    }

    DIR* dir = opendir(src.c_str());
    if (!dir) {
        std::cerr << "Error: opendir failed " << src << ": " << strerror(errno) << std::endl;
        return -1;
    }

    int final_result = 0;
    struct dirent* entry;

    while ((entry = readdir(dir)) != nullptr) {
        // 跳过 "." 和 ".." 以避免无限递归
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) {
            continue;
        }

        std::string src_path = join_path(src, entry->d_name);
        std::string dst_path = join_path(dst, entry->d_name);

        struct stat entry_stat;
        if (lstat(src_path.c_str(), &entry_stat) == -1) {
            std::cerr << "Error: lstat entry failed " << src_path << ": " << strerror(errno) << std::endl;
            final_result = -1;
            continue;
        }

        if (copy_entry(src_path, dst_path, entry_stat) == -1) {
            final_result = -1;
        }
    }

    closedir(dir);
    return final_result;
}

int main(int argc, char* argv[]) {
    if (argc != 3) {
        std::cerr << "Usage: " << argv[0] << " <source_dir> <dest_dir>" << std::endl;
        return 1;
    }

    const char* src_dir = argv[1];
    const char* dst_dir = argv[2];

    struct stat src_stat;
    if (lstat(src_dir, &src_stat) == -1 || !S_ISDIR(src_stat.st_mode)) {
        std::cerr << "Error: Source is not a valid directory" << std::endl;
        return 1;
    }

    struct stat dst_stat;
    if (lstat(dst_dir, &dst_stat) == 0) {
        std::cerr << "Error: Destination already exists" << std::endl;
        return 1;
    }

    return copy_directory(src_dir, dst_dir) == 0 ? 0 : 1;
}
