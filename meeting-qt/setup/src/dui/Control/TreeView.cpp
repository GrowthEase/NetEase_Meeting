/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "StdAfx.h"
#include "TreeView.h"


namespace ui
{
	TreeNode::TreeNode()
	{
	
	}
	
	TreeNode::~TreeNode()
	{
	}

	bool TreeNode::OnClickItem(EventArgs* pMsg)
	{
		TreeNode* pItem = static_cast<TreeNode*>(pMsg->pSender);
		pItem->SetExpand(!pItem->GetExpand());

		return true;
	}

	bool TreeNode::IsVisible() const
	{
		return ListContainerElement::IsVisible()
			&& (!m_pParentTreeNode || (m_pParentTreeNode && m_pParentTreeNode->GetExpand() && m_pParentTreeNode->IsVisible()));
	}

	void TreeNode::SetInternVisible(bool bVisible)
	{
		Control::SetInternVisible(bVisible);
		if( m_items.empty() ) return;

		for( auto it = m_items.begin(); it != m_items.end(); it++ ) {
			auto pControl = *it;
			// 控制子控件显示状态
			// InternVisible状态应由子控件自己控制
			pControl->SetInternVisible(Control::IsVisible());
		}
	}

	bool TreeNode::AddChildNode(TreeNode* pTreeNode)
	{
		return AddChildNodeAt(pTreeNode, GetChildNodeCount());
	}

	bool TreeNode::AddChildNodeAt(TreeNode* pTreeNode, std::size_t iIndex)
	{
		if( iIndex < 0 || iIndex > mTreeNodes.size() ) return false;
		mTreeNodes.insert(mTreeNodes.begin() + iIndex, pTreeNode);
		
		pTreeNode->m_iDepth = m_iDepth + 1;
		pTreeNode->SetParentNode(this);
		pTreeNode->SetTreeView(m_pTreeView);
		if( m_pWindow != NULL ) m_pWindow->InitControls(pTreeNode, NULL);

		UiRect padding = m_pLayout->GetPadding();
		int nodeIndex = -1;
		if (m_iDepth != ROOT_NODE_DEPTH)
		{
			nodeIndex = GetIndex();
			padding.left += m_pTreeView->GetIndent();
		}
		pTreeNode->m_pLayout->SetPadding(padding);
		pTreeNode->OnEvent[EventType::CLICK] += std::bind(&TreeNode::OnClickItem, this, std::placeholders::_1);

		std::size_t global_index = iIndex;
		for (std::size_t i = 0; i < iIndex; i++)
		{
			global_index += ((TreeNode*)mTreeNodes[i])->GetDescendantNodeCount();
		}

		return m_pTreeView->ListBox::AddAt(pTreeNode, nodeIndex + global_index + 1);
	}

	bool TreeNode::RemoveChildNodeAt(std::size_t iIndex)
	{
		if (iIndex < 0 || iIndex >= mTreeNodes.size())
		{
			return false;
		}

		TreeNode* treeNode = ((TreeNode*)mTreeNodes[iIndex]);
		mTreeNodes.erase(mTreeNodes.begin() + iIndex);

		return treeNode->RemoveSelf();
	}

	bool TreeNode::RemoveChildNode(TreeNode* pTreeNode)
	{
		auto it = std::find(mTreeNodes.begin(), mTreeNodes.end(), pTreeNode);
		if (it == mTreeNodes.end())
		{
			return false;
		}
		
		int iIndex = it - mTreeNodes.begin();
		return RemoveChildNodeAt(iIndex);
	}
	
	void TreeNode::RemoveAllChildNode()
	{
		while (mTreeNodes.size() > 0)
		{
			RemoveChildNodeAt(0);
		}
	}

	bool TreeNode::RemoveSelf()
	{
		for( auto it = mTreeNodes.begin(); it != mTreeNodes.end(); it++ ) {
			(*it)->RemoveSelf();
		}
		mTreeNodes.clear();

		if (m_iDepth != ROOT_NODE_DEPTH)
		{
			return m_pTreeView->ListBox::RemoveAt(GetIndex());
		}

		return false;
	}

	void TreeNode::SetParentNode(TreeNode* pParentTreeNode)
	{
		m_pParentTreeNode = pParentTreeNode;
	}

	TreeNode* TreeNode::GetParentNode()
	{
		return m_pParentTreeNode;
	}

	int TreeNode::GetDescendantNodeCount()
	{
		int nodeCount = GetChildNodeCount();
		for( auto it = mTreeNodes.begin(); it != mTreeNodes.end(); it++ ) {
			nodeCount += (*it)->GetDescendantNodeCount();
		}

		return nodeCount;
	}

	std::size_t TreeNode::GetChildNodeCount()
	{
		return mTreeNodes.size();
	}
	
	TreeNode* TreeNode::GetChildNode(std::size_t iIndex)
	{
		if( iIndex < 0 || iIndex >= mTreeNodes.size() ) return NULL;
		return static_cast<TreeNode*>(mTreeNodes[iIndex]);
	}
	
	int TreeNode::GetChildNodeIndex(TreeNode* pTreeNode)
	{
		auto it = std::find(mTreeNodes.begin(), mTreeNodes.end(), pTreeNode);
		if (it == mTreeNodes.end())
		{
			return -1;
		}
		return it - mTreeNodes.begin();
	}

	bool TreeNode::GetExpand() const
	{
		return m_bExpand;
	}

	void TreeNode::SetExpand(bool bExpand)
	{
		if(m_bExpand == bExpand) 
		{
			return;
		}
		m_bExpand = bExpand;
		m_pTreeView->Arrange();
	}

	void TreeNode::SetTreeView(TreeView* pTreeView)
	{
		m_pTreeView = pTreeView;
	}

	void TreeNode::SetWindow(Window* pManager, Box* pParent, bool bInit)
	{
		for (auto it = mTreeNodes.begin(); it != mTreeNodes.end(); it++) {
			(*it)->SetWindow(pManager, this, bInit);
		}

		ListContainerElement::SetWindow(pManager, pParent, bInit);
	}

	TreeView::TreeView() :
		ListBox(new VLayout, new Facade)
	{
		m_rootNode.reset(new TreeNode());
		m_rootNode->SetTreeView(this);
	}

	TreeView::~TreeView()
	{

	}

	void TreeView::SetAttribute(const std::wstring& pstrName, const std::wstring& pstrValue)
	{
		if( pstrName == _T("indent") ) 
		{
			SetIndent(_ttoi(pstrValue.c_str()));
		}
		else
		{
			ListBox::SetAttribute(pstrName, pstrValue);
		}
	}

	void TreeView::SetWindow(Window* pManager, Box* pParent, bool bInit)
	{
		ListBox::SetWindow(pManager, pParent, bInit);
		m_rootNode->SetWindow(pManager, pParent, bInit);
	}
}