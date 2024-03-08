import { useEffect, useRef } from 'react'

type Callback<T> = (prev: T | undefined) => void

export default function useWatch<T>(
  data: T,
  callback: Callback<T>,
  config = { immediate: false }
) {
  const { immediate } = config
  const prev = useRef<T>() // 上一次的值
  const stop = useRef(false) // 是否停止watch
  const inited = useRef(false) // 是否第一次执行

  useEffect(() => {
    const execFn = () => callback(prev.current)

    if (!stop.current) {
      if (!inited.current) {
        inited.current = true
        if (immediate) {
          execFn()
        }
      } else {
        execFn()
      }
      prev.current = data
    }

    // return () => {
    //   console.log('销毁')
    //   stop.current = true
    // }
  }, [data])
}
