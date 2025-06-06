import {
  Button,
  Select,
  SelectProps,
  Divider,
  Space,
  Input,
  Popover,
} from 'antd'
import React, {
  ReactNode,
  forwardRef,
  useCallback,
  useEffect,
  useImperativeHandle,
  useMemo,
  useRef,
  useState,
} from 'react'
import { useTranslation } from 'react-i18next'
import CaretDownOutlined from '@ant-design/icons/CaretDownOutlined'
import PlusCircleOutlined from '@ant-design/icons/PlusCircleOutlined'
import CloseOutlined from '@ant-design/icons/CloseOutlined'
import './index.less'
import {
  InterpretationRes,
  NEMeetingInterpreter,
  NEMeetingScheduledMember,
} from '../../../types/type'
import {
  ActionType,
  EventType,
  InterpreterSettingRef,
  NEMember,
  SearchAccountInfo,
  ServerError,
} from '../../../types'
import {
  debounce,
  getLocalStorageCustomLangs,
  setLocalStorageCustomLangs,
} from '../../../utils'
import UserAvatar from '../Avatar'
import Toast from '../toast'
import NEMeetingService from '../../../services/NEMeeting'
import { useDefaultLanguageOptions } from '../../../hooks/useInterpreterLang'
import { useGlobalContext, useMeetingInfoContext } from '../../../store'
import { NERoomMember } from 'neroom-types'
import { NEContactsService } from '../../../kit'
import CommonModal from '../CommonModal'

interface InterpreterSettingProps {
  className?: string
  value?: string
  neMeeting?: NEMeetingService
  interpretation?: InterpretationRes
  inMeeting?: boolean
  memberList?: NEMember[]
  inInvitingMemberList?: NEMember[]
  onClose?: () => void
  onSaveInterpreters?: (interpreters: NEMeetingInterpreter[]) => void
  enableCustomLang: boolean
  maxCustomLanguageLength?: number
  isStarted?: boolean
  scheduleMembers?: NEMeetingScheduledMember[]
  onDeleteScheduleMember?: (userId: string) => void
  meetingContactsService?: NEContactsService
}

interface InterpreterItemProps {
  interpreter?: InterpreterInfo
  firstLanguage?: string
  secondLanguage?: string
  onInterpreterChange?: (data: { value: string; label: ReactNode }) => void
  onFirstLanguageChange?: (language: string) => void
  onSecondLanguageChange?: (language: string) => void
  memberList?: NEMember[]
  inInvitingMemberList?: NEMember[]
  languageOptions: SelectProps['options']
  neMeeting?: NEMeetingService
  onDelete?: () => void
  onDeleteScheduleMember?: () => void
  inMeeting?: boolean
  onSwitchLanguage?: () => void
  onCustomLangAdd?: (customLang: string) => void
  enableCustomLang: boolean
  maxCustomLanguageLength?: number
  scheduleMembers?: NEMeetingScheduledMember[]
  meetingContactsService?: NEContactsService
}

