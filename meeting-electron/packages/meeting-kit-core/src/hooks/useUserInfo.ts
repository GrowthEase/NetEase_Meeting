import { useEffect, useState } from 'react'
import { LoginUserInfo } from '../app/src/types'
import { LOCALSTORAGE_USER_INFO } from '../config'

export default function useUserInfo(): {
  userInfo: LoginUserInfo | null
  getUserInfo: () => LoginUserInfo | null
} {
  const [userInfo, setUserInfo] = useState<LoginUserInfo | null>(null)

  function getUserInfo(): LoginUserInfo | null {
    const userString = localStorage.getItem(LOCALSTORAGE_USER_INFO)

    let userInfo: LoginUserInfo | null = null

    if (userString) {
      userInfo = JSON.parse(userString)
    }

    return userInfo
  }

  useEffect(() => {
    const info = getUserInfo()

    setUserInfo(info)
  }, [])

  return {
    userInfo,
    getUserInfo,
  }
}
