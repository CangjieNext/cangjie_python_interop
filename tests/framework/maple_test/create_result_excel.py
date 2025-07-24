import csv
import os
import pathlib
import shutil

import pandas as pd
import uuid
import requests
import json
import time
from maple_test.task import TestSuiteTask
from maple_test.utils import read_config, config_section_to_dict
from maple_test.test import read_list
from pandas.io.excel import ExcelWriter

workspace = pathlib.Path(os.path.dirname(__file__)).absolute()
head_list = ["Depth", "Feature_Name", "TestCase_Relation DR ID", "TestCase_Name", "TestCase_Number",
             "TestCase_Automatic script/folder", "TestCase_DesignNote", "TestCase_Pretreatment Condition",
             "TestCase_Test Steps", "TestCase_Expected Result", "TestCase_Automated", "TestCase_Level",
             "TestCase_Test Case Type", "TestCase_Execution Platform"]
UUID = str(uuid.uuid1()).replace("-", "")
clientType = "com.huawei.cangjie"
username = "h30030617"
TMSSTenant = "TMSS-SZV03"
Content_Type = "application/json"
X_HW_APPKEY = "m8Tz9x3KztX+57QmJbDHaQ=="

scopePaths = []
Test_Cases_uri = ""

header = {"Content-Type": Content_Type,
          "clientType": clientType,
          "requestId": UUID,
          "username": username,
          "TMSSTenant": TMSSTenant,
          "X-HW-ID": clientType,
          "X-HW-APPKEY": X_HW_APPKEY,
          }


def call_limit(limit, interval):
    def decorator(func):
        last_called = [0]

        def wrapper(*args, **kwargs):
            now = time.time()

            if now - last_called[0] > interval:
                wrapper.counter = 0

            if wrapper.counter < limit:
                wrapper.counter += 1
                last_called[0] = now
                return func(*args, **kwargs)

        wrapper.counter = 0
        return wrapper

    return decorator


