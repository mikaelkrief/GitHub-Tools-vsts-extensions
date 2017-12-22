## GitHub tools for Build and Release ##

This VSTS extension provide Build/Release tasks for tag GitHub commit and Create GitHub release.

### Tag GitHub commit ###

This task create a Tag on GitHub commit.

![githubtask](static/images/screen1.png)

Task parameters are:
 - The GitHub connection provided by GitHub service end point, see [GitHub service end-point details](https://github.com/mikaelkrief/GitHub-Tools-vsts-extensions/wiki/GitHub-Service-End-point)
 - The repository
 - The Commit SHA id
 - The Tag value
 

See the [Wiki page](https://github.com/mikaelkrief/GitHub-Tools-vsts-extensions/wiki/Tag-GitHub-commit) for more documentation.

### Create GitHub release ###

This task create a GitHub release based on tag.

![githubtask](static/images/screen2.png)

Task parameters are:
 - GitHub connection provided by GitHub service end point, see [GitHub service end-point details](https://github.com/mikaelkrief/GitHub-Tools-vsts-extensions/wiki/GitHub-Service-End-point)
 - The repository
 - The tag
 - The branch
 - The release name
 - Use the commit message or custom release note
 - Select the zip file to upload as asset release
 - Indicate if it's draft release
 - Indicate if it's pre release
 

See the [Wiki page](https://github.com/mikaelkrief/GitHub-Tools-vsts-extensions/wiki/Create-GitHub-release) for more documentation.

### Feedback ###
- Add a review below in Rating & Review section
