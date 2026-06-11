/**
 * 块级渲染分发器
 *
 * 根据 token 类型将块级 token 路由到对应的 UI 组件。
 * 未知类型回退到 customBlockBuilder。
 */
import { MarkdownOptions } from '../Index'
import { Token, Tokens } from '../core'
import { BlockQuote } from '../component/BlockQuote'
import { Code } from '../component/Code'
import { Heading } from '../component/Heading'
import { Hr } from '../component/Hr'
import { Html } from '../component/Html'
import { Inline } from '../component/Inline'
import { Latex } from '../component/Latex'
import { MList } from '../component/MList'
import { Paragraph } from '../component/Paragraph'
import { Table } from '../component/Table'

export interface BlockRenderParams {
  token: Token
  options: MarkdownOptions
}

@Builder
export function BlockRenderDispatcher(params: BlockRenderParams) {
  if (params.token.type === 'hr') {
    Hr({ options: params.options })
  } else if (params.token.type === 'heading') {
    Heading({ token: params.token as Tokens.Heading, options: params.options })
  } else if (params.token.type === 'space') {
    Stack()
  } else if (params.token.type === 'code') {
    Code({ token: params.token as Tokens.Code, options: params.options })
  } else if (params.token.type === 'blockquote') {
    BlockQuote({ token: params.token as Tokens.Blockquote, options: params.options })
  } else if (params.token.type === 'paragraph') {
    Paragraph({ token: params.token as Tokens.Paragraph, options: params.options })
  } else if (params.token.type === 'list') {
    MList({ tokens: params.token as Tokens.List, options: params.options })
  } else if (params.token.type === 'text') {
    Inline({
      token: (params.token as Tokens.Text).tokens ?? [],
      options: params.options
    })
  } else if (params.token.type === 'table') {
    Table({ token: params.token as Tokens.Table, options: params.options })
  } else if (params.token.type === 'html') {
    Html({ html: params.token, options: params.options })
  } else if (params.token.type === 'blockLatex') {
    Latex({ token: params.token, options: params.options })
  } else {
    params.options.customBlockBuilder?.builder(params.token, params.options)
  }
}
