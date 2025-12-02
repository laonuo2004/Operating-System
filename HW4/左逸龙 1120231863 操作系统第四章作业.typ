#set page(
  margin: (top: 2.54cm, bottom: 2.54cm, left: 3.17cm, right: 3.17cm), // 标准 A4 纸张的上下左右边距
  header: context [
    #align(center, text(14pt, "操作系统课程作业"))
    #v(-1em)
    #line(length: 100%, stroke: 1pt)
  ],
  footer: context [
    #align(center, counter(page).display("1"))
  ],
)
#set text(font: ("Times New Roman", "Source Han Serif SC"), size: 12pt)
#set par(first-line-indent: (amount: 2em, all: true))

// 设置标题样式
#set heading(numbering: (..nums) => {
  let level = nums.pos().len()
  if level == 1 {
    // 一级标题：一、, 二、, 三、...
    numbering("一、", ..nums)
  } else if level == 2 {
    // 二级标题：1.1, 1.2, 1.3...
    let parent = nums.pos().first()
    numbering("1.", parent)
    let current = nums.pos().last()
    numbering("1 ", current)
  }
})

// 设置标题字体与大小
#show heading.where(level: 1): it => {
  set text(size: 14pt, font: "SimHei")
  it
  v(1em)
}

#show heading.where(level: 2): it => {
  set text(size: 14pt, font: "SimHei")
  it
  v(1em)
}

// 设置代码块样式：带背景框、边框和行号
#show raw.where(block: true): it => {
  block(
    width: 100%,
    // fill: luma(245),
    inset: 10pt,
    radius: 4pt,
    stroke: (paint: luma(220), thickness: 1pt),
  )[
    #set par(justify: false)
    #set text(size: 8pt, font: "Consolas")
    #it
  ]
}

// 为代码块添加行号（只在多行代码块中显示）
#show raw.line: it => {
  // 只有当代码块有多行时才显示行号
  if it.count > 1 {
    box(width: 2em, {
      text(fill: luma(120), str(it.number))
      h(0.5em)
    })
    it.body
  } else {
    // 单行代码或行内代码不显示行号
    it.body
  }
}

// 设置行内代码样式：带浅色背景
#show raw.where(block: false): box.with(
  // fill: luma(245),
  inset: (x: 3pt, y: 0pt),
  outset: (y: 3pt),
  radius: 2pt,
  stroke: (paint: luma(220), thickness: 0.5pt),
)

// 缩进函数：输入缩进距离（em），返回带缩进的块
#let indent-block(amount, content) = {
  block(inset: (left: amount))[
    #content
  ]
}

// 实验标题
#let exp-title() = {
  set text(font: "SimHei", size: 18pt)
  align(center, [
    第四章作业
  ])
}

// 个人信息
#let student_info(class, id, name) = {
  align(center, grid(
    columns: (auto, 6em, auto, 6em, auto, 6em),
    column-gutter: 0.5em,
    "班级:", stack(spacing: 0.5em, align(center, text(class)), line(length: 100%)),
    "学号:", stack(spacing: 0.5em, align(center, text(id)), line(length: 100%)),
    "姓名:", stack(spacing: 0.5em, align(center, text(name)), line(length: 100%)),
  ))
}

// 题目格式化函数：题号固定宽度，正文自动对齐
#let problem(num, content) = {
  grid(
    columns: (2.5em, 1fr),
    column-gutter: 0.5em,
    align: (left, left),
    [*#num*],
    content
  )
}

// 答案格式化函数：统一的答案样式
#let answer(content) = {
  block(
    width: 100%,
    fill: luma(250),
    inset: (x: 1em, y: 0.8em),
    radius: 3pt,
    stroke: (paint: luma(200), thickness: 0.5pt),
  )[
    #set par(first-line-indent: 0em)
    #set text(size: 12pt)
    #grid(
      columns: (auto, 1fr),
      column-gutter: 0.5em,
      align: (left, left),
      [*答：*],
      content
    )
  ]
}

