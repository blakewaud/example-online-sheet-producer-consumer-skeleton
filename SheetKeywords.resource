*** Settings ***
Documentation       Any shared keywords for handling the Online Sheet system between the
...                 Producer and Consumer.

Library             MockSheetProvider.py
Library             Collections


*** Keywords ***
Update status
    [Documentation]    Update the status of the row within the sheet. The sheet must have a "Status"
    ...    column for this to work.
    [Arguments]    ${row}    ${sheet_id}    ${status}
    Set To Dictionary    ${row}    Status    ${status}
    Update Row    ${row}    ${sheet_id}
