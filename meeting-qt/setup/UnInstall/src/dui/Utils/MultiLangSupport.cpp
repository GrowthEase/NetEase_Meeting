/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "StdAfx.h"

namespace ui {
//界面语言(中文简体、中文繁体、英文等)设置功能
const std::wstring kLangSettingFile = L"lang.xml";
const std::wstring kLangSettingNode = L"LangSetting";
const std::wstring kLangAttr			= L"lang";
const std::wstring kDefaultLangName = L"zh_CN";
const char    kEndWChar = '\0'; 
const char    kFilePathSeparators[]  = "\\/";
const wchar_t kFilePathWSeparators[] = L"\\/";

bool IsFilePathSeparator(const wchar_t separator)
{
	if (separator == kEndWChar)
		return false;

	size_t len = sizeof(kFilePathWSeparators) / sizeof(wchar_t);
	for (size_t i = 0; i < len; i++)
	{
		if (separator == kFilePathWSeparators[i])
			return true;
	}
	return false;
}

bool FilePathApartDirectory(const std::wstring &filepath_in, std::wstring &directory_out)
{
	size_t index = filepath_in.size() - 1;
	if (index <= 0 || filepath_in.size() == 0)
		return false;
	for (; index != 0; index--)
	{
		if (IsFilePathSeparator(filepath_in[index]))
		{
			if (index == filepath_in.size() - 1)
				directory_out = filepath_in;
			else
				directory_out = filepath_in.substr(0, index + 1);
			return true;
		}
	}
	return false;
}

std::wstring GetCurrentDllPath(void)
{
	WCHAR buffer[MAX_PATH];

	ZeroMemory(buffer, sizeof(WCHAR) * MAX_PATH);
	HMODULE h = GetModuleHandle(NULL);
	::GetModuleFileName(h, buffer, MAX_PATH);
	std::wstring app_path = buffer;
	FilePathApartDirectory(app_path,app_path);
	return app_path;
}

MutiLanSupport::MutiLanSupport()
{

}

MutiLanSupport::~MutiLanSupport()
{
	string_table_.clear();
}

MutiLanSupport* MutiLanSupport::GetInstance()
{
	static MutiLanSupport mutiLanSupport;
	return &mutiLanSupport;
}

BOOL MutiLanSupport::LoadStringTable(const std::wstring &file_path)
{
	FILE *file;
	errno_t err;
	err = _wfopen_s(&file, file_path.c_str(), L"r");
	if (file == NULL)
	{
		return FALSE;
	}
	char read_string[4096];
	StringList string_list;
	while (fgets(read_string, 4096, file) != NULL)
	{
		std::wstring string_resourse;
		std::string src = (std::string)read_string;
		StringHelper::MBCSToUnicode(src.c_str(), string_resourse, CP_UTF8);
		string_resourse = StringHelper::TrimLeft(string_resourse);
		string_resourse = StringHelper::TrimRight(string_resourse);
		if (!string_resourse.empty())
		{
			string_list.push_back(string_resourse);
		}
	}
	fclose(file);

	AnalyzeStringTable(string_list);
	return TRUE;
}
BOOL MutiLanSupport::LoadStringTable(const HGLOBAL& hGlobal)
{
	StringList string_list;
	std::string fragment((LPSTR)GlobalLock(hGlobal), GlobalSize(hGlobal));
	fragment.append("\n");
	std::string src;
	for (auto& it : fragment)
	{
		if (it == '\0' || it == '\n')
		{
			std::wstring string_resourse;
			StringHelper::MBCSToUnicode(src.c_str(), string_resourse, CP_UTF8);
			string_resourse = StringHelper::TrimLeft(string_resourse);
			string_resourse = StringHelper::TrimRight(string_resourse);
			if (!string_resourse.empty())
			{
				string_list.push_back(string_resourse);
			}
			src.clear();
			continue;
		}
		src.push_back(it);
	}
	GlobalUnlock(hGlobal);

	AnalyzeStringTable(string_list);
	return TRUE;
}

std::wstring MutiLanSupport::GetStringViaID(const std::wstring& id)
{
	std::wstring	text;

	if( id.length() == 0 )
	{
		return text;
	}

	auto it = string_table_.find(id);
	if (it == string_table_.end())
	{
		assert(FALSE);
		return text;
	}
	else
	{
		text = it->second;
		StringHelper::ReplaceAll(L"\\r", L"\r", text);
		StringHelper::ReplaceAll(L"\\n", L"\n", text);
	}

	return text;
}

BOOL MutiLanSupport::AnalyzeStringTable(const StringList &list)
{
	int	string_count	= (int)list.size();
	if(0 >= string_count)
	{
		return FALSE;
	}
	
	for(int i = 0; i < string_count; i++)
	{
		std::wstring string_src = (std::wstring)list[i];
		std::list<std::wstring> id_and_string = StringHelper::Split(string_src, L"=");
		if (id_and_string.size() != 2)
		{
			continue;
		}
		std::wstring id = (std::wstring)(*(id_and_string.begin()));
		id_and_string.pop_front();
		std::wstring string_resource = (std::wstring)(*(id_and_string.begin()));
		id = StringHelper::TrimLeft(id);
		id = StringHelper::TrimRight(id);
		string_resource = StringHelper::TrimLeft(string_resource);
		string_resource = StringHelper::TrimRight(string_resource);

		if (id.find(L";") == -1)
		{
			string_table_[id] = string_resource;
		}
	}

	return TRUE;
}

void MutiLanSupport::ClearAll()
{
	string_table_.clear();
}

//界面语言(中文简体、中文繁体、英文等)设置功能
bool MutiLanSupport::LoadLangSetting()
{
	std::wstring current_app_dir = GetCurrentDllPath();
	std::wstring file_name;
	file_name = current_app_dir + kLangSettingFile;

	//TiXmlDocument pXmlDoc;
	//if (shared::LoadXmlFromFile(pXmlDoc, file_name))
	//{
	//	std::string lang_setting_node_name;
	//	nbase::UTF16ToUTF8(kLangSettingNode.c_str(), kLangSettingNode.length(), lang_setting_node_name);
	//	TiXmlElement* pNode = pXmlDoc.FirstChildElement(lang_setting_node_name.c_str());
	//	if (pNode)
	//	{
	//		std::string lang_attr;
	//		nbase::UTF16ToUTF8(kLangAttr.c_str(), kLangAttr.length(), lang_attr);
	//		std::string node_lang_name = pNode->Attribute(lang_attr.c_str());
	//		std::wstring lang_name;
	//		nbase::UTF8ToUTF16(node_lang_name.c_str(), node_lang_name.length(), lang_name);
	//		lang_setting_.lang_name = lang_name;
	//	}
	//}

	if (lang_setting_.lang_name.empty())
	{
		lang_setting_.lang_name = kDefaultLangName;//默认语言
	}
	return true;
}

void MutiLanSupport::SetLangSetting(const LangSetting& new_lang_setting)
{
	if (new_lang_setting_.lang_name == new_lang_setting.lang_name)
	{//不需要重新保存，则清空新的设置信息
		new_lang_setting_.lang_name.clear();
	}
	else
	{//重新保存
		new_lang_setting_ = new_lang_setting;
	}
}

BOOL MutiLanSupport::SaveLangSetting()
{
	ASSERT(FALSE);
	//if (new_lang_setting_.lang_name.length() != 0)
	//{//重新保存
	//	lang_setting_.lang_name = new_lang_setting_.lang_name;

	//	std::wstring file_name;
	//	file_name = GetCurrentDllPath() + kLangSettingFile;
	//	TiXmlDocument *pXmlDoc = new TiXmlDocument;
	//	if (!shared::LoadXmlFromFile(*pXmlDoc, file_name))
	//		return FALSE;

	//	std::string lang_setting_node_name;
	//	nbase::UTF16ToUTF8(kLangSettingNode.c_str(), kLangSettingNode.length(), lang_setting_node_name);
	//	TiXmlElement* lang_setting_node = pXmlDoc->FirstChildElement(lang_setting_node_name.c_str());
	//	if (NULL == lang_setting_node)
	//	{
	//		return FALSE;
	//	}
	//	std::string lang_attr;
	//	nbase::UTF16ToUTF8(kLangAttr.c_str(), kLangAttr.length(), lang_attr);
	//	std::string lang_name;
	//	nbase::UTF16ToUTF8(lang_setting_.lang_name.c_str(), lang_setting_.lang_name.length(), lang_name);
	//	lang_setting_node->SetAttribute(lang_attr, lang_name);
	//	return pXmlDoc->SaveFile();
	//}
	return FALSE;
}

BOOL MutiLanSupport::SwitchLang(const std::wstring& new_lang)
{
	LangSetting new_lang_setting;
	new_lang_setting.lang_name = new_lang;
	SetLangSetting(new_lang_setting);
	if (SaveLangSetting())
	{
		ClearAll();
		std::wstring current_app_folder = GetCurrentDllPath();
		if (!MutiLanSupport::GetInstance()->LoadStringTable(current_app_folder + kLangFolderName
			+ L"\\" + new_lang + L"\\gdstrings.ini"))
		{
			return FALSE;
		}
		return TRUE;
	}
	return FALSE;
}


}