// 定义画图函数
#let page-algo-chart(requests, states, status) = {
  let cell-size = 1.8em
  let stroke-width = 0.5pt // 定义边框宽度
  let stroke-color = luma(50)
  
  // 辅助函数：画单个格子的方框
  let frame-box(content) = box(
    width: cell-size, 
    height: cell-size, 
    stroke: stroke-width + stroke-color,
    fill: luma(250), // 填充背景，防止线条重叠时透视
    align(center + horizon, text(size: 10pt, content))
  )

  // 辅助函数：画每一列
  let column-stack(req, state, stat) = stack(
    dir: direction.ttb,
    spacing: 0.5em, // 这是【请求号-内存块-状态】三者之间的大间距
    
    // 1. 顶部的请求页号
    if req != none {
      align(center, text(weight: "bold", str(req)))
    } else {
      align(center, text(weight: "bold", " ")) // 空格占位
    },
    
    // 2. 内存块堆叠（无缝隙）
    stack(
      dir: direction.ttb,
      spacing: -stroke-width, // 关键点：使用负间距让边框重合
      ..state.map(val => frame-box(if val == none { "" } else { str(val) }))
    ),
    
    // 3. 底部的 F 或 S
    if stat != none {
      align(center, text(size: 10pt, stat))
    } else {
      align(center, text(size: 10pt, " ")) // 空格占位
    }
  )

  figure(
    block(
      stroke: none,
      inset: 1em,
      grid(
        columns: (auto,) * requests.len(),
        column-gutter: 0.5em, // 列与列之间保持间距
        ..requests.enumerate().map(((i, req)) => {
          let state = if i < states.len() { states.at(i) } else { (-1, -1, -1, -1) }
          let status = if i < status.len() { status.at(i) } else { "" }
          column-stack(req, state, status)
        })
      )
    ),
  )
}

// // -----------------------------------------------------------
// // 下面是针对 4-16 题的数据录入示例
// // 题目序列: 0, 1, 7, 2, 3, 2, 7, 1, 0, 3, 2, 5, 1, 7
// // -----------------------------------------------------------

// // 示例：FIFO 算法的前几步（你需要自己填完剩下的数据）
// // 每一列代表一个时刻的内存状态，数组长度就是4个物理块
// // none 代表空闲，数字代表页号

// // 1. 定义访问序列
// #let reqs = (0, 1, 7, 2, 3, 2, 7, 1, 0, 3, 2, 5, 1, 7)

// // 2. 定义每一列的状态 (这里只模拟了前5步 FIFO，你需要补全)
// #let fifo-states = (
//   (0, none, none, none), // 访问 0
//   (0, 1, none, none),    // 访问 1
//   (0, 1, 7, none),       // 访问 7
//   (0, 1, 7, 2),          // 访问 2
//   (3, 1, 7, 2),          // 访问 3 (0被替换)
//   // ... 请继续补充后续状态 ...
//   (3, 1, 7, 2),          // 访问 2 (命中)
//   (3, 1, 7, 2),          // 访问 7 (命中)
//   (3, 1, 7, 2),          // 访问 1 (命中)
//   (3, 0, 7, 2),          // 访问 0 (1被替换)
//   (3, 0, 7, 2),          // 访问 3 (命中)
//   (3, 0, 7, 2),          // 访问 2 (命中)
//   (3, 0, 5, 2),          // 访问 5 (7被替换)
//   (3, 0, 5, 1),          // 访问 1 (2被替换)
//   (7, 0, 5, 1),          // 访问 7 (3被替换)
// )

// // 3. 定义底部的状态 F=Fault(缺页), S=Success(命中), 或者空格
// #let fifo-status = (
//   "F", "F", "F", "F", "F", 
//   "S", "S", "S", "F", "S", 
//   "S", "F", "F", "F"
// )

// // 调用绘图函数
// #page-algo-chart(reqs, fifo-states, fifo-status, "图 4-16 FIFO 算法置换图")

// #v(2em)

// // 如果你需要画 OPT 或 LRU，只需要复制上面的变量并修改数据即可
// // 比如这里放一个空的 OPT 模板供你填空：

