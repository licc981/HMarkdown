/**
 * Markdown 解析服务
 *
 * 管理解析生命周期：防抖、版本追踪、并发保护。
 * 支持子线程（taskpool）和主线程两种解析模式。
 */
import { taskpool } from '@kit.ArkTS'
import { BusinessError } from '@kit.BasicServicesKit'
import { Token } from '../core'
import { MarkdownOptions } from '../Index'
import { parseMarkdown, parseMarkdownLocal } from '../utils'

/** 解析回调 */
export interface ParseCallbacks {
  onLoading?: () => void
  onSuccess: (tokens: Token[]) => void
  onError?: (error: BusinessError) => void
}

interface ParseRequest {
  content: string
  options?: MarkdownOptions
  callbacks: ParseCallbacks
}

export class MarkdownParseService {
  private parseTimer: number = -1
  private parseVersion: number = 0
  private isParsing: boolean = false
  private lastRequest?: ParseRequest

  /** 从原始 Markdown 字符串触发解析 */
  updateByContent(content: string, options: MarkdownOptions | undefined,
    currentTokenSize: number, callbacks: ParseCallbacks): void {
    this.lastRequest = { content, options, callbacks }

    if (!content || content.trim().length === 0) {
      this.cancelTimer()
      this.parseVersion++
      callbacks.onSuccess([])
      return
    }

    const version = ++this.parseVersion
    this.cancelTimer()
    this.parseTimer = setTimeout(() => {
      this.parseTimer = -1
      this.executeParse(version, currentTokenSize)
    }, 80)
  }

  /** 释放资源 */
  dispose(): void {
    this.cancelTimer()
    this.lastRequest = undefined
  }

  private executeParse(version: number, initialTokenSize: number): void {
    const request = this.lastRequest
    if (!request || version !== this.parseVersion || this.isParsing) {
      return
    }

    this.isParsing = true

    if (initialTokenSize === 0) {
      request.callbacks.onLoading?.()
    }

    const done = (tokens: Token[]): void => {
      this.isParsing = false
      if (version === this.parseVersion) {
        request.callbacks.onSuccess(tokens)
      } else if (this.lastRequest) {
        // 有新请求到达，使用最新状态重解析
        this.executeParse(this.parseVersion, tokens.length)
      }
    }

    const failed = (error: BusinessError): void => {
      this.isParsing = false
      if (version === this.parseVersion) {
        request.callbacks.onError?.(error)
      } else if (this.lastRequest) {
        this.executeParse(this.parseVersion, 0)
      }
    }

    // 有自定义扩展时使用主线程解析（扩展不可序列化到 worker）
    if ((request.options?.extensions?.length ?? 0) > 0) {
      try {
        done(parseMarkdownLocal(request.content, request.options?.options, request.options?.extensions))
      } catch (e) {
        failed(e as BusinessError)
      }
      return
    }

    taskpool.execute(parseMarkdown, request.content, request.options?.options, request.options?.extensions)
      .then((data) => done(data as Token[]))
      .catch((error: BusinessError) => failed(error))
  }

  private cancelTimer(): void {
    if (this.parseTimer >= 0) {
      clearTimeout(this.parseTimer)
      this.parseTimer = -1
    }
  }
}
