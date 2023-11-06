function prettyConferenceId(conferenceId) {
    if (conferenceId === undefined) {
        conferenceId = meetingManager.meetingId
    }
    return conferenceId.substring(0, 3) + "-" +
            conferenceId.substring(3, 6) + "-" +
            conferenceId.substring(6)
}

function arrangeSpeakerLayout(primaryMember, secondaryMembers, realPage, realCount, primaryContainer, secondaryContainer) {
    for (let i = 0; i < secondaryMembers.length; i++) {
        const member = secondaryMembers[i]
        const result = compareMemberInfo(member, i, secondaryContainer)
        if (-1 === result) {
            // user not exist in listview
            secondaryContainer.append(member)
        } else if (1 === result) {
            // needs to replace
            secondaryContainer.remove(i)
            secondaryContainer.insert(i, member)
        }
    }

    // Remove invalid users when the number of lists exceeds the actual number
    if (secondaryContainer.count > secondaryMembers.length) {
        for (let j = secondaryMembers.length; j < secondaryContainer.count; /* Do not ++ */) {
            secondaryContainer.remove(j)
        }
    }
    if (null !== primaryContainer && !compareSpeaker(primaryMember)) {
        setActiveSpeaker(primaryMember, primaryContainer)
    }
}

function arrangeSplitLayout(secondaryMembers, realPage, realCount, primaryContainer, secondaryContainer) {
    for (let i = 0; i < secondaryMembers.length; i++) {
        const member = secondaryMembers[i]
        const result = compareMemberInfo(member, i, secondaryContainer)
        if (-1 === result) {
            // user not exist in listview
            secondaryContainer.append(member)
        } else if (1 === result) {
            // needs to replace
            secondaryContainer.remove(i)
            secondaryContainer.insert(i, member)
        }
    }

    // Remove invalid users when the number of lists exceeds the actual number
    if (secondaryContainer.count > secondaryMembers.length) {
        for (let j = secondaryMembers.length; j < secondaryContainer.count; /* Do not ++ */) {
            secondaryContainer.remove(j)
        }
    }
}

function compareMemberInfo(memberObject, index, viewModel) {
    if (index > viewModel.count - 1) {
        return -1
    }
    const member = viewModel.get(index)
    if (memberObject.accountId === member.accountId &&
        memberObject.sharingStatus === member.sharingStatus &&
        memberObject.createdAt === member.createdAt) {
        return 0
    }
    return 1
}

function compareSpeaker(memberObject) {
    if (currentSpeaker === undefined) {
        return false
    }
    return  currentSpeaker.accountId === memberObject.accountId &&
            currentSpeaker.sharingStatus === memberObject.sharingStatus &&
            currentSpeaker.createdAt === memberObject.createdAt
}

function setActiveSpeaker(primaryMember, primaryContainer) {
    if (null === primaryContainer || compareSpeaker(primaryMember))
        return
    if (currentSpeaker !== undefined) {
        currentSpeaker.destroy(0)
        currentSpeaker = undefined
    }
    console.info("Setup primary member, info: ", JSON.stringify(primaryMember))
    currentSpeaker = Qt.createComponent("qrc:/qml/components/VideoDelegate.qml").createObject(primaryContainer, {
        accountId: primaryMember.accountId,
        nickname: primaryMember.nickname,
        audioStatus: primaryMember.audioStatus,
        videoStatus: primaryMember.videoStatus,
        sharingStatus: primaryMember.sharingStatus,
        createdAt: primaryMember.createdAt,
        primary: true,
        highQuality: true
    })
    currentSpeaker.anchors.fill = primaryContainer
}

