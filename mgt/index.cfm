<script type="module">
  // Import necessary components and providers from Microsoft Graph Toolkit (MGT)
  import {
    registerMgtComponents,
    Providers,
    Msal2Provider
  } from 'https://unpkg.com/@microsoft/mgt@4';

  // Initialize Microsoft Graph Toolkit with MSAL2 Provider
  // Set up authentication using your Azure AD application's clientId and authority (tenant)
  Providers.globalProvider = new Msal2Provider({
    clientId: '[CLIENT_ID]', // Replace with your Azure AD application's client ID
    authority: 'https://login.microsoftonline.com/common', // Use 'common' for multi-tenant apps or specify your tenant ID
  });

  // Register all Microsoft Graph Toolkit web components
  registerMgtComponents();
</script>

<!-- Microsoft Graph Toolkit Components -->

<!-- Login component: displays sign-in/sign-out button and user info -->
<mgt-login></mgt-login>

<!-- Person component: displays information about the signed-in user -->
<mgt-person person-query="me"></mgt-person>
<br>

<!-- People Picker component: allows searching and selecting users from Microsoft Graph -->
<mgt-people-picker></mgt-people-picker>

<!-- Get component: fetches data from Microsoft Graph (here, user's mail messages) -->
<mgt-get resource="/me/messages" scopes="mail.read">
  <template>
    <!-- Display the fetched messages as formatted JSON -->
    <pre>{{ JSON.stringify(value, null, 2) }}</pre>
  </template>
</mgt-get>
