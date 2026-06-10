import { LengthMetrics } from '@kit.ArkUI';
import { defaultDarkTheme, defaultTheme } from '../config/DefaultTheme';
import { MarkdownTheme } from '../config/MarkdownTheme';
import { MarkdownOptions } from '../Index';
import deepMerge from '../merge';

export interface ResolvedThemeBundle {
  theme: MarkdownTheme
  darkTheme: MarkdownTheme
  lineSpace: number | string
  inlineLineSpace: LengthMetrics
}

export function resolveThemeBundle(options?: MarkdownOptions): ResolvedThemeBundle {
  return {
    lineSpace: options?.lineSpace ?? 12,
    inlineLineSpace: options?.inlineLineSpace ?? LengthMetrics.vp(12),
    theme: deepMerge(defaultTheme, options?.theme),
    darkTheme: deepMerge(defaultDarkTheme, options?.darkTheme)
  };
}
