# Campus Reports

A Flutter mobile app for African Leadership University students to report campus problems (broken facilities, water, electricity, furniture, sanitation, safety, internet) and follow them until they are fixed. Campus staff review the reports and update their status, and students see every change live.

## Features

**Students**
- Register and log in with an ALU email address only; the account must be verified through an email link before the app opens
- Submit a report with a title, category, location and description, an optional photo (camera or gallery), optionally anonymously
- Browse all reports as cards with a photo, place, time ("2 hours ago") and a small status badge; search by title, description or location, and filter by status or category; see their own reports in **My reports**
- See a summary of their own reports on Home (Total, Submitted, In progress, Resolved)
- Edit their name on the Profile tab
- Open a report to see its details, the latest staff note and a live progress timeline
- Delete their own report while it is still "Submitted"

**Staff**
- Browse, search and filter every report (staff do not submit reports; only students do)
- A Staff tab with report counts per status and the open reports, oldest first
- Change a report's status (In review, In progress, Resolved, Rejected) with a note for the student; rejecting requires a reason
- Every change is saved in the report's history

## Tech stack

| Part | Used for |
| --- | --- |
| Flutter (Dart) | Mobile app for Android and iOS |
| Firebase Authentication | Email/password accounts and email verification |
| Cloud Firestore | Users, reports and status history, with live updates |
| Cloudinary | Incident photos (free image hosting, see below) |
| Provider | State management (`AuthProvider`, `IncidentProvider`) |

**Why Cloudinary for photos:** since February 2026, Cloud Storage for Firebase only works on the paid Blaze plan, and the course allowed other cloud services for images. Photos are uploaded to Cloudinary with an *unsigned upload preset* (`campus_reports`), so the app never contains a secret key. Cloudinary returns an https link, which is saved in the report's `photoUrl`. Only `lib/services/storage_service.dart` talks to Cloudinary, so switching storage services changed one file.

## Project structure

```text
lib/
  main.dart              starts Firebase and registers the providers
  models/                AppUser, Incident, StatusUpdate
  services/              the only code that talks to Firebase and Cloudinary
  providers/             app state + logic; screens listen to these
  screens/
    auth/                AuthGate, login, register, verify email
    home/                MainShell (bottom navigation), reports list
    incidents/           new report, report details
    staff/               staff dashboard
    profile/             profile and logout
  widgets/               reusable pieces (IncidentCard, StatusChip, ...)
  utils/                 constants, validators, error messages, filters
test/                    unit and widget tests
firestore.rules          Firestore security rules
```

Screens never call Firebase directly: **screen → provider → service → Firebase**. Updates come back through Firestore streams, and the providers call `notifyListeners()` so the screens rebuild.

## Firestore data

| Collection | One document per | Main fields |
| --- | --- | --- |
| `users/{uid}` | account | `name`, `email`, `role` (`student` or `staff`), `createdAt` |
| `incidents/{id}` | report | `title`, `description`, `category`, `location`, `status`, `photoUrl`, `photoPath`, `reporterId`, `reporterName`, `isAnonymous`, `staffNote`, `createdAt`, `updatedAt` |

Photos are stored on Cloudinary in the `incident_photos` folder with unguessable ids. `photoPath` holds the Cloudinary id, and each photo is tagged with its reporter's uid so misuse can be traced.
| `incidents/{id}/updates/{id}` | status change | `status`, `note`, `updatedBy`, `updatedByName`, `updatedAt` |

Statuses: `submitted` → `in_review` → `in_progress` → `resolved` (or `rejected`).

## Access control

- The role comes from the email at sign-up: ALU staff addresses (`@alueducation.com`) become **staff**, other ALU addresses (`@alustudent.com`) become **students**. There is no role picker in the app.
- An admin can also change a role by hand in the Firestore console (`users` → `role`). The app listens to the profile live, so the change shows straight away.
- The Staff tab and status controls only appear for staff, and the + button only for students. `firestore.rules` enforces the same on the server: only verified ALU users can read reports, only students can create reports, only staff can change a status (and only the status fields), students can only delete their own reports before staff act, and nobody can change their own role or rewrite history.

## How to run

**Prerequisites:** Flutter SDK, an Android emulator, and a Firebase project with Email/Password sign-in and Firestore enabled.

```bash
git clone https://github.com/lilianeuwase2/campus_reporting_app.git
cd campus_reporting_app
flutter pub get
flutterfire configure   # only if you use your own Firebase project
```

Copy `firestore.rules` into Firebase Console → Firestore Database → Rules and click **Publish**.

Then run the app with `flutter run`. Photos upload to Cloudinary (cloud `vekht7dk`, preset `campus_reports`); to use your own account, change `cloudinaryCloudName` and `cloudinaryUploadPreset` in `lib/utils/constants.dart`.

**To test as staff:** register with an `@alueducation.com` email, or register a second student account, verify it, and change its `role` to `staff` in Firestore → `users`. The Staff tab appears by itself.

## Tests

```bash
flutter test
```

- `test/widget_test.dart`: email and password validators
- `test/incident_filters_test.dart`: search and filter logic
- `test/status_chip_test.dart`: status labels shown to users
- `test/roles_test.dart`: which emails become staff
- `test/formatters_test.dart`: "2 hours ago" times and small photo links

## Limitations

- Deleting a report does not delete its photo on Cloudinary: deleting needs Cloudinary's secret key, which must never be inside a mobile app. A small server (for example a Cloud Function) could do it.
- Anyone who finds the preset name could upload images to the Cloudinary account. The preset only allows uploads into one folder, never overwrites, and gives every file an unguessable id.