def write_csv_file(csv_file, header_list, data_list):
    """
    csv_file：结果保存文件的路径
    header_list：保存的关键字，以列表形式传参，如["name", "language", "cpu", "time"]
    data_list：要保存的数据，以列表形式传参
    """
    with open(csv_file, mode="w", encoding="utf-8-sig", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(header_list)
        writer.writerows(data_list)


def get_test_list(cfg_path, base_dir):
    config = read_config(cfg_path)
    suffix_comments = config_section_to_dict(config, "suffix")
    suffixes = suffix_comments.keys()
    top_testlist_path = TestSuiteTask._get_testlist(config, base_dir)
    temp = []
    if top_testlist_path:
        for testlist_path in top_testlist_path:
            with open(testlist_path, 'r', errors='ignore', encoding='UTF-8-sig') as cases:
                content = cases.readlines()
                temp += content
    include, exclude = read_list(temp)
    all_test_case, exclude_test_case = TestSuiteTask._search_case(
        include, exclude, base_dir, suffixes
    )
    return all_test_case


def get_case_information(test_case):
    raw = [["..", "TestCases", "", "", "", "", "", "", "", "", "", "", "", ""]]
    for testsuit in test_case:
        raw.append(["...", testsuit.replace('/', ''), "", "", "", "", "", "", "", "", "", "", "", ""])
        for case in test_case[testsuit]:
            if not judge_case(str(case)):
                continue
            case_path = str(case).split('testsuites/')[-1]
            case_path_split = case_path.split('/')
            index_start = 0
            path_pos = 0
            for path in case_path_split:
                index_end = len(raw)
                for i in raw[index_start: index_end]:
                    if index_start != 0 and len(i[0]) <= len(raw[index_start - 1][0]):
                        index_end = raw[index_start: index_end].index(i) + index_start + 1
                        break
                if path_pos != len(case_path_split) - 1:
                    raw_in = [(path_pos + 3) * ".", path, "", "", "", "", "", "", "", "", "", "", "",
                              ""]
                    if raw_in in raw[index_start: index_end]:
                        index_start = raw[index_start: index_end].index(raw_in) + index_start + 1
                    else:
                        raw.insert(index_start, raw_in)
                        index_start += 1
                else:
                    raw_in = [(path_pos + 3) * "."]
                    r = read_txt(str(case))
                    raw_in += r
                    if raw_in not in raw[index_start: index_end]:
                        raw.insert(index_start, raw_in)
                path_pos += 1
    return raw


def judge_case(case_path):
    if pathlib.Path.exists(pathlib.Path(case_path)):
        with open(case_path, 'r', encoding='utf-8', errors='ignore') as f:
            data = f.read()
            if "EXEC" in data or "DEPENDENCE" in data or "ASSERT" in data or "EXPECTED" in data or "ERRCHECK" in data:
                return True
            else:
                return False


def read_txt(case_path):
    txt_path = ''.join(case_path.split('.')[:-1]) + '.txt'
    TestCase_Relation_DR_ID = ''
    TestCase_Name = ''.join(case_path.split('/')[-1].split('.')[:-1])
    TestCase_Number = txt_path.split('testsuites/')[-1].replace('/', '-.-').replace('.txt', '')
    TestCase_Automatic_script_folder = 'testsuites/' + case_path.split('testsuites/')[-1]
    TestCase_DesignNote = ''
    TestCase_Pretreatment_Condition = ''
    TestCase_Test_Steps = ''
    TestCase_Expected_Result = 'Pass'
    TestCase_Automated = 'TRUE'
    TestCase_Level = 'Level 0'
    TestCase_Test_Case_Type = 'Function test'
    TestCase_Execution_Platform = 'TEP_GTR_PYTHON'
    if pathlib.Path.exists(pathlib.Path(txt_path)):
        with open(txt_path, 'r', encoding='utf-8', errors='ignore') as f:
            case_dict = {}
            lines = f.readlines()
            for line in lines:
                data_line = line.strip('\n')
                if '/*' in data_line or '*/' in data_line:
                    continue
                if '*' not in data_line.replace('* -@', ''):
                    case_dict.setdefault(data_line.replace('* -@', '').split(': ')[0].strip(),
                                         data_line.replace('* -@', '').split(': ')[-1].strip())
                elif '* -#step' in data_line.replace('* -@', ''):
                    TestCase_Test_Steps += data_line.replace('* -#', '').strip() + '\n'
                elif '* #' in data_line.replace('* -@', ''):
                    if 'Brief' in lines[lines.index(line) - 1]:
                        TestCase_DesignNote += data_line.replace('* #', '').strip() + '\n'
            TestCase_Relation_DR_ID = case_dict.get('RequirementID', TestCase_Relation_DR_ID)
            TestCase_DesignNote = case_dict.get('Brief', '') + TestCase_DesignNote
            TestCase_Expected_Result = case_dict.get('Expect', TestCase_Expected_Result)
            TestCase_Level = 'Level ' + case_dict.get('Priority', TestCase_Level).lower().replace('level',
                                                                                                  '').strip() if case_dict.get(
                'Priority', TestCase_Level).lower().replace('level', '').strip().isdigit() else TestCase_Level
    r = ["", TestCase_Relation_DR_ID, TestCase_Name, TestCase_Number, TestCase_Automatic_script_folder,
         TestCase_DesignNote, TestCase_Pretreatment_Condition, TestCase_Test_Steps, TestCase_Expected_Result,
         TestCase_Automated, TestCase_Level, TestCase_Test_Case_Type, TestCase_Execution_Platform]
    return r


def csv2excel(csv_file, excel_file):
    with ExcelWriter(excel_file) as ew:
        pd.read_csv(csv_file).to_excel(ew, sheet_name='result', index=False)
    os.unlink(csv_file)


def get_result_excel(cfg_path, base_dir):
    cfg_path = pathlib.Path(cfg_path)
    base_dir = pathlib.Path(base_dir)
    all_test_case = get_test_list(cfg_path, base_dir)
    raw = get_case_information(all_test_case)
    write_csv_file(str(workspace) + "/result.csv", head_list, raw)
    csv2excel(str(workspace) + "/result.csv", str(workspace) + "/result.xlsx")


def read_result_excel(excel_file):
    df = pd.read_excel(excel_file, sheet_name="result")
    df['TestCase_Pretreatment Condition'] = df['TestCase_Pretreatment Condition'].astype(object)
    df['TestCase_Automated'] = df['TestCase_Automated'].astype(bool)
    return df


def compare(df_pr, df):
    df_pr_numbers = list(filter(lambda x: pd.isnull(x) is False, df_pr["TestCase_Number"].values))
    df_numbers = list(filter(lambda x: pd.isnull(x) is False, df["TestCase_Number"].values))
    same_list, delete_list, create_list = find_samemember(df_pr_numbers, df_numbers)
    updata_case_data_list = []
    updata_numbers_list = []
    for TestCase_Number in same_list:
        df_pr_list = list(df_pr[df_pr["TestCase_Number"] == TestCase_Number].iloc[0])
        df_list = list(df[df["TestCase_Number"] == TestCase_Number].iloc[0])
        for i in range(len(df_pr_list)):
            if (pd.isnull(df_pr_list[i]) and pd.isnull(df_list[i])) or str(df_pr_list[i]).replace('\t', ' ') == str(
                    df_list[i]).replace('\t', ' '):
                continue
            else:
                updata_case_data_list.append(df[df["TestCase_Number"] == TestCase_Number])
                updata_numbers_list.append(df[df["TestCase_Number"] == TestCase_Number]["TestCase_Number"].values[0])
                break
    if delete_list:
        delete_case(delete_list)
    if create_list:
        create_cases(create_list, df)
    if updata_numbers_list:
        updata_case(updata_case_data_list, updata_numbers_list)


@call_limit(limit=10, interval=60)
def BatchListTestCaseByNumber(testcase_number):
    data = {
        "numbers": testcase_number,
        "scopePaths": scopePaths,
        "type": "TestCase",
    }
    data = json.dumps(data)
    data = bytes(data, 'utf-8')
    header['requestId'] = str(uuid.uuid1()).replace("-", "")
    r = requests.post(
        url="https://apigw.dragon.tools.huawei.com/api/hutaf_tmss_search/v1/search/testcase/numbers",
        headers=header,
        data=data,
        verify=False
    )
    return json.loads(r.content.decode('utf-8'))['result']['value']['data']


@call_limit(limit=20, interval=60)
def DeleteEntityBatch(paths):
    data = {
        "paths": paths,
    }
    data = json.dumps(data)
    data = bytes(data, 'utf-8')
    header['requestId'] = str(uuid.uuid1()).replace("-", "")
    r = requests.post(
        url="https://apigw.dragon.tools.huawei.com/api/GT3KServer/v1/resources/delete",
        headers=header,
        data=data,
        verify=False
    )
    return r.content.decode('utf-8')


@call_limit(limit=50, interval=60)
def ListEntityChildren(parameters):
    header['requestId'] = str(uuid.uuid1()).replace("-", "")
    r = requests.get(
        url="https://apigw.dragon.tools.huawei.com/api/GT3KServer/v1/resource/children/{}?pageNo={}&pageSize={}"
            "&types={}".format(parameters.get("uri"), parameters.get("pageNo"), parameters.get("pageSize"),
                               parameters.get("types")),
        headers=header,
        verify=False
    )
    return json.loads(r.content.decode('utf-8'))['result']['value']['children'][0]['children']


@call_limit(limit=120, interval=60)
def CreateEntity(case_data):
    data = json.dumps(case_data)
    data = bytes(data, 'utf-8')
    header['requestId'] = str(uuid.uuid1()).replace("-", "")
    r = requests.post(
        url="https://apigw.dragon.tools.huawei.com/api/GT3KServer/v1/resource/detail/{}".format(
            case_data['parentPath']),
        headers=header,
        data=data,
        verify=False
    )
    return json.loads(r.content.decode('utf-8'))


@call_limit(limit=20, interval=60)
def BatchUpdateEntities(case_data):
    data = json.dumps(case_data)
    data = bytes(data, 'utf-8')
    header['requestId'] = str(uuid.uuid1()).replace("-", "")
    r = requests.put(
        url="https://apigw.dragon.tools.huawei.com/api/GT3KServer/v0/resources",
        headers=header,
        data=data,
        verify=False
    )
    return json.loads(r.content.decode('utf-8'))


@call_limit(limit=100, interval=60)
def ShowProgressTMSS(operationUri):
    header['requestId'] = str(uuid.uuid1()).replace("-", "")
    r = requests.get(
        url="https://apigw.dragon.tools.huawei.com/api/GT3KServer/v0/progress/{}".format(operationUri),
        headers=header,
        verify=False
    )
    return json.loads(r.content.decode('utf-8'))


@call_limit(limit=20, interval=60)
def ListEntityBatch(uri_list):
    header['requestId'] = str(uuid.uuid1()).replace("-", "")
    data = {
        "isSort": "true",
        "paths": uri_list,
        "type": "TestCase"
    }
    data = json.dumps(data)
    data = bytes(data, 'utf-8')
    r = requests.post(
        url="https://apigw.dragon.tools.huawei.com/api/GT3KServer/v1/resources/batch",
        headers=header,
        data=data,
        verify=False
    )
    return json.loads(r.content.decode('utf-8'))


def number2uri(uri_list):
    uri_dict = {}
    for i in range(len(uri_list) // 200 + 1):
        u_list = uri_list[i * 200:] if i == len(uri_list) // 200 else uri_list[i * 200:(i + 1) * 200]
        r = ListEntityBatch(u_list)
        sleep_time = 0
        while sleep_time <= 1440 and r is None:
            time.sleep(60)
            sleep_time += 1
            r = ListEntityBatch(u_list)
        for y in r['result']['value']:
            uri_dict.setdefault(y.get('number'), y.get('realURI'))
    return uri_dict


def delete_case(delete_list):
    delete_uri_list = select_uri_by_list(delete_list)
    for y in range(len(delete_uri_list) // 200 + 1):
        delete_uri_data = delete_uri_list[y * 200:] if y == len(delete_uri_list) // 200 else delete_uri_list[
                                                                                             y * 200:(y + 1) * 200]
        return_code = DeleteEntityBatch(delete_uri_data)
        sleep_time = 0
        while sleep_time <= 1440 and return_code is None:
            time.sleep(60)
            sleep_time += 1
            return_code = DeleteEntityBatch(delete_uri_data)


def create_cases(create_list, df):
    parentPath_dict = {}
    for TestCase_Number in create_list:
        parentPath = Test_Cases_uri
        path_list = TestCase_Number.split("-.-")[:-1]
        parentPath_dict_key = ''
        for path in path_list:
            exists = False
            parentPath_dict_key = parentPath_dict_key + '-.-' + path if parentPath_dict_key != '' else path
            if parentPath_dict_key in parentPath_dict.keys():
                parentPath = parentPath_dict.get(parentPath_dict_key)
                continue
            path_select = ListEntityChildren({
                "uri": parentPath,
                "pageNo": 1,
                "pageSize": 200,
                "types": "TestItem"
            })
            sleep_times = 0
            while sleep_times <= 1440 and path_select is None:
                time.sleep(60)
                sleep_times += 1
                path_select = ListEntityChildren({
                    "uri": parentPath,
                    "pageNo": 1,
                    "pageSize": 200,
                    "types": "TestItem"
                })
            for children in path_select:
                if children['name'] == path:
                    exists = True
                    parentPath_dict.setdefault(parentPath_dict_key, children['realURI'])
                    parentPath = children['realURI']
                    break
            if not exists:
                data = {
                    "content": {
                        "name": path,
                        "type": "TestItem"
                    },
                    "parentPath": parentPath,
                    "typeName": "TestItem"
                }
                r = CreateEntity(data)
                sleep_times = 0
                while sleep_times <= 1440 and r is None:
                    time.sleep(60)
                    sleep_times += 1
                    r = CreateEntity(data)
                parentPath_dict.setdefault(parentPath_dict_key, r['result']['value']['realURI'])
                parentPath = r['result']['value']['realURI']
        df_case = df[df['TestCase_Number'] == TestCase_Number]
        case_data = {
            "content": {
                "drRelationID": df_case['TestCase_Relation DR ID'].values[0] if not pd.isnull(
                    df_case['TestCase_Relation DR ID'].values[0]) else '',
                "name": df_case['TestCase_Name'].values[0],
                "number": df_case['TestCase_Number'].values[0],
                "NetworkScriptName": df_case['TestCase_Automatic script/folder'].values[0],
                "DesignNote": df_case['TestCase_DesignNote'].values[0] if not pd.isnull(
                    df_case['TestCase_DesignNote'].values[0]) else '',
                "Preparation": df_case['TestCase_Pretreatment Condition'].values[0] if not pd.isnull(
                    df_case['TestCase_Pretreatment Condition'].values[0]) else '',
                "TestStep": df_case['TestCase_Test Steps'].values[0] if not pd.isnull(
                    df_case['TestCase_Test Steps'].values[0]) else '',
                "ExpectOutput": df_case['TestCase_Expected Result'].values[0] if not pd.isnull(
                    df_case['TestCase_Expected Result'].values[0]) else "Pass",
                "AutoType": str(int(df_case['TestCase_Automated'].values[0])),
                "rank": "6" if df_case['TestCase_Level'].values[0] == 'Level 0' else df_case['TestCase_Level'].values[
                    0].replace(
                    "Level ", ""),
                "TestType": "1" if df_case['TestCase_Test Case Type'].values[0] == "Function test" else "0",
                "exeplatform": df_case['TestCase_Execution Platform'].values[0],
                "type": "TestCase"
            },
            "parentPath": parentPath,
            "typeName": "TestCase"
        }
        r = CreateEntity(case_data)
        sleep_times = 0
        while sleep_times <= 1440 and r is None:
            time.sleep(60)
            sleep_times += 1
            r = CreateEntity(case_data)


def updata_case(updata_list, updata_number_list):
    updata_uri_list = select_uri_by_list(updata_number_list)
    uri_dict = number2uri(updata_uri_list)
    for i in range(len(updata_list) // 200 + 1):
        updata_list_split = updata_list[i * 200:] if i == len(updata_list) // 200 else updata_list[
                                                                                       i * 200:(i + 1) * 200]
        updata_contents = {
            "contents": [],
            "typeName": "TestCase"
        }
        for df in updata_list_split:
            content = {
                "uri": uri_dict.get(df['TestCase_Number'].values[0]),
                "drRelationID": df['TestCase_Relation DR ID'].values[0] if not pd.isnull(
                    df['TestCase_Relation DR ID'].values[0]) else '',
                "name": df['TestCase_Name'].values[0],
                "number": df['TestCase_Number'].values[0],
                "NetworkScriptName": df['TestCase_Automatic script/folder'].values[0],
                "DesignNote": df['TestCase_DesignNote'].values[0] if not pd.isnull(
                    df['TestCase_DesignNote'].values[0]) else '',
                "Preparation": df['TestCase_Pretreatment Condition'].values[0] if not pd.isnull(
                    df['TestCase_Pretreatment Condition'].values[0]) else '',
                "TestStep": df['TestCase_Test Steps'].values[0] if not pd.isnull(
                    df['TestCase_Test Steps'].values[0]) else '',
                "ExpectOutput": df['TestCase_Expected Result'].values[0] if not pd.isnull(
                    df['TestCase_Expected Result'].values[0]) else "Pass",
                "AutoType": str(int(df['TestCase_Automated'].values[0])),
                "rank": "6" if df['TestCase_Level'].values[0] == 'Level 0' else df['TestCase_Level'].values[0].replace(
                    "Level ", ""),
                "TestType": "1" if df['TestCase_Test Case Type'].values[0] == "Function test" else "0",
                "exeplatform": df['TestCase_Execution Platform'].values[0],
                "type": "TestCase"
            }
            updata_contents["contents"].append(content)
        r = BatchUpdateEntities(updata_contents)
        operationUri = r.get('result').get('value')
        Progress_result = ShowProgressTMSS(operationUri)
        sleep_times = 0
        while sleep_times <= 1440:
            if r is not None and Progress_result is not None:
                if Progress_result.get('result').get('value').get('ended') is False:
                    time.sleep(0.5)
                    Progress_result = ShowProgressTMSS(operationUri)
                else:
                    print("updata cases success")
                    break
            if r is None:
                time.sleep(60)
                sleep_times += 1
                r = BatchUpdateEntities(updata_contents)
                Progress_result = ShowProgressTMSS(r.get('result').get('value'))
            if r is not None and Progress_result is None:
                time.sleep(60)
                sleep_times += 1
                Progress_result = ShowProgressTMSS(operationUri)


def select_uri_by_list(numbers_list):
    uri_list = []
    for i in range(len(numbers_list) // 1000 + 1):
        testcase_numbers = ";".join('%s' % numbers for numbers in numbers_list[i * 1000:]) if i == len(
            numbers_list) // 1000 else ";".join('%s' % numbers for numbers in numbers_list[i * 1000:(i + 1) * 1000])
        uri = BatchListTestCaseByNumber(testcase_numbers)
        sleep_times = 0
        while sleep_times <= 1440 and uri is None:
            time.sleep(60)
            sleep_times += 1
            uri = BatchListTestCaseByNumber(testcase_numbers)
        uri_list += uri.split(",")
    return uri_list


def find_samemember(list1, list2):
    same_list = set(list1).intersection(set(list2))  # in list1 and in list2
    delete_list = set(list1).difference(set(list2))  # in list1 not in list2
    add_list = set(list2).difference(set(list1))  # in list2 not in list1
    return list(same_list), list(delete_list), list(add_list)


def main(scope_paths):
    global scopePaths
    scopePaths.append(scope_paths)
    global Test_Cases_uri
    Test_Cases_uri = scope_paths.split("/")[-2]
    cfg_path = str(workspace) + "/../../testsuites/configs/llvmgc/cangjie2llvmgc_test_voo.cfg"
    base_dir = str(workspace) + "/../../testsuites/configs/llvmgc/../.."
    get_result_excel(cfg_path, base_dir)
    df_pr = read_result_excel(str(workspace) + "/result_ex.xlsx")
    df = read_result_excel(str(workspace) + "/result.xlsx")
    compare(df_pr, df)
