# Authentication and Ownership Plan

## Agreed scope

- Support self-service email/password signup, login, and logout.
- Do not include password reset in the first release.
- Projects are private to their creator; project sharing is out of scope.
- Remove the current Home and Work sample data.
- Add authenticated project and list creation so new accounts can use the app without seeded data.

## Current state

- The Rails 8 application has no user model, authentication, session handling, or authorization layer.
- Projects, items, and their audit trails are publicly accessible.
- Projects and lists are currently seeded; there are no project or list creation routes or forms.
- `ItemStateTransition` records state-machine events but not the actor who performed them.

## Data model

1. Enable `bcrypt` and add a UUID `users` table with a normalized, uniquely indexed email and `password_digest`.
2. Add `User#has_secure_password` and associations for owned projects, created items, and state transitions.
3. Add required, indexed foreign keys:
   - `projects.user_id` for the private project owner.
   - `items.creator_id` for the user who created the item. Project ownership alone cannot reliably answer this question.
   - `item_state_transitions.user_id` for the actor who performed each transition, including completion.
4. Enforce referential integrity with database foreign keys. User IDs must be assigned server-side and must not be accepted in request parameters.
5. Remove existing seeded records before enforcing the new required references. This assumes the existing Home and Work data is disposable.

## Authentication

1. Add signup, login, and logout routes, controllers, and views.
2. Store the authenticated user ID in the Rails session, resetting the session when logging in and out.
3. Add `current_user` and an authentication guard in `ApplicationController`.
4. Leave only signup, login, logout, and the `/up` health endpoint publicly accessible.
5. Add a compact account/sign-out control to the application layout and use the existing Tailwind/daisyUI design system for account forms.

## Authorization and attribution

1. Scope the project index and every project lookup through `current_user.projects`.
2. Scope nested list/item actions and the standalone item audit page through the current user's projects. A record belonging to another user must return `404`.
3. Set `creator_id` from `current_user` when creating an item.
4. Set the audit transition actor from `current_user` when the state machine completes an item. Implement this at the audit-record creation boundary so it remains correct regardless of the transition caller.
5. Show the item creator and transition actor in the audit timeline.

## Project and list creation

1. Add authenticated project create routes, controller action, and form.
2. Add authenticated list create routes, controller action, and form within a project.
3. Assign newly created projects to `current_user` server-side.
4. Preserve the existing Turbo item creation workflow after a user creates a project and list.

## Seed data

1. Remove the Home/Work seed records and their lists/items.
2. Update the empty-project UI so it directs a signed-in user to create their first project rather than running `db:seed`.

## Tests and verification

1. Add model tests for user validation/password authentication and ownership associations.
2. Add integration tests for signup, login, logout, and unauthenticated redirects.
3. Update existing project/item tests to authenticate a fixture user.
4. Verify user A cannot enumerate, view, create items in, update, or view audit trails for user B's projects.
5. Verify item creation stores the creator and item completion stores the transition actor.
6. Run the Rails test suite, RuboCop, and Brakeman after implementation.
