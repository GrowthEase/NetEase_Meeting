/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

//work MiscThread
#include "setup_wnd.h"
#include "utils/7zDec.h"
#include "Resource.h"
#include "main/setup_data.h"
#include <thread>
#include <chrono>
#include <ShlObj.h>

//开始删除旧文件
void SetupForm::DelFile()
{
	LOG_APP(L"DelFile begin");
	int num = CSetupData::GetDelFileInfoListNum();
	for (int i = 0; i < num && !destroy_wnd_; i++)
	{
		CSetupData::DeleteOldFile(i);
		SetProgressCurStepPos(i*PROGRESS_DELFILE / num);
	}
	if (!destroy_wnd_)
	{
		pre_progress_pos_ = PROGRESS_DELFILE;
		LOG_APP(L"DelFile end");
		StdClosure cb = std::bind(&SetupForm::BeginUnzip, this);
		PostTaskWeakly(threading::kThreadMiscGlobal, cb);
	}
}

void SetupForm::BeginUnzip()
{
	LOG_APP(L"BeginUnzip");
	std::wstring tip;
	CFileInStream archiveStream;
	CLookToRead lookStream;
	CSzArEx db;
	int32_t res;
	ISzAlloc allocImp;
	ISzAlloc allocTempImp;
	LPCWSTR temp = NULL;
	LPCWSTR zipPath = NULL;
	size_t tempSize = 0;

	allocImp.Alloc = SzAlloc;
	allocImp.Free = SzFree;

	allocTempImp.Alloc = SzAllocTemp;
	allocTempImp.Free = SzFreeTemp;

	HRSRC   hrsc = FindResource(NULL, MAKEINTRESOURCE(IDR_YIXIN_ZIP), L"ZIP");
	HGLOBAL hG = LoadResource(NULL, hrsc);
	DWORD   dwSize = SizeofResource(NULL, hrsc);
	//if (InFile_Open(&archiveStream.file, str7ZipFilePath))
	//{
	//	PrintError("can not open input file");
	//	return 1;
	//}
	if (hG && dwSize > 0)
	{
		InFile_OpenEx(&archiveStream.file, hG, dwSize);
	}
	else
	{
		LOG_ERR("can not open input file");
		res = SZ_ERROR_OPEN_7Z;
		EndUnzip(L"文件解压失败，请重新下载", res);
		return;
	}

	FileInStream_CreateVTable(&archiveStream);
	LookToRead_CreateVTable(&lookStream, False);

	lookStream.realStream = &archiveStream.s;
	LookToRead_Init(&lookStream);

	CrcGenerateTable();

	SzArEx_Init(&db);
	res = SzArEx_Open(&db, &lookStream.s, &allocImp, &allocTempImp);
	if (res != SZ_OK)
	{
		LOG_ERR("can not open db");
		tip = L"文件解压失败，请重新下载";
	}
	else
	{
		int listCommand = 0, testCommand = 0, extractCommand = 0, fullPaths = 0;
		extractCommand = 1; fullPaths = 1;

		UInt32 i;

		UInt32 blockIndex = 0xFFFFFFFF; /* it can have any value before first call (if outBuffer = 0) */
		Byte *outBuffer = 0; /* it must be 0 before first call for each new archive. */
		size_t outBufferSize = 0;  /* it can have any value before first call (if outBuffer = 0) */

		UInt32 iFileNum = db.db.NumFiles;
		LOG_APP(L"正在释放文件");
		for (i = 0; i < iFileNum && !destroy_wnd_; i++)
		{
			//interface
			SetProgressCurStepPos(i*PROGRESS_UNZIP / iFileNum);

			size_t offset = 0;
			size_t outSizeProcessed = 0;
			const CSzFileItem *f = db.db.Files + i;
			size_t len;

			len = SzArEx_GetFileNameUtf16(&db, i, NULL);

			if (len > tempSize)
			{
				SzFree(NULL, (void *)zipPath);
				tempSize = len;
				zipPath = (LPCWSTR)SzAlloc(NULL, tempSize * sizeof(zipPath[0]));
				if (zipPath == 0)
				{
					res = SZ_ERROR_MEM;
					tip = L"文件解压失败，请重新下载";
					break;
				}
			}
			SzArEx_GetFileNameUtf16(&db, i, (UInt16 *)zipPath);
			std::wstring strTemPath(zipPath);
			if (f->IsDir)
			{
				strTemPath = CSetupData::CheckDirAndReplace(strTemPath);
			}
			strTemPath = CSetupData::GetFileCopyPath(strTemPath);

			if (strTemPath.empty())
			{
				continue;
			}
			nbase::StringReplaceAll(L"\\", L"/", strTemPath);
			temp = strTemPath.c_str();

			if (f->IsDir)
			{
				//printf("/");
				//CFileFind tempFind;
				//if (tempFind.FindFile(strTemPath))
				//{
				//	LOG_APP("MyCreateDir：%s", strTemPath);
				//	MyCreateDir((LPCWSTR)temp);
				//}
				continue;
			}
			else
			{
				//interface
				//LOG_APP(L"正在释放：%s", strTemPath.c_str());

				res = SzArEx_Extract(&db, &lookStream.s, i,
					&blockIndex, &outBuffer, &outBufferSize,
					&offset, &outSizeProcessed,
					&allocImp, &allocTempImp);
				if (res != SZ_OK)
				{
					LOG_ERR(L"can not open db file %s", strTemPath.c_str());
					res = SZ_ERROR_FAIL;
					tip = L"文件解压失败，请重新下载";
					//std::wstring msg_tip = nbase::StringPrintf(L"释放文件“%s”失败！\r\n是否重试？", strTemPath.c_str());
					//uint32_t msg_res = ShowUnzipMsg(msg_tip);
					//if (msg_res == kMsgBtn2)//重试
					//{
					//	i--;
					//	continue;
					//}
					//else if (msg_res == kMsgBtn3)//忽略继续
					//{
					//	continue;
					//}
					break;
				}
			}
			if (!testCommand)
			{
				CSzFile outFile;
				size_t processedSize;
				size_t j;
				UInt16 *name = (UInt16 *)temp;
				const UInt16 *destPath = (const UInt16 *)name;
				for (j = 0; name[j] != 0; j++)
				{
					if (name[j] == '/')
					{
						if (fullPaths)
						{
							name[j] = 0;
							MyCreateDir((LPCWSTR)name);
							name[j] = CHAR_PATH_SEPARATOR;
						}
						else
							destPath = name + j + 1;
					}
				}

				//if (f->IsDir)
				//{
				//	MyCreateDir((LPCWSTR)destPath);
				//	printf("\n");
				//	continue;
				//}
				//else

                // 自动重试，默认10次，如果选了重试则4次
                static int tryTimes = 10;
				if (OutFile_OpenUtf16(&outFile, (const WCHAR *)destPath))
				{
					LOG_ERR(L"can not open output file %s", strTemPath.c_str());
                    if (tryTimes > 0)
                    {
                        tryTimes--;
                        i--;
                        std::this_thread::sleep_for(std::chrono::milliseconds(500));
                        continue;
                    }
                    tryTimes = 10;

					res = SZ_ERROR_FAIL;
					uint32_t msg_res = ShowUnzipMsg(L"检测到文件被占用", strTemPath);
					if (msg_res == kMsgBtn2)//重试
					{
                        tryTimes = 4;
						i--;
						continue;
					}
					else if (msg_res == kMsgBtn3)//忽略继续
					{
						continue;
					}
					break;
				}
                tryTimes = 10;

				processedSize = outSizeProcessed;
				if (File_Write(&outFile, outBuffer + offset, &processedSize) != 0 || processedSize != outSizeProcessed)
				{
					LOG_ERR(L"can not write output file %s", strTemPath.c_str());
					File_Close(&outFile);
					res = SZ_ERROR_FAIL;
					uint32_t msg_res = ShowUnzipMsg(L"检测到文件无法写入", strTemPath);
					if (msg_res == kMsgBtn2)//重试
					{
						i--;
						continue;
					}
					else if (msg_res == kMsgBtn3)//忽略继续
					{
						continue;
					}
					break;
				}
				if (File_Close(&outFile))
				{
					LOG_ERR("can not close output file");
					res = SZ_ERROR_FAIL;
					//break;
				}
#ifdef USE_WINDOWS_FILE
				if (f->AttribDefined)
					SetFileAttributes((LPCWSTR)destPath, f->Attrib);
#endif
			}
		}
		IAlloc_Free(&allocImp, outBuffer);
	}
	SzArEx_Free(&db, &allocImp);
	SzFree(NULL, (void*)zipPath);

	//File_Close(&archiveStream.file);
	if (res == SZ_OK)
	{
		LOG_APP("Everything is Ok");
	}
	else if (res == SZ_ERROR_UNSUPPORTED)
	{
		LOG_ERR("decoder doesn't support this archive");
	}
	else if (res == SZ_ERROR_MEM)
	{
		LOG_ERR("can not allocate memory");
	}
	else if (res == SZ_ERROR_CRC)
	{
		LOG_ERR("CRC error");
	}
	else
	{
		LOG_ERR("ERROR #%d", res);
	}
	EndUnzip(tip, res);
}

