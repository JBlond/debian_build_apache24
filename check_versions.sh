#!/usr/bin/env bash
# Compares the versions pinned in build_apache.sh with the latest upstream releases.
# Set GITHUB_TOKEN to avoid GitHub API rate limits.
set -u

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_SCRIPT="${1:-$DIR/build_apache.sh}"

get_current() {
	sed -n "s/^$1=\"\([^\"]*\)\".*/\1/p" "$BUILD_SCRIPT" | head -n1
}

auth=()
[[ -n "${GITHUB_TOKEN:-}" ]] && auth=(-H "Authorization: Bearer ${GITHUB_TOKEN}")

# Latest GitHub release tag, prefix stripped by the given sed expression
github_latest() {
	curl -fsSL "${auth[@]}" "https://api.github.com/repos/$1/releases/latest" \
		| sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n1 | sed "$2"
}

# Latest GitHub tag (for projects without releases)
github_latest_tag() {
	curl -fsSL "${auth[@]}" "https://api.github.com/repos/$1/tags?per_page=100" \
		| sed -n 's/.*"name": *"\([^"]*\)".*/\1/p' | sed "$2" | grep -E '^[0-9]+(\.[0-9]+)*$' | sort -V | tail -n1
}

# Latest version from an Apache directory listing
apache_latest() {
	curl -fsSL "https://dlcdn.apache.org/$1/" \
		| grep -oE "$2-[0-9]+(\.[0-9]+)*\.tar\.gz\"" | sed -E "s/^$2-(.*)\.tar\.gz\"/\1/" | sort -V | tail -n1
}

outdated=0
check() {
	local name="$1" var="$2" latest="$3" current
	current="$(get_current "$var")"
	if [[ -z "$latest" ]]; then
		printf '%-12s current=%-10s latest=?          [CHECK FAILED]\n' "$name" "$current"
		return
	fi
	if [[ "$current" == "$latest" ]]; then
		printf '%-12s current=%-10s latest=%-10s [OK]\n' "$name" "$current" "$latest"
	else
		printf '%-12s current=%-10s latest=%-10s [UPDATE AVAILABLE]\n' "$name" "$current" "$latest"
		outdated=$((outdated + 1))
	fi
}

check openssl  SSL_VERSION    "$(github_latest openssl/openssl 's/^openssl-//')"
check httpd    HTTPD_VERSION  "$(apache_latest httpd httpd)"
check apr      APR_VERSION    "$(apache_latest apr apr)"
check apr-util APRU_VERSION   "$(apache_latest apr apr-util)"
check apr-iconv APRI_VERSION  "$(apache_latest apr apr-iconv)"
check zlib     ZLIB_VERSION   "$(github_latest madler/zlib 's/^v//')"
check pcre2    PCRE2_VERSION  "$(github_latest PCRE2Project/pcre2 's/^pcre2-//')"
check nghttp2  HTTP2_VERSION  "$(github_latest nghttp2/nghttp2 's/^v//')"
check nghttp3  HTTP3_VERSION  "$(github_latest ngtcp2/nghttp3 's/^v//')"
check ngtcp2   NGTCP2_VERSION "$(github_latest ngtcp2/ngtcp2 's/^v//')"
check jansson  JANSON_VERSION "$(github_latest akheron/jansson 's/^v//')"
check curl     CURL_VERSION   "$(github_latest curl/curl 's/^curl-//; s/_/./g')"
check brotli   BROTLI_VERSION "$(github_latest google/brotli 's/^v//')"
check mod_zstd ZSTD_VERSION   "$(github_latest_tag nono303/mod_zstd 's/^v//')"

echo
if ((outdated > 0)); then
	echo "$outdated component(s) have newer versions."
	exit 1
fi
echo "All checked components are up to date."
