/**
 * 行内 Token 渲染器
 *
 * 将行内 Token 数组递归转换为 MutableStyledString，供 ArkUI Text 组件渲染。
 * 每种 token 类型通过专用处理函数实现，共享主题缓存避免重复查找。
 */
import { MarkdownOptions } from '../Index'
import { clearMarkdown, getTheme, latexToPixelMap } from '../utils'
import { Token, Tokens } from './Tokens'
import { MarkdownTheme } from '../config/MarkdownTheme'

/** 行内 token 渲染参数 */
export interface InlineParams {
  token: Token[]
  options: MarkdownOptions
  uiContext: UIContext
  inlineTextStyle?: MutableStyledString
  isLink?: boolean
  fontWeight?: FontWeight
  onSpanClick?: () => void
}

// ─── 主题缓存（模块级，避免递归时重复查找） ───

let _cachedTheme: MarkdownTheme | null = null

function theme(): MarkdownTheme {
  return _cachedTheme!
}

// ─── 基础工具函数 ───

/** 获取当前文本颜色（链接模式下使用 linkColor） */
function textColor(isLink: boolean | undefined): ResourceColor | undefined {
  return isLink ? theme().linkColor : theme().fontStyle?.fontColor
}

/** 追加一段带样式的文本到 StyledString */
function appendStyledText(
  styledString: MutableStyledString,
  text: string,
  isLink: boolean | undefined,
  fontWeight: FontWeight | undefined,
  italic: boolean,
  strikethrough: boolean,
  onClick: (() => void) | undefined
): void {
  if (text.length === 0) {
    return
  }
  const start = styledString.length

  // 追加字体样式
  styledString.appendStyledString(new MutableStyledString(text, [{
    start: 0,
    length: text.length,
    styledKey: StyledStringKey.FONT,
    styledValue: new TextStyle({
      fontColor: textColor(isLink),
      fontWeight: fontWeight ?? theme().fontStyle?.fontWeight,
      fontStyle: italic ? FontStyle.Italic : undefined,
    })
  }]))

  // 追加删除线样式
  if (strikethrough) {
    styledString.setStyle({
      start: start,
      length: text.length,
      styledKey: StyledStringKey.DECORATION,
      styledValue: new DecorationStyle({
        type: TextDecorationType.LineThrough,
        color: textColor(isLink),
        style: TextDecorationStyle.SOLID
      })
    })
  }

  // 追加手势样式
  if (onClick) {
    styledString.setStyle({
      start: start,
      length: text.length,
      styledKey: StyledStringKey.GESTURE,
      styledValue: new GestureStyle({ onClick: onClick })
    })
  }
}

// ─── 各类型 Token 处理器 ───

async function handleImage(params: InlineParams, token: Tokens.Image): Promise<void> {
  const ss = params.inlineTextStyle!
  ss.appendStyledString(new MutableStyledString(new ImageAttachment({
    resourceValue: token.href,
    verticalAlign: ImageSpanAlignment.CENTER,
    size: { width: '100%' },
    objectFit: theme().imageObjectFit,
  })))
  try {
    ss.setStyle({
      start: ss.length - 1,
      length: 1,
      styledKey: StyledStringKey.GESTURE,
      styledValue: new GestureStyle({
        onClick: () => params.options.imageClick?.(token.href)
      })
    })
  } catch (e) {
    console.warn('[HMarkdown] 图片手势设置失败:', (e as Error)?.message)
  }
}

function handleBr(params: InlineParams): void {
  params.inlineTextStyle!.appendStyledString(new MutableStyledString('\n'))
}

async function handleStrong(params: InlineParams, token: Tokens.Strong): Promise<void> {
  if (token.tokens && token.tokens.length > 0) {
    await parseInlineToken({
      token: token.tokens,
      options: params.options,
      inlineTextStyle: params.inlineTextStyle,
      fontWeight: FontWeight.Bold,
      isLink: params.isLink,
      uiContext: params.uiContext,
      onSpanClick: params.onSpanClick
    })
  } else {
    appendStyledText(params.inlineTextStyle!, clearMarkdown(token.text),
      params.isLink, FontWeight.Bold, false, false, params.onSpanClick)
  }
}

function handleDel(params: InlineParams, token: Tokens.Del): void {
  appendStyledText(params.inlineTextStyle!, clearMarkdown(token.text),
    params.isLink, undefined, false, true, params.onSpanClick)
}

