/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef BASE_MEMORY_SINGLETON_H_
#define BASE_MEMORY_SINGLETON_H_
#include "nipclib/nipclib_export.h"
#include "nipclib/config/build_config.h"
#include <memory>
#include <mutex>
#include <assert.h>
NIPCLIB_BEGIN_DECLS
	//饿汉模式
#define SINGLETON_DEFINE(TypeName)				\
static TypeName* GetInstance()					\
{												\
	static TypeName type_instance;				\
	return &type_instance;						\
}												\
												\
TypeName(const TypeName&) = delete;				\
TypeName& operator=(const TypeName&) = delete
    
// 懒汉模式
//release_atexitmanager 是否由atexitmanager来释放
	template <typename TSingleton>
	class Singleton
	{
		//如果TSingleton的构造函数是private/protected需要在类定义时引入此宏,如下所示
		//class Test : public Singleton<Test>
		//{
		//		SingletonHideConstructor(Test)
		//	private:
		//		Test() = default;
		//		~Test() = default;
		//}       
    #define SingletonHideConstructor(TSingleton) \
    private:\
	friend std::unique_ptr<TSingleton> std::make_unique<TSingleton>();\
    friend struct std::default_delete<TSingleton>;
        
	private:
		friend TSingleton;
		using TSingletonPtr = std::unique_ptr<TSingleton>;
	private:
		Singleton(void) = default;
		virtual ~Singleton() = default;
		Singleton(const Singleton&) = delete;
		Singleton(Singleton&&) = delete;
		Singleton& operator = (const Singleton&) = delete;

		static TSingletonPtr instance;
		static std::unique_ptr<std::once_flag> oc;
	public:
		static const TSingletonPtr& GetInstance()
		{
			assert(!std::is_array<TSingleton>::value);
			std::call_once(*oc, [&] (){
				instance = std::move(std::make_unique<TSingleton>());				
			});
			return instance;
		}
	};
	template <typename TSingleton>
	std::unique_ptr<TSingleton> Singleton< TSingleton>::instance = nullptr;
	template <typename TSingleton>
	std::unique_ptr<std::once_flag> Singleton< TSingleton>::oc = std::make_unique<std::once_flag>();
NIPCLIB_END_DECLS


#endif // BASE_MEMORY_SINGLETON_H_
