import json
import boto3
import os


def lambda_handler(event, context):
    LAMBDASNSTOPIC = os.environ["LambdaSNSTopic"]

    fsx_windows = boto3.client("fsx")
    filesystems = fsx_windows.describe_file_systems()
    for filesystem in filesystems.get("FileSystems"):
        status = filesystem.get("Lifecycle")
        filesystem_id = filesystem.get("FileSystemId")
        sns_client = boto3.client("sns")
        if status != "AVAILABLE":
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
    # Return the status
    return {"statusCode": 200, "body": "OK"}