const InterpreterItem: React.FC<InterpreterItemProps> = ({
  interpreter,
  firstLanguage,
  secondLanguage,
  onInterpreterChange,
  onFirstLanguageChange,
  onSecondLanguageChange,
  languageOptions,
  inMeeting,
  memberList,
  meetingContactsService,
  inInvitingMemberList,
  onDelete,
  onDeleteScheduleMember,
  onSwitchLanguage,
  onCustomLangAdd,
  enableCustomLang,
  maxCustomLanguageLength,
  scheduleMembers,
}) => {
  const { t } = useTranslation()
  const [options, setOptions] = useState<SearchAccountInfo[]>([])
  const [customLang, setCustomLang] = useState('')
  const [searchName, setSearchName] = useState('')

  const searchMember = debounce((name: string, page: number) => {
    if (!name) {
      setOptions([])
      return
    }

    // 会中只搜索会中和未入会成员
    if (inMeeting) {
      const members =
        memberList
          ?.filter((item) => {
            // sip入会无法所搜到
            return (
              item.name
                .toLocaleLowerCase()
                .includes(name?.toLocaleLowerCase()) && item.clientType !== 5
            )
          })
          .map((item) => {
            return {
              ...item,
              inInviting: false,
            }
          }) || []
      const inInvitingMembers =
        inInvitingMemberList
          ?.filter((item) => {
            return item.name
              .toLocaleLowerCase()
              .includes(name?.toLocaleLowerCase())
          })
          .map((item) => {
            return {
              ...item,
              inInviting: true,
            }
          }) || []

      setOptions(
        members.concat(inInvitingMembers).map((item) => {
          return {
            userUuid: item.uuid,
            name: item.name,
            avatar: item.avatar,
            dept: '',
            phoneNumber: '',
            inInviting: !!item.inInviting,
          }
        })
      )
    } else {
      meetingContactsService
        ?.searchContactListByName(name, 100, page)
        .then((res) => {
          setOptions(res.data)
        })
    }
  }, 800)
  const handleSearch = (name: string) => {
    setSearchName(name)
    if (!name) {
      setOptions([])
      return
    }

    searchMember(name, 1)
  }

  const handleChange = (data: { value: string; label: ReactNode }) => {
    setSearchName('')
    onInterpreterChange?.(data)
  }

  const renderItem = useCallback(
    (item: SearchAccountInfo) => {
      return (
        <div className="nemeeting-interp-opt">
          <UserAvatar nickname={item.name} size={32} avatar={item.avatar} />
          <div className="nemeeting-interp-opt-info">
            <div className="nemeeting-interp-opt-name">
              <span className="nemeeting-interp-opt-nick">{item.name}</span>
              {item.inInviting && (
                <span className="nemeeting-interp-opt-inInviting">
                  ({t('notJoined')})
                </span>
              )}
            </div>
            <div className="nemeeting-interp-opt-dep">{item.dept}</div>
          </div>
        </div>
      )
    },
    [t]
  )

  const renderOptions = useMemo(() => {
    return options.map((item) => {
      return {
        value: item.userUuid,
        label: renderItem(item),
        userInfo: item,
        inInviting: item.inInviting,
      }
    })
  }, [options, renderItem])

  const handleFirstLanguageChange = (language: string) => {
    onFirstLanguageChange?.(language)
  }

  const handleSecondLanguageChange = (language: string) => {
    onSecondLanguageChange?.(language)
  }

  const handleSwitchLanguage = () => {
    onSwitchLanguage?.()
  }

  const renderLanguageOptions = useMemo(() => {
    const tmpLanguageOptions = languageOptions ? [...languageOptions] : []

    if (
      firstLanguage &&
      !tmpLanguageOptions?.find((item) => item.value === firstLanguage)
    ) {
      tmpLanguageOptions.push({
        value: firstLanguage,
        label: firstLanguage,
      })
    }

    if (
      secondLanguage &&
      !tmpLanguageOptions?.find((item) => item.value === secondLanguage)
    ) {
      tmpLanguageOptions.push({
        value: secondLanguage,
        label: secondLanguage,
      })
    }

    return tmpLanguageOptions
  }, [languageOptions, firstLanguage, secondLanguage])

  const firstLangOptions = useMemo(() => {
    return (
      renderLanguageOptions?.map((item) => {
        return {
          ...item,
          disabled: item.value === secondLanguage,
        }
      }) || []
    )
  }, [renderLanguageOptions, secondLanguage])

  const secondLangOptions = useMemo(() => {
    return (
      renderLanguageOptions?.map((item) => {
        return {
          ...item,
          disabled: item.value === firstLanguage,
        }
      }) || []
    )
  }, [renderLanguageOptions, firstLanguage])

  const handleAddCustomLang = () => {
    if (customLang?.trim()) {
      onCustomLangAdd?.(customLang)
      setCustomLang('')
    }
  }

  const onCustomLangChange = (customLang: string) => {
    setCustomLang(customLang)
  }

  const DropdownRender = (menu: React.ReactElement) => {
    const menuRef = useRef<HTMLDivElement>(null)

    return (
      <div
        id="nemeeting-inter-setting-dropdown"
        className="nemeeting-inter-setting-dropdown"
      >
        <div ref={menuRef}>{menu}</div>
        {enableCustomLang && (
          <>
            <Divider style={{ margin: '8px 0 4px 0' }} />
            <Space style={{ padding: '0 8px 4px' }}>
              <Input
                value={customLang}
                maxLength={maxCustomLanguageLength || 20}
                placeholder={t('interpInputLanguage')}
                onChange={(e) => onCustomLangChange(e.target.value)}
                onKeyDown={(e) => e.stopPropagation()}
              />
              <PlusCircleOutlined
                className="nemeeting-interp-lang-plus"
                onClick={() => {
                  handleAddCustomLang()
                  setTimeout(() => {
                    const parentElement = menuRef.current

                    const childElements = parentElement?.getElementsByClassName(
                      'nemeeting-select-item-option'
                    )

                    // 找到最后一个子元素，并滚动到可视区域
                    const lastChildElement =
                      childElements?.[childElements?.length - 1]

                    if (lastChildElement) {
                      lastChildElement?.scrollIntoView()
                    }
                  }, 300)
                }}
              />
            </Space>
          </>
        )}
      </div>
    )
  }

  const needPopover = useMemo(() => {
    return (
      !inMeeting &&
      !!interpreter?.userId &&
      !!scheduleMembers?.find((item) => item.userUuid === interpreter?.userId)
    )
  }, [scheduleMembers, inMeeting, interpreter?.userId])

  return (
    <div className="nemeeting-interpreter-item">
      <Select
        className="ne-interpreter-select"
        showSearch
        allowClear
        value={
          interpreter?.userId
            ? {
                value: interpreter.userId,
                label: interpreter?.label,
              }
            : undefined
        }
        placeholder={t('interpSelectInterpreter')}
        defaultActiveFirstOption={false}
        suffixIcon={null}
        labelInValue
        labelRender={({ label }) => {
          return interpreter?.userId
            ? interpreter?.userInfo
              ? renderItem({
                  ...interpreter?.userInfo,
                  inInviting: interpreter.inInviting,
                })
              : interpreter?.label || label
            : ''
        }}
        notFoundContent={searchName ? t('meetingSearchNotFound') : ''}
        filterOption={false}
        onSearch={handleSearch}
        onChange={handleChange}
        options={renderOptions}
        virtual={false}
      />
      <Select
        listHeight={180}
        popupClassName="ne-interpreter-language-popup"
        allowClear
        value={firstLanguage}
        placeholder={t('globalLang')}
        className="ne-interpreter-language-select"
        suffixIcon={<CaretDownOutlined style={{ pointerEvents: 'none' }} />}
        onChange={handleFirstLanguageChange}
        options={firstLangOptions}
        onDropdownVisibleChange={() => setCustomLang('')}
        dropdownRender={DropdownRender}
        virtual={false}
      />
      <svg
        className="icon iconfont ne-interpreter-switch"
        aria-hidden="true"
        onClick={handleSwitchLanguage}
      >
        <use xlinkHref="#iconqiehuan"></use>
      </svg>
      <Select
        allowClear
        placeholder={t('globalLang')}
        listHeight={180}
        value={secondLanguage}
        className="ne-interpreter-language-select"
        popupClassName="ne-interpreter-language-popup"
        suffixIcon={<CaretDownOutlined style={{ pointerEvents: 'none' }} />}
        onChange={handleSecondLanguageChange}
        options={secondLangOptions}
        onDropdownVisibleChange={() => setCustomLang('')}
        dropdownRender={DropdownRender}
        virtual={false}
      />
      {!needPopover ? (
        <div
          onClick={() => onDelete?.()}
          className="nemeeting-interp-setting-del-icon"
        >
          <CloseOutlined style={{ color: '#8D90A0' }} />
        </div>
      ) : (
        <Popover
          overlayClassName="nemeeting-interp-setting-del-wrapper"
          trigger={['click']}
          content={
            <div className="nemeeting-interp-setting-del">
              <div
                title={t('interpRemoveInterpreterOnly')}
                className="nemeeting-interp-setting-del-item"
                onClick={() => onDelete?.()}
              >
                {t('interpRemoveInterpreterOnly')}
              </div>
              <div
                className="nemeeting-interp-setting-del-item nemeeting-interp-setting-del-item-danger"
                onClick={() => onDeleteScheduleMember?.()}
                title={t('interpRemoveInterpreterInMembers')}
              >
                {t('interpRemoveInterpreterInMembers')}
              </div>
            </div>
          }
          placement="bottomRight"
          title={null}
        >
          <div className="nemeeting-interp-setting-del-icon">
            <CloseOutlined style={{ color: '#8D90A0', marginLeft: '10px' }} />
          </div>
        </Popover>
      )}
    </div>
  )
}

