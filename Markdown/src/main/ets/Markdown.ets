/**
 * Markdown 主组件
 *
 * 顶层公共 API 组件。接收原始 content（字符串）或预解析的 token[]，
 * 管理解析生命周期和主题解析，渲染 MarkdownComponent。
 *
 * 当 streaming = true 时，组件内部逐字符渐进展示内容并自动滚动到底部，
 * 调用方只需传入完整 content 并控制 streaming 开关即可。
 */
import { Token } from './core'
import { MarkdownComponent } from './component/MarkdownComponent'
import { MarkdownOptions } from './Index'
import { defaultDarkTheme, defaultTheme } from './config/DefaultTheme'
import { LengthMetrics } from '@kit.ArkUI'
import { BusinessError } from '@kit.BasicServicesKit'
import { MarkdownParseService } from './service/MarkdownParseService'
import { parseMarkdownLocal } from './utils'
import { resolveThemeBundle } from './theme/ThemeResolver'

@ComponentV2
export struct Markdown {
  /** 原始 Markdown 文本（与 token 二选一） */
  @Param content: string = ''

  /** 是否为流式输出模式：内部逐字符渐进渲染并自动滚动到底部 */
  @Param streaming: boolean = false
  /** 配置项：主题、暗色模式、解析选项等 */
  @Param options: MarkdownOptions = {
    theme: defaultTheme,
    darkTheme: defaultDarkTheme,
    lineSpace: 12,
    inlineLineSpace: LengthMetrics.vp(12)
  }

  /** 加载状态回调 */
  @Event onLoading?: () => void
  @Event onSuccess?: () => void
  @Event onError?: (e: BusinessError) => void

  /** 滚动与布局参数 */
  @Param nestedScroll: NestedScrollOptions | undefined = undefined
  @Param contentStartOffset: number | undefined = undefined
  @Param contentEndOffset: number | undefined = undefined
  @Param paddings: Padding | number | undefined = undefined
  @Param scrollBar: BarState | undefined = undefined
  @Param cachedCount: number = 0
  @Param cachedShow: boolean = false

  @Local tokenList: Token[] = []
  @Local streamingContent: string = ''
  private parseService: MarkdownParseService = new MarkdownParseService()
  private streamingTimer: number = -1
  private streamingIndex: number = 0

  aboutToAppear(): void {
    this.applyTheme()
     if (this.streaming && this.content.length > 0) {
      this.startStreaming()
    } else {
      this.onContentChange()
    }
  }

  aboutToDisappear(): void {
    this.stopStreamingTimer()
    this.parseService.dispose()
  }


  @Monitor('content')
  onContentChange(): void {
    if (this.streaming && this.content.length > 0) {
      this.startStreaming()
      return
    }
    this.stopStreamingTimer()
    this.parseService.updateByContent(this.content, this.options, this.tokenList.length, {
      onLoading: () => this.onLoading?.(),
      onSuccess: (tokens: Token[]) => {
        this.diffUpdateTokenList(tokens)
        this.onSuccess?.()
      },
      onError: (error: BusinessError) => {
        this.onError?.(error)
      }
    })
  }

  @Monitor('streaming')
  onStreamingChange(): void {
    if (!this.streaming) {
      this.stopStreamingTimer()
      this.streamingContent = this.content
      this.parseService.updateByContent(this.content, this.options, this.tokenList.length, {
        onSuccess: (tokens: Token[]) => {
          this.tokenList = tokens
        }
      })
    } else if (this.content.length > 0) {
      this.startStreaming()
    }
  }

  // ─── 流式输出 ───

  private startStreaming(): void {
    this.stopStreamingTimer()
    this.streamingIndex = 0
    this.streamingContent = ''
    this.streamingTimer = setInterval(() => {
      if (this.streamingIndex >= this.content.length) {
        this.stopStreamingTimer()
        this.onSuccess?.()
        return
      }
      this.streamingContent += this.content.charAt(this.streamingIndex)
      this.streamingIndex++
      try {
        const tokens = parseMarkdownLocal(
          this.streamingContent,
          this.options?.options,
          this.options?.extensions
        )
        this.diffUpdateTokenList(tokens)
        this.onSuccess?.()
      } catch (e) {
        this.onError?.(e as BusinessError)
      }
    }, 30)
  }

  private stopStreamingTimer(): void {
    if (this.streamingTimer >= 0) {
      clearInterval(this.streamingTimer)
      this.streamingTimer = -1
    }
  }

  // ─── Token 增量更新 ───

  /**
   * 增量更新 Token 列表（流式输出防闪烁核心）
   *
   * 逐位对比新旧 Token：内容相同的保持原引用不变（组件不重建），
   * 内容变化或新增的替换为新对象，多余的移除。
   * 配合 Repeat.key() 使未变化的 List 子项完全跳过重建。
   */
  private diffUpdateTokenList(newTokens: Token[]): void {
    const oldList = this.tokenList
    const newLen = newTokens.length
    const oldLen = oldList.length
    const minLen = Math.min(oldLen, newLen)

    const result: Token[] = []

    for (let i = 0; i < minLen; i++) {
      if (oldList[i].raw === newTokens[i].raw && oldList[i].type === newTokens[i].type) {
        result.push(oldList[i])
      } else {
        result.push(newTokens[i])
      }
    }

    for (let i = minLen; i < newLen; i++) {
      result.push(newTokens[i])
    }

    this.tokenList = result
  }

  // ─── 主题 ───

  @Monitor('options')
  onOptionsChange(): void {
    this.applyTheme()
  }

  /** 将用户主题配置与默认主题深度合并 */
  private applyTheme(): void {
    if (!this.options) {
      return
    }
    const bundle = resolveThemeBundle(this.options)
    this.options.lineSpace = bundle.lineSpace
    this.options.inlineLineSpace = bundle.inlineLineSpace
    this.options.theme = bundle.theme
    this.options.darkTheme = bundle.darkTheme
  }

  // ─── 渲染 ───

  build() {
    if (this.tokenList.length > 0) {
      MarkdownComponent({
        tokenList: this.tokenList,
        options: this.options,
        streaming: this.streaming,
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
