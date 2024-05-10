import React, { useEffect } from 'react'

import './index.less'
import Modal from '../../common/Modal'
import { Button, Input, Form, ModalProps } from 'antd'
import { useTranslation } from 'react-i18next'
import { isLastCharacterEmoji } from '../../../utils'

type SummitValue = {
  nickname: string
}

interface UpdateUserNicknameModalProps extends ModalProps {
  nickname?: string
  onSummit?: (value: SummitValue) => void
}

const UpdateUserNicknameModal: React.FC<UpdateUserNicknameModalProps> = ({
  nickname,
  onSummit,
  ...restProps
}) => {
  const { t } = useTranslation()

  const i18n = {
    title: t('reName'),
    inputPlaceholder: t('reNamePlaceholder'),
    inputTips: t('reNameTips'),
    submitBtn: t('done'),
  }

  const [form] = Form.useForm()

  const nicknameValue = Form.useWatch('nickname', form)

  const isComposingRef = React.useRef(false)

  function onFinish() {
    form.validateFields().then((values) => {
      onSummit?.(values)
    })
  }

  function handleInputChange(value: string) {
    let userInput = value
    if (!isComposingRef.current) {
      let inputLength = 0
      for (let i = 0; i < userInput.length; i++) {
        // 检测字符是否为中文字符
        if (userInput.charCodeAt(i) > 127) {
          inputLength += 2
        } else {
          inputLength += 1
        }
        // 判断当前字符长度是否超过限制，如果超过则终止 for 循环
        if (inputLength > 20) {
          if (isLastCharacterEmoji(userInput)) {
            userInput = userInput.slice(0, -2)
          } else {
            userInput = userInput.slice(0, i)
          }
          break
        }
      }
    }
    form.setFieldValue('nickname', userInput)
  }

  useEffect(() => {
    if (restProps.open) {
      form.setFieldsValue({
        nickname,
      })
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [restProps.open])

  return (
    <Modal
      title={i18n.title}
      width={375}
      maskClosable={false}
      destroyOnClose
      getContainer={() => {
        const dom = document.getElementById('ne-web-meeting') as HTMLElement
        if (dom && dom.style.display !== 'none') {
          return dom
        }
        return document.body
      }}
      footer={
        <div className="before-meeting-modal-footer">
          <Button
            className="before-meeting-modal-footer-button"
            disabled={!nicknameValue?.replace(/\s/g, '')}
            type="primary"
            onClick={() => onFinish()}
          >
            {i18n.submitBtn}
          </Button>
        </div>
      }
      {...restProps}
    >
      <div className="before-meeting-modal-content">
        <Form name="basic" autoComplete="off" form={form}>
          <Form.Item
            className="nickname-input-form-item"
            name="nickname"
            extra={i18n.inputTips}
          >
            <Input
              className="nickname-input"
              placeholder={i18n.inputPlaceholder}
              onChange={(e) => handleInputChange(e.currentTarget.value)}
              allowClear
              onCompositionStart={() => (isComposingRef.current = true)}
              onCompositionEnd={(e) => {
                isComposingRef.current = false
                handleInputChange(e.currentTarget.value)
              }}
            />
          </Form.Item>
        </Form>
      </div>
    </Modal>
  )
}
export default UpdateUserNicknameModal
