import { Markdown } from '@lidary/markdown';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { promptAction } from '@kit.ArkUI';
import { AppUtils } from "@tangs/apputils"
import EntryAbility from '../entryability/EntryAbility';

@Entry
@ComponentV2
struct Index {
  @Local text: string = ''
  @Local isDark: boolean = false
  @Local isLoading: boolean = true
  @Local streamTimer: number = -1
  @Local streamIndex: number = 0

  streamChunks: string[] = [
    '# 流式输出 Demo\n\n',
    '这是一个模拟 LLM 流式返回的示例。\n\n',
    '## 特性\n',
    '- 支持逐段追加内容\n',
    '- 支持公式：$E = mc^2$\n',
    '- 支持代码块\n\n',
    '```ts\n',
    'function greet(name: string) {\n',
    "  return `hello ${name}`\n",
    '}\n',
    '```\n\n',
    '## 引用\n',
    '> 流式渲染应避免频繁重算导致闪烁。\n\n',
    '## 任务列表\n',
    '- [x] 开始流式输出\n',
    '- [x] 逐段渲染\n',
    '- [x] 停止流式输出\n'
  ]

  aboutToAppear(): void {
    this.readFile(getContext(this) as common.UIAbilityContext)

    EntryAbility.install.configurationUpdateListener = (config) => {
      this.isDark = config.colorMode == 0
    }
  }

  aboutToDisappear(): void {
    this.stopStreamingDemo()
  }

  startStreamingDemo() {
    this.stopStreamingDemo()
    this.isLoading = true
    this.streamIndex = 0
    this.text = ''
    this.streamTimer = setInterval(() => {
      if (this.streamIndex >= this.streamChunks.length) {
        this.stopStreamingDemo()
        return
      }
      this.text += this.streamChunks[this.streamIndex]
      this.streamIndex++
    }, 120)
  }

  stopStreamingDemo() {
    if (this.streamTimer >= 0) {
      clearInterval(this.streamTimer)
      this.streamTimer = -1
    }
  }

  readFile(context: common.UIAbilityContext) {
    try {
      context.resourceManager.getRawFileContent("mark_test.md", (error: BusinessError, value: Uint8Array) => {
        if (error != null) {
          console.error("error is " + error);
        } else {
          this.text = util.TextDecoder.create().decodeWithStream(value)
        }
      });
    } catch (_) {
    }
  }

  build() {
    Stack() {
      Scroll() {
        Column() {
          Row() {
            Button(this.isDark ? '亮色主题' : '暗色主题').onClick(() => {
              this.isDark = !this.isDark
            })
            Button('文本内容切换').onClick(() => {
              this.isLoading = true
              if (this.text === '> 1. 第一项\n' +
                '> 2. 第二项\n' +
                '> 3. 第三项') {
                this.readFile(getContext(this) as common.UIAbilityContext)
              } else {
                this.text =
                  '> 1. 第一项\n' +
                    '> 2. 第二项\n' +
                    '> 3. 第三项'
              }
            })
            Button('开始流式').onClick(() => {
              this.startStreamingDemo()
            })
            Button('停止流式').onClick(() => {
              this.stopStreamingDemo()
            })
          }
          .margin({top: AppUtils.WindowUtil.getTopHeight()})

          Markdown({
            content: this.text,
            options: {
              darkMode: this.isDark,
              options: {
                gfm: true
              },
              darkTheme: {
                themeColor: Color.Orange
              },
              imageClick: (url?: string) => {
                promptAction.showToast({
                  message: `图片被点击:${url}`,
                  duration: 1500,
                  bottom: "center",
                })
              },
              linkClick: (url?: string) => {
                promptAction.showToast({
                  message: `超链接被点击----url:${url}`,
                  duration: 1500,
                  bottom: "center",
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
            paddings: {left: 16, right: 16},
            scrollBar: BarState.Off,
            nestedScroll: {
              scrollForward: NestedScrollMode.PARENT_FIRST,
              scrollBackward: NestedScrollMode.SELF_FIRST
            },
            cachedCount: 3,
            cachedShow: true
          }).height("100%")
        }.backgroundColor(this.isDark ? Color.Black : Color.White)
        .width('100%')
      }.width('100%')
      .height("100%")
      .scrollBar(BarState.Off)
      if (this.isLoading) {
        LoadingProgress()
          .size({ width: 40, height: 40 })
      }
    }.width('100%')
  }
}

class TextAttr implements AttributeModifier<TextAttribute> {
  applyNormalAttribute(instance: TextAttribute): void {
    instance.copyOption(CopyOptions.InApp)
  }
}
