import json
import boto3
import logging
import os
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# AWS clients
# IAM Identity Center client for creating user accounts
# CloudWatch client for audit logging
sso_admin = boto3.client('sso-admin')
identitystore = boto3.client('identitystore')
cloudwatch = boto3.client('logs')

def lambda_handler(event, context):
    """
    Onboarding Lambda function
    
    Triggered by API Gateway when a new employee is added
    through the HR portal or directly via API call.
    
    Performs the following automated steps:
    1. Creates a user account in IAM Identity Center
    2. Assigns the user to the correct group based on department
    3. Logs all actions to CloudWatch for audit trail
    
    This satisfies REQ-NCA-P3-01 — automated and auditable
    provisioning of IT resources for new employees.
    
    Expected event format:
    {
        "name": "Jane Doe",
        "email": "jane@innovatech.com",
        "department": "Engineering",
        "role": "Software Engineer"
    }
    """
    
    logger.info(f"Onboarding request received: {json.dumps(event)}")
    
    # Extract employee details from the event
    # Support both direct invocation and API Gateway proxy format
    if 'body' in event:
        body = json.loads(event['body']) if isinstance(event['body'], str) else event['body']
    else:
        body = event
    
    name = body.get('name')
    email = body.get('email')
    department = body.get('department')
    role = body.get('role')
    
    # Validate required fields
    if not all([name, email, department, role]):
        logger.error("Missing required fields in onboarding request")
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'name, email, department and role are required'})
        }
    
    # Get IAM Identity Center instance details from environment
    # These are set by Terraform when deploying the Lambda
    identity_store_id = os.environ.get('IDENTITY_STORE_ID')
    instance_arn = os.environ.get('SSO_INSTANCE_ARN')
    
    if not identity_store_id or not instance_arn:
        logger.error("Missing IAM Identity Center configuration")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'IAM Identity Center not configured'})
        }
    
    try:
        # Step 1 — Create user account in IAM Identity Center
        # The user receives an email to set their password
        # No manual account creation needed
        logger.info(f"Creating IAM Identity Center user for {email}")
        
        create_user_response = identitystore.create_user(
            IdentityStoreId=identity_store_id,
            UserName=email,
            DisplayName=name,
            Emails=[{
                'Value': email,
                'Type': 'work',
                'Primary': True
            }],
            Name={
                'Formatted': name,
                'GivenName': name.split()[0] if ' ' in name else name,
                'FamilyName': name.split()[-1] if ' ' in name else ''
            }
        )
        
        user_id = create_user_response['UserId']
        logger.info(f"Created user with ID: {user_id}")
        
        # Step 2 — Assign user to group based on department
        # Group membership determines which permission set the user gets
        # and what AWS resources they can access
        group_id = get_group_id_for_department(identity_store_id, department)
        
        if group_id:
            identitystore.create_group_membership(
                IdentityStoreId=identity_store_id,
                GroupId=group_id,
                MemberId={'UserId': user_id}
            )
            logger.info(f"Added user to group for department: {department}")
        else:
            logger.warning(f"No group found for department: {department}")
        
        # Step 3 — Log the onboarding action to CloudWatch
        # This creates the audit trail required by REQ-NCA-P3-01
        log_audit_event(
            action='EMPLOYEE_ONBOARDED',
            employee_email=email,
            employee_name=name,
            department=department,
            role=role,
            user_id=user_id,
            status='SUCCESS'
        )
        
        logger.info(f"Onboarding completed successfully for {email}")
        
        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({
                'message': 'Employee onboarded successfully',
                'user_id': user_id,
                'email': email,
                'department': department
            })
        }
        
    except identitystore.exceptions.ConflictException:
        logger.warning(f"User already exists: {email}")
        return {
            'statusCode': 409,
            'body': json.dumps({'error': 'User already exists in IAM Identity Center'})
        }
    except Exception as e:
        logger.error(f"Onboarding failed for {email}: {str(e)}")
        log_audit_event(
            action='EMPLOYEE_ONBOARDING_FAILED',
            employee_email=email,
            employee_name=name,
            department=department,
            role=role,
            status='FAILED',
            error=str(e)
        )
        return {
            'statusCode': 500,
            'body': json.dumps({'error': f'Onboarding failed: {str(e)}'})
        }


def get_group_id_for_department(identity_store_id, department):
    """
    Looks up the IAM Identity Center group ID for a given department.
    
    Groups are pre-created by Terraform and named after departments.
    Each group has a permission set attached that determines AWS access level.
    
    Department to group mapping:
    - IT / Engineering → DevOps group (K8sViewer permission set)
    - HR / Finance / Operations / Sales → Standard group (ReadOnly permission set)
    """
    
    # Map departments to IAM Identity Center group names
    # These group names must match what is created in Terraform
    department_group_map = {
        'IT': 'DevOps',
        'Engineering': 'DevOps',
        'HR': 'HR',
        'Finance': 'Standard',
        'Operations': 'Standard',
        'Sales': 'Standard'
    }
    
    group_name = department_group_map.get(department, 'Standard')
    
    try:
        # Search for the group by display name
        response = identitystore.list_groups(
            IdentityStoreId=identity_store_id,
            Filters=[{
                'AttributePath': 'DisplayName',
                'AttributeValue': group_name
            }]
        )
        
        if response['Groups']:
            return response['Groups'][0]['GroupId']
        else:
            logger.warning(f"Group '{group_name}' not found in Identity Store")
            return None
            
    except Exception as e:
        logger.error(f"Failed to get group ID for {department}: {str(e)}")
        return None


def log_audit_event(action, employee_email, employee_name, department, 
                    role, status, user_id=None, error=None):
    """
    Writes an audit log entry to CloudWatch Logs.
    
    All provisioning and deprovisioning actions are logged here
    to satisfy the auditability requirement in REQ-NCA-P3-01.
    
    Log entries include timestamp, action, employee details,
    and outcome so administrators can trace all lifecycle events.
    """
    
    log_group = os.environ.get('AUDIT_LOG_GROUP', '/innovatech/hr/audit')
    log_stream = f"onboarding/{datetime.utcnow().strftime('%Y/%m/%d')}"
    
    audit_entry = {
        'timestamp': datetime.utcnow().isoformat(),
        'action': action,
        'employee_email': employee_email,
        'employee_name': employee_name,
        'department': department,
        'role': role,
        'status': status
    }
    
    if user_id:
        audit_entry['user_id'] = user_id
    if error:
        audit_entry['error'] = error
    
    try:
        # Ensure log group exists
        try:
            cloudwatch.create_log_group(logGroupName=log_group)
        except cloudwatch.exceptions.ResourceAlreadyExistsException:
            pass
        
        # Ensure log stream exists
        try:
            cloudwatch.create_log_stream(
                logGroupName=log_group,
                logStreamName=log_stream
            )
        except cloudwatch.exceptions.ResourceAlreadyExistsException:
            pass
        
        # Write the audit entry
        cloudwatch.put_log_events(
            logGroupName=log_group,
            logStreamName=log_stream,
            logEvents=[{
                'timestamp': int(datetime.utcnow().timestamp() * 1000),
                'message': json.dumps(audit_entry)
            }]
        )
        
    except Exception as e:
        # Do not fail the main function if audit logging fails
        # but log the error so it can be investigated
        logger.error(f"Failed to write audit log: {str(e)}")