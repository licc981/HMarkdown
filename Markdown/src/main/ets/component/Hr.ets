/**
 * 水平分隔线组件
 */
import { MarkdownOptions } from '../Index'
import { MarkdownTheme } from '../config/MarkdownTheme'
import { getTheme } from '../utils'

@ComponentV2
export struct Hr {
  @Param @Require options: MarkdownOptions

  get theme(): MarkdownTheme {
    return getTheme(this.options)
  }

  build() {
    Divider()
      .strokeWidth(this.theme.hrStyle?.dividerWidth)
      .height(this.theme.hrStyle?.dividerWidth)
      .color(this.theme.hrStyle?.dividerColor)
  }
}
