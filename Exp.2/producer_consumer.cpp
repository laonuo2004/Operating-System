#include <iostream>
#include <windows.h>
#include <string>
#include <vector>
#include <ctime>
#include <iomanip>

// --- 全局常量定义 ---
const int BUFFER_ITEM_LENGTH = 10;
const int BUFFER_COUNT = 6;
const int PRODUCER_COUNT = 2;
const int CONSUMER_COUNT = 3;
const int PRODUCE_LOOPS = 12;
const int CONSUME_LOOPS = 8;
const int MAX_RANDOM_WAIT_MS = 1000;

// --- 共享内存数据结构 ---
struct SharedBufferPool {
    char buffer[BUFFER_COUNT][BUFFER_ITEM_LENGTH + 1]; // +1 是因为需要存储 `\0`
    int write_pos;
    int read_pos;
};

// --- 内核对象命名 ---
const char* SHARED_MEM_NAME = "MySharedMemoryPool";
const char* EMPTY_SEM_NAME = "Semaphore_EmptySlots";
const char* FULL_SEM_NAME = "Semaphore_FullSlots";
const char* MUTEX_SEM_NAME = "Semaphore_MutexLock";

// 打印当前时间和缓冲区映像
void PrintBufferSnapshot(const std::string& message, SharedBufferPool* data) {
    SYSTEMTIME st;
    GetLocalTime(&st);

    std::cout << "[" << std::setw(2) << std::setfill('0') << st.wHour << ":"
              << std::setw(2) << std::setfill('0') << st.wMinute << ":"
              << std::setw(2) << std::setfill('0') << st.wSecond << "."
              << std::setw(3) << std::setfill('0') << st.wMilliseconds << "] "
              << message << std::endl;

    // 恢复填充字符为空格，避免后续宽度填充出现 '0'
    std::cout << std::setfill(' ');

    std::cout << "当前缓冲区映像: ";
    for (int i = 0; i < BUFFER_COUNT; ++i) {
        if (data->buffer[i][0] == '\0') {
            std::cout << "[           ] ";
        } else {
            std::cout << "[ " << std::setw(10) << std::left << data->buffer[i] << "] ";
        }
    }
    std::cout << std::endl << "------------------------------------------------------------------------------------------------" << std::endl;
}

// --- 生产者进程主函数 ---
void ProducerProcess(int id) {
    HANDLE hEmpty = OpenSemaphore(SEMAPHORE_ALL_ACCESS, FALSE, EMPTY_SEM_NAME);
    HANDLE hFull = OpenSemaphore(SEMAPHORE_ALL_ACCESS, FALSE, FULL_SEM_NAME);
    HANDLE hMutex = OpenSemaphore(SEMAPHORE_ALL_ACCESS, FALSE, MUTEX_SEM_NAME);
    HANDLE hMapFile = OpenFileMapping(FILE_MAP_ALL_ACCESS, FALSE, SHARED_MEM_NAME);

    if (!hEmpty || !hFull || !hMutex || !hMapFile) return;

    SharedBufferPool* sharedData = (SharedBufferPool*)MapViewOfFile(hMapFile, FILE_MAP_ALL_ACCESS, 0, 0, sizeof(SharedBufferPool));
    if (sharedData == nullptr) return;

    srand(static_cast<unsigned int>(time(NULL)) * GetCurrentProcessId());

    for (int i = 0; i < PRODUCE_LOOPS; ++i) {
        Sleep(rand() % MAX_RANDOM_WAIT_MS);

        // P操作: 等待空闲缓冲区
        WaitForSingleObject(hEmpty, INFINITE);
        // P操作: 请求互斥访问
        WaitForSingleObject(hMutex, INFINITE);

        // --- 临界区 ---
        int current_pos = sharedData->write_pos;
        std::string item = "P" + std::to_string(id) + "_Item" + std::to_string(i + 1);
        strcpy_s(sharedData->buffer[current_pos], BUFFER_ITEM_LENGTH + 1, item.c_str());
        sharedData->write_pos = (sharedData->write_pos + 1) % BUFFER_COUNT;

        std::string msg = "生产者 P" + std::to_string(id) + " 在缓冲区 " + std::to_string(current_pos) + " 中放入数据 \"" + item + "\"";
        PrintBufferSnapshot(msg, sharedData);
        // --- 临界区结束 ---

        // V操作: 释放互斥锁
        ReleaseSemaphore(hMutex, 1, NULL);
        // V操作: 通知有产品可用
        ReleaseSemaphore(hFull, 1, NULL);
    }

    UnmapViewOfFile(sharedData);
    CloseHandle(hMapFile);
    CloseHandle(hMutex);
    CloseHandle(hFull);
    CloseHandle(hEmpty);
}

