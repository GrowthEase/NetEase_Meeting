import { NEMeetingScheduledMember, Role } from '@meeting-module/types/type';
import { SearchAccountInfo } from '@meeting-module/types';
import { LoginUserInfo } from '../../../../types';
import { useCallback } from 'react';
import NEContactsService from '@meeting-module/kit/interface/service/meeting_contacts_service';

interface AccountInfo {
  userUuid: string;
  name: string;
  avatar?: string;
  role?: Role;
  dept?: string;
  phoneNumber?: string;
}
interface UseMembersProps {
  meetingContactsService?: NEContactsService;
}

export default function useMembers(data: UseMembersProps): {
  getAccountInfoListByPage: (
    page: number,
    pageSize: number,
    originMembers?: NEMeetingScheduledMember[],
  ) => Promise<SearchAccountInfo[]>;
  sortMembers: (
    members: SearchAccountInfo[],
    myUuid: string,
  ) => SearchAccountInfo[];
  getDefaultMembers: (userInfo: LoginUserInfo) => SearchAccountInfo[];
} {
  const { meetingContactsService } = data;
  const getAccountInfoListByPage = async (
    page: number,
    pageSize: number,
    originMembers?: NEMeetingScheduledMember[],
  ): Promise<SearchAccountInfo[]> => {
    if (!originMembers) return [];
    const originUuids = originMembers.map((item) => item.userUuid);
    const sliceUuids = originUuids.slice(
      (page - 1) * pageSize,
      page * pageSize,
    );

    if (sliceUuids.length > 0) {
      try {
        const res = await meetingContactsService?.getContactsInfo(sliceUuids);
        const meetingAccountListResp = res?.data.foundList;

        // 给返回数据添加role
        if (meetingAccountListResp) {
          meetingAccountListResp.forEach((item: AccountInfo) => {
            const index = originMembers.findIndex(
              (originItem) => originItem.userUuid === item.userUuid,
            );

            if (index > -1) {
              item.role = originMembers[index].role;
            }
          });
        }

        return (meetingAccountListResp as SearchAccountInfo[]) || [];
      } catch (error) {
        return [];
      }
    } else {
      return [];
    }
  };

  //排列顺序 我>创建者>主持人>联席主持人>普通参会者
  const sortMembers = useCallback(
    (members: SearchAccountInfo[], myUuid: string) => {
      const mySelf: SearchAccountInfo[] = [];
      const coHost: SearchAccountInfo[] = [];
      const host: SearchAccountInfo[] = [];
      const normalMembers: SearchAccountInfo[] = [];

      members.forEach((item) => {
        if (item.userUuid === myUuid) {
          mySelf.push(item);
        } else if (item.role === Role.coHost) {
          coHost.push(item);
        } else if (item.role === Role.host) {
          host.push(item);
        } else {
          normalMembers.push(item);
        }
      });
      return [...mySelf, ...host, ...coHost, ...normalMembers];
    },
    [],
  );

  const getDefaultMembers = (userInfo: LoginUserInfo) => {
    return [
      {
        userUuid: userInfo?.userUuid || '',
        name: userInfo?.nickname || '',
        avatar: userInfo?.avatar || '',
        role: Role.host,
        dept: '',
        phoneNumber: userInfo?.phoneNumber || '',
      },
    ];
  };

  return {
    getAccountInfoListByPage,
    sortMembers,
    getDefaultMembers,
  };
}
