#!/usr/bin/python3
# -*- coding:utf-8 -*-
#
# Copyright (c) [2020] Huawei Technologies Co.,Ltd.All rights reserved.
#
# OpenArkCompiler is licensed under the Mulan PSL v1.
# You can use this software according to the terms and conditions of the Mulan PSL v1.
# You may obtain a copy of Mulan PSL v1 at:
#
#     http://license.coscl.org.cn/MulanPSL
#
# THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR
# FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v1 for more details.
#
"""
maple test - Maple Tester


"""
import os.path
import shutil
import time
import io
import sys

sys.output = io.TextIOWrapper(sys.stdout.buffer, encoding='utf8')
KeepRunFile = False
from xml.etree import ElementTree

from maple_test import configs
from maple_test.task import TestSuiteTask
from maple_test.run import TestError


def main():
    test_suite_config, running_config, log_config = configs.init_config()
    logger = configs.LOGGER

    test_paths = test_suite_config.get("test_paths")
    cli_test_cfg = test_suite_config.get("test_cfg")
    cli_running_config = test_suite_config.get("cli_running_config")

    root = ElementTree.Element("testsuites")
    json_result = []

    retry = configs.get_val("retry")
    check_retry = configs.get_val("check_retry")
    pass_rate = configs.get_val("pass_rate")
    result = ""
    failed = False
    failed_rate = False
    split_num = configs.get_val("split_num")
    check = configs.get_val("check")
    condition = configs.get_val("condition")
    level = configs.get_val("level")
    xml_output = configs.get_val("xml_output")
    json_output = configs.get_val("json_output")

    try:
        for test in test_paths:
            test_cfg = cli_test_cfg
            test_result = None
            test_failed = False
            test_failed_rate = False
            if test.exists():
                if not test_cfg:
                    test_cfg = test / "test.cfg"
                try:
                    task = TestSuiteTask(test, test_cfg, running_config, log_config, condition, level, cli_running_config)
                except TestError as e:
                    logger.info(e)
                    continue
                if not task.task_set:
                    continue
                if split_num:
                    task.split(split_num)  # only split, not run.
                elif check:
                    task.check(check)
                else:
                    for run_time in range(1, retry + 2):
                        if retry >= 1 and check_retry:
                            mode = "w" if run_time == 1 else "a"
                            with open("check_retry.txt", mode=mode) as f:
                                f.write("-" * 120 + os.linesep)
                        logger.info("Run {} times".format(run_time))
                        failed_num, num_dict = task.run(configs.get_val("processes"), run_time)
                        if num_dict["pass"] / num_dict["total"] * 100 >= pass_rate:
                            test_failed_rate = False
                        else:
                            test_failed_rate = True
                        if failed_num > 0:
                            test_failed = True
                        else:
                            test_failed = False
                        test_result = task.gen_summary([])
                    failed |= test_failed
                    failed_rate |= test_failed_rate
                    result += test_result
                    if xml_output:
                        task.gen_xml_result(root)
                    if json_output:
                        json_result.append(task.gen_json_result())

            else:
                logger.info("Test path: {} does not exist, please check".format(test))

        if xml_output:
            with xml_output.open("w") as f:
                f.write(ElementTree.tostring(root).decode("utf-8"))

        if json_output:
            with json_output.open("w") as f:
                import json

                json.dump(json_result, f, indent=2)

        output = configs.get_val("output")
        if output:
            if output.exists() and output.is_file():
                name = "{}_{}{}".format(output.stem, int(time.time()), output.suffix)
                logger.info(
                    "result file: {} exists, will move exists file to: {}".format(
                        output, name
                    )
                )
                shutil.move(str(output), str(output.parent / name))
            logger.info("Save test result at: {}".format(output))
            with output.open("w", encoding="utf-8") as f:
                f.write(result)
    finally:
        temp_dir = running_config.get("temp_dir")
        if configs.get_val('debug') or configs.get_val('keep_temp'):
            logger.debug("Keep temp file at %s", temp_dir)
        elif temp_dir.exists():
            logger.debug("remove temp_dir %s", temp_dir)
            shutil.rmtree(str(temp_dir))

        if retry >= 1 and check_retry:
            with open("check_retry.txt", mode="r", encoding="utf-8") as file:
                retry_content = file.read().strip()
                retry_list = [
                    [line.strip() for line in item.split(os.linesep) if line.strip()]
                    for item in retry_content.split("-" * 120) if item.strip()
                ]
                fail_cases = list(set([item for item in (retry_list[0] if retry_list else []) if "Result: FAIL" in item]))
                retry_pass_cases = []
                found = False
                for fail_case in fail_cases:
                    case_name = fail_case.split(",")[0].split(":")[-1].strip()
                    log_file = fail_case.split(",")[-1].split(":")[-1].strip()
                    for i in range(1, len(retry_list)):
                        if any("Case: {}, Result: PASS".format(case_name) in line for line in retry_list[i]):
                            found = True
                            break
                    if found:
                        retry_pass_cases.append((case_name, log_file))
                retry_data = {
                    "total": len(retry_pass_cases),
                    "data": []
                }
                for case_name, log_file in retry_pass_cases:
                    with open(log_file, "r", encoding="utf-8") as f:
                        error_reason = f.read()
                    case_data = {
                        "case": case_name,
                        "error": error_reason
                    }
                    retry_data["data"].append(case_data)
                with open('check_retry.json', 'w', encoding='utf-8') as j:
                    import json
                    json.dump(retry_data, j, indent=4, ensure_ascii=False)
                print("These cases only pass after retry:" + os.linesep)
                print(os.linesep.join([case[0] for case in retry_pass_cases]))
                print("-" * 120)

        if "CHECK_LEVEL" in os.environ:
            if os.path.exists("cases_without_level.txt") and os.path.getsize("cases_without_level.txt") != 0:
                with open("cases_without_level.txt", "r", encoding='utf-8') as file:
                    content = file.read().strip()
                    print("These cases do not have level:" + os.linesep)
                    print(content)
                    print("-" * 120)

        if configs.get_val("fail_exit") and failed:
            exit(1)

        if configs.get_val("pass_rate") and failed_rate:
            exit(1)


if __name__ == "__main__":
    main()
