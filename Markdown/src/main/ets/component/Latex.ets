/**
 * 块级 LaTeX 公式组件
 *
 * 将 LaTeX 公式渲染为图片显示。
 */
import { image } from '@kit.ImageKit'
import { Tokens } from '../core'
import { MarkdownOptions } from '../Index'
import { MarkdownTheme } from '../config/MarkdownTheme'
import { getTheme, latexToPixelMap } from '../utils'

@ComponentV2
export struct Latex {
  @Param @Require token: Tokens.Generic
  @Param @Require options: MarkdownOptions
  @Local pixelMap: image.PixelMap | null = null
  @Local imageWidth: number = 0
  @Local imageHeight: number = 0

  get theme(): MarkdownTheme {
    return getTheme(this.options)
  }

  aboutToAppear(): void {
    this.renderLatex()
  }

  @Monitor('options.theme')
  watchTheme(): void {
    this.renderLatex()
  }

  @Monitor('token')
  watchToken(): void {
    this.renderLatex()
  }

  private renderLatex(): void {
    const uiContext = this.getUIContext()
    const t = this.theme

    latexToPixelMap(
      this.token.text,
      uiContext.fp2px(t.latexStyle?.fontSize),
      t.latexStyle?.fontColor ?? 0xffffffff,
      t.latexStyle?.backgroundColor ?? 0xffffffff,
      this.options.latexResPath
    ).then((data) => {
      if (data) {
        this.pixelMap = data.pixelMap
        this.imageWidth = uiContext.px2vp(data.width)
        this.imageHeight = uiContext.px2vp(data.height)
      }
    }).catch((e: Error) => {
      console.warn('[HMarkdown] LaTeX 块渲染失败:', e?.message)
    })
  }

  build() {
    Row() {
      if (this.pixelMap) {
        Image(this.pixelMap)
          .objectFit(ImageFit.Contain)
          .width(this.imageWidth)
          .height(this.imageHeight)
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }
}
