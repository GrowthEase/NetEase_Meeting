// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef UI_UTILS_MULTILANGSUPPORT_H_
#define UI_UTILS_MULTILANGSUPPORT_H_

namespace ui {

typedef std::vector<std::wstring> StringList;
const std::wstring kLangFolderName = L"lang";  //õĿ¼

struct LangSetting {
    std::wstring lang_name;  // Selected language name
    LangSetting(){};
};

class MutiLanSupport  //֧
{
public:
    MutiLanSupport();
    virtual ~MutiLanSupport();

public:  //
    static MutiLanSupport* GetInstance();
    /*
     * ƣMutiLanSupport ::GetStringViaID
     * ͨidϢ
     * nID, Ϣid
     * void
     * ֵ  һַ
     */
    std::wstring GetStringViaID(const std::wstring& id);

    /*
     * ƣMutiLanSupport ::LoadStringTable
     * ׼stringϢ,ԭȵ
     * void
     * void
     * ֵ  ׼ɷTRUE򷵻FALSE;
     */
    BOOL LoadStringTable(const std::wstring& file_path);
    /*
     * ƣMutiLanSupport ::LoadStringTable
     * ׼stringϢ,ԭȵ
     * ļ
     * void
     * ֵ  ׼ɷTRUE򷵻FALSE;
     */
    BOOL LoadStringTable(const HGLOBAL& hGlobal);

    //(ļ塢ķ塢Ӣĵ)ù
    /*
    @Brief
    */
    bool LoadLangSetting();

    /*
    @Brief ȡ
    */
    LangSetting GetLangSetting() { return lang_setting_; }

    /*
    @Brief л zh_CN  zh_TW  en_US Ӣ Ja  Ko
    */
    BOOL SwitchLang(const std::wstring& new_lang);

    void RegisterWindow(void* wnd);

    void UnregisterWindow(void* wnd);

private:  //
    /*
    @Brief
    */
    void ClearAll();

    /*
    @Brief
    */
    BOOL SaveLangSetting();

    /*
    @Brief ȡ
    */
    void SetLangSetting(const LangSetting& new_lang_setting);

    /*
     * ƣMutiLanSupport ::AnalyzeStringTabel
     * ׼proxyϢ
     * void
     * void
     * ֵ  ׼ɷTRUE򷵻FALSE;
     */
    BOOL AnalyzeStringTable(const StringList& list);

private:                                                 //Ա
    std::map<std::wstring, std::wstring> string_table_;  //ַб
    LangSetting lang_setting_;                           //Ϣ
    LangSetting new_lang_setting_;                       //ûùĽϢ˳Żᱣ棩
};

}  // namespace ui
#endif  // UI_UTILS_MULTILANGSUPPORT_H_
