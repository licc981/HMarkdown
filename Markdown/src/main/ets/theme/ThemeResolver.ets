/**
 * 主题解析器
 *
 * 将用户部分主题覆盖与默认主题深度合并，生成完整解析后的主题配置。
 */
import { LengthMetrics } from '@kit.ArkUI'
import { defaultDarkTheme, defaultTheme } from '../config/DefaultTheme'
import { MarkdownTheme } from '../config/MarkdownTheme'
import { MarkdownOptions } from '../Index'
import deepMerge from '../merge'

/** 解析后的主题包 */
export interface ResolvedThemeBundle {
  theme: MarkdownTheme
  darkTheme: MarkdownTheme
  lineSpace: number | string
  inlineLineSpace: LengthMetrics
}

/** 将用户选项与默认主题合并 */
export function resolveThemeBundle(options?: MarkdownOptions): ResolvedThemeBundle {
  return {
    lineSpace: options?.lineSpace ?? 12,
    inlineLineSpace: options?.inlineLineSpace ?? LengthMetrics.vp(12),
    theme: deepMerge(defaultTheme, options?.theme),
    darkTheme: deepMerge(defaultDarkTheme, options?.darkTheme)
  }
}

/** 根据 darkMode 标志获取当前生效的主题 */
export function getActiveTheme(options?: MarkdownOptions): MarkdownTheme {
  return options?.darkMode
    ? (options?.darkTheme ?? defaultDarkTheme)
    : (options?.theme ?? defaultTheme)
}
