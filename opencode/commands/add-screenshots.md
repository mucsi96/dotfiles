---
description: Upload screenshots with the GitHub CLI attachments API and add them to an MR
---

Using the gh CLI attachments API, add screenshots to the MR (pull request on GitHub).

Use $ARGUMENTS for the PR number or URL and screenshot paths, with optional captions. Otherwise identify the PR and screenshots from the current conversation or the current branch using gh. Ask for clarification if the target PR or screenshots are ambiguous or missing.

Resolve the PR's base repository, number, URL, and existing body using gh. Use that repository explicitly for all API calls, including when the PR comes from a fork. Check gh authentication and confirm each screenshot exists, is readable, and has an image MIME type. This upload endpoint requires repository write access and is not supported on GitHub Enterprise Server.

Upload each screenshot's raw bytes using gh api and the GitHub attachments endpoint. For github.com, use this request shape, substituting the resolved values:

```sh
gh api --method POST \
  "https://uploads.github.com/user-attachments/assets?name=<URL-encoded-filename>&content_type=<URL-encoded-image-MIME-type>&repository_id=<numeric-repository-id>" \
  -H 'Accept: application/vnd.github+json' \
  -H 'Content-Type: application/octet-stream' \
  --input "$screenshot_path" \
  --jq '.url'
```

Get the numeric repository ID with `gh api repos/OWNER/REPO --jq '.id'`. URL-encode query values with a proper URL encoder, and quote file paths so spaces and special characters work. Let gh handle authentication. Use the URL returned by the API; require a nonempty HTTPS URL before embedding it. The request shape follows the [GitHub CLI attachment uploader](https://github.com/cli/cli/blob/trunk/internal/attachments/client.go).

Keep a record of successful uploads and their paths so a retry can reuse them. If any upload fails, report the error and successful upload URLs, and stop before editing the PR body.

Read the latest PR body again after uploading. Preserve its existing text and screenshots, then append the uploaded images under a Screenshots heading (or extend the existing section). Use descriptive, Markdown-escaped alt text and optional captions, with before/after labels when appropriate. Avoid adding duplicate URLs. Write the complete updated body to a temporary UTF-8 file and apply it with `gh pr edit NUMBER --repo OWNER/REPO --body-file PATH`.

Read the PR back with gh and verify that all intended attachment URLs appear and the previous body content is preserved. If the edit fails, retain the uploaded URLs for retry. Report the PR URL and the screenshots added, or the precise blocker if the workflow could not finish.
