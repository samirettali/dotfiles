---
name: spotify
description: Search and play Spotify music, inspect listening history and top items, manage the playback queue, and create or edit playlists with spotctl. Use when the user asks to find or play music; inspect their top tracks, top artists, or recent listening history; manage a playlist; add music to the queue; or inspect what is queued.
compatibility: Requires spotctl, Spotify OAuth authentication, and Spotify Premium for queue operations.
---

# Spotify

Use `spotctl` for Spotify searches, listening statistics, queue operations, and playlist management. Its stdout is JSON; errors are JSON on stderr.

## Before using it

Check that authentication is configured:

```sh
spotctl auth status
```

If `authenticated` is false, ask the user to run:

```sh
spotctl auth login --client-id THEIR_SPOTIFY_CLIENT_ID
```

Top items require `user-top-read`; recent history requires `user-read-recently-played`. If either scope is absent from `auth status`, ask the user to authenticate again with the same command. Do not request a client secret. `spotctl` uses OAuth Authorization Code with PKCE.

## Resolve items safely

Search before mutating when the user supplied a title rather than an exact Spotify URI, URL, or ID:

```sh
spotctl search --type track --limit 10 "track and artist"
spotctl search --type album --limit 10 "album and artist"
spotctl search --type artist --limit 10 "artist"
spotctl search --type playlist --limit 10 "playlist"
```

Use IDs or URIs from the JSON response. Match both title and artist; do not blindly select the first result when several plausible matches exist. Ask the user to choose if intent remains ambiguous.

Items may be passed as a Spotify URI, an `open.spotify.com` URL, or a bare track ID.

## Listening statistics

Inspect the user's top tracks or artists:

```sh
spotctl top tracks --time-range short_term --limit 50
spotctl top artists --time-range medium_term --limit 50
spotctl top tracks --time-range long_term --limit 50 --offset 50
```

Valid time ranges are `short_term` (approximately 4 weeks), `medium_term` (approximately 6 months), and `long_term` (several years). The limit is 1-50; use `--offset` to paginate.

Inspect recently played tracks:

```sh
spotctl history recent --limit 50
spotctl history recent --before UNIX_TIMESTAMP_MS
spotctl history recent --after UNIX_TIMESTAMP_MS
```

Recent history returns at most 50 tracks per request. Use the millisecond values in the response's `cursors` object with `--before` or `--after`; the two options cannot be combined.

Spotify does not expose extended or lifetime streaming history through its Web API. If the user wants complete listening statistics, direct them to request Extended Streaming History from Spotify's account privacy page and download the archive from the emailed link.

## Playback

Play a track, episode, album, artist, or playlist on the active Spotify device:

```sh
spotctl play track spotify:track:TRACK_ID
spotctl play episode spotify:episode:EPISODE_ID
spotctl play album spotify:album:ALBUM_ID
spotctl play artist spotify:artist:ARTIST_ID
spotctl play playlist spotify:playlist:PLAYLIST_ID
```

If Spotify reports that no device is active, list available devices and retry with the intended device ID:

```sh
spotctl device list
spotctl play album --device DEVICE_ID spotify:album:ALBUM_ID
```

When several devices are available and the user's intended device is not evident, ask them which one to use. Do not select an integrated or third-party player merely because it appears first.

## Queue

Inspect the current queue:

```sh
spotctl queue get
```

Append a track or episode:

```sh
spotctl queue add spotify:track:TRACK_ID
spotctl queue add --device DEVICE_ID spotify:track:TRACK_ID
```

Adding requires Spotify Premium and an active playback device. Spotify's API cannot remove, clear, replace, or reorder queue entries. State that limitation instead of attempting a workaround unless the user asks for one.

## Playlists

List the user's playlists or inspect one:

```sh
spotctl playlist list
spotctl playlist get PLAYLIST_ID
```

Create a playlist:

```sh
spotctl playlist create --name "NAME" --description "DESCRIPTION"
spotctl playlist create --name "NAME" --public
```

Update metadata. Boolean values must be explicit:

```sh
spotctl playlist update PLAYLIST_ID --name "NEW NAME"
spotctl playlist update PLAYLIST_ID --description "NEW DESCRIPTION"
spotctl playlist update PLAYLIST_ID --public=true
spotctl playlist update PLAYLIST_ID --collaborative=false
```

Add or remove up to 100 tracks or episodes per request:

```sh
spotctl playlist add PLAYLIST_ID spotify:track:TRACK_ID spotify:track:OTHER_ID
spotctl playlist remove PLAYLIST_ID spotify:track:TRACK_ID
```

Delete/unfollow a playlist:

```sh
spotctl playlist delete PLAYLIST_ID
```

Spotify implements playlist deletion as unfollowing. Before deleting a playlist or removing items, confirm the target and summarize the destructive change unless the user's request already identifies both unambiguously.

## Operating rules

- Run only the mutations the user requested; do not add related tracks automatically.
- Preserve the order given by the user when adding multiple items.
- Report what changed using names and artists, not only opaque IDs.
- If a command fails with `403`, explain that Spotify application access, scopes, ownership, or Premium requirements may be responsible.
- If a command fails with `404`, re-check the item type and ID before retrying.
- Never expose access or refresh tokens in responses or command output.
