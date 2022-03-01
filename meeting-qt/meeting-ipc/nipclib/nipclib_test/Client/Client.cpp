/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Client.cpp : 此文件包含 "main" 函数。程序执行将在此处开始并结束。
//

#include "pch.h"
#include <iostream>
#include <thread>
#include "tnet.h"
#include "NIPCLib/NIPCLib_export.h"
#include "NIPCLib/config/build_config.h"
#include "NIPCLib/ipc/ipc_client.h"
#include "NIPCLib/base/ipc_thread.h"

NS_NIPCLIB::IPCThread main_thread;
NS_NIPCLIB::IPCClient client;
int index = 0;
int port;
int main()
{
	client.AttachInit([](bool ret,const std::string& host,int port) {
		std::string text("client init (res:");
		text.append(std::to_string(ret)).
			append(" host:").
			append(host).
			append(" port:").
			append(std::to_string(port)).
			append(")");
		std::cout << text << std::endl;
	});
	client.AttachReady([]() {
		std::cout << "read" << std::endl;
		client.SendData(NS_NIPCLIB::IIPC::MakeIPCData(std::to_string(index++)));
	});
	client.AttachReceiveData([](const NS_NIPCLIB::IPCData& data) {
		std::string sendtext = "I am client Get data from srv :\"";
		sendtext.append(*data);
		sendtext.append("\"");
		std::cout << sendtext << std::endl;
		client.SendData(NS_NIPCLIB::IIPC::MakeIPCData(std::to_string(index++)));
	});
	main_thread.AttachBegin([]() {
		client.Init(port);
		client.Start();
	});
	client.AttachClose([]() {		
		main_thread.PostTask([]() {
			client.Stop();
			main_thread.Stop();
			});
		});
	std::cout << "input port:";
	std::cin >> port;
	main_thread.AttachCurrentThread();
	main_thread.Join();
	std::cout << "exit main" << std::endl;
	system("pause");
}
