# Copyright (c) 2022 Vladislav Ploaia (Vitagroup - CDR Core Team)
#
# This file is part of Project EHRbase
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


*** Settings ***
Documentation   Composition Integration Tests
...             ${\n}Based on:
...             https://github.com/ehrbase/ehrbase/blob/develop/doc/conformance_testing/COMPOSITION_VALIDATION_DATATYPES.md#431-test-case-dv_time-open-constraint
...             ${\n}*4.3.1. Test case DV_TIME open constraint*
Metadata        TOP_TEST_SUITE    COMPOSITION

Resource        ../../_resources/keywords/composition_keywords.robot
Resource        ../../_resources/suite_settings.robot

Suite Setup       Precondition


*** Variables ***
${composition_file}      Test_all_types_v2__.json


*** Test Cases ***
Create Composition With DV_TIME Combinations - Positive
    [Documentation]     *Operations done here (Positive flows):*
    ...     - load json file from CANONICAL_JSON folder
    ...     - update DV_TIME using ${dvTimeValue} argument value
    ...     - commit composition
    ...     - check status code of the commited composition to be 201.
    ...     *Postcondition:* Add DV_TIME value 10:30:34, to ${composition_file}.
    [Template]      PositiveCompositionTemplate
    10
    10:30
    10:30:47
    10:30:47.5
    10:30:47.333
    10:30:47.333333
    10:30:47Z
    10:30:47.5Z
    10:30:47.333Z
    10:30:47.333333Z
    10:30:47-03:00
    10:30:47.5-03:00
    10:30:47.333-03:00
    10:30:47.333333-03:00
    [Teardown]      PositiveCompositionTemplate     10:30:34

Create Composition With DV_TIME Combinations - Negative
    [Documentation]     *Operations done here (Negative flows):*
    ...     - load json file from CANONICAL_JSON folder
    ...     - update DV_TIME using ${dvTimeValue} argument value
    ...     - commit composition
    ...     - check status code of the commited composition to be 400.
    ...     *Postcondition:* Add DV_TIME value 10:30:34, to ${composition_file}.
    [Template]      NegativeCompositionTemplate
    NULL
    ${EMPTY}
    48
    10:95
    10:30:78
    10:30:78Z
    10:30:78-03:00
    10.5
    10:05.5
    [Teardown]      PositiveCompositionTemplate     10:30:34


*** Keywords ***
Precondition
    Upload OPT    all_types/Test_all_types_v2.opt
    create EHR

PositiveCompositionTemplate
    [Arguments]     ${dvTimeValue}=10:30:47
    Load Json File With Composition
    ${initalJson}           Load Json From File     ${compositionFilePath}
    ${returnedJsonFile}     Change Json KeyValue and Save Back To File
    ...     ${initalJson}   ${dvTimeValue}
    commit composition      format=CANONICAL_JSON
    ...                     composition=${composition_file}
    Should Be Equal As Strings      ${response.status_code}     201

NegativeCompositionTemplate
    [Arguments]     ${dvTimeValue}=48
    Load Json File With Composition
    ${initalJson}           Load Json From File     ${compositionFilePath}
    Change Json KeyValue and Save Back To File
    ...     ${initalJson}   ${dvTimeValue}
    commit composition      format=CANONICAL_JSON
    ...                     composition=${composition_file}
    Should Be Equal As Strings      ${response.status_code}     400

Load Json File With Composition
    [Documentation]     Loads Json content from composition file.
    ...     Stores file content in test variable, as well as full file path.
    ${COMPO DATA SETS}     Set Variable
    ...     ${PROJECT_ROOT}${/}tests${/}robot${/}_resources${/}test_data_sets${/}compositions
    ${file}                 Get File   ${COMPO DATA SETS}/CANONICAL_JSON/${composition_file}
    ${compositionFilePath}  Set Variable    ${COMPO DATA SETS}/CANONICAL_JSON/${composition_file}
    Set Test Variable       ${file}
    Set Test Variable       ${compositionFilePath}

Change Json KeyValue and Save Back To File
    [Documentation]     Updates $.content[0].data.events[0].data.items[11].value.value to
    ...     value provided as argument.
    ...     Takes 2 arguments:
    ...     1 - jsonContent = Loaded Json content
    ...     2 - value to be on $..data.events..items.[8].value.value key
    [Arguments]     ${jsonContent}      ${valueToUpdate}
    #${objPath}      Set Variable        $..data.events..items.[?(@._type=='DV_TIME')].value
    ${objPath}      Set Variable        $..data.events..items.[8].value.value
    ${json_object}          Update Value To Json	json_object=${jsonContent}
    ...             json_path=${objPath}        new_value=${valueToUpdate}
    ${changedDvTimeValue}   Get Value From Json     ${jsonContent}      ${objPath}
    Should Be Equal     ${changedDvTimeValue[0]}   ${valueToUpdate}
    ${json_str}     Convert JSON To String    ${json_object}
    Create File     ${compositionFilePath}    ${json_str}
    [return]    ${compositionFilePath}