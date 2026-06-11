/**
 * Markdown 解析引擎
 *
 * 工厂函数：创建配置好的 Marked 实例并提供一次性解析能力。
 * 默认注册 LaTeX 扩展（块级 + 行内）。
 */
import { Marked, MarkedOptions, Token, TokenizerExtension } from '../core'
import { latexBlock, latexInline } from '../core/plugins/latex'

/** 创建配置好的 Marked 解析引擎实例 */
export function createMarkdownEngine(
  markedOptions?: MarkedOptions,
  markedExtensions?: TokenizerExtension[]
): Marked {
  const marked = new Marked()
  const extensions = [...(markedExtensions ?? []), latexBlock(), latexInline()]
  marked.setOptions(markedOptions)
  marked.use({ extensions: extensions })
  return marked
}

/** 使用 Marked 引擎一次性解析 Markdown 内容为 Token 数组 */
export function parseByMarkdownEngine(
  content: string,
  markedOptions?: MarkedOptions,
  markedExtensions?: TokenizerExtension[]
): Token[] {
  if (!content) {
    return []
  }
  return createMarkdownEngine(markedOptions, markedExtensions).lexer(content)
}
