/**
 * Markdown 根渲染组件
 *
 * 遍历块级 Token 数组，将每个 token 委托给 BlockRenderDispatcher 渲染。
 */
import { Token } from '../core'
import { MarkdownOptions } from '../Index'
import { BlockRenderDispatcher } from '../render/BlockRenderDispatcher'

@ComponentV2
export struct MarkdownComponent {
  @Param @Require tokenList: Token[] = []
  @Param @Require options: MarkdownOptions
  @Param streaming: boolean = false
  @Param nestedScroll: NestedScrollOptions | undefined = undefined
  @Param contentStartOffset: number | undefined = undefined
  @Param contentEndOffset: number | undefined = undefined
  @Param paddings: Padding | number | undefined = undefined
  @Param scrollBar: BarState | undefined = undefined
  @Param cachedCount: number = 0
  @Param cachedShow: boolean = false

  private scroller: Scroller = new Scroller()

  @Monitor('tokenList')
  onTokenListChange(): void {
    if (this.streaming && this.tokenList.length > 0) {
      setTimeout(() => {
        this.scroller.scrollEdge(Edge.Bottom)
      }, 50)
    }
  }

  build() {
    List({ space: this.options.lineSpace, scroller: this.scroller }) {
      Repeat<Token>(this.tokenList)
        .each((repeatItem) => {
          BlockRenderDispatcher({ token: repeatItem.item, options: this.options })
        })
        .key((item: Token, index: number): string => {
          return `${item.type}_${index}_${item.raw.substring(0, 64)}`
        })
    }
    .width('100%')
    .clip(false)
    .nestedScroll(this.nestedScroll)
    .contentStartOffset(this.contentStartOffset)
    .contentEndOffset(this.contentEndOffset)
    .padding(this.paddings)
    .scrollBar(this.scrollBar)
    .cachedCount(this.cachedCount, this.cachedShow)
  }
}