function handleText(params: InlineParams, token: Tokens.Text): void {
  appendStyledText(params.inlineTextStyle!, clearMarkdown(token.text),
    params.isLink, params.fontWeight, false, false, params.onSpanClick)
}

function handleEm(params: InlineParams, token: Tokens.Em): void {
  appendStyledText(params.inlineTextStyle!, clearMarkdown(token.text),
    params.isLink, undefined, true, false, params.onSpanClick)
}

function handleCodespan(params: InlineParams, token: Tokens.Codespan): void {
  const codeText = `  ${clearMarkdown(token.text)}  `
  const ss = params.inlineTextStyle!
  ss.appendStyledString(new MutableStyledString(codeText, [{
    start: 0,
    length: codeText.length,
    styledKey: StyledStringKey.FONT,
    styledValue: new TextStyle({
      fontColor: theme().fontStyle?.fontColor
    })
  }, {
    start: 0,
    length: codeText.length,
    styledKey: StyledStringKey.BACKGROUND_COLOR,
    styledValue: new BackgroundColorStyle({
      color: theme().codeSpan?.backgroundColor,
      radius: theme().codeSpan?.borderRadius
    })
  }]))
}

async function handleLink(params: InlineParams, token: Tokens.Link): Promise<void> {
  await parseInlineToken({
    token: token.tokens ?? [],
    options: params.options,
    inlineTextStyle: params.inlineTextStyle,
    fontWeight: params.fontWeight,
    uiContext: params.uiContext,
    isLink: true,
    onSpanClick: () => params.options.linkClick?.(token.href)
  })
}

async function handleInlineLatex(params: InlineParams, token: Tokens.Generic): Promise<void> {
  try {
    const t = theme()
    const imageInfo = await latexToPixelMap(
      token.text,
      params.uiContext.fp2px(t.latexStyle?.fontSize),
      t.latexStyle?.fontColor ?? 0xffffffff,
      t.latexStyle?.backgroundColor ?? 0xffffffff,
      params.options.latexResPath
    )
    params.inlineTextStyle!.appendStyledString(new MutableStyledString(new ImageAttachment({
      value: imageInfo.pixelMap,
      verticalAlign: ImageSpanAlignment.CENTER,
      size: {
        width: params.uiContext.px2vp(imageInfo.width),
        height: params.uiContext.px2vp(imageInfo.height)
      },
      objectFit: ImageFit.Contain,
    })))
  } catch (e) {
    console.warn('[HMarkdown] LaTeX 渲染失败:', (e as Error)?.message)
  }
}

async function handleHtml(params: InlineParams, token: Tokens.HTML): Promise<void> {
  if (token.block) {
    try {
      const htmlStyledString = await StyledString.fromHtml(token.text)
      params.inlineTextStyle!.appendStyledString(htmlStyledString)
    } catch (e) {
      console.warn('[HMarkdown] HTML 渲染失败:', (e as Error)?.message)
    }
  }
}

// ─── 主函数 ───

/** 将行内 Token 数组递归解析为 MutableStyledString */
export async function parseInlineToken(params: InlineParams): Promise<MutableStyledString | undefined> {
  // 初始化 StyledString 和主题缓存
  const isRoot = params.inlineTextStyle === undefined
  if (isRoot) {
    params.inlineTextStyle = new MutableStyledString('')
    _cachedTheme = getTheme(params.options)
  }

  try {
    for (const token of params.token) {
      switch (token.type) {
        case 'image':
          await handleImage(params, token as Tokens.Image)
          break
        case 'br':
          handleBr(params)
          break
        case 'strong':
          await handleStrong(params, token as Tokens.Strong)
          break
        case 'del':
          handleDel(params, token as Tokens.Del)
          break
        case 'text':
          handleText(params, token as Tokens.Text)
          break
        case 'em':
          handleEm(params, token as Tokens.Em)
          break
        case 'codespan':
          handleCodespan(params, token as Tokens.Codespan)
          break
        case 'link':
          await handleLink(params, token as Tokens.Link)
          break
        case 'inlineLatex':
          await handleInlineLatex(params, token as Tokens.Generic)
          break
        case 'html':
          await handleHtml(params, token as Tokens.HTML)
          break
        default:
          params.options.customInlineBuilder?.(token, params)
          break
      }
    }
  } finally {
    if (isRoot) {
      _cachedTheme = null
    }
  }

  return params.inlineTextStyle
}
