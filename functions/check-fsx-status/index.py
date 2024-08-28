import json
import logging
import boto3
import os

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

try:
    ENABLE_CLOUDWATCH_METRICS = os.environ["ENABLE_CLOUDWATCH_METRICS"]
    ENABLE_SNS_NOTIFICATIONS = os.environ["ENABLE_SNS_NOTIFICATIONS"]
    FILESYSTEM_IDS = os.environ["FILESYSTEM_IDS"].split(",")
    LAMBDASNSTOPIC = os.environ["LambdaSNSTopic"]
    SUPPRESS_STATES = os.environ["SUPPRESS_STATES"].split(",")
    VALID_STATES = ["AVAILABLE"] + SUPPRESS_STATES
except KeyError as e:
    logger.error("Missing environment variable: {}".format(e))
    raise e


def lambda_handler(event, context):
    logger.info("Received event: " + json.dumps(event, indent=2))

    fsx = boto3.client("fsx")
    logger.info("Successfully created fsx client")

    sns = boto3.client("sns")
    logger.info("Successfully created sns client")

    cloudwatch = boto3.client("cloudwatch")
    logger.info("Successfully created cloudwatch client")

    logger.info(
        "Notifications suppressed for these FSx states: {}".format(
            ", ".join(VALID_STATES)
        )
    )

    for fs_id in FILESYSTEM_IDS:
        response = fsx.describe_file_systems(
            FileSystemIds=[fs_id],
        )
        logger.info(response["ResponseMetadata"])
        status = response["FileSystems"][0].get("Lifecycle")

        if status not in VALID_STATES:
            logger.info("The file system {} needs attention.".format(fs_id))
            if ENABLE_SNS_NOTIFICATIONS:
                sns.publish(
                    TopicArn=LAMBDASNSTOPIC,
                    Message="File System "
                    + fs_id
                    + " needs attention. The status is "
                    + status,
                    Subject="FSx Health Warning!",
                )
                logger.info("Successfully sent SNS notification for filesystem {}".format(fs_id))
            if ENABLE_CLOUDWATCH_METRICS:
                put_custom_metric(cloudwatch, fs_id, 1)
                logger.info("Successfully put metric for filesystem {}".format(fs_id))

        else:
            logger.info(
                "The file system {} is in a healthy state, and is reachable and available for use.".format(
                    fs_id
                )
            )
            if ENABLE_CLOUDWATCH_METRICS:
                put_custom_metric(cloudwatch, fs_id, 0)
                logger.info("Successfully put metric for filesystem {}".format(fs_id))

    return {"statusCode": 200, "body": "OK"}


def put_custom_metric(cloudwatch_client, filesystem_id: str, value: int):
    """
    Put the filesystem status metric into the custom namespace Custom/FSx.
    :param cloudwatch_client:  The CloudWatch client to use for putting the metric.
    :param filesystem_id: The filesystem id to use for the metric.
    :param value: 0 for healthy, 1 for unhealthy.
    :return:
    """
    return cloudwatch_client.put_metric_data(
        MetricData=[
            {
                "MetricName": "Status",
                "Dimensions": [
                    {"Name": "FileSystemId", "Value": filesystem_id},
                ],
                "Unit": "None",
                "Value": value,
            },
        ],
        Namespace="Custom/FSx",
    )


if __name__ == "__main__":
    lambda_handler(None, None)
