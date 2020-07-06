# Github Release to Deb

A project to easily grab released binaries from a github repository and package them into a deb

It works by
1. Grabbing the list of tags/releases from a github repo
1. Download a released asset file from the repo releases
1. Build a debian changelog formatted file from the contents of CHANGELOG.md(If it exists, otherwise try and guess from the github releases)
1. Execute the `dpkg-buildpakcage` command

# How to use:

## Define environment variables
Define your environment variables in: `./github_project_vars`

Available Variables:

| Variable | Description | Required |
|---       | ---         | ---      |
| `GITHUB_URL` | The GITHUB URL where the project is you want to debianize | **True** |
| `GITHUB_OWNER` | Override the owner of the github project/repo instead of pulling out of the URL | **False** |
| `GITHUB_PROJECT_NAME` | Override the name of the github project instead of pulling out of the URL | **False** |
| `GITHUB_ASSET_FILE` | This is the destination file/resultant thing we care about from the download. Defaults to the `GITHUB_PROJECT_NAME` | **Fase** |
| `GITHUB_RELEASE_ASSET_TMPLT` | Template of the name of the release asset to download. Currently `{version}` and `{tag}` are the only substitutions allowed. Example: `yet-another-cloudwatch-exporter_{version}_Linux_x86_64.tar.gz`. If not defined then `GITHUB_PROJECT_NAME` is used | **False** |
| `GITHUB_ASSET_ARCHIVE_EXTRACT_FILE` | File inside of a compressed archive that should be extracted and renamed to `GITHUB_ASSET_FILE`. Not needed if the `GITHUB_RELEASE_ASSET_TMPLT` is not a tar archive. | **False** |
| `CHANGELOG_EMAIL` | Set the email to use for the debian changelog entries. Default is `none@example.com`. | **False** |
| `CHANGELOG_AUTHOR` | Set the author name for debian changelog entries. Default is `Anonymous`. | **False** |
| `PACKAGE_NAME` | Override the default package name in the changelog. Default is `GITHUB_PROJECT_NAME`. | **False** |
| `PACKAGE_DESCRIPTION` | Override the default description for the debian package from the GITHUB repo URL. Default is the github repository's description | **False** |

## Execute the build
Execute the build with:
```
cicd/build.sh <optional version>
```

## Manual
General process is to do the following:
1. Source the environment vars file: `. ./github_project_vars`
1. Run the `./get_release <Optional version>` script, redirecting it's stdout to debian/changelog, If no version is specific then the latest version is auto-discovered from the github project. This will also create a file `./release.env` with input and populated release info.
1. Copy the copyright doc into place: `cp docs/LICENSE debian/copyright`
1. Generate an appropriate `./debian/changelog`
1. Generate an appropriate `./debian/install`
1. Run `dpkg-buildpackage -us -uc`
