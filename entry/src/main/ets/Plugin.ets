/**
 * 自定义 LaTeX 插件示例
 *
 * 这是一个使用正则表达式匹配的替代 LaTeX 插件实现，
 * 可作为 customBlockBuilder 配合使用。
 *
 * 注意：本插件使用 blockKatex/inlineKatex token 类型名，
 * 与库内置的 blockLatex/inlineLatex 不同。
 * 如需使用本插件，需同时提供 customBlockBuilder 来渲染 blockKatex 类型。
 *
 * 推荐直接使用库内置的 LaTeX 扩展（已通过 MarkdownParseEngine 自动注册）。
 */
import { TokenizerExtension, Tokens } from '@lidary/markdown'

const inlineRule = /^(\${1,2})(?!\$)((?:\\.|[^\\\n])*?(?:\\.|[^\\\n\$]))\1(?=[\s?!\.,:？！。，：]|$)/
const blockRule = /^(\${1,2})\n((?:\\[^]|[^\\])+?)\n\1(?:\n|$)/

export function latexBlockPlugin(): TokenizerExtension {
  return {
    name: 'blockKatex',
    level: 'block',
    tokenizer(src: string): Tokens.Generic | undefined {
      const match = src.match(blockRule)
      if (match) {
        return {
          type: 'blockKatex',
          raw: match[0],
          text: match[2].trim(),
          displayMode: match[1].length === 2,
        }
      }
      return undefined
    },
  }
}

export function latexInlinePlugin(): TokenizerExtension {
  return {
    name: 'inlineKatex',
    level: 'inline',
    start: (src: string): number | void => {
      let searchFrom = 0
      while (searchFrom < src.length) {
        const idx = src.indexOf('$', searchFrom)
        if (idx === -1) {
          return
        }
        if (idx === 0 || src.charAt(idx - 1) === ' ') {
          const candidate = src.substring(idx)
          if (candidate.match(inlineRule)) {
            return idx
          }
        }
        searchFrom = idx + 1
      }
    },
    tokenizer: (src: string): Tokens.Generic | undefined => {
      const match = src.match(inlineRule)
      if (match) {
        return {
          type: 'inlineKatex',
          raw: match[0],
          text: match[2].trim(),
          displayMode: match[1].length === 2
        }
      }
      return undefined
    },
  }
}
