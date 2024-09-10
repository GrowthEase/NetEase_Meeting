import {
  BeforeMeetingConfig,
  Role,
  SearchAccountInfo,
} from '@meeting-module/types';
import './index.less';
import React, {
  useCallback,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react';
import { Button, Modal as AntdModal } from 'antd';
import { useTranslation } from 'react-i18next';
import AddressBook from '@meeting-module/components/common/AddressBook';
import useUserInfo from '@meeting-module/hooks/useUserInfo';

import {
  InterpretationRes,
  NEMeetingScheduledMember,
} from '@meeting-module/types/type';
import Toast from '@meeting-module/components/common/toast';
import { PreviewMemberItem } from './PreviewMemberList';
import useMembers from './useMembers';
import { useUpdateEffect } from 'ahooks';
import { getLocalUserInfo } from '@meeting-module/utils';
import Modal from '@meeting-module/components/common/Modal';
import NEContactsService from '@meeting-module/kit/impl/service/meeting_contacts_service';

interface ParticipantAddProps {
  className?: string;
  onMembersChange?: (members: SearchAccountInfo[]) => void;
  value?: NEMeetingScheduledMember[];
  onChange?: (value: NEMeetingScheduledMember[]) => void;
  canEdit: boolean;
  ownerUserUuid?: string;
  globalConfig?: BeforeMeetingConfig;
  interpretation?: InterpretationRes;
  onDeleteInterpreter?: (uuid: string) => void;
  meetingContactsService?: NEContactsService;
}

const ParticipantAdd: React.FC<ParticipantAddProps> = ({
  value,
  meetingContactsService,
  canEdit,
  onChange,
  ownerUserUuid,
  globalConfig,
  interpretation,
  onDeleteInterpreter,
}) => {
  const { t } = useTranslation();
  const [openAddressBook, setOpenAddressBook] = useState(false);

  const { userInfo } = useUserInfo();
  const [pageSize] = useState(20);
  const [selectedMembers, setSelectedMembers] = useState<SearchAccountInfo[]>(
    [],
  );
  // 点击确认按钮才保存更新的数据
  const [confirmedMembers, setConfirmedMembers] = useState<SearchAccountInfo[]>(
    [],
  );
  const isFirstMountedRef = useRef(false);
  const { getAccountInfoListByPage, getDefaultMembers, sortMembers } =
    useMembers({
      meetingContactsService,
    });

  const scheduleConfig = useMemo(() => {
    return globalConfig?.appConfig.MEETING_SCHEDULED_MEMBER_CONFIG;
  }, [globalConfig?.appConfig.MEETING_SCHEDULED_MEMBER_CONFIG]);
  const selectedMembersRef = useRef<SearchAccountInfo[]>([]);

  selectedMembersRef.current = selectedMembers;
  // 点击添加成员按钮处理
  const onAddMemberHandler = () => {
    // 如果是ELectron则单独弹窗
    if (window.isElectronNative) {
      const parentWindow = window.parent;

      setSelectedMembers([...confirmedMembers]);
      parentWindow?.postMessage(
        {
          event: 'openWindow',
          payload: {
            name: 'addressBook',
            postMessageData: {
              event: 'updateData',
              payload: {
                selectedMembers: JSON.parse(
                  JSON.stringify(
                    sortMembers(confirmedMembers, userInfo?.userUuid || ''),
                  ),
                ),
                globalConfig,
              },
            },
          },
        },
        parentWindow.origin,
      );
    } else {
      setOpenAddressBook(true);
    }
  };

  const onCancelHandler = useCallback(() => {
    setOpenAddressBook(false);
    setSelectedMembers(confirmedMembers);
  }, [confirmedMembers]);

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;

      // 关闭统一处理页面重置逻辑
      switch (event) {
        case 'onMembersChangeHandler':
          onMembersChangeHandler(payload.member, payload.isChecked);
          break;
        case 'onRoleChange':
          onRoleChange(payload.uuid, payload.role);
          break;
        case 'onAddressBookConfirmHandler':
          onConfirmHandler();
          break;
        case 'onAddressBookCancelHandler':
          onCancelHandler();
          break;
        case 'onDeleteInterpreterAndAddressBookMember':
          deleteMember(payload.userUuid);
          break;
        default:
          break;
      }
    }

    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, [onCancelHandler]);

  useEffect(() => {
    // if (isFirstMountedRef.current) {
    //   return
    // }

    isFirstMountedRef.current = true;
    const userInfo = getLocalUserInfo();

    if (value && value.length > 0) {
      // 如果存在scheduleMembers则表示编辑模式，需要获取对应成员的详细信息，分页获取，每页20个
      getAccountInfoListByPage(1, pageSize, value).then(
        (meetingAccountList) => {
          if (meetingAccountList && meetingAccountList.length > 0) {
            // 把本端放到首位
            const myIndex = meetingAccountList.findIndex(
              (item) => item.userUuid === userInfo?.userUuid,
            );

            if (myIndex > -1) {
              const [localMember] = meetingAccountList.splice(myIndex, 1);

              meetingAccountList.unshift(localMember);
            }

            setSelectedMembers(meetingAccountList);
            setConfirmedMembers(meetingAccountList);
          } else {
            if (userInfo) {
              const memberList = getDefaultMembers(userInfo);

              setSelectedMembers(memberList);
              setConfirmedMembers(memberList);
            }
          }
        },
      );
    } else {
      if (userInfo) {
        const memberList = getDefaultMembers(userInfo);

        setSelectedMembers(memberList);
        setConfirmedMembers(memberList);
      }
    }
  }, [value?.length]);

  const selectedMemberBySort = useMemo(() => {
    return sortMembers(selectedMembers, userInfo?.userUuid || '');
  }, [selectedMembers, userInfo?.userUuid, sortMembers]);

  const onMembersChangeHandler = (
    member: SearchAccountInfo,
    isChecked: boolean,
  ) => {
    const maxCount = Number(scheduleConfig?.max) || 5000;

    if (isChecked && selectedMembers.length >= maxCount) {
      Toast.fail(
        t('sipCallMaxCount', {
          count: maxCount,
        }),
      );
      return;
    }

    const tmpSelectedMembers = [...selectedMembersRef.current];

    if (isChecked) {
      tmpSelectedMembers.push(member);
    } else {
      if (interpretation && interpretation.interpreters[member.userUuid]) {
        if (window.isElectronNative) {
          const parentWindow = window.parent;

          parentWindow?.postMessage(
            {
              event: 'confirmDeleteInterpreter',
              payload: {
                userUuid: member.userUuid,
              },
            },
            parentWindow.origin,
          );
        } else {
          Modal.confirm({
            title: t('commonTitle'),
            content: t('interpRemoveMemberInInterpreters'),
            cancelText: t('globalCancel'),
            okText: t('globalDelete'),
            onOk: () => {
              deleteMember(member.userUuid);
              onDeleteInterpreter?.(member.userUuid);
            },
          });
        }

        return;
      } else {
        const index = tmpSelectedMembers.findIndex(
          (item) => item.userUuid === member.userUuid,
        );

        if (index > -1) {
          tmpSelectedMembers.splice(index, 1);
        }
      }
    }

    setSelectedMembers([...tmpSelectedMembers]);
  };

  const deleteMember = (userUuid: string) => {
    const tmpSelectedMembers = [...selectedMembersRef.current];
    const index = tmpSelectedMembers.findIndex(
      (item) => item.userUuid === userUuid,
    );

    if (index > -1) {
      tmpSelectedMembers.splice(index, 1);
    }

    setSelectedMembers([...tmpSelectedMembers]);
  };

  const onConfirmHandler = () => {
    const selectedMembers = selectedMembersRef.current;

    setOpenAddressBook(false);
    setConfirmedMembers(selectedMembers);
    const memberList = selectedMembers.map((item) => {
      return {
        userUuid: item.userUuid,
        role: item.role || Role.member,
      };
    });

    onChange?.(memberList);
  };

  const onRoleChange = (uuid: string, role?: Role) => {
    const tmpSelectedMembers = [...selectedMembersRef.current];

    if (
      role === Role.coHost &&
      tmpSelectedMembers.filter((item) => item.role === Role.coHost).length >= 4
    ) {
      Toast.fail(t('participantOverRoleLimitCount'));
      return;
    }

    const index = tmpSelectedMembers.findIndex(
      (item) => item.userUuid === uuid,
    );

    if (index > -1) {
      // 如果是设置主持人，则之前主持人角色需要变更
      if (role === Role.host) {
        const hostIndex = tmpSelectedMembers.findIndex(
          (item) => item.role === Role.host,
        );

        if (hostIndex > -1) {
          tmpSelectedMembers[hostIndex].role = Role.member;
        }
      }

      tmpSelectedMembers[index].role = role;
      setSelectedMembers([...tmpSelectedMembers]);
    }
  };

  useUpdateEffect(() => {
    if (!window.isElectronNative) return;
    const parentWindow = window.parent;

    parentWindow?.postMessage(
      {
        event: 'updateWindowData',
        payload: {
          name: 'addressBook',
          postMessageData: {
            event: 'updateData',
            payload: {
              selectedMembers: JSON.parse(
                JSON.stringify(
                  sortMembers(selectedMembers, userInfo?.userUuid || ''),
                ),
              ),
            },
          },
        },
      },
      parentWindow.origin,
    );
  }, [selectedMembers]);

  return (
    <div className="nemeeting-schedule-participant-add">
      {canEdit && (
        <div
          className="nemeeting-schedule-member-add nemeeting-schedule-member-item"
          onClick={() => onAddMemberHandler()}
        >
          <svg className="icon iconfont iconcross" aria-hidden="true">
            <use xlinkHref="#iconcross" />
          </svg>
        </div>
      )}
      {
        // 获取selectedMembers前面7个进展展示
        confirmedMembers.slice(0, 7).map((item) => {
          return (
            <PreviewMemberItem
              key={item.userUuid}
              member={item}
              ownerUserUuid={ownerUserUuid || ''}
            />
          );
        })
      }
      {!window.isElectronNative && (
        <AntdModal
          title={t('meetingAttendees')}
          open={openAddressBook}
          footer={null}
          width={498}
          centered
          getContainer={false}
          destroyOnClose
          wrapClassName="user-select-none nemeeting-address-book-modal-wrap"
          onCancel={() => onCancelHandler()}
        >
          <div className="address-book-wrap">
            <AddressBook
              ownerUserUuid={ownerUserUuid}
              maxCount={scheduleConfig?.max}
              maxCoHostCount={scheduleConfig?.coHostLimit}
              selectedMembers={selectedMemberBySort}
              meetingContactsService={meetingContactsService}
              myUuid={userInfo?.userUuid || ''}
              onChange={onMembersChangeHandler}
              onRoleChange={onRoleChange}
              showMore={true}
            />
          </div>
          <div className="nemeeting-address-confirm-wrapper">
            <Button
              className="nemeeting-address-confirm-cancel"
              style={{ width: '128px' }}
              shape="round"
              size="large"
              onClick={onCancelHandler}
            >
              {t('globalCancel')}
            </Button>
            <Button
              className="nemeeting-address-confirm-cancel"
              style={{ width: '128px' }}
              type="primary"
              shape="round"
              size="large"
              disabled={selectedMembers.length === 0}
              onClick={onConfirmHandler}
            >
              {t('globalSure')}
            </Button>
          </div>
        </AntdModal>
      )}
    </div>
  );
};

export default ParticipantAdd;
