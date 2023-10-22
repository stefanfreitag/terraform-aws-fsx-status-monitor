import json
import boto3
import os


LAMBDASNSTOPIC = os.environ["LambdaSNSTopic"]
SUPPRESS_STATES = os.environ["SUPPRESS_STATES"].split(",")
VALID_STATES = ["AVAILABLE"] + SUPPRESS_STATES


def lambda_handler(event, context):
    fsx_windows = boto3.client("fsx")
    filesystems = fsx_windows.describe_file_systems()
    print(
        "Notifications suppressed for these FSx states: {}".format(
            ", ".join(VALID_STATES)
        )
    )
    for filesystem in filesystems.get("FileSystems"):
        status = filesystem.get("Lifecycle")
        filesystem_id = filesystem.get("FileSystemId")
        sns_client = boto3.client("sns")
        if status not in VALID_STATES:
            print("The file system: {} needs attention.".format(filesystem_id))
            sns_client.publish(
                TopicArn=LAMBDASNSTOPIC,
                Message="File System: "
                + filesystem_id
                + " needs attention. The status is: "
                + status,
                Subject="FSx Health Warning!",
            )
        else:
            print(
                "The file system: {} is in a healthy state, and is reachable and available for use.".format(
                    filesystem_id
                )
            )
    return {"statusCode": 200, "body": "OK"}
