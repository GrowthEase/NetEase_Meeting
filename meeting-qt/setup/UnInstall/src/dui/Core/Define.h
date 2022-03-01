/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef UI_CORE_DEFINE_H_
#define UI_CORE_DEFINE_H_

#pragma once


namespace ui
{

class Control;

#define UI_FORBID_COPY(FORBIDDEN_CLASS) \
	FORBIDDEN_CLASS(const FORBIDDEN_CLASS& tmp) = delete; \
	FORBIDDEN_CLASS& operator = (const FORBIDDEN_CLASS& tmp) = delete;

#define DUI_NOSET_VALUE  -1
#define DUI_LENGTH_STRETCH  -1
#define DUI_LENGTH_AUTO  -2

enum class HorAlignType
{
	LEFT,
	CENTER,
	RIGHT,
};

enum class VerAlignType
{
	TOP,
	CENTER,
	BOTTOM,
};

// Flags used for controlling the paint
enum class ControlStateType
{
	NORMAL,
	HOT,
	PUSHED,
	DISABLED
};

enum class UILIB_API AnimationType
{
	FADE_NONE,
	FADE_ALPHA,
	FADE_HEIGHT,
	FADE_WIDTH,
	FADE_HOT,
	FADE_INOUT_X,
	FADE_INOUT_Y,
};

enum class GifStopType
{
	FIRST = 0,//gif 停止时定位到第一帧
	CUR,//当前帧
	END,//最后一帧
};

enum class CursorType
{
	ARROW,
	HAND,
	IBEAM
};


//定义所有消息类型
enum class EventType
{
	INTERNAL_DBLCLICK,
	INTERNAL_CONTEXTMENU,
	INTERNAL_SETFOCUS,            
	INTERNAL_KILLFOCUS, 

	NONE,

	FIRST,

	ALL,

	KEYBEGIN,
	KEYDOWN,
	KEYUP,
	CHAR,
	SYSKEY,
	KEYEND,

	MOUSEBEGIN,
	MOUSEMOVE,
	MOUSEENTER,
	MOUSELEAVE,
	MOUSEHOVER,
	BUTTONDOWN,
	BUTTONUP,
	RBUTTONDOWN,
	DOUBLECLICK,
	MENU,
	SCROLLWHEEL,
	MOUSEEND,

	SETFOCUS,
	KILLFOCUS,
	WINDOWSIZE,
	SETCURSOR,

	CLICK,
	SELECT,
	UNSELECT,
	TEXTCHANGE,

	SCROLLAPPEAR,          
	SCROLLDISAPPEAR,        
	SCROLLUPOVER,        
	SCROLLDOWNOVER,  
	SCROLLCHANGE, 

	VALUECHANGE,
	RETURN,                			  
	TAB,
	WINDOWINIT,          
	WINDOWCLOSE,        
	SHOWACTIVEX,

	LAST,
};


#define	EVENTSTR_ALL				(_T("all"))
#define	EVENTSTR_KEYDOWN			(_T("keydown"))
#define	EVENTSTR_KEYUP				(_T("keyup"))
#define	EVENTSTR_CHAR				(_T("char"))
#define	EVENTSTR_SYSKEY				(_T("syskey"))

#define EVENTSTR_SETFOCUS			(_T("setfocus"))
#define EVENTSTR_KILLFOCUS			(_T("killfocus"))
#define	EVENTSTR_SETCURSOR			(_T("setcursor"))

#define EVENTSTR_MOUSEMOVE			(_T("mousemove"))
#define	EVENTSTR_MOUSEENTER			(_T("mouseenter"))
#define	EVENTSTR_MOUSELEAVE			(_T("mouseleave"))
#define	EVENTSTR_MOUSEHOVER			(_T("mousehover"))

#define	EVENTSTR_BUTTONDOWN			(_T("buttondown"))
#define	EVENTSTR_BUTTONUP			(_T("buttonup"))
#define	EVENTSTR_RBUTTONDOWN		(_T("rbuttondown"))
#define	EVENTSTR_DOUBLECLICK		(_T("doubleclick"))

#define EVENTSTR_SELECT				(_T("select"))
#define EVENTSTR_UNSELECT			(_T("unselect"))
#define	EVENTSTR_MENU				(_T("menu"))

#define	EVENTSTR_SCROLLWHEEL		(_T("scrollwheel"))
#define EVENTSTR_SCROLLAPPEAR		(_T("scrollappear"))
#define EVENTSTR_SCROLLDISAPPEAR	(_T("scrolldisappear"))
#define EVENTSTR_SCROLLUPOVER		(_T("scrollupover"))
#define EVENTSTR_SCROLLDOWNOVER		(_T("scrolldownover"))
#define EVENTSTR_SCROLLCHANGE		(_T("scrollchange"))

#define EVENTSTR_VALUECHANGE		(_T("valuechange"))
#define EVENTSTR_RETURN				(_T("return"))
#define EVENTSTR_TAB				(_T("tab"))
#define EVENTSTR_WINDOWINIT			(_T("windowinit"))
#define EVENTSTR_WINDOWCLOSE		(_T("windowclose"))
#define EVENTSTR_SHOWACTIVEX		(_T("showactivex"))



struct EventArgs
{
	EventArgs()
	: Type(EventType::NONE),
     pSender(nullptr),
	 dwTimestamp(0),
	 chKey(0),
	 wKeyState(0),
	 wParam(0),
	 lParam(0)
	{
		ptMouse.x = ptMouse.y = 0;
	}

