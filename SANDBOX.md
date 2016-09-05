# ScreenMeet Sandbox and Zendesk Setup

## Sandbox Account Setup

Before you can start developing with the ScreenMeet SDK, you will need to set up your developer account on our sandbox environment. This process should only take about a minute.

1. Open your browser, and go to https://sandbox.screenmeet.com/#/register

2. Fill out the required fields and create your account.

3. Click on "Settings" from the top menu.

4. Then click on "Personal URL"

5. The "Link ID" is your room id, which you can modify. The URL at which you will be viewing stream from your developer account is shown below the text input. It will be in the format:
`https://sandbox.screenmeet.com/[YOUR LINK ID]`.

## Configuring Zendesk Chat

In order to request screensharing from an end-user, we will need to associate your screenmeet developer account with your agent in Zendesk chat.

1. Log into the screenmeet sandbox https://sandbox.screenmeet.com/#/login

2. Click on "Settings" from the top menu.

3. Go to "Access Keys"

4. Create a new key.

5. Copy the new access key to your clipboard.

6. Open your Zendesk or Zopim agent chat UI

7. Go to Shortcuts

8. Create a new shortCut with the following message:

`requestScreenShare|YOURACCESSKEY`

eg:

`requestScreenShare|455a0uc2316ookwswsog48sk4s8sc00g4g8gocg08wgkw0sg8k`

9. This will be the message you send to an end-user to request access to their screen.
