/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef UI_CONTROL_TREEVIEW_H_
#define UI_CONTROL_TREEVIEW_H_

#pragma once

namespace ui
{
	class TreeView;
	#define ROOT_NODE_DEPTH  -1

	class UILIB_API TreeNode : public ListContainerElement
	{
	public:
		TreeNode();
		~TreeNode(void);

	public:
		virtual bool OnClickItem(EventArgs* param);
		virtual bool IsVisible() const override;
		virtual void SetInternVisible(bool bVisible) override;

		bool	AddChildNode(TreeNode* pTreeNode);
		bool	AddChildNodeAt(TreeNode* pTreeNode, std::size_t iIndex);
		bool	RemoveChildNodeAt(std::size_t index);
		bool	RemoveChildNode(TreeNode* pTreeNode);
		void	RemoveAllChildNode();
		int		GetDescendantNodeCount();
		std::size_t		GetChildNodeCount();
		TreeNode* GetChildNode(std::size_t _nIndex);
		int		GetChildNodeIndex(TreeNode* pTreeNode);

		void	SetParentNode(TreeNode* pParentTreeNode);
		TreeNode* GetParentNode();

		bool	GetExpand() const; 
		void	SetExpand(bool bExpand);

		int		GetDepth()
		{
			return	m_iDepth;
		}

		void	SetTreeView(TreeView* pTreeView);
		virtual void SetWindow(Window* pManager, Box* pParent, bool bInit = true) override;

	private:
		bool	RemoveSelf();

	private:
		bool		 m_bExpand = true;
		TreeView* m_pTreeView = nullptr;
		TreeNode* m_pParentTreeNode = nullptr;
		std::vector<TreeNode*> mTreeNodes;
		int			 m_iDepth = ROOT_NODE_DEPTH;
	};

	class UILIB_API TreeView : public ListBox
	{
	public:
		TreeView(void);
		~TreeView(void);

	public:
		virtual void SetAttribute(const std::wstring& pstrName, const std::wstring& pstrValue) override;

		TreeNode*	GetRootNode()
		{
			return m_rootNode.get();
		}

		int GetIndent()
		{
			return m_iIndent;
		}
		void SetIndent(int indent)
		{
			m_iIndent = indent;
		}

	private:
		//以下函数故意私有化，表明禁止使用；应该使用TreeNode中的相关函数
		bool Add(Control* pControl) override
		{
			ASSERT(FALSE);
			return true;
		}
		bool AddAt(Control* pControl, std::size_t iIndex) override
		{
			ASSERT(FALSE);
			return true;
		}
		bool Remove(Control* pControl) override
		{
			ASSERT(FALSE);
			return true;
		}
		bool RemoveAt(std::size_t iIndex) override
		{
			ASSERT(FALSE);
			return true;
		}
		void RemoveAll() override
		{
			ASSERT(FALSE);
		}

		virtual void SetWindow(Window* pManager, Box* pParent, bool bInit = true) override;

	private:
		std::unique_ptr<TreeNode> m_rootNode;
		int			 m_iIndent = 0;
	};
}


#endif // UI_CONTROL_TREEVIEW_H_
