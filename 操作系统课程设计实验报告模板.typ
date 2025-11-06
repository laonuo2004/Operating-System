#set page(
  margin: (top: 2.54cm, bottom: 2.54cm, left: 3.17cm, right: 3.17cm), // 标准 A4 纸张的上下左右边距
  header: context [
    #align(center, text(14pt, "操作系统课程设计实验报告"))
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
    fill: luma(245),
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
  fill: luma(245),
  inset: (x: 3pt, y: 0pt),
  outset: (y: 3pt),
  radius: 2pt,
)

// 缩进函数：输入缩进距离（em），返回带缩进的块
#let indent-block(amount, content) = {
  block(inset: (left: amount))[
    #content
  ]
}

// 实验标题
#let exp-title(experiment_number, experiment_name) = {
  set text(font: "SimHei", size: 18pt)
  align(center, [
    实验#experiment_number  #experiment_name
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

#exp-title("一", "编译 Linux 内核")

#student_info("07112303", "1120231863", "左逸龙")

#v(2em)

= 实验目的

// 此处攥写实验目的

#v(1.5em)

= 实验内容

// 此处攥写实验内容

#v(1.5em)

= 实验步骤

// 此处攥写实验步骤

#v(1.5em)

= 实验结果及分析

// 此处攥写实验结果及分析

#v(1.5em)

= 实验收获与体会

// 此处攥写实验收获与体会
