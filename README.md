# CalVer Increment and Tag

This GitHub Action automatically increments and tags the latest commit with
a [Calendar Versioning (CalVer)](http://calver.org/) scheme in the format `Year.Month.Increment`

Where:

_Year_ is the full four digit year (2023)

_Month_ is the month excluding padding (1..12)

_Increment_ is the number that's incremented per commit and resets to 0 at the start of every month

## Inputs

#### `github-token` 
**Required**: Your GitHub Token to allow the action to create tags.


## Outputs

#### `new_tag`
New tag auto-incremented using the CalVer action.

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
        fetch-depth: '0'

    - name: Increment and tag with CalVer
      uses: mani-sh-reddy/calver-increment@v1.1.0
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## License

This GitHub Action is released under the MIT License. See the License File for more details.

## Contributing

If you would like to contribute to this project, please follow the Contribution Guidelines.

## Support

If you encounter any issues or have questions about this GitHub Action, please open an issue in the GitHub repository.

## Acknowledgments

This action is based on the idea of Calendar Versioning (CalVer) and is inspired by other versioning and release
automation actions in the GitHub Marketplace.
