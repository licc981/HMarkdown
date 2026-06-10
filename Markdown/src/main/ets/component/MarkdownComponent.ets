import { Token } from '../core'
import { MarkdownOptions } from '../Index'
import { BlockRenderDispatcher } from '../render/BlockRenderDispatcher'

@ComponentV2
export struct MarkdownComponent {
  @Param @Require tokenList: Token[] = []
  @Param @Require options: MarkdownOptions
  @Param nestedScroll: NestedScrollOptions | undefined = undefined
  @Param contentStartOffset: number | undefined = undefined
  @Param contentEndOffset: number | undefined = undefined
  @Param paddings: Padding | number | undefined = undefined
  @Param scrollBar: BarState | undefined = undefined
  @Param cachedCount: number = 0;
  @Param cachedShow: boolean = false;

  build() {
    List({ space: this.options.lineSpace }) {
      Repeat(this.tokenList)
        .each((repeatItem) => {
          BlockRenderDispatcher({ token: repeatItem.item, options: this.options })
        })
    }.width('100%')
    .clip(false)
    .nestedScroll(this.nestedScroll)
    .contentStartOffset(this.contentStartOffset)
    .contentEndOffset(this.contentEndOffset)
    .padding(this.paddings)
    .scrollBar(this.scrollBar)
    .cachedCount(this.cachedCount, this.cachedShow)
  }
}
