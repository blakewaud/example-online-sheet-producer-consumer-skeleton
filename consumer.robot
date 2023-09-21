*** Settings ***
Library     Collections
Library     RPA.Robocorp.WorkItems
Library     RPA.Tables
Library     MockSheetProvider.py
Resource    TargetAutomation.resource
Resource    SheetKeywords.resource


*** Variables ***
@{REQUIRED_WORKITEM_KEYS}=      ROW_ID    Status    Order ID    Owner    Approval


*** Tasks ***
Load and Process All Orders
    [Documentation]    Complete all orders in the work item queue
    [Setup]    Initialize App
    TRY
        For Each Input Work Item    Load and Process Order
    EXCEPT    AS    ${err}
        # This is the general error handler that will release the error
        # to the control room as received from the code.
        #
        # If this is called after a lower level error has already
        # released the work item, the `Release input work item` keyword
        # will fail, producing a non-continuable failure (but not necessarily
        # a failure for the previously released work item). This failure will
        # force this instance of the robot to close and the Control Room
        # will start up a new run of the bot to continue processing other
        # work items.
        Log    ${err}    level=ERROR
        Release input work item
        ...    state=FAILED
        ...    exception_type=APPLICATION
        ...    code=UNCAUGHT_ERROR
        ...    message=${err}
    END
    # Note that teardown can be called even after a failure and you are also able
    # create a more complex teardown in a separate keyword.
    [Teardown]    Close browser


*** Keywords ***
Load and Process Order
    [Documentation]    Process a single order and perform updates against the online sheet
    ...    as work progresses.
    ${work_item}=    Get work item variables
    TRY
        Validate Order    ${work_item}
        Update status    ${work_item}[ROW_ID]    Status    Bot Processing
        Process order    ${work_item}[Order ID]    ${work_item}[owner]    ${work_item}[approval]
        Update status    ${work_item}[ROW_ID]    Status    Complete
        Release Input Work Item    DONE
    EXCEPT    Order validation failed    type=START    AS    ${err}
        # Catching different errors with search strings allows the robot to
        # release them to CR with different error codes for easy sorting,
        # troubleshooting, and retrying. Normally, you would try to
        # program error handling into the bot so it could work through
        # common errors encountered during execution. But this pattern
        # allows you to handle and release those errors when you cannot
        # handle them in the program, especially for errors related to the
        # work item itself that need to be corrected by the business users.
        Log    ${err}    level=ERROR
        Release input work item
        ...    state=FAILED
        ...    exception_type=BUSINESS
        ...    code=WEBSITE_UNRESPONSIVE
        ...    message=${err}
    EXCEPT    *timeout*    type=GLOB    AS    ${err}
        Log    ${err}    level=ERROR
        Release input work item
        ...    state=FAILED
        ...    exception_type=APPLICATION
        ...    code=WEBSITE_UNRESPONSIVE
        ...    message=${err}
    EXCEPT    *order incomplete*    type=GLOB    AS    ${err}
        Log    ${err}    level=ERROR
        # You can manipulate the error to
        # extract relevant information.
        # When creating your pattern, you must first allow the robot
        # to fail a few times to see what the errors look like, than you
        # can look at the documentation for `Get regexp matches` to
        # understand how to extract the information you need.
        ${item_causing_problem}=    Get regexp matches    ${err}    .*text\\(\\), "([\\w\\s]+)"    1
        ${message}=    Catenate
        ...    The requested order '${item_causing_problem}[0]' could not be completed.
        ...    Check the order and consider trying again.
        Release input work item
        ...    state=FAILED
        ...    exception_type=BUSINESS
        ...    code=ORDER_PROBLEM
        ...    message=${message}
    END

Validate Order
    [Documentation]    Validate that the order is complete and ready to be processed.
    ...    If the order is not valid, raise an exception.
    ...
    ...    It is important to capture details around each check so you are able to provider
    ...    more information to the user and to the control room.
    [Arguments]    ${work_item}
    # Create a list of failures to be used in the exception message
    @{failures}=    Create list
    # Check that the identifiers exist before using them in other messages.
    TRY
        Dictionary Should Contain Key    ${work_item}    Order ID
        ${order_id}=    Set variable    ${work_item}[Order ID]
    EXCEPT    KeyError    type=START
        Append To List    ${failures}    MISSING_KEY: Work item is missing required key: Order ID
        ${order_id}=    Set variable    ${None}
    END
    # Check work item has required keys
    ${keys}=    Get dictionary keys    ${work_item}
    FOR    ${required_key}    IN    @{REQUIRED_WORKITEM_KEYS}
        IF    "${required_key}" not in ${keys}
            Create validation message
            ...    ${failures}
            ...    MISSING_KEY
            ...    Work item is missing required key: ${required_key}
            ...    ${order_id}
        END
    END
    # Check that values are not empty
    FOR    ${key}    IN    @{keys}
        ${value}=    Get from dictionary    ${work_item}    ${key}
        IF    "${value}" == ""
            Create validation message
            ...    ${failures}
            ...    EMPTY_VALUE
            ...    Work item has empty value for key: ${key}
            ...    ${order_id}
        END
    END
    # Check that the order is approved
    ${approval}=    Get from dictionary    ${work_item}    Approval
    IF    "Approved by" not in "${approval}"
        Create validation message    ${failures}    INVALID_APPROVAL    Work item has not been approved    ${order_id}
    END
    # You can create as many checks as you need using this pattern.
    # If there are no failures, the list will be empty.
    IF    ${failures}
        ${message}=    Catenate    SEPARATOR=\n
        ...    Order validation failed:
        ...    ${failures}
        ...    \n
        ...    Please correct the following issues and try again.
        ...    \n
        ...    Order ID: ${order_id}
        Fail    ${message}
    END

Create validation message
    [Documentation]    Creates a standardized error message for validation failures and adds it
    ...    to the provided list of failures. The list is modified in place. Note that because
    ...    of the final message created, adding the order_id here is superflous, but this present
    ...    a pattern you can use to inject additional details into the message if needed in a
    ...    more complex validation and still keep cognitive complexity low.
    ...
    ...    If an order_id is not provided the message will ommit the order id as a reference.
    [Arguments]    ${failures}    ${code}    ${message}    ${order_id}=${None}
    IF    $order_id is not None
        ${msg}=    Catenate    ${code}: [Order ID: ${order_id}] ${message}
    ELSE
        ${msg}=    Catenate    ${code}: ${message}
    END
    Append To List    ${failures}    ${msg}
