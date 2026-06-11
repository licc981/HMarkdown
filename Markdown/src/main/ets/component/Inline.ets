/**
 * 行内富文本组件
 *
 * 所有行内内容的核心渲染器（段落、列表项、表格单元格等）。
 * 通过 parseInlineToken 将 Token 数组转换为 MutableStyledString。
 */
import { Token } from '../core'
import { parseInlineToken } from '../core/parseInlineToken'
import { MarkdownOptions } from '../Index'
import { MarkdownTheme } from '../config/MarkdownTheme'
import { getTheme } from '../utils'

@ComponentV2
export struct Inline {
  @Param @Require options: MarkdownOptions
  @Param @Require token: Token[]
  private textController = new TextController()

  get theme(): MarkdownTheme {
    return getTheme(this.options)
  }

  aboutToAppear(): void {
    this.parseToken()
  }

  @Monitor('token', 'options')
  watchToken(): void {
    this.parseToken()
  }

  private parseToken(): void {
    parseInlineToken({
      token: this.token,
      options: this.options,
      uiContext: this.getUIContext()
    }).then((data: MutableStyledString | undefined) => {
      if (data) {
        this.textController.setStyledString(data)
      }
    }).catch((e: Error) => {
      console.warn('[HMarkdown] 行内解析失败:', e?.message)
    })
  }

  build() {
    Text(undefined, { controller: this.textController })
      .fontColor(this.theme.fontStyle?.fontColor)
      .fontSize(this.theme.fontStyle?.fontSize)
      .fontWeight(this.theme.fontStyle?.fontWeight)
      .maxLines(this.options.maxLines)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .lineSpacing(this.options.inlineLineSpace)
  }
}
