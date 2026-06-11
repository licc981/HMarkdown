/**
 * 表格组件
 *
 * 渲染 Markdown 表格，支持表头、数据行和动态列宽。
 */
import { MarkdownTheme } from '../config/MarkdownTheme'
import { Tokens } from '../core'
import { parseInlineToken } from '../core/parseInlineToken'
import { MarkdownOptions } from '../Index'
import { getTheme, textAlign } from '../utils'

/** 单元格水平内边距 */
const CELL_HORIZONTAL_PADDING: number = 20

/** 更新列宽映射表（表头与数据单元格共用逻辑） */
function updateColumnWidth(widthMap: Map<number, number>, columnIndex: number, measuredWidth: number): void {
  const currentWidth = widthMap.get(columnIndex)
  if (currentWidth === undefined || measuredWidth > currentWidth) {
    widthMap.set(columnIndex, measuredWidth + CELL_HORIZONTAL_PADDING)
  }
}

// ─── 表格主体 ───

@ComponentV2
export struct Table {
  @Param @Require token: Tokens.Table
  @Param @Require options: MarkdownOptions
  @Local columnWidths: Map<number, number> = new Map()
  /** 用私有字段（非 @Local）存储高度，避免测量更新触发额外重渲染形成反馈循环 */
  private tableHeight: number = 0

  get theme(): MarkdownTheme {
    return getTheme(this.options)
  }

  build() {
    Scroll() {
      Column() {
        TableHeader({
          cells: this.token?.header,
          columnWidths: this.columnWidths,
          theme: this.theme
        })
        TableBody({
          rows: this.token?.rows,
          columnWidths: this.columnWidths,
          options: this.options
        })
      }
      .alignItems(HorizontalAlign.Start)
      .onSizeChange((_: SizeOptions, newValue: SizeOptions) => {
        if (typeof newValue.height === 'number' && newValue.height > 0) {
          this.tableHeight = newValue.height
        }
      })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .height(this.tableHeight > 0 ? this.tableHeight : undefined)
    .borderWidth(this.theme.tableStyle?.dividerWidth)
    .borderColor(this.theme.tableStyle?.dividerColor)
  }
}

// ─── 表头 ───

@ComponentV2
export struct TableHeader {
  @Param @Require cells: Tokens.TableCell[]
  @Param @Require theme: MarkdownTheme
  @Param @Require columnWidths: Map<number, number>

  build() {
    Row() {
      ForEach(this.cells, (cell: Tokens.TableCell, index: number) => {
        Text(cell.text)
          .fontWeight(FontWeight.Bold)
          .textAlign(textAlign(cell.align))
          .padding({ top: 8, bottom: 8, left: 8, right: 8 })
          .maxLines(1)
          .width(this.columnWidths.get(index))
          .fontColor(this.theme.fontStyle?.fontColor)
          .fontSize(this.theme.fontStyle?.fontSize)
          .onSizeChange((_: SizeOptions, newValue: SizeOptions) => {
            if (typeof newValue.width === 'number') {
              updateColumnWidth(this.columnWidths, index, newValue.width)
            }
          })

        if (index !== this.cells.length - 1) {
          Column()
            .width(this.theme.tableStyle?.dividerWidth ?? 1)
            .backgroundColor(this.theme.tableStyle?.dividerColor)
        }
      })
    }
    .alignItems(VerticalAlign.Center)
    .border({
      width: { bottom: this.theme.tableStyle?.dividerWidth },
      color: this.theme.tableStyle?.dividerColor
    })
  }
}

// ─── 表体 ───

@ComponentV2
struct TableBody {
  @Param @Require rows: Tokens.TableCell[][]
  @Param @Require options: MarkdownOptions
  @Param @Require columnWidths: Map<number, number>

  get theme(): MarkdownTheme {
    return getTheme(this.options)
  }

  build() {
    Column() {
      ForEach(this.rows, (row: Tokens.TableCell[]) => {
        Row() {
          ForEach(row, (cell: Tokens.TableCell, index: number) => {
            TableCellInline({
              cell: cell,
              columnWidths: this.columnWidths,
              index: index,
              options: this.options
            })

            if (index !== row.length - 1) {
              Column()
                .width(this.theme.tableStyle?.dividerWidth ?? 1)
                .backgroundColor(this.theme.tableStyle?.dividerColor)
            }
          })
        }
        .alignItems(VerticalAlign.Center)
        .border({
          width: { bottom: this.theme.tableStyle?.dividerWidth },
          color: this.theme.tableStyle?.dividerColor
        })
      })
    }
  }
}

// ─── 单元格 ───

@ComponentV2
export struct TableCellInline {
  @Param @Require index: number
  @Param @Require cell: Tokens.TableCell
  @Param @Require columnWidths: Map<number, number>
  @Param @Require options: MarkdownOptions
  private textController = new TextController()

  aboutToAppear(): void {
    this.parseToken()
  }

  @Monitor('options')
  watchOptions(): void {
    this.parseToken()
  }

  private parseToken(): void {
    parseInlineToken({
      token: this.cell.tokens ?? [],
      options: this.options,
      uiContext: this.getUIContext()
    }).then((data: MutableStyledString | undefined) => {
      if (data) {
        this.textController.setStyledString(data)
      }
    }).catch((e: Error) => {
      console.warn('[HMarkdown] 表格单元格解析失败:', e?.message)
    })
  }

  get theme(): MarkdownTheme {
    return getTheme(this.options)
  }

  build() {
    Text(undefined, { controller: this.textController })
      .textAlign(textAlign(this.cell.align))
      .fontColor(this.theme.fontStyle?.fontColor)
      .fontSize(this.theme.fontStyle?.fontSize)
      .padding({ top: 8, bottom: 8, left: 8, right: 8 })
      .maxLines(1)
      .width(this.columnWidths.get(this.index))
      .onSizeChange((_: SizeOptions, newValue: SizeOptions) => {
        if (typeof newValue.width === 'number') {
          updateColumnWidth(this.columnWidths, this.index, newValue.width)
        }
      })
  }
}