// --- 消费者进程主函数 ---
void ConsumerProcess(int id) {
    HANDLE hEmpty = OpenSemaphore(SEMAPHORE_ALL_ACCESS, FALSE, EMPTY_SEM_NAME);
    HANDLE hFull = OpenSemaphore(SEMAPHORE_ALL_ACCESS, FALSE, FULL_SEM_NAME);
    HANDLE hMutex = OpenSemaphore(SEMAPHORE_ALL_ACCESS, FALSE, MUTEX_SEM_NAME);
    HANDLE hMapFile = OpenFileMapping(FILE_MAP_ALL_ACCESS, FALSE, SHARED_MEM_NAME);

    if (!hEmpty || !hFull || !hMutex || !hMapFile) return;

    SharedBufferPool* sharedData = (SharedBufferPool*)MapViewOfFile(hMapFile, FILE_MAP_ALL_ACCESS, 0, 0, sizeof(SharedBufferPool));
    if (sharedData == nullptr) return;

    srand(static_cast<unsigned int>(time(NULL)) * GetCurrentProcessId());

    for (int i = 0; i < CONSUME_LOOPS; ++i) {
        Sleep(rand() % MAX_RANDOM_WAIT_MS);

        // P操作: 等待产品
        WaitForSingleObject(hFull, INFINITE);
        // P操作: 请求互斥访问
        WaitForSingleObject(hMutex, INFINITE);

        // --- 临界区 ---
        int current_pos = sharedData->read_pos;
        std::string item(sharedData->buffer[current_pos]);
        sharedData->buffer[current_pos][0] = '\0'; // 模拟取出数据
        sharedData->read_pos = (sharedData->read_pos + 1) % BUFFER_COUNT;

        std::string msg = "消费者 C" + std::to_string(id) + " 从缓冲区 " + std::to_string(current_pos) + " 中取出数据 \"" + item + "\"";
        PrintBufferSnapshot(msg, sharedData);
        // --- 临界区结束 ---

        // V操作: 释放互斥锁
        ReleaseSemaphore(hMutex, 1, NULL);
        // V操作: 通知有空缓冲区可用
        ReleaseSemaphore(hEmpty, 1, NULL);
    }

    UnmapViewOfFile(sharedData);
    CloseHandle(hMapFile);
    CloseHandle(hMutex);
    CloseHandle(hFull);
    CloseHandle(hEmpty);
}

int main(int argc, char* argv[]) {
    // 根据命令行参数判断当前进程的角色
    if (argc > 1) {
        std::string role = argv[1];
        int id = std::stoi(argv[2]);
        if (role == "producer") {
            ProducerProcess(id);
        } else if (role == "consumer") {
            ConsumerProcess(id);
        }
        return 0;
    }

    // 同步对象1: 记录空闲缓冲区数量的信号量
    HANDLE hEmpty = CreateSemaphore(NULL, BUFFER_COUNT, BUFFER_COUNT, EMPTY_SEM_NAME);
    // 同步对象2: 记录已用缓冲区数量的信号量
    HANDLE hFull = CreateSemaphore(NULL, 0, BUFFER_COUNT, FULL_SEM_NAME);
    // 同步对象3: 用于保证缓冲区被互斥访问的二值信号量
    HANDLE hMutex = CreateSemaphore(NULL, 1, 1, MUTEX_SEM_NAME);
    
    // 创建用于进程间通信的共享内存区域
    HANDLE hMapFile = CreateFileMapping(
        INVALID_HANDLE_VALUE, NULL, PAGE_READWRITE, 0, 
        sizeof(SharedBufferPool), SHARED_MEM_NAME);

    if (!hEmpty || !hFull || !hMutex || !hMapFile) {
        std::cerr << "初始化内核同步对象或共享内存失败，错误代码: " << GetLastError() << std::endl;
        return 1;
    }

    SharedBufferPool* sharedData = (SharedBufferPool*)MapViewOfFile(hMapFile, FILE_MAP_ALL_ACCESS, 0, 0, sizeof(SharedBufferPool));
    if (sharedData == nullptr) {
        std::cerr << "映射共享内存失败，错误代码: " << GetLastError() << std::endl;
        return 1;
    }
    // 初始化共享内存数据
    sharedData->write_pos = 0;
    sharedData->read_pos = 0;
    for (int i = 0; i < BUFFER_COUNT; ++i) {
        sharedData->buffer[i][0] = '\0';
    }

    PrintBufferSnapshot("缓冲池初始化完毕", sharedData);

    std::vector<PROCESS_INFORMATION> processInfo(PRODUCER_COUNT + CONSUMER_COUNT);
    std::vector<HANDLE> processHandles;

    char selfPath[MAX_PATH];
    GetModuleFileName(NULL, selfPath, MAX_PATH);

    for (int i = 0; i < PRODUCER_COUNT; ++i) {
        std::string cmd = std::string(selfPath) + " producer " + std::to_string(i + 1);
        STARTUPINFO si = { sizeof(si) };
        if (CreateProcess(NULL, (LPSTR)cmd.c_str(), NULL, NULL, FALSE, 0, NULL, NULL, &si, &processInfo[i])) {
            processHandles.push_back(processInfo[i].hProcess);
            CloseHandle(processInfo[i].hThread);
        }
    }

    for (int i = 0; i < CONSUMER_COUNT; ++i) {
        std::string cmd = std::string(selfPath) + " consumer " + std::to_string(i + 1);
        STARTUPINFO si = { sizeof(si) };
        if (CreateProcess(NULL, (LPSTR)cmd.c_str(), NULL, NULL, FALSE, 0, NULL, NULL, &si, &processInfo[PRODUCER_COUNT + i])) {
            processHandles.push_back(processInfo[PRODUCER_COUNT + i].hProcess);
            CloseHandle(processInfo[PRODUCER_COUNT + i].hThread);
        }
    }
    
    std::cout << "已创建 " << PRODUCER_COUNT << " 个生产者与 " << CONSUMER_COUNT << " 个消费者进程。" << std::endl;

    WaitForMultipleObjects(static_cast<DWORD>(processHandles.size()), processHandles.data(), TRUE, INFINITE);

    std::cout << "所有任务已完成。" << std::endl;

    // 清理句柄
    for(auto h : processHandles) {
        CloseHandle(h);
    }
    UnmapViewOfFile(sharedData);
    CloseHandle(hMapFile);
    CloseHandle(hMutex);
    CloseHandle(hFull);
    CloseHandle(hEmpty);

    return 0;
}