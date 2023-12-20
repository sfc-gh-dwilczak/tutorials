# Okta - Snowflake.

Images to come soon.
```
Signup for okta
	- Create a user with your email in snowflake. IT HAS TO BE IN QUOTES. Example - create user 'daniel.wilczak@snowflake.com';
	- Go to admin page on top right navbar.
	- Go to application on left sidebar.
	- Click browse app catalog.
	- Find snowflake and add it.
	- Add your subdoin https:<THIS NAME>snowflakecomputing.com
	- Get your metadata URL from sign on tab.
	- Get: 
		○ entityID=
			§ This is your SAML2_ISSUER
		○ SingleSignOnService / Location
			§ This is your SAML2_SSO_URL
		○ SAML2_X509_CERT
			§ This is your SAML2_X509_CERT
		○ Additional inputs for entering into snowflake
			§ SAML2_SP_INITIATED_LOGIN_PAGE_LABEL = OKTA SSO
			§ SAML2_ENABLE_SP_INITIATED = TRUE;
			§ SAML2_PROVIDER = OKTA
			§ TYPE = SAML2
			§ ENABLED = TRUE 
			§ saml2_snowflake_acs_url = ' https://<Account>.snowflakecomputing.com/fed/login';
			§ saml2_snowflake_issuer_url = ' https://<account>.snowflakecomputing.com';


	- Create the security integration in snowflake with the information above:
		
			


create security integration <name>
  TYPE = saml2
  ENABLED = true
  SAML2_ISSUER = 'entityID'
  SAML2_SSO_URL = 'smal2_sso_url'
  SAML2_PROVIDER = OKTA
  SAML2_X509_CERT = 'LONGER ASS CERTIFICATE'
  saml2_snowflake_acs_url = ' https://<Account>.snowflakecomputing.com/fed/login';
  saml2_snowflake_issuer_url = ' https://<account>.snowflakecomputing.com';
```