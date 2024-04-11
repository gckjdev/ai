# Copyright (c) Microsoft. All rights reserved.

import asyncio
import logging

import semantic_kernel as sk
import semantic_kernel.connectors.ai.open_ai as sk_oai
from semantic_kernel.contents.chat_history import ChatHistory
from semantic_kernel.utils.settings import azure_openai_settings_from_dot_env_as_dict
import sys

script_name = sys.argv[0]

if len(sys.argv) > 1:
    function_name = sys.argv[1]
else:
    function_name = None

logging.basicConfig(level=logging.WARNING)

system_message = """
You are a chat bot. Your name is Mosscap and
you are the best coding expert in the world.
Your goal is to help everyone to write high quality codes.
"""

kernel = sk.Kernel()

service_id = "chat-gpt"
chat_service = sk_oai.AzureChatCompletion(
    service_id=service_id, **azure_openai_settings_from_dot_env_as_dict(include_api_version=True)
)
kernel.add_service(chat_service)

# note: using plugins from the samples folder
plugins_directory = "./plugins"
code_plugin = kernel.import_plugin_from_prompt_directory(plugins_directory, "CodePlugin")

if function_name == None:
    function_name = "FeatureToTestCase"

feature_to_testcase_function = code_plugin["FeatureToTestCase"]
optimize_testcase_function = code_plugin["OptimizeTestCase"]
more_testcase_function = code_plugin["MoreTestCase"]
testcase_to_robot_framework_function = code_plugin["TestCaseToRobotFramework"]

from semantic_kernel.planners.basic_planner import BasicPlanner

planner = BasicPlanner(service_id)



# history = ChatHistory()
# history.add_user_message("Hi there, who are you?")
# history.add_assistant_message("I am Mosscap, a chat bot. I'm trying to figure out what people need.")

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

    stream = True
    if stream:

        # basic_plan = await planner.create_plan(user_input, kernel)

        # print(basic_plan.generated_plan)

        # answer = await planner.execute_plan(basic_plan, kernel)
        history = ChatHistory()
        history.add_user_message(user_input)
        
        answer = await kernel.invoke(feature_to_testcase_function, sk.KernelArguments(input=user_input), chat_history=history)
        print(f"Test Boost AI:> {answer}")        
        print("\n")
        print(f"Test Boost AI:> keep thinking......")        
        
        answer = await kernel.invoke(optimize_testcase_function, sk.KernelArguments(input=answer), chat_history=history)
        print(f"Test Boost AI:> {answer}")        
        print("\n")
        print(f"Test Boost AI:> keep thinking......")        

        answer = await kernel.invoke(more_testcase_function, sk.KernelArguments(input=answer), chat_history=history)
        print(f"Test Boost AI:> {answer}")        
        print("\n")
        print(f"Test Boost AI:> keep thinking......")        

        answer = await kernel.invoke(testcase_to_robot_framework_function, sk.KernelArguments(input=answer), chat_history=history)
        print(f"Test Boost AI:> {answer}")        
        print("\n")

        # answer = kernel.invoke_stream(
        #     chat_function,
        #     user_input=user_input,
        #     chat_history=history,
        # )
        # print("Mosscap:> ", end="")
        # async for message in answer:
        #     print(str(message[0]), end="")
        # print("\n")
        return True
        
    # answer = await kernel.invoke(
    #     chat_function,
    #     user_input=user_input,
    #     chat_history=history,
    # )
    # print(f"Mosscap:> {answer}")
    # history.add_user_message(user_input)
    # history.add_assistant_message(str(answer))
    return True


async def main() -> None:
    chatting = True
    while chatting:
        chatting = await chat()


if __name__ == "__main__":
    asyncio.run(main())
