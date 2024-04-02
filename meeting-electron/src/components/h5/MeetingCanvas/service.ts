import { LayoutTypeEnum, NEMember } from '../../../types'
import { sortMembers } from '../../../store'

export function groupMembersService(data: {
  memberList: NEMember[]
  myUuid: string
  groupNum: number
  focusUuid: string
  screenUuid: string
  activeSpeakerUuid: string
  groupType: 'web' | 'h5'
  enableSortByVoice: boolean
  layout?: LayoutTypeEnum
  isWhiteboardTransparent?: boolean
  whiteboardUuid?: string
}): Array<NEMember[]> {
  const {
    memberList,
    groupNum,
    focusUuid,
    screenUuid,
    myUuid,
    activeSpeakerUuid,
    enableSortByVoice,
    groupType,
    layout,
    isWhiteboardTransparent,
    whiteboardUuid,
  } = data
  let tmpMemberList: NEMember[] = Array.isArray(memberList)
    ? [...memberList]
    : []
  if (tmpMemberList.length === 1) {
    return [tmpMemberList]
  }
  const localMember = tmpMemberList.find(
    (member) => member.uuid === myUuid
  ) as NEMember
  let groupMembers: Array<NEMember[]> = []

  // 画廊模式不排序只把本端排第一位
  if (layout === LayoutTypeEnum.Gallery) {
    // 如果本端是巡查则找不到localMember
    localMember && sortMember2Top(tmpMemberList, myUuid)
    // 进行分组
    groupMembers = getGroupMembers(tmpMemberList, groupNum)
    return groupMembers
  }
  tmpMemberList = sortMembers(tmpMemberList, myUuid)
  // web端使用 主画面成员
  let mainViewMember: NEMember = localMember || tmpMemberList[0]
  const activeMember = tmpMemberList.find(
    (member) => member.uuid === activeSpeakerUuid
  )
  if (screenUuid) {
    // 共享屏幕者
    sortMember2Top(tmpMemberList, screenUuid, true)
  } else if (activeSpeakerUuid && activeMember && enableSortByVoice) {
    // 说话最大声者进行排序
    sortMember2Top(tmpMemberList, activeSpeakerUuid)
  }
  // 首页需要特殊处理
  if (tmpMemberList.length >= 2) {
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
      } else if (activeSpeakerUuid && activeMember && enableSortByVoice) {
        // 存在说话最大声者, 设置第二个元素为本端
        // 先把本端排第一位，由于最开始active已经排序过，所以第一个位置为active
        const activeSpeakerMember = tmpMemberList.shift()
        // 去除第一个元素后，把本端排第一个位置
        localMember && sortMember2Top(tmpMemberList, localMember.uuid)
        // 把说话最大声这放入第一个位置，此时本端在第二个位置
        tmpMemberList.unshift(activeSpeakerMember as NEMember)
      } else {
        // 默认情况，本端在第二个位置
        const firstMember = tmpMemberList.shift()
        // 如果第一个元素非本端，则继续排序把本端排第一个位置
        if (firstMember && firstMember.uuid !== myUuid) {
          sortMember2Top(tmpMemberList, myUuid)
          tmpMemberList.unshift(firstMember as NEMember)
        } else {
          // 第一项是自己则排在第二位置
          const secondMember = tmpMemberList.shift()
          tmpMemberList.unshift(firstMember as NEMember)
          tmpMemberList.unshift(secondMember as NEMember)
        }
      }
    }
    // h5使用首页前两个成员
    let firstMember: NEMember | undefined
    let secondMember: NEMember | undefined

    if (groupType === 'h5') {
      // 第一页只有两项
      firstMember = tmpMemberList.shift() as NEMember
      secondMember = tmpMemberList.shift() as NEMember
    } else {
      // 目前只有web存在不同layout
      if (
        !layout ||
        (layout &&
          (layout === 'speaker' || screenUuid) &&
          (!whiteboardUuid || isWhiteboardTransparent))
      ) {
        mainViewMember = tmpMemberList.shift() as NEMember
      }
    }
    // 进行分组

    groupMembers = getGroupMembers(tmpMemberList, groupNum)
    // const groupCount = Math.ceil(tmpMemberList.length / groupNum)
    // // console.log('tmpMemberList', tmpMemberList, firstMember, secondMember)
    // for (let i = 0; i < groupCount; i++) {
    //   // 原有逻辑
    //   groupMembers.push(tmpMemberList.slice(i * groupNum, (i + 1) * groupNum))
    // }
    if (firstMember && secondMember) {
      groupMembers.unshift([firstMember, secondMember])
    } else {
      // 目前只有web存在不同layout
      if (
        !layout ||
        (layout &&
          layout === 'speaker' &&
          (!whiteboardUuid || isWhiteboardTransparent))
      ) {
        groupMembers.unshift([mainViewMember])
      }
    }
  } else {
    groupMembers = [memberList]
  }

  return groupMembers
}

function getGroupMembers(memberList: NEMember[], groupNum: number) {
  // 进行分组
  const groupCount = Math.ceil(memberList.length / groupNum)
  const groupMembers: Array<NEMember[]> = []
  for (let i = 0; i < groupCount; i++) {
    // 原有逻辑
    groupMembers.push(memberList.slice(i * groupNum, (i + 1) * groupNum))
  }

  return groupMembers
}

function sortMember2Top(
  memberList: NEMember[],
  uuid: string,
  isScreen = false
): NEMember | null {
  const index = memberList.findIndex((member) => member.uuid === uuid)
  let member: NEMember | null = null
  if (index >= 0) {
    // 删除原先位置元素
    const [deletedMember] = memberList.splice(index, 1)
    member = deletedMember
    memberList.unshift(member)
    // 共享屏幕时候，画廊不显示共享者，首页显示共享者画面和视频画面
    if (isScreen) {
      memberList.unshift(member)
    }
  }
  return member
}
