/**
 * 深度合并工具
 *
 * 对象递归合并，数组替换（非拼接），基本类型直接覆盖。
 * 仅对纯对象（plain object）进行递归，确保 ArkUI 系统类型不被错误拆解。
 */
export default function deepMerge<T extends object>(...sources: (Partial<T> | undefined)[]): T {
  const result: Partial<T> = {}

  sources.forEach(source => {
    if (!source) {
      return
    }

    Object.keys(source).forEach(key => {
      const typedKey = key as keyof T
      const currentValue = result[typedKey]
      const sourceValue = source[typedKey]

      if (isPlainObject(sourceValue)) {
        result[typedKey] = deepMerge(
          (currentValue as object) || {},
          sourceValue as object
        ) as T[Extract<keyof T, string>]
      } else if (Array.isArray(sourceValue)) {
        result[typedKey] = [...sourceValue] as T[Extract<keyof T, string>]
      } else {
        result[typedKey] = sourceValue as T[Extract<keyof T, string>]
      }
    })
  })

  return result as T
}

/** 判断是否为纯对象（排除 null、数组、class 实例等） */
function isPlainObject(value: unknown): value is object {
  if (value === null || value === undefined || typeof value !== 'object') {
    return false
  }
  if (Array.isArray(value)) {
    return false
  }
  const proto = Object.getPrototypeOf(value)
  return proto === Object.prototype || proto === null
}
