import json
import boto3
import logging
import os
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# AWS clients
sso_admin = boto3.client('sso-admin')
identitystore = boto3.client('identitystore')
cloudwatch = boto3.client('logs')

def lambda_handler(event, context):
    """
    Offboarding Lambda function
    
    Triggered by API Gateway when an employee is offboarded
    through the HR portal or directly via API call.
    
    Performs the following automated steps:
    1. Looks up the user in IAM Identity Center by email
    2. Removes user from all groups (revokes access)
    3. Disables the user account immediately
    4. Logs all actions to CloudWatch for audit trail
    
    Account disablement happens in the same API call as the trigger
    so there is no delay between the offboarding request and
    access revocation. This directly addresses the security gap
    where accounts remained active after an employee's last day.
    
    Satisfies REQ-NCA-P3-01 — automated and auditable
    deprovisioning of IT resources for departing employees.
    
    Expected event format:
    {
        "email": "jane@innovatech.com"
    }
    """
    
    logger.info(f"Offboarding request received: {json.dumps(event)}")
    
    # Support both direct invocation and API Gateway proxy format
    if 'body' in event:
        body = json.loads(event['body']) if isinstance(event['body'], str) else event['body']
    else:
        body = event
    
    email = body.get('email')
    
    if not email:
        logger.error("Missing required field: email")
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'email is required'})
        }
    
    identity_store_id = os.environ.get('IDENTITY_STORE_ID')
    
    if not identity_store_id:
        logger.error("Missing IAM Identity Center configuration")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'IAM Identity Center not configured'})
        }
    
    try:
        # Step 1 — Look up the user by email address
        logger.info(f"Looking up user in IAM Identity Center: {email}")
        
        user_id = get_user_id_by_email(identity_store_id, email)
        
        if not user_id:
            logger.warning(f"User not found in IAM Identity Center: {email}")
            return {
                'statusCode': 404,
                'body': json.dumps({'error': 'User not found in IAM Identity Center'})
            }
        
        # Step 2 — Remove user from all groups
        # This revokes all access permissions immediately
        # since group membership determines permission sets
        logger.info(f"Removing user {email} from all groups")
        
        remove_user_from_all_groups(identity_store_id, user_id)
        
        # Step 3 — Disable the user account
        # A disabled account cannot log in or receive new credentials
        # This happens immediately with no delay
        logger.info(f"Disabling user account: {email}")
        
        identitystore.update_user(
            IdentityStoreId=identity_store_id,
            UserId=user_id,
            Operations=[{
                'AttributePath': 'active',
                'AttributeValue': json.dumps(False)
            }]
        )
        
        # Step 4 — Log the offboarding action to CloudWatch
        log_audit_event(
            action='EMPLOYEE_OFFBOARDED',
            employee_email=email,
            user_id=user_id,
            status='SUCCESS'
        )
        
        logger.info(f"Offboarding completed successfully for {email}")
        
        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({
                'message': 'Employee offboarded successfully',
                'email': email,
                'user_id': user_id,
                'account_disabled': True
            })
        }
        
    except Exception as e:
        logger.error(f"Offboarding failed for {email}: {str(e)}")
        log_audit_event(
            action='EMPLOYEE_OFFBOARDING_FAILED',
            employee_email=email,
            status='FAILED',
            error=str(e)
        )
        return {
            'statusCode': 500,
            'body': json.dumps({'error': f'Offboarding failed: {str(e)}'})
        }


def get_user_id_by_email(identity_store_id, email):
    """
    Looks up a user in IAM Identity Center by their email address.
    Returns the user ID if found, None if not found.
    """
    try:
        response = identitystore.list_users(
            IdentityStoreId=identity_store_id,
            Filters=[{
                'AttributePath': 'UserName',
                'AttributeValue': email
            }]
        )
        
        if response['Users']:
            return response['Users'][0]['UserId']
        return None
        
    except Exception as e:
        logger.error(f"Failed to look up user {email}: {str(e)}")
        return None


def remove_user_from_all_groups(identity_store_id, user_id):
    """
    Removes a user from all IAM Identity Center groups.
    
    This revokes all permission sets associated with those groups
    which means the user immediately loses all AWS access.
    Group membership is how permission sets are assigned so
    removing group membership is equivalent to revoking access.
    """
    try:
        # Get all group memberships for this user
        response = identitystore.list_group_memberships_for_member(
            IdentityStoreId=identity_store_id,
            MemberId={'UserId': user_id}
        )
        
        memberships = response.get('GroupMemberships', [])
        logger.info(f"Found {len(memberships)} group memberships to remove")
        
        # Remove each membership
        for membership in memberships:
            identitystore.delete_group_membership(
                IdentityStoreId=identity_store_id,
                MembershipId=membership['MembershipId']
            )
            logger.info(f"Removed membership: {membership['MembershipId']}")
            
    except Exception as e:
        logger.error(f"Failed to remove group memberships: {str(e)}")
        raise


def log_audit_event(action, employee_email, status, 
                    user_id=None, error=None):
    """
    Writes an audit log entry to CloudWatch Logs for offboarding actions.
    Same log group as onboarding for unified audit trail.
    """
    
    log_group = os.environ.get('AUDIT_LOG_GROUP', '/innovatech/hr/audit')
    log_stream = f"offboarding/{datetime.utcnow().strftime('%Y/%m/%d')}"
    
    audit_entry = {
        'timestamp': datetime.utcnow().isoformat(),
        'action': action,
        'employee_email': employee_email,
        'status': status
    }
    
    if user_id:
        audit_entry['user_id'] = user_id
    if error:
        audit_entry['error'] = error
    
    try:
        try:
            cloudwatch.create_log_group(logGroupName=log_group)
        except cloudwatch.exceptions.ResourceAlreadyExistsException:
            pass
        
        try:
            cloudwatch.create_log_stream(
                logGroupName=log_group,
                logStreamName=log_stream
            )
        except cloudwatch.exceptions.ResourceAlreadyExistsException:
            pass
        
        cloudwatch.put_log_events(
            logGroupName=log_group,
            logStreamName=log_stream,
            logEvents=[{
                'timestamp': int(datetime.utcnow().timestamp() * 1000),
                'message': json.dumps(audit_entry)
            }]
        )
        
    except Exception as e:
        logger.error(f"Failed to write audit log: {str(e)}")