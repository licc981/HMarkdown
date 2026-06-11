/**
 * MarkdownOptions 接口定义
 *
 * 公共配置 API，使用者通过此接口配置 Markdown 组件的主题、事件和解析选项。
 */
import { MarkdownTheme } from './config/MarkdownTheme'
import { MarkedOptions, Token, TokenizerExtension } from './core'
import { LengthMetrics } from '@kit.ArkUI'
import { InlineParams } from './core/parseInlineToken'

/** 点击事件回调类型 */
export type OnClick = (url?: string) => void

/** Markdown 组件配置选项 */
export interface MarkdownOptions {
  /** 亮色主题 */
  theme?: MarkdownTheme
  /** 暗色主题 */
  darkTheme?: MarkdownTheme
  /** 块级元素间距 */
  lineSpace?: number | string
  /** 行内文本行间距 */
  inlineLineSpace?: LengthMetrics
  /** 是否启用暗色模式 */
  darkMode?: boolean
  /** Marked 解析配置 */
  options?: MarkedOptions
  /** Marked 扩展插件 */
  extensions?: TokenizerExtension[]
  /** 图片点击事件 */
  imageClick?: OnClick
  /** 超链接点击事件 */
  linkClick?: OnClick
  /** 自定义块级元素渲染 */
  customBlockBuilder?: WrappedBuilder<[Token, MarkdownOptions]>
  /** 自定义行内元素渲染 */
  customInlineBuilder?: (tokenItem: Token, params: InlineParams) => void
  /** 行内元素最大显示行数 */
  maxLines?: number
  /** LaTeX 公式资源路径 */
  latexResPath?: string
}
