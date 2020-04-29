== get-all ==

The `get-all` script orchestrates the process of making scheduled or
on-demand archiving of websites or data tables accessible through the web.

Usage: get-all [--sync] [--data] [--web] [SLUG...]

--sync: transmit the current data store on this node to the destination server
--data: only capture data tables (or tables matching the slug patterns)
--web: only capture web pages (or web pages matching the slug patterns)

To retrieve a subset of the scheduled web page or data sources, use one or
more prefixes or regular expressions for SLUG. If you have sites called
adph, adphtable, adphdash, adphdata1, etc., then this will retrieve them
all:

	get-all adph

If you want to only retrieve "adph" and not the others beginning with the
"adph" prefix, use a regular expression with the end-of-string operator `$`:

	get-all 'adph$'