// #let opt-states-template = (
//   (0, none, none, none), // 0
//   (0, 1, none, none),    // 1
//   (0, 1, 7, none),       // 7
//   (0, 1, 7, 2),          // 2
//   // ... 接着填 ...
//   (3, 1, 7, 2),          // 3 (OPT: 0后续最晚用，换0?)
//   (3, 1, 7, 2),          // 2
//   (3, 1, 7, 2),          // 7
//   (3, 1, 7, 2),          // 1
//   (3, 1, 0, 2),          // 0 (OPT: 7后续最晚用，换7?)
//   (3, 1, 0, 2),          // 3
//   (3, 1, 0, 2),          // 2
//   (3, 1, 0, 5),          // 5 (OPT: 2后续不用了，换2?)
//   (3, 1, 0, 5),          // 1
//   (7, 1, 0, 5),          // 7 (OPT: 3后续不用了，换3?)
// )
// #let opt-status = ("F", "F", "F", "F", "F", "S", "S", "S", "F", "S", "S", "F", "S", "F")

// #page-algo-chart(reqs, opt-states-template, opt-status, "图 4-16 OPT 算法置换图")

#exp-title()

#student_info("07112303", "1120231863", "左逸龙")

#v(2em)

#problem("4-14", [考虑有一个可变分区系统，含有如下顺序的空闲区：10K, 40K, 20K, 18K, 7K, 9K, 12K 和 15K。现有请求分配存储空间的序列：(1) 12K; (2) 10K; (3) 9K。
])

#indent-block(3em, [
若采用首次适应算法时，将分配哪些空闲区；若采用最佳、最坏适应算法呢？
])

#v(1em)
#answer([
  1. 使用首次适应算法时：
    - 12K: 分配空闲区 40K，剩余空闲区为 28K，保留下来
    - 10K: 分配空闲区 10K
    - 9K: 分配空闲区 28K
  2. 使用最佳适应算法时：
    - 12K: 分配空闲区 12K
    - 10K: 分配空闲区 10K
    - 9K: 分配空闲区 9K
  3. 使用最坏适应算法时：
    - 12K：分配空闲区 40K，剩余空闲区为 28K，保留下来
    - 10K：分配空闲区 28K，剩余空闲区为 18K，保留下来
    - 9K：分配空闲区 20K
])
#v(2em)

#problem("4-15", [有下图所示的页表中的虚地址与物理地址之间的关系，即该进程分得 6 个主存块。页的大小为 4096。给出对应下面虚地址的物理地址。
  (1) 20; (2) 5100; (3) 8300; (4) 47000
])

#align(center)[
  #figure(
    table(
      columns: (auto, auto),
      align: center,
      stroke: 0.5pt,
      inset: 5pt,
      [页号], [块号],
      [0], [2],
      [1], [1],
      [2], [6],
      [3], [0],
      [4], [4],
      [5], [3],
      [6], [x],
      [7], [x],
    )
  )
]

#v(1em)
#answer([
  (1) 20 / 4096 = 0 余 20，对应块号为 2，页内地址为 20，物理地址为 2 $dot$ 4096 + 20 = 8212

  (2) 5100 / 4096 = 1 余 1004，对应块号为 1，页内地址为 1004，物理地址为 1 $dot$ 4096 + 1004 = 5100

  (3) 8300 / 4096 = 2 余 108，对应块号为 6，页内地址为 108，物理地址为 6 $dot$ 4096 + 108 = 24684

  (4) 47000 / 4096 = 11 余 1944，由于 11 > 6，因此地址越界，程序中断
])
#v(2em)

#problem("4-16", [
  一个进程在执行过程中，按如下顺序依次访问各页，进程分得四个主存块，问分别采用 FIFO、LRU 和 OPT 算法时，要产生多少次缺页中断？设进程开始运行时，主存没有页面。页访问串顺序为：0, 1, 7, 2, 3, 2, 7, 1, 0, 3, 2, 5, 1, 7。
])

#v(1em)

#let reqs = (0, 1, 7, 2, 3, 2, 7, 1, 0, 3, 2, 5, 1, 7)

