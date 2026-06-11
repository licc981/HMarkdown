/**
 * LaTeX 数学公式扩展
 *
 * 为 Marked 解析器提供块级 ($$...$$) 和行内 ($...$) LaTeX 公式的 tokenizer 扩展。
 */
import { TokenizerExtension, Tokens } from '../marked'

/** 块级 LaTeX 扩展 ($$...$$) */
export function latexBlock(): TokenizerExtension {
  return {
    name: 'blockLatex',
    level: 'block',
    start: (src: string): number | void => {
      // 查找有效的 $$ 开头（必须在行首或紧跟空白字符）
      let searchFrom = 0
      while (searchFrom < src.length) {
        const idx = src.indexOf('$$', searchFrom)
        if (idx === -1) {
          return
        }
        if (idx === 0 || /\s/.test(src.charAt(idx - 1))) {
          return idx
        }
        searchFrom = idx + 1
      }
    },
    tokenizer(src: string): Tokens.Generic | undefined {
      if (!src.startsWith('$$')) {
        return undefined
      }
      const endIndex = src.indexOf('$$', 2)
      if (endIndex === -1) {
        return undefined
      }
      return {
        type: 'blockLatex',
        raw: src.substring(0, endIndex + 2),
        text: src.substring(2, endIndex).trim()
      }
    },
  }
}

/** 行内 LaTeX 扩展 ($...$) */
export function latexInline(): TokenizerExtension {
  return {
    name: 'inlineLatex',
    level: 'inline',
    start: (src: string): number | void => {
      // 查找有效的 $ 开头（不能在行首/串首之后紧跟另一个 $）
      let searchFrom = 0
      while (searchFrom < src.length) {
        const idx = src.indexOf('$', searchFrom)
        if (idx === -1) {
          return
        }
        // 排除 $$ 的情况（块级公式由 latexBlock 处理）
        if (src.charAt(idx + 1) !== '$') {
          return idx
        }
        searchFrom = idx + 2
      }
    },
    tokenizer: (src: string): Tokens.Generic | undefined => {
      if (!src.startsWith('$') || src.startsWith('$$')) {
        return undefined
      }
      const endIndex = src.indexOf('$', 1)
      if (endIndex === -1) {
        return undefined
      }
      return {
        type: 'inlineLatex',
        raw: src.substring(0, endIndex + 1),
        text: src.substring(1, endIndex).trim()
      }
    },
  }
}
