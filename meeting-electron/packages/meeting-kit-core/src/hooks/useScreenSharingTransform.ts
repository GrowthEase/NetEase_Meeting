import { useState, useRef, useEffect } from 'react'
import {
  ReactZoomPanPinchRef,
  ReactZoomPanPinchContentRef,
} from 'react-zoom-pan-pinch'
import { useMeetingInfoContext } from '../store'
import { ActionType } from '../kit'

type ScreenSharingTransformProps = {
  transformWrapperRef: ReactZoomPanPinchContentRef | null
}

export default function useScreenSharingTransform(
  props: ScreenSharingTransformProps
) {
  const { transformWrapperRef } = props
  const { meetingInfo, dispatch } = useMeetingInfoContext()
  const zoomToastTimer = useRef<NodeJS.Timeout>()
  const scaleRef = useRef<number>(1)
  const zoomRef = useRef<number>(0)
  const canvasRef = useRef<HTMLCanvasElement | null>(null)
  const [minScale, setMinScale] = useState(1)
  const [maxScale, setMaxScale] = useState(1)
  const [zoomToast, setZoomToast] = useState<string>('')

  const meetingInfoRef = useRef(meetingInfo)

  meetingInfoRef.current = meetingInfo

  function onTransformed(
    ref: ReactZoomPanPinchRef,
    state: {
      scale: number
      positionX: number
      positionY: number
    }
  ) {
    if (canvasRef.current && state.scale !== scaleRef.current) {
      scaleRef.current = state.scale
      const { width, clientWidth } = canvasRef.current

      const zoom = Math.round(((clientWidth * state.scale) / width) * 100)

      zoomRef.current = zoom

      zoom && setZoomToast(`${zoom}%`)
      zoomToastTimer.current && clearTimeout(zoomToastTimer.current)

      zoomToastTimer.current = setTimeout(() => {
        setZoomToast('')
        zoomToastTimer.current = undefined
      }, 1000)
    }
  }

  function onWheelStop() {
    const screenZoom = zoomRef.current / 100

    if ([0.5, 1, 1.5, 2, 3].includes(screenZoom)) {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          screenZoom: screenZoom,
        },
      })
    } else {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          screenZoom: undefined,
        },
      })
    }
  }

  function onCanvasResize(canvas: HTMLCanvasElement) {
    //
    canvasRef.current = canvas

    if (canvas) {
      const { width, clientWidth } = canvas

      let min = (width * 0.5) / clientWidth

      if (min > clientWidth / width) {
        min = 1
      }

      setMaxScale((width * 3) / clientWidth)
      setMinScale(min)
    }
  }

  function onWrapperResize(
    transformWrapperRef: ReactZoomPanPinchContentRef | null
  ) {
    const zoom = meetingInfoRef.current.screenZoom

    if (transformWrapperRef && canvasRef.current && zoom !== undefined) {
      const { width, clientWidth } = canvasRef.current

      if (clientWidth) {
        const scale = zoom === 0 ? 1 : (width * zoom) / clientWidth

        transformWrapperRef.centerView(scale)
      }
    }
  }

  useEffect(() => {
    if (meetingInfo.screenZoom !== undefined) {
      const zoom = meetingInfo.screenZoom

      if (transformWrapperRef && canvasRef.current) {
        const { width, clientWidth } = canvasRef.current

        if (clientWidth) {
          const scale = zoom === 0 ? 1 : (width * zoom) / clientWidth

          transformWrapperRef.centerView(scale)
        }
      }
    }
  }, [meetingInfo.screenZoom])

  useEffect(() => {
    if (meetingInfo.pinVideoUuid) {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          screenZoom: 0,
        },
      })
    }
  }, [meetingInfo.pinVideoUuid])

  return {
    onTransformed,
    onCanvasResize,
    onWheelStop,
    onWrapperResize,
    scaleRef,
    minScale,
    maxScale,
    zoomToast,
  }
}
