# VerifiX — Field Verification Network

A premium Flutter prototype for banking field-agent verification. Connects financial institutions with verified field agents who perform on-site loan/document verification.

**Demo only** — uses mock data throughout. No real banking APIs, payments, or backend integration.

## Demo Flow

1. **Login** — Enter any 10-digit mobile number, tap Continue, then enter OTP `1234` (or leave blank)
2. **Dashboard** — View earnings, stats, and nearby jobs
3. **Jobs** — Browse available jobs with search/filters; view Active, Submitted, Completed tabs
4. **Accept & Verify** — View job details → Accept → Start verification workflow
5. **Verification** — Complete 6 steps: Applicant → Identity → Address → Media → Questions → Submit
6. **Earnings** — View dashboard, charts, transaction history, withdraw (demo sheet)
7. **Profile** — Agent info, KYC status, settings

## Run

```bash
flutter pub get
flutter run
```

### Android build fails with `ConnectException: Operation timed out`?

Some Mac setups (often VPN apps like Clash/Surge) route Java through a broken SOCKS proxy. Gradle downloads then fail even though `curl` works.

**Quick fix — use the helper script:**

```bash
chmod +x run_android.sh
./run_android.sh
```

**Or export these before `flutter run`:**

```bash
export JAVA_TOOL_OPTIONS="-Djava.net.useSystemProxies=false -DsocksProxyHost= -DsocksProxyPort="
export GRADLE_OPTS="-Djava.net.useSystemProxies=false -DsocksProxyHost= -DsocksProxyPort="
flutter run
```

**If Gradle still can't download**, bootstrap it via curl (one-time):

```bash
chmod +x scripts/bootstrap_gradle.sh
./scripts/bootstrap_gradle.sh
./run_android.sh
```

Also try disabling your VPN/proxy temporarily during the first build.

## Architecture

- **State management:** Riverpod
- **Navigation:** go_router with bottom nav shell
- **Charts:** fl_chart
- **Typography:** Google Fonts (Inter)

```
lib/
├── core/          # theme, router, widgets, utils
├── data/          # models, mock services, providers
└── features/      # auth, dashboard, jobs, verification, earnings, profile, notifications
```

## Tech Stack

| Package | Purpose |
|---------|---------|
| flutter_riverpod | State management |
| go_router | Navigation |
| google_fonts | Typography |
| fl_chart | Earnings charts |
| shimmer | Skeleton loaders |
| image_picker | Camera capture |
| flutter_animate | Entrance animations |
