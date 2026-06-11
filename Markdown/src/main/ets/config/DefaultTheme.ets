/**
 * 默认主题配置
 *
 * 提供亮色 / 暗色两套默认主题，基于 JetBrains IDE 风格设计。
 * 使用工厂函数 createTheme() 消除结构重复。
 */
import {
  BlockQuoteMargin,
  BlockQuoteStyle,
  CodeHighlightColors,
  CodeStyle,
  CodeSpanStyle,
  DividerStyle,
  LatexStyle,
  ListStyle,
  MarkdownFontStyle,
  MarkdownTheme
} from './MarkdownTheme'

// ─── 字体基础 ───

const lightFont: MarkdownFontStyle = {
  fontWeight: FontWeight.Normal,
  fontColor: Color.Black,
  fontSize: 16
}

const darkFont: MarkdownFontStyle = {
  fontWeight: FontWeight.Normal,
  fontColor: Color.White,
  fontSize: 16
}

// ─── 标题字重与字号 (h1 → h6) ───

const HEADING_WEIGHTS: FontWeight[] = [
  FontWeight.Bolder, FontWeight.Bold, FontWeight.Medium,
  FontWeight.Regular, FontWeight.Normal, FontWeight.Lighter
]

const HEADING_SIZES: number[] = [30, 28, 26, 24, 22, 20]

function buildHeadingStyles(fontColor: ResourceColor): MarkdownFontStyle[] {
  return HEADING_WEIGHTS.map((weight: FontWeight, i: number): MarkdownFontStyle => {
    const style: MarkdownFontStyle = {
      fontWeight: weight,
      fontColor: fontColor,
      fontSize: HEADING_SIZES[i]
    }
    return style
  })
}

// ─── 语法高亮颜色（代码块在亮/暗主题下共用深色背景） ───

function buildCodeColors(): CodeHighlightColors {
  const colors: CodeHighlightColors = {
    text: Color.White,
    string: Color.White,
    keyword: '#0A69DA',
    type: '#0A69DA',
    symbol: '#E3DA90',
    number: '#B3E54C',
    boolean: Color.White,
  }
  return colors
}

// ─── 工厂参数接口 ───

interface ThemeColorParams {
  bg: ResourceColor
  fontColor: ResourceColor
  themeColor: ResourceColor
  linkColor: ResourceColor
  quoteDivider: ResourceColor
  quoteBg: ResourceColor
  tableDivider: ResourceColor
  hrColor: ResourceColor
  codeSpanBg: ResourceColor
  latexFontColor: number
  copyIconColor: ResourceColor
}

// ─── 工厂函数 ───

function createTheme(colors: ThemeColorParams): MarkdownTheme {
  const quoteMargin: BlockQuoteMargin = { left: 10, right: 20 }

  const bqStyle: BlockQuoteStyle = {
    borderRadius: 4,
    dividerWidth: 2,
    dividerColor: colors.quoteDivider,
    backgroundColor: colors.quoteBg,
    contentMargin: quoteMargin
  }

  const tblStyle: DividerStyle = {
    dividerWidth: 0.5,
    dividerColor: colors.tableDivider
  }

  const lstStyle: ListStyle = {
    marginLeft: 8,
    bulletSize: 6
  }

  const latexSty: LatexStyle = {
    fontSize: 22,
    fontColor: colors.latexFontColor,
    backgroundColor: 0x00000000
  }

  const codeSty: CodeStyle = {
    fontColor: buildCodeColors(),
    backgroundColor: '#303236',
    borderRadius: 4,
    codeLineHeight: 25,
    codeSpanBorderRadius: 8,
    codeSpanBackgroundColor: colors.codeSpanBg,
    copyIcon: $r('app.media.ic_copy'),
    copyIconColor: colors.copyIconColor,
  }

  const codeSpanSty: CodeSpanStyle = {
    backgroundColor: colors.codeSpanBg,
    borderRadius: 4
  }

  const hrSty: DividerStyle = {
    dividerColor: colors.hrColor,
    dividerWidth: 1
  }

  const result: MarkdownTheme = {
    backgroundColor: colors.bg,
    themeColor: colors.themeColor,
    fontStyle: colors.fontColor === Color.White ? darkFont : lightFont,
    headingStyle: buildHeadingStyles(colors.fontColor),
    blockQuoteStyle: bqStyle,
    tableStyle: tblStyle,
    listStyle: lstStyle,
    paragraphStyle: colors.fontColor === Color.White ? darkFont : lightFont,
    latexStyle: latexSty,
    code: codeSty,
    codeSpan: codeSpanSty,
    hrStyle: hrSty,
    linkColor: colors.linkColor,
    imageObjectFit: ImageFit.Contain,
  }

  return result
}

// ─── 导出 ───

/** 默认暗色主题 */
const darkThemeParams: ThemeColorParams = {
  bg: '#1E1F22',
  fontColor: Color.White,
  themeColor: '#6B9BFA',
  linkColor: '#6A9BFA',
  quoteDivider: '#485C84',
  quoteBg: '#303236',
  tableDivider: Color.White,
  hrColor: '#393B41',
  codeSpanBg: '#303236',
  latexFontColor: 0xffffffff,
  copyIconColor: Color.White,
}
export const defaultDarkTheme: MarkdownTheme = createTheme(darkThemeParams)

/** 默认亮色主题 */
const lightThemeParams: ThemeColorParams = {
  bg: '#FFFFFF',
  fontColor: Color.Black,
  themeColor: '#6B9BFA',
  linkColor: '#6A9BFA',
  quoteDivider: '#A6BAE1',
  quoteBg: '#F5F7F9',
  tableDivider: '#EBECF0',
  hrColor: '#393B41',
  codeSpanBg: '#F5F7F9',
  latexFontColor: 0xff000000,
  copyIconColor: Color.White,
}
export const defaultTheme: MarkdownTheme = createTheme(lightThemeParams)