function arrangeGridLayout(members, page, memberCount, rootContainer, membersContainer, membersModel, highQualityCount) {
    console.info("Arrang gallery layout, current page:", currentPage,
                 "actual page:", page,
                 "page size:", pageSize,
                 "member count:", members.length,
                 "all member count:", memberCount)
    membersModel.clear()
    const gridLayoutInfo = resizeGridCell(members.length, rootContainer, membersContainer)
    const columnCount = gridLayoutInfo.columnCount
    const itemHeight = gridLayoutInfo.itemHeight
    const itemWidth = gridLayoutInfo.itemWidth
    const remainder = members.length % columnCount
    const lastFirst = members.length - remainder
    let highQuality = true
    if (members.length > highQualityCount) highQuality = false
    for (let i = 0; i < members.length; i++) {
        let member = members[i]
        const currentRow = Math.floor(i / columnCount)
        if (i >= lastFirst) {
            const beginSpan = columnCount - remainder
            const rowIndex = i % columnCount
            const column = beginSpan + (rowIndex * 2)
            Object.assign(member, { column: column, row: currentRow, height: itemHeight, width: itemWidth, highQuality: highQuality })
        } else {
            const column = i % columnCount * 2
            Object.assign(member, { column: column, row: currentRow, height: itemHeight, width: itemWidth, highQuality: highQuality })
        }
        if (compareMemberInfo(member, i, membersModel) === -1) {
            // user not exist in listview
            membersModel.append(member)
            continue;
        }
        if (compareMemberInfo(member, i, membersModel) === 1) {
            // needs to replace
            membersModel.remove(i)
            membersModel.insert(i, member)
            continue;
        }
    }

    // Remove invalid users when the number of lists exceeds the actual number
    if (membersModel.count > members.length) {
        for (let j = members.length; j < membersModel.count; j++) {
            membersModel.remove(j)
        }
    }
}

function resizeGridCell(memberCount, rootContainer, membersContainer) {
    let columnCount = 1
    let itemWidth = 0
    let itemHeight = 0
    membersContainer.height = rootContainer.height
    membersContainer.width = rootContainer.width
    if (memberCount >= 13) {
        columnCount = 4
    } else if (memberCount >= 10) {
        columnCount = 4
    } else if (memberCount >= 5) {
        columnCount = 3
    } else if (memberCount >= 2) {
        columnCount = 2
    } else {
        columnCount = 1
    }
    const rowCount = Math.ceil(memberCount / columnCount)
    const columnSpacing = (columnCount - 1) * membersContainer.columnSpacing
    const rowSpacing = (rowCount - 1) * membersContainer.rowSpacing
    itemWidth = (membersContainer.width - columnSpacing) / columnCount
    itemHeight = itemWidth / 16 * 9
    // console.log(`--- Resize grid cell, row count: ${rowCount}, item height: ${itemHeight}, row spacing ${rowSpacing}, max height: ${Math.floor(rowCount * itemHeight + rowSpacing)}, root container height: ${rootContainer.height}`)
    // membersContainer.height = Math.min(Math.floor(rowCount * itemHeight + rowSpacing), rootContainer.height)

    if (membersContainer.height > rootContainer.height) {
        membersContainer.height = rootContainer.height
        const rowCount = Math.ceil(memberCount / columnCount)
        const rowSpacing = (rowCount - 1) * membersContainer.rowSpacing
        const columnSpacing = (columnCount - 1) * membersContainer.columnSpacing
        itemHeight = (membersContainer.height - rowSpacing) / rowCount
        itemWidth = itemHeight / 9 * 16
        membersContainer.width = itemWidth * columnCount + columnSpacing
    }
    membersContainer.columns = columnCount * 2
    return {
        columnCount: columnCount,
        itemWidth: itemWidth,
        itemHeight: itemHeight
    }
}

function arrangeWhiteboardMemberLayout(members, page, memberCount, membersModel){
    for (let i = 0; i < members.length; i++) {
        const member = members[i]
        const result = compareMemberInfo(member, i, membersModel)
        if (-1 === result) {
            // user not exist in listview
            membersModel.append(member)
        } else if (1 === result) {
            // needs to replace
            membersModel.remove(i)
            membersModel.insert(i, member)
        }
    }

    if (membersModel.count > members.length) {
        for (let j = members.length; j < membersModel.count; /* Do not ++ */) {
            membersModel.remove(j)
        }
    }
}

const debounce = (func, wait = 50) => {
    let timer = 0
    return function(...args) {
        if (timer) clearTimeout(timer)
        timer = setTimeout(() => {
            func.apply(this, args)
        }, wait)
    }
}
