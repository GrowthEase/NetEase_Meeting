import { SaveSipCallItem,  SaveRoomSipCallItem} from '../kit'

export function saveCallRecord(key: string, value: SaveSipCallItem[]) {
  const oldValue = localStorage.getItem(key)
  let newValue: SaveSipCallItem[] = value

  if (oldValue) {
    newValue = [...value, ...JSON.parse(oldValue)]
    if (newValue.length > 100) {
      newValue.splice(100, newValue.length - 100)
    }
  }

  localStorage.setItem(key, JSON.stringify(newValue))
}

export function saveRoomSIPCallRecord(key: string, value: SaveRoomSipCallItem[], limit: number = 100) {
  const oldValue = localStorage.getItem(key)
  let newValue: SaveRoomSipCallItem[] = value

  if (oldValue) {
    newValue = [...value, ...JSON.parse(oldValue)]
    if (newValue.length > limit) {
      newValue.splice(limit, newValue.length - limit)
    }
  }

  localStorage.setItem(key, JSON.stringify(newValue))
}

export function removeCallRecordItem(key: string, index: number) {
  const value = localStorage.getItem(key)
    ? JSON.parse(localStorage.getItem(key) as string)
    : []

  value?.splice(index, 1)
  localStorage.setItem(key, JSON.stringify(value))
}

export function removeAllCallRecord(key: string) {
  localStorage.removeItem(key)
}
