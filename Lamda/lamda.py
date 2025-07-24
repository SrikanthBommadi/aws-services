import boto3

def lambda_handler(event, context):
    ec2 = boto3.client('ec2', region_name='us-east-1')
    instance_id = "<REPLACE_WITH_INSTANCE_ID>"

    # Example: Stop the instance
    ec2.stop_instances(InstanceIds=[instance_id])
    return {
        'statusCode': 200,
        'body': f'Stopped instance {instance_id}'
    }
