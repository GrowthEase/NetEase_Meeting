function calcContainerSize(itemSize, spacing, columnCount, rowCount) {
    const columnSpacing = (columnCount - 1) * spacing;
    const rowSpacing = (rowCount - 1) * spacing;
    const containerWidth = itemSize.width * columnCount + columnSpacing;
    const containerHeight = itemSize.height * rowCount + rowSpacing;
    return {
        "width": containerWidth,
        "height": containerHeight
    };
}
function calcGridLayout(memberCount) {
    let columnCount = 1;
    if (memberCount >= 10) {
        columnCount = 4;
    } else if (memberCount >= 5) {
        columnCount = 3;
    } else if (memberCount >= 2) {
        columnCount = 2;
    } else {
        columnCount = 1;
    }
    const rowCount = Math.ceil(memberCount / columnCount);
    return {
        "columnCount": columnCount,
        "rowCount": rowCount
    };
}
function calcItemSize(outsider, columnCount, memberCount, spacing) {
    let itemWidth = 0;
    let itemHeight = 0;
    const rowCount = Math.ceil(memberCount / columnCount);
    const columnSpacing = (columnCount - 1) * spacing;
    const rowSpacing = (rowCount - 1) * spacing;
    itemWidth = (outsider.width - columnSpacing) / columnCount;
    itemHeight = itemWidth / 16 * 9;

    // 当高度超出了 containerSize.height 时，需要重新计算 itemWidth 和 itemHeight
    // 计算方式为先计算高度，然后根据高度计算宽度，宽高比例为 16/9
    if (itemHeight * rowCount + rowSpacing > outsider.height) {
        itemHeight = (outsider.height - rowSpacing) / rowCount;
        itemWidth = itemHeight / 9 * 16;
    }
    return {
        "width": itemWidth,
        "height": itemHeight
    };
}
function calcItemsPosition(members, itemSize, spacing, gridLayout, listModel) {
    listModel.clear();
    let currentRow = 0;
    for (let index = 0; index < members.length; index++) {
        if (index % gridLayout.columnCount === 0)
            currentRow++;
        let itemX = (index % gridLayout.columnCount) * (itemSize.width + spacing);
        let itemY = (currentRow - 1) * (itemSize.height + spacing);
        let member = members[index];
        // 如果是最后一行，居中显示
        const lastRowItemCount = members.length % gridLayout.columnCount;
        if (currentRow === gridLayout.rowCount && lastRowItemCount > 0) {
            const lastRowX = (gridLayout.columnCount - lastRowItemCount) / 2 * (itemSize.width + spacing);
            itemX = lastRowX + (index % gridLayout.columnCount) * (itemSize.width + spacing);
            itemY = (currentRow - 1) * (itemSize.height + spacing);
        }
        Object.assign(member, {
            "x": itemX,
            "y": itemY,
            "width": itemSize.width,
            "height": itemSize.height,
            "highQuality": members.length <= 4
        });
        listModel.append(member);
    }
}
function updateItemsPosition(itemSize, spacing, gridLayout, listModel) {
    let currentRow = 0;
    for (let index = 0; index < listModel.count; index++) {
        if (index % gridLayout.columnCount === 0)
            currentRow++;
        let itemX = (index % gridLayout.columnCount) * (itemSize.width + spacing);
        let itemY = (currentRow - 1) * (itemSize.height + spacing);
        let member = listModel.get(index);
        // 如果是最后一行，居中显示
        const lastRowItemCount = listModel.count % gridLayout.columnCount;
        if (currentRow === gridLayout.rowCount && lastRowItemCount > 0) {
            const lastRowX = (gridLayout.columnCount - lastRowItemCount) / 2 * (itemSize.width + spacing);
            itemX = lastRowX + (index % gridLayout.columnCount) * (itemSize.width + spacing);
            itemY = (currentRow - 1) * (itemSize.height + spacing);
        }
        member.x = itemX;
        member.y = itemY;
        member.width = itemSize.width;
        member.height = itemSize.height;
    }
}