void SetupForm::EndUnzip(std::wstring tip, uint32_t res)
{
	LOG_APP(L"EndUnzip tip:%s, res %d", tip.c_str(), res);
	if (!destroy_wnd_)
	{
		if (res == SZ_OK)
		{
			pre_progress_pos_ = PROGRESS_DELFILE + PROGRESS_UNZIP;
			StdClosure cb_temp = std::bind(&SetupForm::InstallRedist, this);
			PostTaskWeakly(threading::kThreadMiscGlobal, cb_temp);
		} 
		else
		{
			StdClosure cb_temp = std::bind(&SetupForm::EndSetupCallback, this, tip, res);
			PostTaskWeakly(threading::kThreadUI, cb_temp);
		}
	}
}
//开始结束后操作，创建快捷方式等
void SetupForm::CreateLink()
{
	if (!destroy_wnd_)
	{
		LOG_APP("CreateLink begin");
		CSetupData::CreateLnkList();
		SetProgressCurStepPos(PROGRESS_CREATE_LINK);
		::SHChangeNotify(SHCNE_ASSOCCHANGED, NULL, NULL, NULL);
		LOG_APP("CreateLink end");
		pre_progress_pos_ = PROGRESS_DELFILE + PROGRESS_UNZIP + PROGRESS_CREATE_LINK;
		StdClosure cb_temp = std::bind(&SetupForm::WriteRegList, this);
		PostTaskWeakly(threading::kThreadMiscGlobal, cb_temp);
	}
}
//写注册表
void SetupForm::WriteRegList()
{
	if (!destroy_wnd_)
	{
		LOG_APP("WriteRegList begin");
		uint32_t num = CSetupData::GetAddRegInfoListNum();
		for (int i = 0; i < num && !destroy_wnd_; i++)
		{
			CSetupData::WriteRegInfo(i);
			SetProgressCurStepPos(i*PROGRESS_WRITE_REG / num);
		}
		SetProgressCurStepPos(PROGRESS_WRITE_REG);
		pre_progress_pos_ = 100;
		LOG_APP("WriteRegList end");

		StdClosure cb_temp = std::bind(&SetupForm::EndSetupCallback, this, L"", 0);
		PostTaskWeakly(threading::kThreadUI, cb_temp);
	}
}
uint32_t SetupForm::ShowUnzipMsg(std::wstring tip, std::wstring path, std::wstring tip2)
{
	show_msg_res_ = -1;
	path = CSetupData::CheckPathAndReplace(path);
	StdClosure cb = std::bind(&SetupForm::ShowUnzipMsgUI, this, tip, path, tip2);
	PostTaskWeakly(threading::kThreadUI, cb);
	while (show_msg_res_ == -1)
	{
		MSG msg;
		while (PeekMessage(&msg, NULL, 0, 0, PM_REMOVE))
		{
			::TranslateMessage(&msg);
			::DispatchMessage(&msg);
		}
		Sleep(10);
	}
	return show_msg_res_;
}

void SetupForm::SetProgressCurStepPos(uint32_t pos)
{
	if (!destroy_wnd_)
	{
		uint32_t progress_pos = pre_progress_pos_ + pos;
		StdClosure cb_temp = std::bind(&SetupForm::ShowProgress, this, progress_pos);
		PostTaskWeakly(threading::kThreadUI, cb_temp);
	}
}