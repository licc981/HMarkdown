/**
 * 工具函数集
 *
 * 提供 HTML 实体解码、剪贴板操作、LaTeX 渲染、主题获取等公共工具。
 */
import { LatexMathColorFormat, latexStringToImage } from '@cangjie-tpc/formula_hybrid'
import { promptAction } from '@kit.ArkUI'
import { BusinessError, pasteboard } from '@kit.BasicServicesKit'
import { MarkedOptions, Token, TokenizerExtension } from './core'
import { image } from '@kit.ImageKit'
import { defaultDarkTheme, defaultTheme } from './config/DefaultTheme'
import { MarkdownTheme } from './config/MarkdownTheme'
import { MarkdownOptions } from './Index'
import { parseByMarkdownEngine } from './engine/MarkdownParseEngine'

/** 清理 HTML 实体字符 */
export function clearMarkdown(content: string): string {
  return content
    .replaceAll('&amp;', '&')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&#39;', "'")
}

/** 用于 taskpool 子线程的解析函数（@Concurrent 装饰器为 taskpool 所必需） */
@Concurrent
export function parseMarkdown(content: string, markedOptions?: MarkedOptions,
  markedExtensions?: TokenizerExtension[]): Token[] {
  return parseByMarkdownEngine(content, markedOptions, markedExtensions)
}

/** 主线程同步解析函数（用于包含自定义扩展的场景，因扩展不可序列化到 worker） */
export function parseMarkdownLocal(content: string, markedOptions?: MarkedOptions,
  markedExtensions?: TokenizerExtension[]): Token[] {
  return parseByMarkdownEngine(content, markedOptions, markedExtensions)
}

/** 将表格对齐字符串转换为 ArkUI TextAlign 枚举 */
export function textAlign(align?: 'center' | 'left' | 'right' | null): TextAlign {
  if (align === 'left') {
    return TextAlign.Start
  }
  if (align === 'right') {
    return TextAlign.End
  }
  return TextAlign.Center
}

/** 复制文本到系统剪贴板并显示 Toast 反馈 */
export async function copyToPasteboard(text?: string): Promise<void> {
  if (!text) {
    return
  }
  try {
    const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
    const systemPasteboard = pasteboard.getSystemPasteboard()
    await systemPasteboard.setData(pasteData)
    promptAction.showToast({ message: $r('app.string.copy_success') })
  } catch (err) {
    const error = err as BusinessError
    console.warn(`[HMarkdown] 复制失败: ${error.message}`)
    promptAction.showToast({ message: $r('app.string.copy_failed') })
  }
}

/** LaTeX 公式渲染结果 */
export interface LatexRenderResult {
  pixelMap: image.PixelMap
  width: number
  height: number
}

/** 公式渲染缓存（相同公式 + 相同样式参数直接返回缓存，避免流式输出时重复渲染导致闪烁） */
const _latexCache: Map<string, LatexRenderResult> = new Map()

/** 将 LaTeX 公式字符串渲染为图片 */
export async function latexToPixelMap(
  latexText: string,
  fontSize: number,
  fontColor: number,
  backgroundColor: number,
  resPath?: string
): Promise<LatexRenderResult> {
  const cacheKey: string = `${latexText}|${fontSize}|${fontColor}|${backgroundColor}|${resPath ?? ''}`
  const cached = _latexCache.get(cacheKey)
  if (cached) {
    return cached
  }

  const buf: ArrayBuffer = await latexStringToImage(
    latexText, fontSize, fontColor, backgroundColor,
    LatexMathColorFormat.COLOR_FORMAT_BGRA_8888, resPath
  )
  const imageSource = image.createImageSource(buf)
  const pixelMap = imageSource.createPixelMapSync()
  const size: Size = pixelMap.getImageInfoSync().size
  const result: LatexRenderResult = {
    pixelMap,
    width: size.width,
    height: size.height
  }
  _latexCache.set(cacheKey, result)
  return result
}

/** 根据 darkMode 标志获取当前生效的主题 */
export const getTheme =
  (options?: MarkdownOptions): MarkdownTheme => options?.darkMode
    ? (options?.darkTheme ?? defaultDarkTheme)
    : (options?.theme ?? defaultTheme)
