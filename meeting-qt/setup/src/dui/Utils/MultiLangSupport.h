/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef UI_UTILS_MULTILANGSUPPORT_H_
#define UI_UTILS_MULTILANGSUPPORT_H_


namespace ui {

typedef std::vector<std::wstring> StringList;
const std::wstring kLangFolderName = L"lang";//存放语言设置的目录名

struct LangSetting
{
	std::wstring  lang_name;// Selected language name
	LangSetting(){};
};

class MutiLanSupport	//多语言支持类
{
public:
	MutiLanSupport();
	virtual ~MutiLanSupport();

public:	//公共函数
    static MutiLanSupport* GetInstance();
	/*
	* 函数名称：MutiLanSupport ::GetStringViaID
	* 函数描述：通过id返回文字信息
	* 输入参数：nID, 文字信息的id
	* 输出参数：void
	* 返回值  ：返回一个字符串
	*/
	std::wstring GetStringViaID(const std::wstring& id);

	/*
	* 函数名称：MutiLanSupport ::LoadStringTable
	* 函数描述：准备string的信息,不清除原先的内容
	* 输入参数：void
	* 输出参数：void
	* 返回值  ：准备完成返回TRUE；否则返回FALSE;
	*/
	BOOL LoadStringTable(const std::wstring& file_path);
	/*
	* 函数名称：MutiLanSupport ::LoadStringTable
	* 函数描述：准备string的信息,不清除原先的内容
	* 输入参数：文件数据
	* 输出参数：void
	* 返回值  ：准备完成返回TRUE；否则返回FALSE;
	*/
	BOOL LoadStringTable(const HGLOBAL& hGlobal);

	//界面语言(中文简体、中文繁体、英文等)设置功能
	/*
	@Brief 加载语言设置
	*/
	bool LoadLangSetting();
	
	/*
	@Brief 获取语言设置
	*/
	LangSetting GetLangSetting(){ return lang_setting_; }

	/*
	@Brief 热切换语言 zh_CN 简体中文 zh_TW 繁体 en_US 英文 Ja 日语 Ko 韩语
	*/
	BOOL SwitchLang(const std::wstring& new_lang);

	void RegisterWindow(void *wnd);

	void UnregisterWindow(void *wnd);

private:	//函数
	/*
	@Brief 清除所有内容
	*/
	void ClearAll();

	/*
	@Brief 保存语言设置
	*/
	BOOL SaveLangSetting();

	/*
	@Brief 获取语言设置
	*/
	void SetLangSetting(const LangSetting& new_lang_setting);

	/*
	* 函数名称：MutiLanSupport ::AnalyzeStringTabel
	* 函数描述：准备proxy的信息
	* 输入参数：void
	* 输出参数：void
	* 返回值  ：准备完成返回TRUE；否则返回FALSE;
	*/
	BOOL AnalyzeStringTable(const StringList& list);

private:	//成员    
	std::map<std::wstring,std::wstring>  string_table_;	//字符串列表
	LangSetting	lang_setting_;//界面语言设置信息
	LangSetting	new_lang_setting_;//用户重新设置过的界面语言设置信息（退出程序后才会保存）
};

}
#endif //UI_UTILS_MULTILANGSUPPORT_H_
