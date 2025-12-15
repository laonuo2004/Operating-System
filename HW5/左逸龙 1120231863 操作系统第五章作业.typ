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
    第五章作业
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

#problem("5-9")[
  文件存储空间管理可采用成组自由块链表或位示图。若一磁盘有 $B$ 个盘块，其中有 $F$ 个自由块，盘空间用 $D$ 位表示。试给出使用自由块链表比使用位示图占用更少的空间的条件。当 $D$ 为 16 时，给出满足条件的自由空间占整个空间的百分比。
]
#v(1em)
#answer[
  (1) 分别计算使用成组自由块链表和位示图所需的空间大小：
  - 成组自由块链表：每个自由块需要 $D$ 位来表示，总共有 $F$ 个自由块，因此总共需要占用 $F dot D$ 位的空间。
  - 位示图：由于总共有 $B$ 个盘块，因此位示图需要占用 $B$ 位空间。
  - 因此，使用成组自由块链表比位示图占用更少空间的条件是：
  $ F dot D < B $
  
  (2) 当 $D$ 为 16 时：
  $16F < B arrow.r.double F/B < 1/16 = 6.25%$
]
#v(2em)

#import "@preview/cetz:0.4.2"

#problem("5-10")[
  文件系统的执行速度依赖于缓冲池中找到盘块的比率。假设盘块从缓冲池读出用 1ms，从盘上读出用 40ms，从缓冲池找到盘块的比率为 $n$，请给出一个公式计算读盘块的平均时间，并画出 $n$ 从 0 到 1.0 的函数图像。
]
#v(1em)
#answer[
  平均时间为：$T = n + (1-n) dot 40 = 40 - 39n$ (ms)

  函数图像如下：

  #align(center)[
    #cetz.canvas(length: 10cm, {
      import cetz.draw: *

      // 全局样式
      set-style(
        stroke: (thickness: 0.4pt, cap: "round"),
        mark: (fill: black, scale: 1),
        content: (padding: 1pt),
      )

      scale(x: 1, y: 0.015)

      // 坐标轴：n 轴（水平方向）和 T 轴（竖直方向）
      line((0, 0), (1.1, 0), mark: (end: "stealth"))
      content((1.1, 0), $ n $, anchor: "west")

      line((0, 0), (0, 42), mark: (end: "stealth"))
      content((0, 42), $ T(m s) $, anchor: "south")

      // x 轴刻度（n）
      for x in (0.2, 0.4, 0.6, 0.8, 1.0) {
        line((x, -1pt), (x, 1pt))
        content((x, -1pt), $ #x $, anchor: "north")
      }

      // y 轴刻度（T）
      for y in (0, 10, 20, 30, 40) {
        line((-1.5pt, y), (1.5pt, y))
        content((-1.5pt, y), $ #y $, anchor: "east")
      }

      // 函数 T = 40 - 39n，在 n ∈ [0,1] 上是一条直线：
      // 当 n = 0 时 T = 40；n = 1 时 T = 1
      line((0, 40), (1, 1), stroke: (paint: blue, thickness: 0.8pt))

      // 标注函数表达式
      content((0.4, 40 - 39 * 0.3), $ T = 40 - 39n $, anchor: "south-west")
    })
  ]
]
#v(2em)

#problem("5-13")[
  磁盘上有一个链接文件 A。它有 10 个记录，每个记录的长度为 256B，存放在 5 个磁盘块中，如下图所示。若要访问该文件的第 1574 字节数据，应该访问哪个磁盘块？要访问几次磁盘才能将该字节的内容读出。
]
#v(1em)
#align(center)[
  #figure(
    table(
      columns: (auto, auto),
      align: center,
      stroke: 1pt,
      inset: 8pt,
      [物理块号], [链接指针],
      [5], [7],
      [7], [14],
      [14], [4],
      [4], [10],
      [10], [0]
    )
  )
]

#v(1em)
#answer[
  该文件总长度：$10 dot 256 = 2560$ B, 平均每个磁盘块存储：$2560 / 5 = 512$ B

  故第 1574 字节数据所在磁盘块：第 $ceil(1574 / 512) = 4$ 个
  
  根据链表顺序：$5 -> 7 -> 14 -> 4$，故应访问物理块号为 4 的磁盘块。

  需要访问 4 次磁盘才能将该字节的内容读出。 
]
#v(2em)

#problem("5-14")[
  一个文件系统中，当前只有根目录被缓存到主存。假定所有目录文件都只占用一个磁盘块。那么要打开文件 `/usr/lim/course/os/result.txt`，共需要多少次磁盘操作？
]
#v(1em)
#answer[
  需要 5 次磁盘操作。(前 4 次访问目录文件，第 5 次访问 `txt` 文件)
]
#v(2em)

#problem("5-15")[
  一个文件系统采用索引结构来组织文件，且索引表的内容只包含存储文件的磁盘块号。假定一个索引项占 2B，磁盘块大小为 16KB，磁盘空间为 1GB。现有一个目录只包含 3 个文件，大小分别为 10KB, 1089KB, 129MB。若忽略目录文件占用的空间，请问存储这些文件要占用该磁盘多少空间？
]
#v(1em)
#answer[
  磁盘空间为 1GB，故磁盘块数为 $(1024"MB") / (16"KB") = 65536$；

  又因为一个磁盘块最多能够存储 $(16"KB") / (2"B") = 8192$ 个索引项，满足 $8192 < 65536 < 8192 dot 8192$，故需要二级索引。

  1. 10KB 文件：
    - 占用块数：$ceil((10"KB") / (16"KB")) = 1$
    - 一级索引项数：$1$
    - 一级索引表占用块数：$ceil(1 / 8192) = 1$
    - 二级索引项数：$1$
    - 二级索引表占用块数：$ceil(1 / 8192) = 1$
    - 总占用块数：$1 + 1 + 1 = 3$

  2. 1089KB 文件：
    - 占用块数：$ceil((1089"KB") / (16"KB")) = 69$
    - 一级索引项数：$69$
    - 一级索引表占用块数：$ceil(69 / 8192) = 1$
    - 二级索引项数：$1$
    - 二级索引表占用块数：$ceil(1 / 8192) = 1$
    - 总占用块数：$69 + 1 + 1 = 71$
    
  3. 129MB 文件：
    - 占用块数：$ceil((129"MB") / (16"KB")) = 8256$
    - 一级索引项数：$8256$
    - 一级索引表占用块数：$ceil(8256 / 8192) = 2$
    - 二级索引项数：$2$
    - 二级索引表占用块数：$ceil(2 / 8192) = 1$
    - 总占用块数：$8256 + 2 + 1 = 8259$

  总占用块数：$3 + 71 + 8259 = 8333$

  总占用空间：$8333 dot 16"KB" = 133328"KB"$
]