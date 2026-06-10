import { taskpool } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { Token } from '../core';
import { MarkdownOptions } from '../Index';
import { parseMarkdown, parseMarkdownLocal } from '../utils';

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
  private parseTimer: number = -1;
  private parseVersion: number = 0;
  private isParsing: boolean = false;
  private lastRequest?: ParseRequest;

  updateByTokens(tokens: Token[], callbacks: ParseCallbacks): void {
    this.cancelTimer();
    this.parseVersion++;
    this.lastRequest = undefined;
    callbacks.onSuccess(tokens);
  }

  updateByContent(content: string, options: MarkdownOptions | undefined,
    currentTokenSize: number, callbacks: ParseCallbacks): void {
    this.lastRequest = { content, options, callbacks };

    if (!content || content.trim().length === 0) {
      this.cancelTimer();
      this.parseVersion++;
      callbacks.onSuccess([]);
      return;
    }

    const parseVersion = ++this.parseVersion;
    this.cancelTimer();
    this.parseTimer = setTimeout(() => {
      this.parseTimer = -1;
      this.executeParse(parseVersion, currentTokenSize);
    }, 80);
  }

  dispose(): void {
    this.cancelTimer();
    this.lastRequest = undefined;
  }

  private executeParse(parseVersion: number, currentTokenSize: number): void {
    const request = this.lastRequest;
    if (!request || parseVersion !== this.parseVersion || this.isParsing) {
      return;
    }

    this.isParsing = true;
    if (currentTokenSize === 0) {
      request.callbacks.onLoading?.();
    }

    const done = (tokens: Token[]) => {
      if (parseVersion === this.parseVersion) {
        request.callbacks.onSuccess(tokens);
      }
      this.isParsing = false;
      if (parseVersion !== this.parseVersion) {
        this.executeParse(this.parseVersion, currentTokenSize);
      }
    };

    const failed = (error: BusinessError) => {
      if (parseVersion === this.parseVersion) {
        request.callbacks.onError?.(error);
      }
      this.isParsing = false;
      if (parseVersion !== this.parseVersion) {
        this.executeParse(this.parseVersion, currentTokenSize);
      }
    };

    if ((request.options?.extensions?.length ?? 0) > 0) {
      try {
        done(parseMarkdownLocal(request.content, request.options?.options, request.options?.extensions));
      } catch (e) {
        failed(e as BusinessError);
      }
      return;
    }

    taskpool.execute(parseMarkdown, request.content, request.options?.options, request.options?.extensions)
      .then((data) => {
        done(data as Token[]);
      })
      .catch((error: BusinessError) => {
        failed(error);
      });
  }

  private cancelTimer(): void {
    if (this.parseTimer >= 0) {
      clearTimeout(this.parseTimer);
      this.parseTimer = -1;
    }
  }
}
