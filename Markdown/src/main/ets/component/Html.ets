/**
 * HTML 块组件
 *
 * 将 HTML token 委托给 Inline 组件渲染。
 */
import { Token } from '../core'
import { MarkdownOptions } from '../Index'
import { Inline } from './Inline'

@ComponentV2
export struct Html {
  @Param @Require html: Token
  @Param @Require options: MarkdownOptions

  build() {
    Inline({ options: this.options, token: [this.html] })
  }
}
