
# Microsoft OAuth2 Environment Configuration

This file provides environment-specific configuration details for integrating an application with **Microsoft's OAuth2.0 authentication system**. It is typically used to authorize access to Microsoft APIs (e.g., Microsoft Graph) with delegated permissions.

## Purpose

The purpose of this configuration is to define credentials and parameters required to initiate and manage the **OAuth2 Authorization Code Flow** for a Microsoft identity provider.

## Structure and Fields

```json
{
  "credentials": {
    "type": "microsoft",
    "providerConfig": {
      "tenant": "{{tenantId}}"
    },
    "clientid": "{{client_id}}",
    "redirecturi": "{{redirectUri}}",
    "scope": "offline_access mail.read",
    "secretKey": "{{client_secret}}",
    "granttype": "authorization_code",
    "urlparams": "prompt=select_account"
  }
}
```

### Field Breakdown

| Field                   | Description                                                                                                                                                            |
| ----------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `type`                  | Indicates the type of identity provider. Here, it's set to `"microsoft"` for Microsoft Entra ID (Azure AD).                                                            |
| `providerConfig.tenant` | The Microsoft Entra tenant ID or domain (e.g., `contoso.onmicrosoft.com`) that the authentication flow targets.                                                        |
| `clientid`              | The application's **Client ID** registered in the Microsoft Entra ID App Registrations.                                                                                |
| `REDIRECTURI`           | The URI to which Microsoft will redirect after a user completes authentication. This must match the redirect URI registered in the app.                                |
| `scope`                 | The OAuth2 scope(s) being requested. Here, `offline_access` allows for refresh tokens, and `mail.read` grants read access to the user's mailbox via Microsoft Graph.   |
| `secretKey`             | The application's **Client Secret** used to authenticate with the Microsoft token endpoint.                                                                            |
| `granttype`             | The OAuth2 grant type used. `"authorization_code"` is used when exchanging a one-time authorization code for access/refresh tokens.                                    |
| `urlparams`             | Optional URL parameters to modify the authentication prompt behavior. In this case, `prompt=select_account` ensures users are prompted to choose an account each time. |

## Usage

This file is typically loaded into an application that:

* Presents a login button to the user
* Redirects them to the Microsoft login page
* Handles the redirect with the authorization code
* Exchanges the code for access and refresh tokens using this configuration

## Notes

* Fields wrapped in `{{ }}` are placeholders and should be replaced with actual values in a deployment environment.
* This configuration is useful in server-side web apps, API services, and integrations with Microsoft 365 services.