type InterpreterInfo = NEMeetingInterpreter & {
  userInfo?: SearchAccountInfo
  key: string
  inInviting?: boolean
  label?: ReactNode
}
const InterpreterSetting = forwardRef<
  InterpreterSettingRef,
  React.PropsWithChildren<InterpreterSettingProps>
>(
  (
    {
      interpretation,
      neMeeting,
      memberList,
      inInvitingMemberList,
      inMeeting,
      onClose,
      onSaveInterpreters,
      enableCustomLang,
      maxCustomLanguageLength,
      scheduleMembers,
      onDeleteScheduleMember,
      isStarted,
      meetingContactsService,
    },
    ref
  ) => {
    const { t } = useTranslation()
    const { dispatch } = useMeetingInfoContext()
    const { eventEmitter } = useGlobalContext()
    const { languageOptions } = useDefaultLanguageOptions()
    const [customLangs, setCustomLangs] = useState<string[]>(
      getLocalStorageCustomLangs()
    )

    const inInvitingMemberListRef = useRef(inInvitingMemberList)
    const memberListRef = useRef(memberList)

    inInvitingMemberListRef.current = inInvitingMemberList
    memberListRef.current = memberList
    const isFirstMountedRef = useRef(false)

    const [interpreterSelected, setInterpreterSelected] = useState<
      InterpreterInfo[]
    >([
      {
        userId: undefined,
        firstLang: '',
        secondLang: '',
        key: '',
      },
    ])

    const interpreterSelectedRef = useRef(interpreterSelected)

    interpreterSelectedRef.current = interpreterSelected

    const enableInterpretation = useMemo(() => {
      return isStarted
    }, [isStarted])

    useEffect(() => {
      if (
        interpretation?.interpreters &&
        (neMeeting || meetingContactsService)
      ) {
        const keys = Object.keys(interpretation.interpreters)
        const tmpList: InterpreterInfo[] = []

        if (inMeeting) {
          const needGetFromServer: string[] = []

          keys.forEach((key) => {
            const interpreter = interpretation.interpreters[key]

            const index = memberListRef.current?.findIndex(
              (member) => member.uuid === key
            )

            if (memberListRef.current && index !== undefined && index > -1) {
              const member = memberListRef.current[index]

              tmpList.push({
                userId: key,
                key: member.uuid,
                firstLang: interpreter.length >= 1 ? interpreter[0] : '',
                secondLang: interpreter.length >= 2 ? interpreter[1] : '',
                userInfo: {
                  userUuid: member.uuid,
                  dept: '',
                  phoneNumber: '',
                  name: member.name,
                  avatar: member.avatar,
                },
                inInviting: false,
              })
              return
            }

            const inInviteingIndex = inInvitingMemberListRef.current?.findIndex(
              (member) => member.uuid === key
            )

            if (
              inInvitingMemberListRef.current &&
              inInviteingIndex !== undefined &&
              inInviteingIndex > -1
            ) {
              if (inInviteingIndex > -1) {
                const member = inInvitingMemberListRef.current[inInviteingIndex]

                tmpList.push({
                  userId: key,
                  key: member.uuid,
                  firstLang: interpreter.length >= 1 ? interpreter[0] : '',
                  secondLang: interpreter.length >= 2 ? interpreter[1] : '',
                  userInfo: {
                    userUuid: member.uuid,
                    dept: '',
                    phoneNumber: '',
                    name: member.name,
                    avatar: member.avatar,
                  },
                  inInviting: true,
                })
              }

              return
            }

            needGetFromServer.push(key)
          })
          // 如果一些人从会中离开并且不在未入会列表中则需要从服务器获取
          if (needGetFromServer.length > 0) {
            neMeeting?.getAccountInfoList(needGetFromServer).then((data) => {
              const list = data.meetingAccountListResp

              needGetFromServer.forEach((key) => {
                const interpreter = interpretation.interpreters[key]

                tmpList.push({
                  userId: key,
                  firstLang: interpreter.length >= 1 ? interpreter[0] : '',
                  secondLang: interpreter.length >= 2 ? interpreter[1] : '',
                  userInfo: list.find((item) => item.userUuid === key),
                  inInviting: true,
                  key,
                })
              })
              setInterpreterSelected(tmpList)
            })
          } else {
            setInterpreterSelected(tmpList)
          }
        } else if (!isFirstMountedRef.current) {
          isFirstMountedRef.current = true
          meetingContactsService?.getContactsInfo(keys).then(({ data }) => {
            const list = data.foundList

            keys.forEach((key) => {
              const interpreter = interpretation.interpreters[key]

              tmpList.push({
                userId: key,
                firstLang: interpreter.length >= 1 ? interpreter[0] : '',
                secondLang: interpreter.length >= 2 ? interpreter[1] : '',
                userInfo: list.find((item) => item.userUuid === key),
                inInviting: inInvitingMemberListRef.current
                  ? inInvitingMemberListRef.current?.findIndex(
                      (item) => item.uuid === key
                    ) > -1
                  : false,
                key,
              })
            })
            if (tmpList.length === 0) {
              tmpList.push({
                userId: undefined,
                firstLang: '',
                secondLang: '',
                key: new Date().getTime().toString(),
              })
            }

            setInterpreterSelected(tmpList)
          })
        }
      } else {
        setInterpreterSelected([
          {
            userId: undefined,
            firstLang: '',
            secondLang: '',
            key: '',
          },
        ])
      }
    }, [
      neMeeting,
      interpretation?.interpreters,
      inMeeting,
      meetingContactsService,
    ])

    // 会前编辑时，自定义语言则添加到customLangs
    useEffect(() => {
      if (interpretation?.interpreters) {
        const keys = Object.keys(interpretation.interpreters)
        const _customLangs: string[] = []

        keys.forEach((key) => {
          interpretation.interpreters[key].forEach((lang) => {
            if (!languageOptions.find((item) => item.value === lang)) {
              _customLangs.push(lang)
            }
          })
        })
        setLocalStorageCustomLangs(_customLangs)
        setCustomLangs(_customLangs)
      }
    }, [interpretation?.interpreters])

    const handleMemberJoinRoom = useCallback((members: NERoomMember[]) => {
      members.forEach((_member) => {
        const index = interpreterSelectedRef.current.findIndex(
          (item) => item.userId === _member.uuid
        )

        if (index > -1) {
          const member = interpreterSelectedRef.current[index]

          if (member.inInviting) {
            member.inInviting = false
            member.userInfo = {
              ...member.userInfo,
              userUuid: _member.uuid,
              dept: '',
              phoneNumber: '',
              name: _member.name,
              avatar: _member.avatar,
            }
            interpreterSelectedRef.current[index] = member
            setInterpreterSelected([...interpreterSelectedRef.current])
          }
        }
      })
    }, [])

    const handleMemberLeaveRoom = useCallback((members: NERoomMember[]) => {
      members.forEach((member) => {
        const index = interpreterSelectedRef.current.findIndex(
          (item) => item.userId === member.uuid
        )

        if (index > -1) {
          const member = interpreterSelectedRef.current[index]

          if (member.inInviting) {
            member.inInviting = true
            interpreterSelectedRef.current[index] = member
            setInterpreterSelected([...interpreterSelectedRef.current])
          }
        }
      })
    }, [])

    const handleMemberNameChanged = useCallback(
      (member: NERoomMember, name: string) => {
        const index = interpreterSelectedRef.current.findIndex(
          (item) => item.userId === member.uuid
        )

        if (index > -1) {
          const interpreterMember = interpreterSelectedRef.current[index]

          interpreterMember.userInfo = {
            ...interpreterMember.userInfo,
            userUuid: member.uuid,
            dept: '',
            phoneNumber: '',
            name: name,
            avatar: member.avatar,
          }
          interpreterSelectedRef.current[index] = interpreterMember
          setInterpreterSelected([...interpreterSelectedRef.current])
        }
      },
      []
    )

    useEffect(() => {
      eventEmitter?.on(EventType.MemberLeaveRoom, handleMemberLeaveRoom)
      eventEmitter?.on(EventType.MemberJoinRoom, handleMemberJoinRoom)
      eventEmitter?.on(EventType.MemberNameChanged, handleMemberNameChanged)

      return () => {
        eventEmitter?.off(EventType.MemberLeaveRoom, handleMemberLeaveRoom)
        eventEmitter?.off(EventType.MemberJoinRoom, handleMemberJoinRoom)
        eventEmitter?.off(EventType.MemberNameChanged, handleMemberNameChanged)
      }
    }, [
      eventEmitter,
      handleMemberJoinRoom,
      handleMemberLeaveRoom,
      handleMemberNameChanged,
    ])

    const onSwitchLanguage = (index) => {
      const tmpList = [...interpreterSelected]
      const tmp = tmpList[index].firstLang

      tmpList[index].firstLang = tmpList[index].secondLang
      tmpList[index].secondLang = tmp
      setInterpreterSelected(tmpList)
    }

    const onAddInterpreter = () => {
      if (interpreterSelected.length >= 10) {
        return
      }

      const tmpList = [...interpreterSelected]

      tmpList.push({
        userId: undefined,
        firstLang: '',
        secondLang: '',
        key: new Date().getTime().toString(),
      })
      setInterpreterSelected(tmpList)
    }

    const onDelete = (index) => {
      const tmpList = [...interpreterSelected]

      tmpList.splice(index, 1)
      setInterpreterSelected(tmpList)
    }

    const onFirstLanguageChange = (index, language) => {
      const tmpList = [...interpreterSelected]

      tmpList[index].firstLang = language
      setInterpreterSelected(tmpList)
    }

    const onSecondLanguageChange = (index, language) => {
      const tmpList = [...interpreterSelected]

      tmpList[index].secondLang = language
      setInterpreterSelected(tmpList)
    }

    const onInterpreterChange = (
      index,
      data?: { value: string; label: ReactNode }
    ) => {
      const userId = data?.value

      if (
        userId &&
        interpreterSelected.findIndex((item) => item.userId === userId) > -1
      ) {
        Toast.warning(t('interpInterpreterAlreadyExists'))

        const tmpList = [...interpreterSelected]

        tmpList[index].userId = ''
        setInterpreterSelected(tmpList)
        return
      }

      const tmpList = [...interpreterSelected]

      if (userId) {
        tmpList[index].userId = userId
        tmpList[index].key = userId
        tmpList[index].label = data.label
        tmpList[index].userInfo = undefined
      } else {
        tmpList[index].userId = undefined
        tmpList[index].label = ''
        tmpList[index].userInfo = undefined
      }

      setInterpreterSelected(tmpList)
    }

    const onClickStop = () => {
      const closeModal = CommonModal.confirm({
        title: t('commonTitle'),
        content: t('interpConfirmStopMsg'),
        width: 270,
        footer: (
          <div className="nemeeting-modal-confirm-btns">
            <Button
              onClick={() => {
                closeModal.destroy()
              }}
            >
              {t('globalCancel')}
            </Button>
            <Button
              danger
              onClick={async () => {
                neMeeting?.stopInterpretation().catch((e: ServerError) => {
                  Toast.fail(e.message || e.msg)
                  dispatch?.({
                    type: ActionType.UPDATE_MEETING_INFO,
                    data: {
                      openInterpretationBySelf: false,
                    },
                  })
                })
                closeModal.destroy()
                dispatch?.({
                  type: ActionType.UPDATE_MEETING_INFO,
                  data: {
                    openInterpretationBySelf: true,
                  },
                })
              }}
            >
              {t('globalClose')}
            </Button>
          </div>
        ),
      })
    }

    const onClickCancel = () => {
      if (window.isElectronNative) {
        handleCloseBeforeMeetingWindow()
      } else {
        onClose?.()
      }
    }

    const onClickSave = () => {
      const interpreterList = interpreterSelected.map((item) => {
        return {
          userId: item.userId,
          firstLang: item.firstLang,
          secondLang: item.secondLang,
        }
      })

      onSaveInterpreters?.(interpreterList)
    }

    const startOrUpdateInterpretation = () => {
      const interpreters = interpreterSelected.map((item) => {
        return {
          userId: item.userId,
          firstLang: item.firstLang,
          secondLang: item.secondLang,
        }
      })

      // 如果已开启则更新
      return neMeeting
        ?.updateInterpretation({
          interpreters: interpreters,
        })
        .then(() => {
          onClose?.()
        })
        .catch((e: ServerError) => {
          Toast.fail(e.msg)
        })
    }

    const onClickStartOrUpdate = () => {
      if (enableInterpretation) {
        CommonModal.confirm({
          title: t('commonTitle'),
          content: t('interpConfirmUpdateMsg'),
          width: 270,
          onOk: () => {
            dispatch?.({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                openInterpretationBySelf: true,
              },
            })
            startOrUpdateInterpretation()
          },
          cancelText: t('globalCancel'),
          okText: t('globalSure'),
        })
      } else {
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            openInterpretationBySelf: true,
          },
        })
        startOrUpdateInterpretation()?.catch(() => {
          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              openInterpretationBySelf: false,
            },
          })
        })
      }
    }

    // 会前是否能够点击完成按钮
    const canSaveInterpretation = useMemo(() => {
      return interpreterSelected.every(
        (item) =>
          (item.firstLang && item.secondLang && item.userId) ||
          (!item.firstLang && !item.secondLang && !item.userId)
      )
    }, [interpreterSelected])
    const canStartInterpretation = useMemo(() => {
      // 如果每一个添加的都是空的则不能开启
      if (
        interpreterSelected.length <= 0 ||
        interpreterSelected.every(
          (item) => !item.userId && !item.firstLang && !item.secondLang
        )
      ) {
        return false
      }

      // 如果有一个翻译员未选择语言则不能开启
      return interpreterSelected.every(
        (item) =>
          (item.firstLang && item.secondLang && item.userId) ||
          (!item.firstLang && !item.secondLang && !item.userId)
      )
    }, [interpreterSelected])

    const canUpdateInterpretation = useMemo(() => {
      // 和原先已选择的翻译员对比，如果有变化则可以更新
      if (interpretation?.interpreters) {
        const keys = Object.keys(interpretation.interpreters)

        // 去除空行
        const filterInterpreterSelected = interpreterSelected.filter(
          (item) => item.userId || item.firstLang || item.secondLang
        )

        if (filterInterpreterSelected.length === 0) {
          return false
        }

        if (
          filterInterpreterSelected.length !== keys.length &&
          filterInterpreterSelected.every(
            (item) => item.userId && item.firstLang && item.secondLang
          )
        ) {
          return true
        }

        for (let i = 0; i < keys.length; i++) {
          if (
            (keys[i] !== filterInterpreterSelected[i]?.userId ||
              interpretation.interpreters[keys[i]][0] !==
                filterInterpreterSelected[i]?.firstLang ||
              interpretation.interpreters[keys[i]][1] !==
                filterInterpreterSelected[i]?.secondLang) &&
            !!(
              filterInterpreterSelected[i]?.firstLang &&
              filterInterpreterSelected[i]?.secondLang &&
              filterInterpreterSelected[i]?.userId
            )
          ) {
            return true
          }
        }

        return false
      } else {
        return false
      }
    }, [interpreterSelected, interpretation?.interpreters])

    const getNeedUpdate = useCallback((): boolean => {
      return !!canUpdateInterpretation
    }, [canUpdateInterpretation])

    const getNeedSave = useCallback((): boolean => {
      return !!canSaveInterpretation
    }, [canSaveInterpretation])

    const canCloseBeforeMeetingWindow = useMemo(() => {
      if (interpretation?.interpreters) {
        return canUpdateInterpretation
      } else {
        return interpreterSelected.every(
          (item) => item.userId || item.firstLang || item.secondLang
        )
      }
    }, [interpretation?.interpreters, interpreterSelected])

    const closeConfirm = useCallback(() => {
      const modal = CommonModal.confirm({
        title: t('commonTitle'),
        content: t('interpConfirmCancelEditMsg'),
        width: 400,
        onOk: () => {
          modal.destroy()
          window.ipcRenderer?.send('childWindow:closed')
        },
        cancelText: t('globalCancel'),
        okText: t('globalSure'),
      })
    }, [t])

    const handleCloseBeforeMeetingWindow = useCallback(() => {
      if (canCloseBeforeMeetingWindow) {
        closeConfirm()
      } else {
        window.ipcRenderer?.send('childWindow:closed')
      }
    }, [canCloseBeforeMeetingWindow])

    const handleCloseInMeetingWindow = useCallback(() => {
      if (canUpdateInterpretation) {
        closeConfirm()
      } else {
        window.ipcRenderer?.send('childWindow:closed')
      }
    }, [canUpdateInterpretation])

    useImperativeHandle(
      ref,
      () => ({
        getNeedUpdate,
        getNeedSave,
        handleCloseBeforeMeetingWindow,
        handleCloseInMeetingWindow,
      }),
      [
        getNeedUpdate,
        getNeedSave,
        handleCloseBeforeMeetingWindow,
        handleCloseInMeetingWindow,
      ]
    )
    const renderLanguageOptions = useMemo(() => {
      const customLangOptions = customLangs.map((item) => {
        return {
          value: item,
          label: item,
        }
      })

      return languageOptions.concat(customLangOptions)
    }, [languageOptions, customLangs])

    const onCustomLangAdd = (customLang: string) => {
      // 把自定义语言缓存到localStorage，如果缓存已有则添加到已有缓存语言列表
      let customLangs: string[] = []

      customLangs = getLocalStorageCustomLangs()
      // 判断当前语言是否已存在
      if (
        customLangs.includes(customLang) ||
        (languageOptions &&
          languageOptions.findIndex(
            (item) => item.value === customLang || item.label === customLang
          ) > -1)
      ) {
        Toast.warning(t('interpLanguageAlreadyExists'))
        return
      }

      customLangs.push(customLang)
      setCustomLangs(customLangs)
      setLocalStorageCustomLangs(customLangs)
    }

    const handleDeleteScheduleMember = (index: number, userId?: string) => {
      onDelete(index)
      if (userId) {
        onDeleteScheduleMember?.(userId)
      }
    }

    return (
      <div className="nemeeting-interpreter-setting">
        <div className="nemeeting-interpreter-setting-content">
          {interpreterSelected.map((item, index) => {
            return (
              <InterpreterItem
                onDeleteScheduleMember={() =>
                  handleDeleteScheduleMember(index, item.userId)
                }
                scheduleMembers={scheduleMembers}
                enableCustomLang={enableCustomLang}
                maxCustomLanguageLength={maxCustomLanguageLength}
                inMeeting={inMeeting}
                key={item.key}
                memberList={memberList}
                inInvitingMemberList={inInvitingMemberList}
                neMeeting={neMeeting}
                firstLanguage={item.firstLang || undefined}
                secondLanguage={item.secondLang || undefined}
                onSwitchLanguage={() => onSwitchLanguage(index)}
                onCustomLangAdd={onCustomLangAdd}
                interpreter={item || undefined}
                onDelete={() => onDelete(index)}
                languageOptions={renderLanguageOptions}
                meetingContactsService={meetingContactsService}
                onInterpreterChange={(userId) =>
                  onInterpreterChange(index, userId)
                }
                onFirstLanguageChange={(lang) =>
                  onFirstLanguageChange(index, lang)
                }
                onSecondLanguageChange={(lang) =>
                  onSecondLanguageChange(index, lang)
                }
              />
            )
          })}
        </div>

        {/* footer */}
        <div className="nemeeting-interpreter-footer">
          <Button
            style={{ height: '36px', fontSize: '14px' }}
            disabled={interpreterSelected.length >= 10}
            onClick={onAddInterpreter}
            icon={<PlusCircleOutlined />}
            type="link"
          >
            {t('interpAddInterperter')}
          </Button>
          <div className="nemeeting-interpreter-update-wrapper">
            {inMeeting ? (
              <>
                {enableInterpretation && (
                  <Button
                    style={{ height: '36px', fontSize: '14px' }}
                    danger
                    size="large"
                    className="nemeeting-interpreter-close"
                    onClick={onClickStop}
                  >
                    {t('interpStop')}
                  </Button>
                )}
                <Button
                  style={{ height: '36px', fontSize: '14px' }}
                  size="large"
                  disabled={
                    enableInterpretation
                      ? !canUpdateInterpretation
                      : !canStartInterpretation
                  }
                  type="primary"
                  className="nemeeting-interpreter-update"
                  onClick={onClickStartOrUpdate}
                >
                  {enableInterpretation ? t('globalUpdate') : t('interpStart')}
                </Button>
              </>
            ) : (
              <>
                <Button
                  style={{ height: '36px', fontSize: '14px' }}
                  size="large"
                  className="nemeeting-interpreter-close"
                  onClick={onClickCancel}
                >
                  {t('globalCancel')}
                </Button>
                <Button
                  style={{ height: '36px', fontSize: '14px' }}
                  size="large"
                  disabled={!canSaveInterpretation}
                  type="primary"
                  className="nemeeting-interpreter-update"
                  onClick={onClickSave}
                >
                  {t('done')}
                </Button>
              </>
            )}
          </div>
        </div>
      </div>
    )
  }
)

InterpreterSetting.displayName = 'InterpreterSetting'
export default InterpreterSetting
