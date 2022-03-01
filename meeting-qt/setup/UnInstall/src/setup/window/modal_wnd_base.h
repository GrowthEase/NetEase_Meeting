/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef YIXIN_MSG_BOX_MODAL_WND_BASE_H_
#define YIXIN_MSG_BOX_MODAL_WND_BASE_H_

class ModalWndBase
{
public:
	virtual void SyncShowModal() = 0;
	virtual ~ModalWndBase() {}
};

#endif // YIXIN_MSG_BOX_MODAL_WND_BASE_H_
