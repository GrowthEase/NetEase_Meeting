import { useEffect, useState } from 'react'

const useMouseInsideWindow = () => {
  const [isMouseInsideWindow, setIsMouseInsideWindow] = useState(false)

  useEffect(() => {
    function onMouseout(event: MouseEvent) {
      const relatedTarget = event.relatedTarget as Node | null

      if (!relatedTarget || relatedTarget.nodeName === 'HTML') {
        setIsMouseInsideWindow(false)
      }
    }

    function onMouseenter() {
      setIsMouseInsideWindow(true)
    }

    window.addEventListener('mousemove', onMouseenter)
    window.addEventListener('mouseout', onMouseout)
    return () => {
      window.removeEventListener('mouseout', onMouseout)
      window.removeEventListener('mousemove', onMouseenter)
    }
  }, [])

  return {
    isMouseInsideWindow,
  }
}

export default useMouseInsideWindow
