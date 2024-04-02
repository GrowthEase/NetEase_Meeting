import 'cropperjs/dist/cropper.css'
import { createRef, MouseEventHandler, useState } from 'react'
import Cropper, { ReactCropperElement } from 'react-cropper'
// import 'react-cropper/dist/cropper.css'

import { Button } from 'antd'
import { useTranslation } from 'react-i18next'
import NEMeetingService from '../../../services/NEMeeting'
import Toast from '../toast'
import './index.less'

interface ImageCropProps {
  className?: string
  neMeeting?: NEMeetingService
  image: string
  onOk?: (avatar: string) => void
  onCancel?: MouseEventHandler<HTMLElement>
}

const ImageCrop: React.FC<ImageCropProps> = (props) => {
  const { image, neMeeting } = props
  const { t } = useTranslation()
  const cropperRef = createRef<ReactCropperElement>()

  const [loading, setLoading] = useState(false)

  const getCropData = () => {
    setLoading(true)
    if (typeof cropperRef.current?.cropper !== 'undefined') {
      if (window.isElectronNative) {
        const base64 = cropperRef.current?.cropper
          .getCroppedCanvas()
          .toDataURL()
        window.ipcRenderer
          ?.invoke('saveAvatarToPath', base64)
          .then(({ filePath }) => {
            neMeeting
              ?.updateAccountAvatar(filePath)
              .then((url) => {
                props.onOk?.(url)
              })
              .catch(() => {
                Toast.fail(t('settingAvatarUpdateFail'))
              })
              .finally(() => {
                setLoading(false)
              })
          })
      } else {
        cropperRef.current?.cropper.getCroppedCanvas().toBlob((blob) => {
          if (blob) {
            neMeeting
              ?.updateAccountAvatar(blob)
              .then((url) => {
                props.onOk?.(url)
              })
              .catch(() => {
                Toast.fail(t('settingAvatarUpdateFail'))
              })
              .finally(() => {
                setLoading(false)
              })
          }
        })
      }
    }
  }

  return (
    <div className="image-crop-wrapper">
      <Cropper
        ref={cropperRef}
        style={{ height: 270, width: '100%' }}
        aspectRatio={1}
        initialAspectRatio={1}
        preview=".img-preview"
        src={image}
        viewMode={1}
        minCropBoxHeight={10}
        minCropBoxWidth={10}
        background={false}
        responsive={true}
        autoCropArea={1}
        checkOrientation={false}
        guides={true}
      />
      <div className="image-crop-footer">
        <Button className="image-crop-footer-button" onClick={props.onCancel}>
          {t('globalCancel')}
        </Button>
        <Button
          className="image-crop-footer-button"
          type="primary"
          loading={loading}
          onClick={getCropData}
        >
          {t('save')}
        </Button>
      </div>
    </div>
  )
}

export default ImageCrop
