/**
 * 段落组件
 *
 * 将段落子 token 委托给 Inline 组件渲染。
 */
import { Tokens } from '../core'
import { MarkdownOptions } from '../Index'
import { Inline } from './Inline'

@ComponentV2
export struct Paragraph {
  @Param @Require token: Tokens.Paragraph
  @Param @Require options: MarkdownOptions

  build() {
    Inline({ token: this.token?.tokens, options: this.options })
  }
}
