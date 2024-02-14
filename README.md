# CalVer Increment and Tag

This GitHub Action automatically increments and tags the latest commit with
a [Calendar Versioning (CalVer)](http://calver.org/) scheme in the format `Year.Month.Increment`

_Year_ is the two or four digit year (2023 or 23)

_Month_ is the month excluding padding (1..12)

_Increment_ is the number that's incremented per commit and resets to 0 at the start of every month

## Inputs

| Name                | Description                                                     | Required | Default | Options              |
| ------------------- | --------------------------------------------------------------- | -------- | ------- | -------------------- |
| `GITHUB_TOKEN`      | Your GitHub Token to allow the action to create tags            | yes      |         |                      |
| `YEAR_FORMAT`       | Format of the year value, eg. <br> `YYYY` = 2024 <br> `YY` = 24 | no       | `YYYY`  | `YYYY` <br> `YY`     |
| `INITIAL_INCREMENT` | Initial increment value                                         | no       | `0`     | Any positive integer |

## Outputs

| Name      | Description                                           |
| --------- | ----------------------------------------------------- |
| `NEW_TAG` | The new tag auto-incremented using the CalVer action. |

## Usage

To use this GitHub Action in your workflow, you can include the following step in your workflow configuration
file (`.github/workflows/calver.yml`):

```yaml
name: CalVer increment and tag
on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: "0"

      - name: Increment and tag with CalVer
        uses: mani-sh-reddy/calver-increment@v1.2.0
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          YEAR_FORMAT: "YY"
```

## Using the `GITHUB_TOKEN` in a workflow

At the start of each workflow job, GitHub automatically creates a unique `GITHUB_TOKEN` secret to use in your workflow. You can use the `GITHUB_TOKEN` to authenticate in the workflow job.

You can use the `GITHUB_TOKEN` by using the standard syntax for referencing secrets: `${{ secrets.GITHUB_TOKEN }}`. Examples of using the `GITHUB_TOKEN` include passing the token as an input to an action, or using it to make an authenticated GitHub API request.

ref: _[Automatic token authentication](https://docs.github.com/en/actions/security-guides/automatic-token-authentication)_

## License

This GitHub Action is released under the MIT License. See the License File for more details.

## Contributing

If you would like to contribute to this project, please follow the Contribution Guidelines.

## Support

If you encounter any issues or have questions about this GitHub Action, please open an issue in the GitHub repository.

## Acknowledgments

This action is based on the idea of Calendar Versioning (CalVer) and is inspired by other versioning and release
automation actions in the GitHub Marketplace.
