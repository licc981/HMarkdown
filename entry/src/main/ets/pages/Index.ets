/**
 * 演示页面
 *
 * 展示 Markdown 库的核心功能：主题切换、内容切换、流式输出和各种配置选项。
 * 流式输出由 Markdown 组件内部处理，调用方只需传入 streaming 属性。
 */
import { Markdown } from '@lidary/markdown'
import { common } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { util } from '@kit.ArkTS'
import { promptAction } from '@kit.ArkUI'
import { AppUtils } from '@tangs/apputils'
import EntryAbility from '../entryability/EntryAbility'

const ALTERNATIVE_TEXT = '> 1. 第一项\n> 2. 第二项\n> 3. 第三项'

@Entry
@ComponentV2
struct Index {
  @Local text: string = ''
  @Local isDark: boolean = false
  @Local isLoading: boolean = true
  @Local isStreaming: boolean = false

  aboutToAppear(): void {
    this.loadMarkdownFile()

    EntryAbility.install.configurationUpdateListener = (config) => {
      this.isDark = config.colorMode === 0
    }
  }

  // ─── 文件加载 ───

  private loadMarkdownFile(): void {
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext
      context.resourceManager.getRawFileContent('mark_test.md', (error: BusinessError, value: Uint8Array) => {
        if (error != null) {
          console.error('[Demo] 文件加载失败:', error)
          this.isLoading = false
        } else {
          this.text = util.TextDecoder.create().decodeWithStream(value)
          this.isLoading = false
        }
      })
    } catch (e) {
      console.warn('[Demo] 读取文件异常:', (e as Error)?.message)
      this.isLoading = false
    }
  }

  // ─── UI ───

  build() {
    Stack() {
      Scroll() {
        Column() {
          Row() {
            Button(this.isDark ? '亮色主题' : '暗色主题')
              .onClick(() => {
                this.isDark = !this.isDark
              })

            Button('文本内容切换')
              .onClick(() => {
                this.isStreaming = false
                this.isLoading = true
                if (this.text === ALTERNATIVE_TEXT) {
                  this.loadMarkdownFile()
                } else {
                  this.text = ALTERNATIVE_TEXT
                  this.isLoading = false
                }
              })

            Button('流式输出')
              .onClick(() => {
                this.isLoading = false
                this.isStreaming = true
              })

            Button('停止流式')
              .onClick(() => {
                this.isStreaming = false
              })
          }
          .margin({ top: AppUtils.WindowUtil.getTopHeight() })

          Markdown({
            content: this.text,
            streaming: this.isStreaming,
            options: {
              darkMode: this.isDark,
              options: { gfm: true },
              darkTheme: { themeColor: Color.Orange },
              imageClick: (url?: string) => {
                promptAction.showToast({
                  message: `图片被点击: ${url}`,
                  duration: 1500,
                  bottom: 'center',
                })
              },
              linkClick: (url?: string) => {
                promptAction.showToast({
                  message: `超链接被点击: ${url}`,
                  duration: 1500,
                  bottom: 'center',
                })
              }
            },
            onLoading: () => {
              this.isLoading = true
            },
            onError: () => {
              this.isLoading = false
            },
            onSuccess: () => {
              this.isLoading = false
            },
            contentStartOffset: AppUtils.WindowUtil.getBottomHeight(),
            contentEndOffset: AppUtils.WindowUtil.getBottomHeight(),
            paddings: { left: 16, right: 16 },
            scrollBar: BarState.Off,
            nestedScroll: {
              scrollForward: NestedScrollMode.PARENT_FIRST,
              scrollBackward: NestedScrollMode.SELF_FIRST
            },
            cachedCount: 3,
            cachedShow: true
          }).height('100%')
        }
        .backgroundColor(this.isDark ? Color.Black : Color.White)
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)

      if (this.isLoading) {
        LoadingProgress()
          .size({ width: 40, height: 40 })
      }
    }
    .width('100%')
  }
}
