*** Settings ***
Documentation       This resource file represents a skeleton for implementing
...                 automation around a single target application. It is intended to be
...                 used as a starting point for building out a more complex automation
...                 suite.

Library             String
Library             RPA.Browser.Selenium
Library             RPA.Robocorp.WorkItems
Library             RPA.Robocorp.Vault


*** Variables ***
${TARGET_URL}=      https://www.example.com


*** Keywords ***
Initialize App
    [Documentation]    Perform any setup required to run the application.
    TRY
        Open app
        Login

        # You can catch specific errors here and handle them differently
        # You must specifiy the type as GLOB, START or REGEXP depending
        # on the pattern you want to match against the error message string.
    EXCEPT    *Website unavailable*    type=GLOB    AS    ${err}
        Log    ${err}    level=ERROR
        Release input work item
        ...    state=FAILED
        ...    exception_type=APPLICATION
        ...    code=WEBSITE_DOWN
        ...    message=${err}
        Fail    Bot could not Initialize
    EXCEPT    *Login failed*    type=GLOB    AS    ${err}
        Log    ${err}    level=ERROR
        Release input work item
        ...    state=FAILED
        ...    exception_type=APPLICATION
        ...    code=LOGIN_FAILURE
        ...    message=${err}
        Fail    Bot could not Initialize
    END

Open app
    [Documentation]    Opens a new browser and navigates to the app.
    Log    NOT IMPLEMENTED    level=WARN
    RETURN    # delete this line when implementing

    # Possible implementation
    Open Available Browser    ${TARGET_URL}

Login
    [Documentation]    Logs into the app and confirms app is ready for input
    Log    NOT IMPLEMENTED    level=WARN
    RETURN    # delete this line when implementing

    # Possible implementation
    ${credentials}=    Get Secret    target-app
    Input Text    user-name    ${credentials}[username]
    Input Password    password    ${credentials}[password]
    Submit Form
    Assert logged in

Process order
    [Documentation]    Process a work item. The implementation of this keyword
    ...    will contain the primary logic of your robot for a single work item.
    ...
    ...    You can consider configuring this keyword to have an argument for each
    ...    expected input it requires or you can use a single argument for the full
    ...    work item dictionary. The former is recommended as it makes the keyword
    ...    more reusable and easier to test.
    [Arguments]    ${order_id}    ${owner}    ${approval}
    Log    NOT IMPLEMENTED    level=WARN
    RETURN    # delete this line when implementing

    # Possible implementation
    Reset application state
    Open orders page    ${order_id}
    Complete order    ${owner}    ${approval}
    Capture page screenshot    ${OUTPUTDIR}/order_${order_id}_completed.png
    Submit Form

Reset application state
    [Documentation]    Resets the application state to a known good state. This
    ...    keyword is intended to be used as a setup step for other keywords.
    ...
    ...    The implementation of this keyword usually requires identifying a reliable
    ...    way to cancel any current actions on the webpage and return to a home page
    ...    or other known good state.
    Log    NOT IMPLEMENTED    level=WARN

Open orders page
    [Documentation]    Opens a specific order ID so it can be completed. Assumes
    ...    the robot is on the home page.
    ...
    ...    This keyword represents a common pattern for building navigation steps
    ...    in your robot. It is recommended to create a keyword for each page you
    ...    need to navigate to and then use those keywords in your tasks.
    ...
    ...    Such step keywords usually assume the context they are in, but more
    ...    advanced cases can utilize checking to confirm the context before the move
    ...    forward, like some of the `Assert logged in` keywords in this example.
    [Arguments]    ${order_id}
    Log    NOT IMPLEMENTED    level=WARN

Complete Order
    [Documentation]    Completes an order. Assumes the robot is on the order page.
    ...
    ...    This keyword represents a page action step. You often implement all the actions
    ...    you would take on one page in one keyword up until you hit the submit button.
    ...    But, if there are complex actions or sub-windows involved, you can break those
    ...    out into their own keywords.
    [Arguments]    ${owner}    ${approval}
    Log    NOT IMPLEMENTED    level=WARN

Assert logged in
    [Documentation]    Checks if login was successful
    ...
    ...    Implementaiton of this keyword requires you to identify a reliable way to
    ...    confirm the application is in the expected state. This is usually done by
    ...    checking for a specific element on the page or by checking the URL.
    Log    NOT IMPLEMENTED    level=WARN
    RETURN    # delete this line when implementing

    # Possible implementation
    Wait Until Page Contains Element    inventory_container
    Location Should Be    ${TARGET_URL}/inventory.html
