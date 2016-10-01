# BR-CLI (Work In Progress)
BRCLI is a Backup &amp; Restore CLI. It's built for self hosted VPS with EasyEngine for WP websites.

##Installation
To install `brcli` run the following command in your Mac's terminal.
```bash
wget -qO brcli https://git.io/vPqty && sudo chmod +x ./brcli && sudo install ./brcli /usr/local/bin/brcli
```

## Usage
Usage: brcli `[ -b |--backup ]`, `[ -ba | --backup_all ]`, `[ -r | --resotre ]`, `[ -ra | --restore-all ]`, and `[ -h | help ]`"
 - `[ -h | help ]` Usage help."
 - `[ -b | --backup ]` Takes backup of a particular site & its databases."
 - `[ -ba | --backup_all ]` Takes backup of all sites & their databases in /var/www/ except html and 22222 folders."
 - `[ -r | --restore ]` Restores a particular site in /var/www/ as well as its database."
 - `[ -ra | --restore-all ]` Restores all sites in /var/www/ as well as their databases."

## Changelog
### 1.0.0 (2016-10-02)
- NEW: Backup all sites to Dropbox
- NEW: Restore all sites from Dropbox