	EventType Type;
	Control* pSender;
	DWORD dwTimestamp;
	POINT ptMouse;
	TCHAR chKey;
	WORD wKeyState;
	WPARAM wParam;
	LPARAM lParam;
};

EventType StringToEnum(const std::wstring& messageType);


//定义所有控件类型
#define  DUI_CTR_CONTROL                         (_T("Control"))
#define  DUI_CTR_LABEL                           (_T("Label"))
#define  DUI_CTR_BUTTON                          (_T("Button"))
#define  DUI_CTR_TEXT                            (_T("Text"))
#define  DUI_CTR_OPTION                          (_T("Option"))
#define  DUI_CTR_CHECKBOX                        (_T("CheckBox"))

#define  DUI_CTR_LABELBOX                        (_T("LabelBox"))
#define  DUI_CTR_BUTTONBOX                       (_T("ButtonBox"))
#define  DUI_CTR_TEXTBOX						 (_T("TextBox"))
#define  DUI_CTR_OPTIONBOX                       (_T("OptionBox"))
#define  DUI_CTR_CHECKBOXBOX                     (_T("CheckBoxBox"))

#define  DUI_CTR_BOX							 (_T("Box"))
#define  DUI_CTR_HBOX							 (_T("HBox"))
#define  DUI_CTR_VBOX                            (_T("VBox"))
#define  DUI_CTR_TABBOX                          (_T("TabBox"))
#define  DUI_CTR_TILEBOX						 (_T("TileBox"))
#define  DUI_CTR_CHILDBOX                        (_T("ChildBox"))

#define  DUI_CTR_LISTITEM                        (_T("ListItem"))
#define  DUI_CTR_LISTELEMENT                     (_T("ListElement"))
#define  DUI_CTR_LISTCONTAINERELEMENT            (_T("ListContainerElement"))
#define  DUI_CTR_LISTLABELELEMENT                (_T("ListLabelElement"))
#define  DUI_CTR_HLISTBOX						 (_T("HListBox"))
#define  DUI_CTR_VLISTBOX                        (_T("VListBox"))
#define  DUI_CTR_TILELISTBOX                     (_T("TileListBox"))

#define  DUI_CTR_TREENODE                        (_T("TreeNode"))
#define  DUI_CTR_TREEVIEW                        (_T("TreeView"))

#define  DUI_CTR_RICHEDIT                        (_T("RichEdit"))
#define  DUI_CTR_COMBO                           (_T("Combo"))
#define  DUI_CTR_FLASH							 (_T("Flash"))
#define  DUI_CTR_SLIDER                          (_T("Slider"))
#define  DUI_CTR_ACTIVEX                         (_T("ActiveX"))

#define  DUI_CTR_PROGRESS                        (_T("Progress"))
#define  DUI_CTR_DATETIME                        (_T("DateTime"))

#define  DUI_CTR_SCROLLBAR                       (_T("ScrollBar"))
#define  DUI_CTR_WEBBROWSER                      (_T("WebBrowser"))
#define  DUI_CTR_DIALOGLAYOUT                    (_T("DialogLayout"))




}// namespace ui

#endif // UI_CORE_DEFINE_H_