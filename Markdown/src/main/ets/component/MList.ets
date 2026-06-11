/**
 * 列表组件
 *
 * 渲染有序和无序列表，支持递归嵌套。
 */
import { Token, Tokens } from '../core'
import { Inline } from './Inline'
import { MarkdownOptions } from '../Index'
import { MarkdownTheme } from '../config/MarkdownTheme'
import { getTheme } from '../utils'

@ComponentV2
export struct MList {
  @Param @Require tokens: Tokens.List
  @Param @Require options: MarkdownOptions

  get theme(): MarkdownTheme {
    return getTheme(this.options)
  }

  build() {
    Column({ space: this.options.lineSpace }) {
      ForEach(this.tokens?.items, (item: Tokens.ListItem, index: number) => {
        Row({ space: 8 }) {
          if (this.tokens.ordered) {
            Text(typeof this.tokens.start === 'number' ? `${this.tokens.start + index}.` : '')
              .fontColor(this.theme.fontStyle?.fontColor)
              .fontSize(this.theme.fontStyle?.fontSize)
              .fontWeight(this.theme.fontStyle?.fontWeight)
              .lineSpacing(this.options.inlineLineSpace)
          } else {
            Circle({ width: this.theme.listStyle?.bulletSize ?? 6, height: this.theme.listStyle?.bulletSize ?? 6 })
              .margin({ top: this.calcBulletMarginTop(item.text) })
              .foregroundColor(this.theme.themeColor)
          }
          Column({ space: this.options.lineSpace }) {
            ForEach(item.tokens, (itemChild: Token, _: number) => {
              if (itemChild.type === 'list') {
                MList({ tokens: itemChild as Tokens.List, options: this.options })
                  .padding({ left: this.theme.listStyle?.marginLeft })
              } else if (itemChild.type === 'space') {
                Stack()
              } else {
                Inline({ token: (itemChild as Tokens.Text).tokens ?? [], options: this.options })
              }
            }, (item: Token) => item.raw)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
      }, (item: Tokens.ListItem) => item.raw)
    }
    .layoutWeight(1)
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  /** 计算圆点垂直居中偏移量（对齐首行文本中心） */
  private calcBulletMarginTop(tokenText: string | undefined): number {
    if (!tokenText) {
      return 0
    }
    const bulletSize = this.theme.listStyle?.bulletSize ?? 6
    try {
      const measured = this.getUIContext().getMeasureUtils().measureTextSize({
        textContent: tokenText,
        constraintWidth: '100%',
        fontSize: this.theme.fontStyle?.fontSize,
        maxLines: 1
      })
      const textHeight = measured.height
      if (typeof textHeight === 'number') {
        const lineSpacing = typeof this.options.lineSpace === 'number'
          ? this.options.lineSpace
          : parseFloat(String(this.options.lineSpace)) || 0
        return this.getUIContext().px2vp(textHeight) / 2 - bulletSize / 2 + lineSpacing / 2
      }
    } catch (e) {
      console.warn('[HMarkdown] 列表圆点位置计算失败:', (e as Error)?.message)
    }
    return 0
  }
}
