# Copyright (c) Microsoft. All rights reserved.

import asyncio
import logging

import semantic_kernel as sk
import semantic_kernel.connectors.ai.open_ai as sk_oai
from semantic_kernel.contents.chat_history import ChatHistory
from semantic_kernel.utils.settings import azure_openai_settings_from_dot_env_as_dict
import sys

script_name = sys.argv[0]

logging.basicConfig(level=logging.WARNING)

kernel = sk.Kernel()

service_id = "chat-gpt"
chat_service = sk_oai.AzureChatCompletion(
    service_id=service_id, **azure_openai_settings_from_dot_env_as_dict(include_api_version=True)
)
kernel.add_service(chat_service)

# note: using plugins from the code plugin folder
plugins_directory = "./plugins"
code_plugin = kernel.import_plugin_from_prompt_directory(plugins_directory, "CodePlugin")

feature_to_testcase_function = code_plugin["FeatureToTestCase"]
optimize_testcase_function = code_plugin["OptimizeTestCase"]
more_testcase_function = code_plugin["MoreTestCase"]
testcase_to_robot_framework_function = code_plugin["TestCaseToRobotFramework"]

print(f"Test Boost AI:> May I help you?")

async def chat() -> bool:
    try:
        user_input = input("User:> ")
    except KeyboardInterrupt:
        print("\n\nExiting chat...")
        return False
    except EOFError:
        print("\n\nExiting chat...")
        return False

    if user_input == "exit":
        print("\n\nExiting chat...")
        return False

    stream = True  # not used
    if stream:
        
        history = ChatHistory()
        answer = await kernel.invoke(feature_to_testcase_function, sk.KernelArguments(input=user_input), chat_history=history)
        print(f"Test Boost AI:> {answer}")        
        print("\n")
        print(f"Test Boost AI:> keep thinking......")        
        
        history = ChatHistory()
        answer = await kernel.invoke(optimize_testcase_function, sk.KernelArguments(input=answer), chat_history=history)
        print(f"Test Boost AI:> {answer}")        
        print("\n")
        print(f"Test Boost AI:> keep thinking......")        

        history = ChatHistory()
        answer = await kernel.invoke(more_testcase_function, sk.KernelArguments(input=answer), chat_history=history)
        print(f"Test Boost AI:> {answer}")        
        print("\n")
        print(f"Test Boost AI:> keep thinking......")        

        history = ChatHistory()
        answer = await kernel.invoke(testcase_to_robot_framework_function, sk.KernelArguments(input=answer), chat_history=history)
        print(f"Test Boost AI:> {answer}")        
        print("\n")

    return True

async def main() -> None:
    chatting = True
    while chatting:
        chatting = await chat()

if __name__ == "__main__":
    asyncio.run(main())
