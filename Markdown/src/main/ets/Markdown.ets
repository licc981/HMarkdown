import { Token } from './core'
import { MarkdownComponent } from './component/MarkdownComponent'
import { MarkdownOptions } from './Index'
import { defaultDarkTheme, defaultTheme } from './config/DefaultTheme'
import { LengthMetrics } from '@kit.ArkUI'
import { BusinessError } from '@kit.BasicServicesKit'
import { MarkdownParseService } from './service/MarkdownParseService'
import { resolveThemeBundle } from './theme/ThemeResolver'


@ComponentV2
export struct Markdown {
  /**
   * 外层传入时仅需传递content或token
   */
  @Param token: Token[] = []
  @Param content: string = ''
  @Param options: MarkdownOptions = {
    theme: defaultTheme,
    darkTheme: defaultDarkTheme,
    lineSpace: 12,
    inlineLineSpace: LengthMetrics.vp(12)
  }
  @Event onLoading?: () => void
  @Event onSuccess?: () => void
  @Event onError?: (e: BusinessError) => void
  @Local tokenList: Token[] = []
  private parseService: MarkdownParseService = new MarkdownParseService()

  @Param nestedScroll: NestedScrollOptions | undefined = undefined
  @Param contentStartOffset: number | undefined = undefined
  @Param contentEndOffset: number | undefined = undefined
  @Param paddings: Padding | number | undefined = undefined
  @Param scrollBar: BarState | undefined = undefined
  @Param cachedCount: number = 0;
  @Param cachedShow: boolean = false;

  aboutToAppear(): void {
    this.watchOptions()
    if (this.token.length != 0) {
      this.watchToken()
    } else {
      this.watchContent()
    }
  }

  aboutToDisappear(): void {
    this.parseService.dispose()
  }

  @Monitor('token')
  watchToken() {
    this.parseService.updateByTokens(this.token, {
      onSuccess: (tokens: Token[]) => {
        this.tokenList = tokens
      },
      onError: (error: BusinessError) => {
        this.onError?.(error)
      }
    })
  }

  @Monitor('content')
  watchContent() {
    this.parseService.updateByContent(this.content, this.options, this.tokenList.length, {
      onLoading: () => {
        this.onLoading?.()
      },
      onSuccess: (tokens: Token[]) => {
        this.tokenList = tokens
        this.onSuccess?.()
      },
      onError: (error: BusinessError) => {
        this.onError?.(error)
      }
    })
  }

  @Monitor('options')
  watchOptions() {
    if (this.options) {
      const resolvedThemeBundle = resolveThemeBundle(this.options)
      this.options.lineSpace = resolvedThemeBundle.lineSpace
      this.options.inlineLineSpace = resolvedThemeBundle.inlineLineSpace
      this.options.theme = resolvedThemeBundle.theme
      this.options.darkTheme = resolvedThemeBundle.darkTheme
    }
  }

  build() {
    if (this.tokenList.length != 0) {
      MarkdownComponent({
        tokenList: this.tokenList,
        options: this.options,
        nestedScroll: this.nestedScroll,
        contentStartOffset: this.contentStartOffset,
        contentEndOffset: this.contentEndOffset,
        paddings: this.paddings,
        scrollBar: this.scrollBar,
        cachedCount: this.cachedCount,
        cachedShow: this.cachedShow
      })
    }
  }
}
