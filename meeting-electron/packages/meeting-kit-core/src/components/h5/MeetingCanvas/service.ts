import { sortMembers } from '../../../store'
import { LayoutTypeEnum, NEMember } from '../../../types'

export function groupMembersService(data: {
  memberList: NEMember[]
  inInvitingMemberList?: NEMember[]
  myUuid: string
  groupNum: number
  focusUuid: string
  screenUuid: string
  activeSpeakerUuid: string
  groupType: 'web' | 'h5'
  enableSortByVoice: boolean
  layout?: LayoutTypeEnum
  isWhiteboardTransparent?: boolean
  enableVoicePriorityDisplay: boolean
  whiteboardUuid?: string
  pinVideoUuid?: string
  hostUuid?: string
  viewOrder?: string
  enableHideVideoOffAttendees?: boolean
}): Array<NEMember[]> {
  const {
    memberList,
    groupNum,
    focusUuid,
    screenUuid,
    myUuid,
    activeSpeakerUuid,
    enableSortByVoice,
    enableVoicePriorityDisplay,
    groupType,
    layout,
    isWhiteboardTransparent,
    whiteboardUuid,
    pinVideoUuid,
    viewOrder,
    inInvitingMemberList,
    hostUuid,
    enableHideVideoOffAttendees,
  } = data

  if (memberList.length === 0) {
    return []
  }

  let tmpMemberList: NEMember[] = Array.isArray(memberList)
    ? [...memberList]
    : []

  if (
    tmpMemberList.length === 1 &&
    !screenUuid &&
    !whiteboardUuid &&
    (!inInvitingMemberList || inInvitingMemberList?.length === 0)
  ) {
    return [tmpMemberList]
  }

  const localMember = tmpMemberList.find(
    (member) => member.uuid === myUuid
  ) as NEMember
  const hostMember = hostUuid
    ? tmpMemberList.find((member) => member.uuid === hostUuid)
    : null
  let groupMembers: Array<NEMember[]> = []

  // 画廊模式不排序只把本端排第一位
  if (layout === LayoutTypeEnum.Gallery) {
    // 如果本端是巡查则找不到localMember
    if (viewOrder) {
      const idOrder = viewOrder.split(',')

      tmpMemberList.sort((a, b) => {
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
    } else {
      localMember && sortMember2Top(tmpMemberList, myUuid)
    }

    // 进行分组
    groupMembers = getGroupMembers({
      memberList: tmpMemberList,
      groupNum,
      inInvitingMemberList,
      enableHideVideoOffAttendees,
    })
    return groupMembers
  }

  tmpMemberList = sortMembers(tmpMemberList, myUuid)
  // web端使用 主画面成员
  let mainViewMember: NEMember = hostMember || localMember || tmpMemberList[0]
  const activeMember = activeSpeakerUuid
    ? tmpMemberList.find((member) => member.uuid === activeSpeakerUuid)
    : null

  if (screenUuid) {
    // 共享屏幕者
    sortMember2Top(tmpMemberList, screenUuid)
  } else if (
    activeSpeakerUuid &&
    activeMember &&
    enableSortByVoice &&
    enableVoicePriorityDisplay
  ) {
    // 说话最大声者进行排序
    sortMember2Top(tmpMemberList, activeSpeakerUuid)
  } else if (hostUuid) {
    sortMember2Top(tmpMemberList, hostUuid)
  }

  // h5使用首页前两个成员
  let firstMember: NEMember | undefined
  let secondMember: NEMember | undefined

  // 首页需要特殊处理
  if (tmpMemberList.length >= 2 || whiteboardUuid) {
    // 共享屏幕逻辑已处理完成
    if (!screenUuid) {
      if (whiteboardUuid && groupType != 'h5' && !isWhiteboardTransparent) {
        // 白板画面逻辑
        // do nothing
        sortMember2Top(tmpMemberList, whiteboardUuid)
      } else if (focusUuid) {
        // 焦点画面排序
        // 如果第一个不是本端，则设置第二个元素为本端
        sortMember2Top(tmpMemberList, myUuid)
        sortMember2Top(tmpMemberList, focusUuid)
      } else if (pinVideoUuid) {
        pinVideoUuid !== myUuid && sortMember2Top(tmpMemberList, myUuid)
        sortMember2Top(tmpMemberList, pinVideoUuid)
      } else if (
        activeSpeakerUuid &&
        activeMember &&
        enableSortByVoice &&
        enableVoicePriorityDisplay
      ) {
        // 存在说话最大声者, 设置第二个元素为本端
        // 先把本端排第一位，由于最开始active已经排序过，所以第一个位置为active
        const activeSpeakerMember = tmpMemberList.shift()

        // 去除第一个元素后，把本端排第一个位置
        localMember && sortMember2Top(tmpMemberList, localMember.uuid)
        // 把说话最大声这放入第一个位置，此时本端在第二个位置
        tmpMemberList.unshift(activeSpeakerMember as NEMember)
      }
      // else {
      //   // 默认情况，本端在第二个位置，主持人排第一位
      //   const firstMember = tmpMemberList.shift()

      //   // 如果第一个元素非本端，则继续排序把本端排第一个位置
      //   if (firstMember && firstMember.uuid !== myUuid) {
      //     sortMember2Top(tmpMemberList, myUuid)
      //     tmpMemberList.unshift(firstMember as NEMember)
      //   } else {
      //     // 第一项是自己则排在第二位置
      //     const secondMember = tmpMemberList.shift()

      //     tmpMemberList.unshift(firstMember as NEMember)
      //     tmpMemberList.unshift(secondMember as NEMember)
      //   }
      // }
    }

    // 自定义排序
    if (viewOrder) {
      const idOrder = viewOrder.split(',')

      tmpMemberList.sort((a, b) => {
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
      if (focusUuid) {
        sortMember2Top(tmpMemberList, focusUuid)
      } else if (pinVideoUuid) {
        sortMember2Top(tmpMemberList, pinVideoUuid)
      }
    }

    generateMembers()
  } else {
    const tmpMemberList = [...memberList]

    if (inInvitingMemberList) {
      generateMembers()
    } else {
      groupMembers = [tmpMemberList]
    }
  }

  function generateMembers() {
    if (groupType === 'h5') {
      // 第一页只有两项
      if (screenUuid) {
        const member = tmpMemberList.find(
          (member) => member.uuid === screenUuid
        ) as NEMember

        firstMember = member
      } else {
        firstMember = tmpMemberList.shift() as NEMember
      }

      secondMember = tmpMemberList.shift() as NEMember
    } else {
      // 目前只有web存在不同layout
      if (screenUuid) {
        const _screenMember = tmpMemberList.find(
          (member) => member.uuid === screenUuid
        ) as NEMember

        let screenMember

        if (_screenMember) {
          screenMember = JSON.parse(JSON.stringify(_screenMember)) as NEMember

          screenMember.isSharingScreenView = true
        }

        if (pinVideoUuid) {
          const index = tmpMemberList.findIndex(
            (member) => member.uuid === pinVideoUuid
          )

          if (index >= 0) {
            mainViewMember = tmpMemberList[index]
            tmpMemberList.splice(index, 1)
            screenMember && tmpMemberList.unshift(screenMember)
          }
        } else {
          mainViewMember = screenMember
        }
      } else if (whiteboardUuid && !isWhiteboardTransparent) {
        const _whiteboardMember = tmpMemberList.find(
          (member) => member.uuid === whiteboardUuid
        ) as NEMember

        if (_whiteboardMember) {
          const whiteboardMember = JSON.parse(
            JSON.stringify(_whiteboardMember)
          ) as NEMember

          whiteboardMember.isSharingWhiteboardView = true

          if (pinVideoUuid) {
            const index = tmpMemberList.findIndex(
              (member) => member.uuid === pinVideoUuid
            )

            if (index >= 0) {
              mainViewMember = tmpMemberList[index]
              tmpMemberList.splice(index, 1)
              tmpMemberList.unshift(whiteboardMember)
            }
          }
        }
      } else {
        mainViewMember = tmpMemberList.shift() as NEMember
      }
    }

    // 进行分组
    groupMembers = getGroupMembers({
      memberList: tmpMemberList,
      groupNum,
      inInvitingMemberList,
      enableHideVideoOffAttendees,
    })

    if (firstMember && secondMember) {
      groupMembers.unshift([firstMember, secondMember])
    } else {
      // 目前只有web存在不同layout
      if (!layout || (layout && layout === 'speaker')) {
        groupMembers.unshift([mainViewMember])
      }
    }
  }

  return groupMembers
}

function getGroupMembers(data: {
  memberList: NEMember[]
  groupNum: number
  inInvitingMemberList?: NEMember[]
  enableHideVideoOffAttendees?: boolean
}) {
  const { memberList, groupNum, inInvitingMemberList } = data
  let tmpMemberList = [...memberList]

  // if (enableHideVideoOffAttendees) {
  //   // 去除当前正在共享屏幕，但是没有开启视频的成员
  //   const index = tmpMemberList.findIndex(
  //     (member) => member.isSharingScreenView && !member.isVideoOn
  //   )

  //   if (index) {
  //     tmpMemberList.splice(index, 1)
  //   }
  // }

  if (inInvitingMemberList) {
    tmpMemberList = tmpMemberList.concat(inInvitingMemberList)
  }

  // 进行分组
  const groupCount = Math.ceil(tmpMemberList.length / groupNum)
  const groupMembers: Array<NEMember[]> = []

  for (let i = 0; i < groupCount; i++) {
    // 原有逻辑
    groupMembers.push(tmpMemberList.slice(i * groupNum, (i + 1) * groupNum))
  }

  return groupMembers
}

function sortMember2Top(memberList: NEMember[], uuid: string): NEMember | null {
  const index = memberList.findIndex((member) => member.uuid === uuid)
  let member: NEMember | null = null

  if (index >= 0) {
    // 删除原先位置元素
    const [deletedMember] = memberList.splice(index, 1)

    member = deletedMember
    memberList.unshift(member)
    // 共享屏幕时候，画廊不显示共享者，首页显示共享者画面和视频画面
    /*
    if (isScreen) {
      memberList.unshift(member)
    }
    */
  }

  return member
}
