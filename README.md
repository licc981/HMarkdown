# HMarkdown

> **注意**：原 GitHub 账号 [lidary-byte](https://github.com/lidary-byte) 于 2026 年 6 月因被盗用于 GitHub Actions 挖矿而被封禁，本项目已迁移至新账号 [licc981](https://github.com/licc981981)。原仓库的所有链接（Releases、Issues 等）已不可用，请以当前仓库为准。

[![Downloads](https://img.shields.io/github/downloads/licc981/HMarkdown/total?style=for-the-badge&logo=github)](https://github.com/licc981/HMarkdown)
[![Last Version](https://img.shields.io/github/v/release/licc981/HMarkdown?style=for-the-badge)](https://github.com/licc981/HMarkdown/releases)
[![License](https://img.shields.io/github/license/licc981/HMarkdown?style=for-the-badge)](LICENSE)
[![OpenHarmony](https://img.shields.io/github/v/release/licc981/HMarkdown?style=for-the-badge&logo=harmonyos&color=76CE65)](https://ohpm.openharmony.cn/#/cn/detail/@lidary%2Fmarkdown)
[![CHANGELOG](https://img.shields.io/badge/CHANGELOG-E87436?style=for-the-badge&logo=googledocs&logoColor=ffffff)](https://github.com/licc981/HMarkdown/blob/main/Markdown/CHANGELOG.md)

基于[**marked**](https://github.com/markedjs/marked)的鸿蒙端markdown渲染库

## v3.1.0 特性

1. **流式输出**：内置逐字符渐进渲染 + 自动滚动，调用方只需传入 `streaming: true`
2. **LaTeX 渲染缓存**：相同公式复用缓存 PixelMap，流式场景零闪烁
3. **Token 增量 Diff**：未变化的 block 组件保持引用不重建，配合 `Repeat.key()` 防闪烁
4. 修复亮色主题段落颜色、分割线颜色、LaTeX 插件逻辑等多个 Bug

## v3.0.0 特性

1. 支持**公式本地渲染**
2. 支持**子线程渲染**
3. 完全重构

Tips:

1. **本次更新 API 变动较大，如需旧版本请查看[→](https://github.com/licc981/HMarkdown/blob/feat-v2.0.8)**
2. v2.0.8 因为没有考虑到子线程内存隔离问题会导致设置的插件不生效

### 效果图（如无法预览请前往 [Github](https://github.com/licc981/HMarkdown)）

<p align="center">
  <img src="https://github.com/licc981/HMarkdown/blob/main/screen/image_1.png" width="20%" alt="图1" />
  <img src="https://github.com/licc981/HMarkdown/blob/main/screen/image_2.png" width="20%" alt="图2" />
  <img src="https://github.com/licc981/HMarkdown/blob/main/screen/image_3.png" width="20%" alt="图3" />
  <img src="https://github.com/licc981/HMarkdown/blob/main/screen/image_4.png" width="20%" alt="图4" />
  <img src="https://github.com/licc981/HMarkdown/blob/main/screen/image_5.png" width="20%" alt="图5" />
  <img src="https://github.com/licc981/HMarkdown/blob/main/screen/dark_image_1.png" width="20%" alt="图6" />
  <img src="https://github.com/licc981/HMarkdown/blob/main/screen/dark_image_2.png" width="20%" alt="图7" />
  <img src="https://github.com/licc981/HMarkdown/blob/main/screen/dark_image_3.png" width="20%" alt="图8" />
  <img src="https://github.com/licc981/HMarkdown/blob/main/screen/dark_image_4.png" width="20%" alt="图9" />
  <img src="https://github.com/licc981/HMarkdown/blob/main/screen/dark_image_5.png" width="20%" alt="图10" />
</p>

---

## 参数

| 名称 | 是否必传 | 默认值 | 说明 |
|:---:|:---:|:---:|:---:|
| content | 否 | `""` | markdown 文本内容 |
| streaming | 否 | `false` | 流式输出模式（逐字符渲染 + 自动滚动） |
| options | 否 | `undefined` | 属性，主题等相关配置 |
| onLoading / onSuccess / onError | 否 | `undefined` | 加载状态回调（方便设置 Loading 等） |
| nestedScroll | 否 | `undefined` | 嵌套滚动 |
| contentStartOffset | 否 | `undefined` | 内容头部偏移量，参考 List 组件 |
| contentEndOffset | 否 | `undefined` | 内容尾部偏移量，参考 List 组件 |
| paddings | 否 | `undefined` | 内边距 |
| scrollBar | 否 | `undefined` | 滚动条状态 |
| cachedCount | 否 | `0` | 懒加载缓存数量 |
| cachedShow | 否 | `false` | 懒加载缓存组件是否显示 |

### MarkdownOptions 参数

| 名称 | 是否必传 | 默认值 | 说明 |
|:---:|:---:|:---:|:---|
| theme | 否 | `defaultTheme`（参考 JetBrains 的 UI） | 亮色主题相关配置 |
| darkTheme | 否 | `defaultDarkTheme`（参考 JetBrains 的 UI） | 暗色主题相关配置 |
| darkMode | 否 | `false` | 是否暗色模式 |
| lineSpace | 否 | `12` | item 之间的间距 |
| inlineLineSpace | 否 | `LengthMetrics.vp(12)` | item 中 text 的行间距 |
| options | 否 | `undefined` | [marked 相关配置](https://marked.js.org/using_advanced) |
| extensions | 否 | `undefined` | [marked 插件](https://marked.js.org/using_advanced#extensions)，可参考[数学公式](https://github.com/licc981/HMarkdown/blob/main/Markdown/src/main/ets/core/plugins/latex.ets) |
| latexResPath | 否 | `undefined` | LaTeX 公式资源路径 |
| imageClick | 否 | `undefined` | 图片点击事件 |
| linkClick | 否 | `undefined` | 超链接点击事件 |
| customBlockBuilder | 否 | `undefined` | 自定义块元素渲染 |
| customInlineBuilder | 否 | `undefined` | 自定义行内元素渲染 |
| maxLines | 否 | `undefined` | 行内元素最大行数（多个 List item 都是 Markdown 时使用） |

---

## 下载安装

```bash
ohpm install @lidary/markdown
```

---

## 导包

```typescript
// V2 状态管理，不支持 V1
import { Markdown } from '@lidary/markdown';
```

---

## 使用方式

```typescript
Markdown({
  content: this.text,
  streaming: this.isStreaming, // 流式输出：内部逐字符渲染 + 自动滚动
  options: {
    darkMode: this.isDark,
    options: {
      gfm: true
    },
    darkTheme: {
      themeColor: Color.Orange
    },
    imageClick: (url?: string) => {
      promptAction.showToast({
        message: `图片被点击: ${url}`,
        duration: 1500,
        bottom: 'center',
      })
    },
    linkClick: (url?: string) => {
      promptAction.showToast({
        message: `超链接被点击: ${url}`,
        duration: 1500,
        bottom: 'center',
      })
    }
  },
  onLoading: () => {
    this.isLoading = true
  },
  onError: () => {
    this.isLoading = false
  },
  onSuccess: () => {
    this.isLoading = false
  },
  contentStartOffset: AppUtils.WindowUtil.getBottomHeight(),
  contentEndOffset: AppUtils.WindowUtil.getBottomHeight(),
  paddings: { left: 16, right: 16 },
  scrollBar: BarState.Off,
  nestedScroll: {
    scrollForward: NestedScrollMode.PARENT_FIRST,
    scrollBackward: NestedScrollMode.SELF_FIRST
  },
  cachedCount: 3,
  cachedShow: true
}).height('100%')
```

---

## 特性

- [x] 支持标题语法
- [x] 支持段落语法
- [x] 支持分割线语法
- [x] 支持代码语法
- [x] 支持加粗语法
- [x] 支持斜体语法
- [x] 支持删除线语法
- [x] 支持链接语法
- [x] 支持表格语法
- [x] 支持有序列表语法
- [x] 支持无序列表语法
- [x] 支持块引用语法
- [x] 支持数学公式语法
- [x] 支持图片语法
- [x] 支持单独代码块功能
- [x] 支持列表嵌套功能
- [x] 支持文本样式设置
- [x] 支持深浅主题色设置
- [x] 支持部分 HTML 语法
- [x] 支持任务列表语法
- [x] 支持流式输出（逐字符渲染 + 自动滚动）

## [更新日志](https://github.com/licc981/HMarkdown/blob/main/Markdown/CHANGELOG.md)

## 开源协议

本项目基于 [MIT License](https://gitee.com/daryl_code/HMarkdown/blob/main/Markdown/LICENSE)，请自由地享受和参与开源。
