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
    ${row_id}=    Get Row Id    ${row}
    Set To Dictionary    ${row}    Status    ${status}
    Update Row    ${row}    ${sheet_id}

Get Row Id
    [Documentation]    Get the row id from the row. Depending on the sheet provider, this may be
    ...    different. In this example, we attempt to get a row id from the row dictionary assuming
    ...    it's column is labeled "ROW_ID" and if that fails, we return the value in the first column
    ...    of the row.
    [Arguments]    ${row}
    TRY
        ${row_id}=    Get From Dictionary    ${row}    ROW_ID
    EXCEPT    KeyError    type=START
        ${row_id}=    Get row value by index    ${row}    0
    END
    RETURN    ${row_id}

Get row value by index
    [Documentation]    Get the value of a row by index. This is useful for sheets that don't have
    ...    column names or if you want to get a value from a column that you don't know the name of.
    ...
    ...    NOTE: This works because dictionaries are order-preserving in Python 3.6+.
    [Arguments]    ${row}    ${index}
    ${key_list}=    Convert To List    ${row}
    ${value}=    Get From List    ${key_list}    ${index}
    RETURN    ${value}
