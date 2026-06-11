/**
 * 引用块组件
 *
 * 左侧显示彩色竖线分隔符，右侧通过 MarkdownComponent 递归渲染嵌套内容。
 */
import { Tokens } from '../core'
import { MarkdownOptions } from '../Index'
import { getTheme } from '../utils'
import { MarkdownTheme } from '../config/MarkdownTheme'
import { MarkdownComponent } from './MarkdownComponent'

@ComponentV2
export struct BlockQuote {
  @Param @Require token: Tokens.Blockquote
  @Param @Require options: MarkdownOptions
  @Local blockHeight: Length = 0

  get theme(): MarkdownTheme {
    return getTheme(this.options)
  }

  build() {
    Row() {
      Divider()
        .vertical(true)
        .strokeWidth(this.theme.blockQuoteStyle?.dividerWidth)
        .height(this.blockHeight)
        .color(this.theme.blockQuoteStyle?.dividerColor)
      MarkdownComponent({ tokenList: this.token?.tokens, options: this.options })
        .margin({
          left: this.theme.blockQuoteStyle?.contentMargin?.left ?? 10,
          right: this.theme.blockQuoteStyle?.contentMargin?.right ?? 20
        })
        .layoutWeight(1)
        .padding({ top: this.options.inlineLineSpace, bottom: this.options.inlineLineSpace })
    }
    .backgroundColor(this.theme.blockQuoteStyle?.backgroundColor)
    .borderRadius(this.theme.blockQuoteStyle?.borderRadius)
    .onSizeChange((_: SizeOptions, newValue: SizeOptions) => {
      if (newValue.height) {
        this.blockHeight = newValue.height
      }
    })
  }
}
