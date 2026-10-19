# Permissions step and notification toggles

Type: grilling
Status: open
Blocked by: 05

## Question

The onboarding Permissions step and the Settings notification toggles (Push, Email, Weekly summary) suggest the app asks for OS permissions and sends notifications. Real push needs FCM plus APNs keys, which is manual work. Decide:
- **Permissions:** which ones the step asks for on each platform, and what happens when the user grants or denies them.
- **Toggles:** what each one actually does in this boilerplate: stores the preference only, or delivers something?
- **Push:** how the app behaves before push is configured.

Use the Permissions and Settings designs in `.refs/design/`.
