/**
 * 标题组件 (h1-h6)
 *
 * 通过 parseInlineToken 解析行内富文本，再叠加标题级别的字重和字号。
 */
import { Tokens } from '../core'
import { parseInlineToken } from '../core/parseInlineToken'
import { MarkdownOptions } from '../Index'
import { MarkdownTheme } from '../config/MarkdownTheme'
import { getTheme } from '../utils'

@ComponentV2
export struct Heading {
  @Param @Require token: Tokens.Heading
  @Param @Require options: MarkdownOptions
  private textController = new TextController()

  get theme(): MarkdownTheme {
    return getTheme(this.options)
  }

  aboutToAppear(): void {
    this.parseToken()
  }

  @Monitor('options.theme')
  watchTheme(): void {
    this.parseToken()
  }

  @Monitor('token')
  watchToken(): void {
    this.parseToken()
  }

  private parseToken(): void {
    if (!this.token?.tokens?.length) {
      return
    }

    const headingStyle = this.theme.headingStyle?.[this.token.depth]

    parseInlineToken({
      token: this.token.tokens,
      uiContext: this.getUIContext(),
      options: this.options,
    }).then((data: MutableStyledString | undefined) => {
      if (!data) {
        return
      }
      try {
        const textLen = data.getString().length
        if (textLen === 0) {
          return
        }
        // 保留行内格式（如链接颜色、粗体等），叠加标题级字重
        const fontStyles = data.getStyles(0, textLen, StyledStringKey.FONT)
        fontStyles?.forEach((e) => {
          data.replaceStyle({
            start: e.start,
            length: e.length,
            styledKey: StyledStringKey.FONT,
            styledValue: new TextStyle({
              fontWeight: headingStyle?.fontWeight,
              fontColor: e.styledValue['fontColor'],
            })
          })
        })
      } catch (e) {
        console.warn('[HMarkdown] 标题样式处理失败:', (e as Error)?.message)
      }
      this.textController.setStyledString(data)
    }).catch((e: Error) => {
      console.warn('[HMarkdown] 标题解析失败:', e?.message)
    })
  }

  build() {
    Text(undefined, { controller: this.textController })
      .fontColor(this.theme.headingStyle?.[this.token?.depth]?.fontColor)
      .fontSize(this.theme.headingStyle?.[this.token?.depth]?.fontSize)
      .fontWeight(this.theme.headingStyle?.[this.token?.depth]?.fontWeight)
      .lineSpacing(this.options.inlineLineSpace)
  }
}
