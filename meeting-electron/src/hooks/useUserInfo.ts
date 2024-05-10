import { useEffect, useState } from 'react'
import { LoginUserInfo } from '../../app/src/types'
import { LOCALSTORAGE_USER_INFO } from '../config'

export default function useUserInfo(): { userInfo: LoginUserInfo | null } {
  const [userInfo, setUserInfo] = useState<LoginUserInfo | null>(null)
  useEffect(() => {
    const userString = localStorage.getItem(LOCALSTORAGE_USER_INFO)
    if (userString) {
      const user = JSON.parse(userString)
      setUserInfo(user)
    }
  }, [])

  return {
    userInfo,
  }
}
