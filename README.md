# BR-CLI (Work In Progress)
BRCLI is a Backup &amp; Restore CLI. It's built for self hosted VPS with EasyEngine for WP websites.

## Installation
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

### v 1.1.0 — 2016-10-09
- NEW: Better space management
- NEW: Remove SITE or SITE_NAME backups by default

### v 1.0.0 — 2016-10-02
- NEW: Backup all sites to Dropbox
- NEW: Restore all sites from Dropbox

---

		### 🙌 [WPCOUPLE PARTNERS](https://WPCouple.com/partners):
		This open source project is maintained by the help of awesome businesses listed below. What? [Read more about it →](https://WPCouple.com/partners)

		<table width='100%'>
			<tr>
				<td width='333.33'><a target='_blank' href='https://www.gravityforms.com/?utm_source=WPCouple&utm_medium=Partner'><img src='http://on.ahmda.ws/mtrE/c' /></a></td>
				<td width='333.33'><a target='_blank' href='https://kinsta.com/?utm_source=WPCouple&utm_medium=Partner'><img src='http://on.ahmda.ws/mu5O/c' /></a></td>
				<td width='333.33'><a target='_blank' href='https://wpengine.com/?utm_source=WPCouple&utm_medium=Partner'><img src='http://on.ahmda.ws/mto3/c' /></a></td>
			</tr>
			<tr>
				<td width='333.33'><a target='_blank' href='https://www.sitelock.com/?utm_source=WPCouple&utm_medium=Partner'><img src='http://on.ahmda.ws/mtyZ/c' /></a></td>
				<td width='333.33'><a target='_blank' href='https://wp-rocket.me/?utm_source=WPCouple&utm_medium=Partner'><img src='http://on.ahmda.ws/mtrv/c' /></a></td>
				<td width='333.33'><a target='_blank' href='https://blogvault.net/?utm_source=WPCouple&utm_medium=Partner'><img src='http://on.ahmda.ws/mtph/c' /></a></td>
			</tr>
			<tr>
				<td width='333.33'><a target='_blank' href='http://cridio.com/?utm_source=WPCouple&utm_medium=Partner'><img src='http://on.ahmda.ws/mtmy/c' /></a></td>
				<td width='333.33'><a target='_blank' href='http://wecobble.com/?utm_source=WPCouple&utm_medium=Partner'><img src='http://on.ahmda.ws/mtrW/c' /></a></td>
				<td width='333.33'><a target='_blank' href='https://www.cloudways.com/?utm_source=WPCouple&utm_medium=Partner'><img src='http://on.ahmda.ws/mu0C/c' /></a></td>
			</tr>
			<tr>
				<td width='333.33'><a target='_blank' href='https://www.cozmoslabs.com/?utm_source=WPCouple&utm_medium=Partner'><img src='http://on.ahmda.ws/mu9W/c' /></a></td>
				<td width='333.33'><a target='_blank' href='https://wpgeodirectory.com/?utm_source=WPCouple&utm_medium=Partner'><img src='http://on.ahmda.ws/mtwv/c' /></a></td>
				<td width='333.33'><a target='_blank' href='https://www.wpsecurityauditlog.com/?utm_source=WPCouple&utm_medium=Partner'><img src='http://on.ahmda.ws/mtkh/c' /></a></td>
			</tr>
			<tr>
				<td width='333.33'><a target='_blank' href='https://mythemeshop.com/?utm_source=WPCouple&utm_medium=Partner'><img src='http://on.ahmda.ws/n3ug/c' /></a></td>
				<td width='333.33'><a target='_blank' href='https://www.liquidweb.com/?utm_source=WPCouple&utm_medium=Partner'><img src='http://on.ahmda.ws/mtnt/c' /></a></td>
				<td width='333.33'><a target='_blank' href='https://WPCouple.com/contact?utm_source=WPCouple&utm_medium=Partner'><img src='http://on.ahmda.ws/mu3F/c' /></a></td>
			</tr>
		</table>
		
