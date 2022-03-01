/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Server.cpp : 此文件包含 "main" 函数。程序执行将在此处开始并结束。
//

#include "pch.h"
#include <iostream>
#include "NIPCLib/NIPCLib_export.h"
#include "NIPCLib/config/build_config.h"
#include "NIPCLib/base/ipc_thread.h"
#include "NIPCLib/ipc/ipc_server.h"


NS_NIPCLIB::IPCThread main_thread;
NS_NIPCLIB::IPCServer server;
NS_NIPCLIB::IPCThread timer_thread;
int main()
{	
	server.AttachInit([](bool ret, const std::string& host, int port) {
		std::string text("server init (res:");
		text.append(std::to_string(ret)).
			append(" host:").
			append(host).
			append(" port:").
			append(std::to_string(port)).
			append(")");
		std::cout << text << std::endl;
	});
	server.AttachReady([]() {
		std::cout << "read" << std::endl;
	});
	server.AttachReceiveData([](const NS_NIPCLIB::IPCData& data) {
		std::string tt("I am server got data from client:\"");
		tt.append(data->data()).append("\"");
		std::cout << tt << std::endl;
		std::string rsp("I got the data :");
		rsp.append(*data);
		server.SendData(std::make_shared<std::string>(rsp));
	});
	main_thread.AttachBegin([]() {
		server.Init();
		server.Start();
		timer_thread.PostTask([]() {
			Sleep(10000);
			server.Close();
			});
		});
	server.AttachClose([]() {
		main_thread.PostTask([] {
			server.Stop();
			main_thread.Stop();
		});		
	});
	server.AttachClientClose([]() {
		main_thread.PostTask([] {
			std::cout << "client exit!" << std::endl;
			});
		});
	//timer_thread.Start();
	main_thread.AttachCurrentThread();	
	main_thread.Join();
	std::cout << "exit main" << std::endl;
	system("pause");
}
