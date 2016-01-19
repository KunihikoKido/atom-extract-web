# extract-web package

Extract content from web pages, including link URLs, image URLs and entire web page contents.

![overview](https://raw.githubusercontent.com/KunihikoKido/atom-extract-web/master/screenshots/overview.gif)


## Commands

* _Extract Web: Extract Link URLs_
 * Extracts all the URLs from links in the target page.
* _Extract Web: Extract Image URLs_
 * Extracts all the URLs from images in the target page.
* _Extract Web: Extract Contents_
  * Extracts the HTML content of the target page to a JSON or YAML document. Requires a URL list.


## Settings

* User-Agent:
  * Valid values: `android`, `chrome`, `googlebot`, `ie`, `ios`, `opera`, `safari`
  * Default value: `chrome`
* Accept-Language:
  * Default value: `en`
* Extract URL Pattern:
  * Filters the URLs returned by the `Extract Link URLs` and `Extract Image URLs` commands using a regular expression.
  * Default: `https?://.+`
* Extract Contents Config Path:
  * The location of a JSON file that determines the setting used by the ``Extract Contents`` command. An example is included in the package as `default-config.json`.
  * Default value: `extract-web/default-config.json`
* Extract Contents Output Format:
  * Determines the format of the output of the ``Extract Contents`` command.
  * Valid values: `json`, `yaml`
  * Default value: `json`
* JSON Indent Size
  * Sets the indentation used in the output for the ``Extract Contents`` command when it is in JSON mode.
  * Default value: `2`
* YAML Indent Size
  * Sets the indentation used in the output for the ``Extract Contents`` command when it is in YAML mode.
  * Default value: `2`

## Customizing the output of the Extract Contents command
The Extract Contents command outputs a JSON or YAML document containing an array of objects. Each extracted web page is represented by a JSON/YAML object in this array.

The `properties` object for each extracted web page contains an array of properties extracted from the web page.

If you want to customize the properties extracted from each item, prepare a configuration file similar to the example below. Properties to extract are specified using CSS syntax.

**Example:**
```json
{
  "target": [
    {
      "pattern": {
        "url": "https://atom.io/packages/.*"
      },
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
        },
        "domain": {
          "default": "atom.io"
        }
      }
    }
  ]
}
```

## Screenshots
### Extract Contents

![Extract Contents Screenshot](https://raw.githubusercontent.com/KunihikoKido/atom-extract-web/master/screenshots/extract_contents.gif)
