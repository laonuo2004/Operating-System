#include <windows.h>
#include <psapi.h>
#include <iostream>
#include <vector>
#include <string>
#include <iomanip>
#include <cstdint>

struct RegionInfo {
    void* base;
    SIZE_T size;
    DWORD state;
    DWORD protect;
    DWORD type;
};

std::string StateToStr(DWORD state) {
    switch (state) {
        case MEM_COMMIT: return "Committed";
        case MEM_RESERVE: return "Reserved";
        case MEM_FREE: return "Free";
        default: return "Unknown";
    }
}

std::string ProtectToStr(DWORD prot) {
    switch (prot & 0xFF) {
        case PAGE_READONLY: return "R--";
        case PAGE_READWRITE: return "RW-";
        case PAGE_WRITECOPY: return "RWC";
        case PAGE_EXECUTE: return "--X";
        case PAGE_EXECUTE_READ: return "R-X";
        case PAGE_EXECUTE_READWRITE: return "RWX";
        case PAGE_EXECUTE_WRITECOPY: return "RWXC";
        default: return "---";
    }
}

void PrintSystemInfo() {
    SYSTEM_INFO si{};
    GetSystemInfo(&si);
    PERFORMANCE_INFORMATION perf{};
    perf.cb = sizeof(perf);
    GetPerformanceInfo(&perf, sizeof(perf));
    MEMORYSTATUSEX ms{};
    ms.dwLength = sizeof(ms);
    GlobalMemoryStatusEx(&ms);

    std::cout << "Page size: " << si.dwPageSize
              << "  Min addr: " << si.lpMinimumApplicationAddress
              << "  Max addr: " << si.lpMaximumApplicationAddress << "\n";
    std::cout << "Total phys (MB): " << ms.ullTotalPhys / (1024 * 1024)
              << "  Avail phys (MB): " << ms.ullAvailPhys / (1024 * 1024) << "\n";
    std::cout << "System cache (MB): " << perf.SystemCache * perf.PageSize / (1024 * 1024)
              << "  Commit limit (MB): " << perf.CommitLimit * perf.PageSize / (1024 * 1024)
              << "\n\n";
}

std::vector<RegionInfo> EnumerateRegions(HANDLE process) {
    std::vector<RegionInfo> regions;
    SYSTEM_INFO si{};
    GetSystemInfo(&si);
    auto addr = reinterpret_cast<std::uintptr_t>(si.lpMinimumApplicationAddress);
    auto maxAddr = reinterpret_cast<std::uintptr_t>(si.lpMaximumApplicationAddress);
    MEMORY_BASIC_INFORMATION mbi{};
    while (addr < maxAddr) {
        if (VirtualQueryEx(process, reinterpret_cast<void*>(addr), &mbi, sizeof(mbi)) == 0)
            break;
        RegionInfo info{mbi.BaseAddress, mbi.RegionSize, mbi.State, mbi.Protect, mbi.Type};
        regions.push_back(info);
        addr += mbi.RegionSize;
    }
    return regions;
}

void PrintRegions(const std::vector<RegionInfo>& regions) {
    std::cout << std::left << std::setw(18) << "Base"
              << std::setw(12) << "Size(KB)"
              << std::setw(12) << "State"
              << std::setw(8) << "Prot"
              << "Type\n";
    for (const auto& r : regions) {
        std::cout << std::setw(18) << r.base
                  << std::setw(12) << (r.size / 1024)
                  << std::setw(12) << StateToStr(r.state)
                  << std::setw(8) << ProtectToStr(r.protect)
                  << r.type << "\n";
    }
}

void PrintWorkingSet(HANDLE process) {
    PROCESS_MEMORY_COUNTERS_EX pmc{};
    if (GetProcessMemoryInfo(process, reinterpret_cast<PROCESS_MEMORY_COUNTERS*>(&pmc), sizeof(pmc))) {
        std::cout << "Working Set (MB): " << pmc.WorkingSetSize / (1024 * 1024)
                  << "  Private WS (MB): " << pmc.PrivateUsage / (1024 * 1024)
                  << "  Pagefile (MB): " << pmc.PagefileUsage / (1024 * 1024) << "\n";
    }
}

int main() {
    DWORD pid;
    std::cout << "Enter PID: ";
    std::cin >> pid;

    HANDLE process = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, pid);
    if (!process) {
        std::cerr << "OpenProcess failed: " << GetLastError() << "\n";
        return 1;
    }

    while (true) {
        system("cls");
        std::cout << "Process PID " << pid << "\n\n";
        PrintSystemInfo();
        auto regions = EnumerateRegions(process);
        PrintWorkingSet(process);
        PrintRegions(regions);

        Sleep(1500);
    }

    CloseHandle(process);
    return 0;
}