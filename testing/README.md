# OPS <Application Name>

# Issues
# How to fix instance-profile that's already create outside terraform
aws iam list-instance-profiles --region eu-west-1 | grep app-name
aws iam delete-instance-profile --instance-profile-name app-name-profile.qa --region eu-west-1
aws iam delete-instance-profile --instance-profile-name app-name-profile-1.qa --region eu-west-1
