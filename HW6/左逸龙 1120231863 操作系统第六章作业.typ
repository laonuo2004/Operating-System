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
    第六章作业
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

#exp-title()

#student_info("07112303", "1120231863", "左逸龙")

#v(2em)

#problem("6-6", [
  下列工作各是在四层 I/O 软件的哪一层上实现的？
])

#indent-block(3em, [
+ 对于读磁盘，计算柱面、磁头和扇区
+ 维持最近所用块而设的高速缓冲
+ 向设备寄存器写命令
+ 查看是否允许用户使用设备
+ 为了打印，把二进制整数转换成 ASCII 码
])

#v(1em)

#answer[
  + 设备驱动程序
  + 独立于设备的软件
  + 设备驱动程序
  + 独立于设备的软件
  + 用户空间的 I/O 软件
]

#v(2em)

#problem("6-13", [
  假设移动头磁盘有 200 个磁道（从 0 号到 199 号）。目前正在处理 143 号磁道上的请求，而刚刚处理结束的请求是 125 号，如果下面给出的顺序是按 FIFO 排成的等待服务队列顺序：
])

#align(center)[86, 147, 91, 177, 94, 150, 102, 175, 130]

#indent-block(3em, [
  那么，用下列各种磁盘调度算法来满足这些请求所需的总磁头移动量是多少？
])

#indent-block(3em, [
  (1) FCFS; #h(1em) (2) SSTF; #h(1em) (3) SCAN; #h(1em) (4) LOOK; #h(1em) (5) C-SCAN
])

#v(1em)

#answer[
  以下分别展示各种磁盘调度算法的处理顺序与相应的总磁头移动量：

  (1) $143 attach(->, t: "57") 86 attach(->, t: "61") 147 attach(->, t: "56") 91 attach(->, t: "86") 177 attach(->, t: "83") 94 attach(->, t: "56") 150 attach(->, t: "48") 102 attach(->, t: "73") 175 attach(->, t: "45") 130$
  
  总移动量：$57 + 61 + 56 + 86 + 83 + 56 + 48 + 73 + 45 = 565$

  (2) $143 attach(->, t: "4") 147 attach(->, t: "3") 150 attach(->, t: "20") 130 attach(->, t: "28") 102 attach(->, t: "8") 94 attach(->, t: "3") 91 attach(->, t: "5") 86 attach(->, t: "89") 175 attach(->, t: "2") 177$

  总移动量：$4 + 3 + 20 + 28 + 8 + 3 + 5 + 89 + 2 = 162$

  (3), (4), (5)：由于上次处理的请求是 125 号，因此磁头正*向右移动*

  (3) $143 attach(->, t: "4") 147 attach(->, t: "3") 150 attach(->, t: "25") 175 attach(->, t: "2") 177 attach(->, t: "22") 199 attach(->, t: "69") 130 attach(->, t: "28") 102 attach(->, t: "8") 94 attach(->, t: "3") 91 attach(->, t: "5") 86$

  总移动量：$4 + 3 + 25 + 2 + 22 + 69 + 28 + 8 + 3 + 5 = 169$

  (4) $143 attach(->, t: "4") 147 attach(->, t: "3") 150 attach(->, t: "25") 175 attach(->, t: "2") 177 attach(->, t: "47") 130 attach(->, t: "28") 102 attach(->, t: "8") 94 attach(->, t: "3") 91 attach(->, t: "5") 86$

  总移动量：$4 + 3 + 25 + 2 + 47 + 28 + 8 + 3 + 5 = 125$

  (5) $143 attach(->, t: "4") 147 attach(->, t: "3") 150 attach(->, t: "25") 175 attach(->, t: "2") 177 attach(->, t: "22") 199 attach(->, t: "199") 0 attach(->, t: "86") 86 attach(->, t: "5") 91 attach(->, t: "3") 94 attach(->, t: "8") 102 attach(->, t: "28") 130$

  总移动量：$4 + 3 + 25 + 2 + 22 + 199 + 86 + 5 + 3 + 8 + 28 = 385$
]