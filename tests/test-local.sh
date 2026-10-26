#!/usr/bin/env bash
# Read-only checks of depends-on.sh against real repositories: no statuses, no comments.
set -euo pipefail
DEPENDS_ON_REPOSITORY="armbian/build"
# shellcheck source=/dev/null
source "${DEPENDS_ON_SCRIPT:-${HOME}/armbian-actions/depends-on/depends-on.sh}"

echo "== parse"
body="$(
	cat << 'EOF'
Some text
Depends-on: #11108
  depends-on: armbian/configng#1067 released
```
Depends-on: #1 inside a fence
```
> Depends-on: #2 quoted
Depends-on: git https://github.com/torvalds/linux.git v7.3
Notify-when: git https://github.com/torvalds/linux.git contains "genirq/kexec" in master after v7.3
EOF
)"
parse_lines depends-on <<< "${body}"
echo "-- notify-when"
parse_lines notify-when <<< "${body}"

echo "== check"
while IFS= read -r dep; do
	check_condition "${dep}"
	printf '%-75s -> %s: %s\n' "${dep}" "${dep_state}" "${dep_reason}"
done <<'EOF'
#11108
#11120
#99999999
armbian/configng#1067
armbian/configng#1066 released
armbian/build#11108 in main
https://github.com/armbian/build/pull/10929
iav/armbian#307
armbian/build#11108 sideways
git https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git v7.2.13
git https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git v9.9
git https://github.com/torvalds/linux.git 5b6e2a46b80d1234567890123456789012345678 in master
git https://github.com/armbian/build.git 08f004762cbfb966ddf8bbf66b01c9ba89757b63 in main
git https://github.com/armbian/build.git v26.8.1 in main
git --upload-pack=touch${IFS}/tmp/pwned v1
git https://example.com/x -v
git ext::sh v1
EOF