#let fifo-states = (
  (0, none, none, none), // 0
  (1, 0, none, none), // 1
  (7, 1, 0, none), // 7
  (2, 7, 1, 0), // 2
  (3, 2, 7, 1), // 3
  (3, 2, 7, 1), // 2
  (3, 2, 7, 1), // 7
  (3, 2, 7, 1), // 1
  (0, 3, 2, 7), // 0
  (0, 3, 2, 7), // 3
  (0, 3, 2, 7), // 2
  (5, 0, 3, 2), // 5
  (1, 5, 0, 3), // 1
  (7, 1, 5, 0), // 7
)
#let fifo-status = ("F", "F", "F", "F", "F", "S", "S", "S", "F", "S", "S", "F", "F", "F")

#let lru-states = (
  (0, none, none, none), // 0
  (1, 0, none, none), // 1
  (7, 1, 0, none), // 7
  (2, 7, 1, 0), // 2
  (3, 2, 7, 1), // 3
  (2, 3, 7, 1), // 2
  (7, 2, 3, 1), // 7
  (1, 7, 2, 3), // 1
  (0, 1, 7, 2), // 0
  (3, 0, 1, 7), // 3
  (2, 3, 0, 1), // 2
  (5, 2, 3, 0), // 5
  (1, 5, 2, 3), // 1
  (7, 1, 5, 2), // 7
)

#let lru-status = ("F", "F", "F", "F", "F", "S", "S", "S", "F", "F", "F", "F", "F", "F")

#let opt-states = (
  (0, none, none, none), // 0
  (1, 0, none, none),    // 1
  (7, 1, 0, none),       // 7
  (2, 7, 1, 0),          // 2
  (3, 2, 7, 1),          // 3
  (3, 2, 7, 1),          // 2
  (3, 2, 7, 1),          // 7
  (3, 2, 7, 1),          // 1
  (0, 3, 2, 1),          // 0
  (0, 3, 2, 1),          // 3
  (0, 3, 2, 1),          // 2
  (5, 3, 2, 1),          // 5
  (5, 3, 2, 1),          // 1
  (7, 3, 2, 1),          // 7
)

#let opt-status = ("F", "F", "F", "F", "F", "S", "S", "S", "F", "S", "S", "F", "S", "F")

#answer([
  1. 采用 FIFO 算法，共产生 9 次缺页中断：
  #page-algo-chart(reqs, fifo-states, fifo-status)

  2. 采用 LRU 算法，共产生 11 次缺页中断：
  #page-algo-chart(reqs, lru-states, lru-status)

  3. 采用 OPT 算法，共产生 8 次缺页中断：
  #page-algo-chart(reqs, opt-states, opt-status)
])
#v(2em)

#problem("4-17", [考虑下图所示的段表，给出如下所示的逻辑地址所对应的物理地址。
])

#indent-block(3em, [
  (1) 0, 430 #h(1em) (2) 1, 10 #h(1em) (3) 2, 500 #h(1em) (4) 3, 400 #h(1em) (5) 4, 112
])

#align(center)[
  #figure(
    table(
      columns: (auto, auto),
      align: center,
      stroke: 0.5pt,
      inset: 5pt,
      [段始址], [段的长度],
      [219], [600],
      [2300], [14],
      [92], [100],
      [1326], [580],
      [1954], [96],
    )
  )
]

#v(1em)
#answer([
  (1) 段始址 219，段内偏移 430，则物理地址为 219 + 430 = 649

  (2) 段始址 2300，段内偏移 10，则物理地址为 2300 + 10 = 2310

  (3) 段始址 92，由于段内偏移 500 > 段长 100，地址越界，程序中断

  (4) 段始址 1326，段内偏移 400，则物理地址为 1326 + 400 = 1726

  (5) 段始址 1954，由于段内偏移 112 > 段长 96，地址越界，程序中断
])
#v(2em)

#problem("4-18", [
  一台计算机含有 65536B 的存储空间，这一空间被分成许多长度为 4096B 的页。有一程序，其代码段为 32768B，数据段为 16386B，栈段为 15870B。试问该机器的主存空间适合这个进程吗？如果每页改成 512B，适合吗？
])

