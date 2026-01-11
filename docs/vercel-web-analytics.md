# Vercel Web Analytics Setup

This guide explains how Vercel Web Analytics is integrated into the GoPit web build and how to use it.

## Overview

GoPit is a Godot game exported to HTML/WebGL and deployed to Vercel. Vercel Web Analytics has been integrated to track user engagement and gameplay metrics.

## Prerequisites

Before you can use Vercel Web Analytics, you need:

- A Vercel account. If you don't have one, you can [sign up for free](https://vercel.com/signup).
- The GoPit project deployed to Vercel.
- The Vercel CLI installed:
  ```bash
  npm install -g vercel
  # or
  yarn global add vercel
  # or
  pnpm add -g vercel
  ```

## Implementation Details

### Custom HTML Shell

The GoPit web export uses a custom HTML shell template (`html/shell.html`) that includes the Vercel Web Analytics tracking script. This template is used when exporting the Godot game to HTML/WebGL.

The analytics integration consists of two lines added to the HTML:

```html
<!-- Vercel Web Analytics -->
<script>
  window.va = window.va || function () { (window.vaq = window.vaq || []).push(arguments); };
</script>
<script defer src="/_vercel/insights/script.js"></script>
```

### Export Configuration

The `export_presets.cfg` file specifies the custom HTML shell for both debug and release builds:

```ini
custom_template/debug="html/shell.html"
custom_template/release="html/shell.html"
```

## Enabling Web Analytics in Vercel

### Step 1: Enable Web Analytics on Your Project

1. Go to the [Vercel dashboard](https://vercel.com/dashboard)
2. Select your GoPit project
3. Click the **Analytics** tab
4. Click **Enable** from the dialog

> **Note:** Enabling Web Analytics will add new routes (scoped at `/_vercel/insights/*`) after your next deployment.

### Step 2: Deploy to Vercel

Deploy your project with the web analytics enabled:

```bash
vercel deploy
```

Or if you've connected your Git repository to Vercel, simply push to your main branch and Vercel will deploy automatically.

### Step 3: Verify Analytics Collection

After deployment:

1. Visit your GoPit game at `https://go-pit.vercel.app` (or your custom domain)
2. Play the game for a bit
3. Open your browser's Network tab (DevTools)
4. Look for requests to `/_vercel/insights/view` - you should see fetch/XHR requests as you interact with the game

### Step 4: View Your Data

Once the game has been played by users:

1. Go to your [Vercel dashboard](https://vercel.com/dashboard)
2. Select your GoPit project
3. Click the **Analytics** tab
4. After a few days of visitors, you'll be able to explore your data by viewing and filtering the panels

## What Gets Tracked

Vercel Web Analytics automatically tracks:

- **Page views** - Each time a user loads the game
- **Core Web Vitals** - Performance metrics like LCP, FID, CLS
- **User interactions** - General browser and game interactions
- **Device and browser information** - To understand your audience

## Privacy & Compliance

Vercel Web Analytics is designed with privacy in mind:

- No cookies are used for tracking
- Data is collected from the browser but anonymized
- GDPR and CCPA compliant
- No personal information is collected

For more details, see [Vercel's privacy policy](https://vercel.com/legal/privacy-policy).

## Next Steps

Now that you have Vercel Web Analytics set up, you can:

1. **Monitor gameplay** - See how many players are engaging with GoPit
2. **Identify performance issues** - Use Web Vitals to spot slow page loads
3. **Track deployment impact** - See how new versions affect player engagement
4. **Analyze user behavior** - Understand which features are most popular

## Troubleshooting

### Analytics Not Appearing

If you don't see any analytics data after deployment:

1. **Check that Web Analytics is enabled** on your Vercel project dashboard
2. **Clear browser cache** - The script might be cached from before analytics was enabled
3. **Use incognito mode** - Test in a fresh browser session
4. **Check Network tab** - Verify that `/_vercel/insights/view` requests are being sent

### Build Issues

If the web export fails to build:

1. Ensure the custom HTML shell is in the correct location: `./html/shell.html`
2. Verify that `export_presets.cfg` correctly points to the shell template
3. Try rebuilding the web export in the Godot editor

## More Information

For more details about Vercel Web Analytics, visit the [official documentation](https://vercel.com/docs/analytics).
