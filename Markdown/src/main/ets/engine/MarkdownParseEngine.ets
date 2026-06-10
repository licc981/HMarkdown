import { Marked, MarkedOptions, Token, TokenizerExtension } from '../core';
import { latexBlock, latexInline } from '../core/plugins/latex';

export function createMarkdownEngine(markedOptions?: MarkedOptions, markedExtensions?: TokenizerExtension[]): Marked {
  const marked = new Marked();
  const extensions = [...(markedExtensions ?? []), latexBlock(), latexInline()];
  marked.setOptions(markedOptions);
  marked.use({ extensions: extensions });
  return marked;
}

export function parseByMarkdownEngine(content: string, markedOptions?: MarkedOptions,
  markedExtensions?: TokenizerExtension[]): Token[] {
  if (!content) {
    return [];
  }
  return createMarkdownEngine(markedOptions, markedExtensions).lexer(content);
}