#v(1em)
#answer([
  1. 页大小为 4096B 时，总页数为 65536 / 4096 = 16 页，此时：
    - 代码段：$ ceil(32768 / 4096) = 8$ 页
    - 数据段：$ ceil(16386 / 4096) = 5$ 页 (此处余数为2，需要多占用一页)
    - 栈段：$ ceil(15870 / 4096) = 4$ 页
    由于总页数为 17 页，大于 16 页，因此主存空间不适合这个进程。

  2. 页大小为 512B 时，总页数为 65536 / 512 = 128 页，此时：
    - 代码段：$ ceil(32768 / 512) = 64$ 页
    - 数据段：$ ceil(16386 / 512) = 33$ 页
    - 栈段：$ ceil(15870 / 512) = 31$ 页
    由于总页数为 128 页，等于 128 页，因此主存空间适合这个进程。
])
#v(2em)

#problem("4-19", [
  在某虚拟页式管理系统中，页表包括有 512 项，每个页表项占 16 位（其中一位是有效位）。每页大小为 1024 个字节。问逻辑地址中分别用多少位表示页号和页内地址？
])

#v(1em)
#answer([
  逻辑地址使用 9 位表示页号，10 位表示页内地址。页表项位数与逻辑地址需要多少位来定位物理地址没有关系，所以不用考虑。
])
#v(2em)

#problem("4-20", [有一个虚存系统，按行存储矩阵的元素。一进程要为矩阵进行清零操作，系统为该进程分配物理主存共 3 页，系统用其中一页存放程序，且已经调入，其余两页空闲。按需调入矩阵数据。若进程按如下两种方式进行编程：
])


#indent-block(3em, [
  ```pascal
  var A:array[1..100, 1..100] of integer;

  程序 A:
  for i:=1 to 100 do
      for j:=1 to 100 do
        A[i,j]:=0;

  程序 B:
  for j:=1 to 100 do
      for i:=1 to 100 do
        A[i,j]:=0;
  ```

])

#indent-block(3em, [
1. 若每页可存放 200 个整数，问采用程序 A 和程序 B 方式时，各个执行过程分别会发生多少次缺页？
2. 若每页只能存放 100 个整数时，会是什么情况？
])

#v(1em)
#answer([
  1. 采用程序 A 方式时，会发生 50 次缺页 (全部的 50 页依次被访问)

    采用程序 B 方式时，会发生 50 $times$ 100 = 5000 次缺页中断；

  2. 采用程序 A 方式时，会发生 100 次缺页

    采用程序 B 方式时，会发生 100 $times$ 100 = 10000 次缺页中断；
])
#v(2em)

#problem("4-21", [
  一个请求分页系统中，内存的读写周期为 8ns，当配置有快表时，查快表需要 1ns，内外存之间传送一个页面的平均时间为 5000ns。假定快表的命中率为 75%，页面失效律为 10%，求内存的有效存取时间。
])

#v(1em)
#answer([
  总共有 3 种情况：

  1. 快表命中 (P=0.75)，此时内存存取时间为：1+8=9ns (查快表+实际操作)

  2. 快表未命中，但是页面在内存中 (P=0.15)，此时内存存取时间为：8+8=16ns (查页表+实际操作，注意查快表和查页表是并行的，所以快表查找失败不会影响页表查找，即不用加上查快表的1ns时间)

  3. 快表未命中，且页面不在内存中 (P=0.1)，此时内存存取时间为：8+5000+8=5016ns (查页表+内外存传送+实际操作)

  因此，内存的有效存取时间为：

  0.75*9 + 0.15*16 + 0.1*5016 = 6.75 + 1.8 + 501.6 = 510.75ns
])
#v(2em)

#problem("4-23", [
  某计算机的 CPU 的地址长度为 64 位，若页的大小为 8192B，页表项占 4B。要求一个页表的信息应该放在一个页中。问采用几级页表比较好？
])

#v(1em)
#answer([
  首先，由于页的大小为 8192B，所以地址中需要 $log_2 8192 = 13$ 位来表示页内偏移。
  
  随后，由于一个页表的信息应该放在一个页中，而一个页表项占 4B，所以一个页表可以存放的页表项数量为 8192 / 4 = 2048 个，需要 $log_2 2048 = 11$ 位来进行索引。

  假设采用 n 级页表，求解 13 + 11n $>=$ 64，得到 n $>=$ 5，因此采用 5 级页表比较好。
])