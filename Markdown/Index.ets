/**
 * @lidary/markdown 公共 API 导出
 */

// 主题类型
export { MarkdownTheme, MarkdownFontStyle, DividerStyle, CodeHighLight, BlockQuoteStyle, ListStyle, CodeStyle, CodeSpanStyle, LatexStyle } from './src/main/ets/config/MarkdownTheme'

// 核心类型
export { TokenizerExtension, TokenizerStartFunction } from './src/main/ets/core/MarkedOptions'
export { MarkedToken, Token, Tokens, Links, TokensList } from './src/main/ets/core/Tokens'

// 配置
export { MarkdownOptions, OnClick } from './src/main/ets/Index'

// 主组件
export { Markdown } from './src/main/ets/Markdown'

// Marked 引擎 API
export {
  marked,
  options,
  setOptions,
  use,
  walkTokens,
  parseInline,
  parse,
  parser,
  lexer,
  defaults,
  getDefaults,
  Lexer,
  Parser,
  Tokenizer,
  Renderer,
  TextRenderer,
  Hooks,
  Marked
} from './src/main/ets/core/marked'
