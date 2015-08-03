# extract-web package

Extract Website for Atom.

![overview](https://raw.githubusercontent.com/KunihikoKido/atom-extract-web/master/screenshots/overview.gif)


## Commands

* Extract Web: Extract Link Urls
* Extract Web: Extract Image Urls
* Extract Web: Extract Contents


## Settings

* User-Agent:
  * android, chrome, googlebot, ie, ios, opera, safari
  * default: chrome
* Accept-Language:
  * default: en
* Extract URL Pattern:
  * Settings for ``Extract Link Urls`` and ``Extract Image Urls`` commands
  * default: https?://.+
* Extract Contents Config Path:
  * Settings for ``Extract Contents`` command.
  * default: extract-web/default-config.json
* Extract Contents Output Format:
  * Settings for ``Extract Contents`` command.
  * json, yaml
  * default: json

## Customize Extract Contents
If you want to customize the extracted item you want is to prepare a configuration file to reference the following examples.

**Example:**
```json
{
  "properties": {
    "title": {
      "text": "title"
    },
    "body": {
      "text": "body"
    },
    "bodyAsHtml": {
      "html": "body"
    },
    "package_meta": {
      "text": ".package-meta ul li a",
      "isArray": true
    },
    "meta_description": {
      "attr": "meta[name=description]",
      "args": ["content"]
    }
  }
}
```

## Screenshots
### Extract Contents

![Extract Contents Screenshot](https://raw.githubusercontent.com/KunihikoKido/atom-extract-web/master/screenshots/extract_contents.gif)
