/**
 * 代码块组件
 *
 * 渲染围栏/缩进代码块，支持基础语法高亮和一键复制。
 * 通过 @Monitor 响应 token 和 options 变化。
 */
import { Tokens } from '../core'
import { CodeToken, CodeType, highlightCodeAnalyzer } from '../core/analyzer/HighlightAnalyzer'
import { MarkdownOptions } from '../Index'
import { CodeHighlightColors } from '../config/MarkdownTheme'
import { copyToPasteboard, getTheme } from '../utils'

/** 根据 token 类型从 CodeHighlightColors 中取出对应颜色（ArkTS 不允许索引访问） */
function colorForType(colors: CodeHighlightColors, type: CodeType): ResourceColor | undefined {
  switch (type) {
    case 'code': return colors.code
    case 'keyword': return colors.keyword
    case 'type': return colors.type
    case 'number': return colors.number
    case 'symbol': return colors.symbol
    case 'string': return colors.string
    case 'text': return colors.text
    case 'boolean': return colors.boolean
    default: return undefined
  }
}

@ComponentV2
export struct Code {
  @Param @Require token: Tokens.Code
  @Param @Require options: MarkdownOptions
  @Local codeLines: string[] = []

  aboutToAppear(): void {
    this.updateCodeLines()
  }

  @Monitor('token')
  watchToken(): void {
    this.updateCodeLines()
  }

  private updateCodeLines(): void {
    this.codeLines = this.token?.text.split('\n') ?? []
  }

  get theme() {
    return getTheme(this.options)
  }

  get lineHeight(): number {
    return this.theme.code?.codeLineHeight ?? 25
  }

  @Builder
  codeLine(code: string) {
    Text() {
      ForEach(highlightCodeAnalyzer(code), (token: CodeToken) => {
        Span(token.text)
          .fontColor(colorForType(this.theme.code?.fontColor ?? {}, token.type))
          .fontSize(this.theme.code?.fontSize)
      })
    }
    .textAlign(TextAlign.Start)
  }

  build() {
    Row() {
      Column() {
        Scroll() {
          Column() {
            ForEach(this.codeLines, (code: string) => {
              Row() {
                this.codeLine(code)
              }
              .height(this.lineHeight)
            })
          }
          .alignItems(HorizontalAlign.Start)
          .padding({ top: 15, bottom: 15, left: 10, right: 5 })
        }
        .scrollable(ScrollDirection.Horizontal)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Image(this.theme.code?.copyIcon || $r('app.media.ic_copy'))
        .fillColor(this.theme.code?.copyIconColor || '#fff')
        .width(20)
        .height(20)
        .margin({ right: 8, top: 8 })
        .onClick(() => {
          copyToPasteboard(this.token?.text)
        })
    }
    .width('100%')
    .borderRadius(this.theme.code?.borderRadius)
    .alignItems(VerticalAlign.Top)
    .backgroundColor(this.theme.code?.backgroundColor)
  }
}
