Overview
============
DDColorPicker is a pod allowing colors to be picked from a color palette.
It allows for transparency and lightness to be altered with sliders.

It uses the delegate pattern to inform the calling class of the color selected.


Authors
============
The primary author of this library is Vasco d'Orey, but it is also maintained by other developers within Tasboa.

This project is part of a larger Tasboa project and it was built because we felt that there was a need for a beautiful color picker that was easier to use.

Contributing
============
If you want to contribute to the project please do:

1. Fork the project
2. Create a branch on your fork and make your changes
3. Request a pull request with your changes

*Any contributions to this project will be considered as licensed as MIT and right to define the license for all contributed code as transferred to Vasco Orey*

Versioning
============
This library aims to adhere to [Semantic Versioning 2.0.0][semver]. Violations
of this scheme should be reported as bugs. Specifically, if a minor or patch
version is released that breaks backward compatibility, that version should be
immediately yanked and/or a new version should be immediately released that
restores compatibility. Breaking changes to the public API will only be
introduced with new major versions. As a result of this policy, you can (and
should) specify a dependency on this gem using the [Pessimistic Version
Constraint][pvc] with two digits of precision. For example:

    'DDColorPicker', '~> 1.0'
