# OSHW Mark Generator

This web service was created by [Capable Robot Components](http://capablerobot.com) to simplify the generation of OSHW marks, after certification is complete. Certification process information is available on the [OSHWA Website](https://certification.oshwa.org/).

If you have suggestions on how to make this tool more useful, please create an issue in this GitHub repo, or email us at robot@capablerobot.com

Follow [Capable Robot on Twitter](http://twitter.com/capablerobot) for product announcements and updates.

## Usage

The service is available at [oshwmark.capablerobot.com](http://oshwmark.capablerobot.com)

[![Web Service Screenshot](ext/screenshot.png?raw=true)](http://oshwmark.capablerobot.com)

After entering your certification's two digit country code and number, the service will generate PDF or PNG versions of the OSHW Mark.

![Example Mark](ext/OSHW_mark_US000000.png?raw=true)

The service does not use cookies and no tracking of usage is enabled.  The service is hosted on [Heroku](http://heroku.com) and here is their [privacy policy](https://www.salesforce.com/company/privacy/).

## Heroku Notes

PNG creation requires a newer version of ImageMagick than is installed on Heroku.  To upgrade from 6.9.7 to 7.0.5, run:

```
heroku buildpacks:add --index 1 https://github.com/osterwood/heroku-buildpack-imagemagick-7.0.8.git
git push heroku master
```

The first deployment after this command will take a while as ImageMagick will be downloaded and installed.  Later deploys will use a cached copy.  This ImageMagick buildpack builds without WMF, DJVU, GVC, autotrace, etc.

## Attribution

The OSHW Certification Logo (or Mark) is trademarked by the OSHWA.  There is more information about why and what that means on the [OSHWA website](https://www.oshwa.org/2018/07/09/oshwa-certification-logo-is-official/).

The typeface is Deja Vu Sans Mono, which is freely licensed and available at [https://dejavu-fonts.github.io](https://dejavu-fonts.github.io).

The source code for this webservice is MIT Licensed.