# AWS credentials saved to server
mkdir ~/.aws
printf "[default]\naws_access_key_id={AWS_CREDENTIALS.AWS_ACCESS_KEY}\naws_secret_access_key={AWS_CREDENTIALS.AWS_SECRET_ACCESS_KEY}\n" >> ~/.aws/credentials
printf "[default]\nregion={AWS_CREDENTIALS.AWS_REGION}\noutput=json\n" >> ~/.aws/config
