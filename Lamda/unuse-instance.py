import boto3
from datetime import datetime, timedelta

ec2 = boto3.client('ec2')
cloudwatch = boto3.client('cloudwatch')

def lambda_handler(event, context):
    # Find all running EC2 instances
    instances = ec2.describe_instances(Filters=[{
        'Name': 'instance-state-name',
        'Values': ['running']
    }])

    stopped_instances = []

    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            instance_id = instance['InstanceId']
            
            # Get CPU utilization for the last 7 days
            metric = cloudwatch.get_metric_statistics(
                Namespace='AWS/EC2',
                MetricName='CPUUtilization',
                Dimensions=[{'Name': 'InstanceId', 'Value': instance_id}],
                StartTime=datetime.utcnow() - timedelta(days=7),
                EndTime=datetime.utcnow(),
                Period=86400,  # Daily
                Statistics=['Average']
            )

            # Check if CPU was below 5% for all 7 days
            low_usage = all(dp['Average'] < 5.0 for dp in metric['Datapoints'])

            if low_usage and metric['Datapoints']:
                ec2.stop_instances(InstanceIds=[instance_id])
                stopped_instances.append(instance_id)

    return {
        'statusCode': 200,
        'body': f"Stopped instances: {stopped_instances}"
    }
