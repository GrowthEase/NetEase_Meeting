import {
  Dispatch,
  SetStateAction,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react'
import { NEMeetingInfo, NEMember } from '../types'
import { Swiper as SwiperClass } from 'swiper/types'

interface UseIsAudioModeProps {
  meetingInfo: NEMeetingInfo
  memberList: NEMember[]
}
export function useIsAudioMode(
  data: UseIsAudioModeProps
): {
  isAudioMode: boolean
} {
  const { memberList, meetingInfo } = data
  const isAudioMode = useMemo(() => {
    if (meetingInfo.dualMonitors) {
      return memberList.every((item) => !item.isVideoOn)
    } else {
      // 如果都为开启过视频则为音频模式；
      return (
        !meetingInfo.screenUuid &&
        !meetingInfo.whiteboardUuid &&
        memberList.every(
          (item) =>
            !item.isVideoOn &&
            !item.isSharingScreen &&
            !item.isSharingWhiteboard
        )
      )
    }
  }, [
    memberList,
    meetingInfo.whiteboardUuid,
    meetingInfo.screenUuid,
    meetingInfo.dualMonitors,
  ])

  return {
    isAudioMode,
  }
}

interface UseAudioModeCanvasProps {
  meetingInfo: NEMeetingInfo
  memberList: NEMember[]
}

interface UseAudioModeCanvasRes {
  groupMemberList: NEMember[][][]
  activeIndex: number
  setColumnCount: Dispatch<SetStateAction<number>>
  setLineCount: Dispatch<SetStateAction<number>>
  setActiveIndex: Dispatch<SetStateAction<number>>
  swiperInstanceRef: React.MutableRefObject<SwiperClass | null>
}
export default function useAudioMode(
  data: UseAudioModeCanvasProps
): UseAudioModeCanvasRes {
  const { memberList, meetingInfo } = data
  const [columnCount, setColumnCount] = useState(3)
  const [lineCount, setLineCount] = useState(7)
  const swiperInstanceRef = useRef<SwiperClass | null>(null)
  const [activeIndex, setActiveIndex] = useState(0)

  // 二维数组转换
  function convertTo2DArray(
    arr: NEMember[],
    lineCount: number,
    columnCount: number
  ): Array<Array<NEMember[]>> {
    const result: Array<Array<NEMember[]>> = []

    if (columnCount <= 0 || lineCount <= 0) {
      return result
    }

    let pageIndex = 0

    // 遍历所有项
    while (pageIndex * lineCount * columnCount < arr.length) {
      const page: Array<NEMember[]> = []

      for (
        let i = 0;
        i < lineCount && (pageIndex * lineCount + i) * columnCount < arr.length;
        i++
      ) {
        // 每一行的数据
        const row = arr.slice(
          (pageIndex * lineCount + i) * columnCount,
          (pageIndex * lineCount + i + 1) * columnCount
        )

        page.push(row)
      }

      // 整个棋盘数据
      result.push(page)
      pageIndex++
    }

    return result
  }

  const viewOrder = meetingInfo.remoteViewOrder || meetingInfo.localViewOrder

  if (viewOrder) {
    const idOrder = viewOrder.split(',')

    memberList.sort((a, b) => {
      // 获取 a 和 b 对象的 id 在 idOrder 数组中的索引位置
      const indexA = idOrder.indexOf(a.uuid)
      const indexB = idOrder.indexOf(b.uuid)

      // 根据 id 在 idOrder 中的索引位置进行排序
      if (indexA === -1 && indexB === -1) {
        return 0 // 如果两个都不在给定的 UUID 数组中，则保持原顺序
      } else if (indexA === -1) {
        return 1 // 如果 a 不在数组中但 b 在，则 b 应该在前面
      } else if (indexB === -1) {
        return -1 // 如果 b 不在数组中但 a 在，则 a 应该在前面
      } else {
        return indexA - indexB // 否则按照在给定数组中的位置排序
      }
    })
  }

  // 最终渲染成员三维数组，第一个表示多少页，第二个表示多少行，第三个表示多少列
  const groupMemberList = useMemo(() => {
    const res = convertTo2DArray(memberList, lineCount, columnCount)

    if (swiperInstanceRef.current && !swiperInstanceRef.current.destroyed) {
      swiperInstanceRef.current?.slideTo(0)
    }

    return res
  }, [columnCount, lineCount, memberList])

  useEffect(() => {
    if (activeIndex > groupMemberList.length - 1) {
      const _activeIndex = Math.max(groupMemberList.length - 1, 0)

      if (swiperInstanceRef.current && !swiperInstanceRef.current.destroyed) {
        swiperInstanceRef.current?.slideTo(_activeIndex)
      }

      setActiveIndex(_activeIndex)
    }
  }, [groupMemberList.length, activeIndex])

  return {
    groupMemberList,
    activeIndex,
    setActiveIndex,
    setColumnCount,
    setLineCount,
    swiperInstanceRef,
  }
}
