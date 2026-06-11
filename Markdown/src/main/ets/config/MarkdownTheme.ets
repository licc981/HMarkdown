/**
 * Markdown 主题接口定义
 *
 * 定义主题系统的所有可配置样式接口，所有属性均为可选以支持部分覆盖。
 */

/** 字体样式 */
export interface MarkdownFontStyle {
  fontColor?: ResourceColor
  fontWeight?: FontWeight
  fontSize?: Length
}

/** 引用块内容区边距 */
export interface BlockQuoteMargin {
  left?: Length
  right?: Length
}

/** 引用块样式 */
export interface BlockQuoteStyle {
  backgroundColor?: ResourceColor
  borderRadius?: Length
  /** 左侧分隔线颜色 */
  dividerColor?: ResourceColor
  /** 左侧分隔线宽度 */
  dividerWidth?: string | number
  /** 内容区左右边距 */
  contentMargin?: BlockQuoteMargin
}

/** 通用分隔线样式（用于表格边框、水平线等） */
export interface DividerStyle {
  dividerColor?: ResourceColor
  dividerWidth?: string | number
}

/** 列表样式 */
export interface ListStyle {
  marginLeft?: Length
  /** 无序列表圆点大小 */
  bulletSize?: number
}

/** 代码高亮颜色映射 */
export interface CodeHighlightColors {
  code?: ResourceColor
  text?: ResourceColor
  string?: ResourceColor
  keyword?: ResourceColor
  type?: ResourceColor
  symbol?: ResourceColor
  number?: ResourceColor
  boolean?: ResourceColor
}

/** 代码块样式 */
export interface CodeStyle {
  /** 语法高亮颜色映射 */
  fontColor?: CodeHighlightColors
  fontWeight?: FontWeight
  fontSize?: Length
  backgroundColor?: ResourceColor
  borderRadius: Length | BorderRadiuses | LocalizedBorderRadiuses
  /** 代码行高 */
  codeLineHeight?: number
  /** 行内代码圆角 */
  codeSpanBorderRadius?: Dimension | BorderRadiuses
  /** 行内代码背景色 */
  codeSpanBackgroundColor?: ResourceColor
  /** 复制按钮图标 */
  copyIcon?: ResourceStr
  copyIconColor?: ResourceColor
}

/** 行内代码片段样式 */
export interface CodeSpanStyle {
  backgroundColor?: ResourceColor
  borderRadius?: Dimension | BorderRadiuses
}

/** LaTeX 公式样式 */
export interface LatexStyle {
  fontSize?: number
  fontColor?: number
  backgroundColor?: number
}

export interface MarkdownTheme {
  /** 主题色 */
  themeColor?: ResourceColor
  /** 背景色 */
  backgroundColor?: ResourceColor
  /** 默认字体样式 */
  fontStyle?: MarkdownFontStyle
  /** 标题样式 (h1-h6，索引 0-5) */
  headingStyle?: MarkdownFontStyle[]
  /** 引用块样式 */
  blockQuoteStyle?: BlockQuoteStyle
  /** 表格分隔线样式 */
  tableStyle?: DividerStyle
  /** 列表样式 */
  listStyle?: ListStyle
  /** 段落样式 */
  paragraphStyle?: MarkdownFontStyle
  /** LaTeX 公式样式 */
  latexStyle?: LatexStyle
  /** 代码块及行内代码样式 */
  code?: CodeStyle
  /** 行内代码片段样式 */
  codeSpan?: CodeSpanStyle
  /** 水平分隔线样式 */
  hrStyle?: DividerStyle
  /** 超链接颜色（不设置则为主题色） */
  linkColor?: ResourceColor
  /** 图片填充模式 */
  imageObjectFit?: ImageFit
  /** HTML 块字体样式 */
  html?: MarkdownFontStyle
}

/** 代码高亮 token 类型（需与 core/analyzer/HighlightAnalyzer 的 CodeType 一致） */
export type CodeHighLight = 'string' | 'text' | 'keyword' | 'type' | 'symbol' | 'number' | 'boolean'
