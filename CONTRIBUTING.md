
# CONTRIBUTING

No matter your current skills, it’s possible to contribute to the `rgugik` package.
We appreciate any contribution no matter the amount.

## Bugs

If you’ve found a bug, please create a minimal reproducible example using the [reprex](https://www.tidyverse.org/help#reprex) package first.
Spend some time trying to make it as minimal as possible, this will facilitate the task and speed up the entire process.
Next, submit an issue on the [Issues page](https://github.com/kadyb/rgugik/issues).

## Contributions

### Fixing typos

You can fix typos, spelling mistakes, or grammatical errors in the documentation.
We use [roxygen2](https://roxygen2.r-lib.org/), so the documentation should be generated using `.R` files, not by editing the `.Rd` files directly.

### Greater changes

If you want to make a greater change, it's a good idea to file an issue first and make sure someone from the team agrees that it’s needed.
We don’t want you to spend a bunch of time on something that we don’t think is a suitable idea.

Once accepted, you can follow the pull request process:

1. Fork this repo to your GitHub account.
2. Clone your version to your machine, e.g., `git clone https://github.com/kadyb/rgugik.git`.
3. Make sure to track progress upstream (i.e., our version of `rgugik` at `kadyb/rgugik`) by doing `git remote add upstream https://github.com/kadyb/rgugik.git`. 
Before making any changes, make sure to pull changes in from upstream by either doing `git fetch upstream` then merge later, or `git pull upstream` to fetch and merge in one step.
4. Make your changes (make changes to a new branch).
5. If you alter package functionality at all (e.g., the code itself, not just documentation) please do write some tests to cover the new functionality.
6. Push changes to your account.
7. Submit a pull request to the master branch at `kadyb/rgugik`.

We use [testthat](https://testthat.r-lib.org/) for unit tests. Contributions with test cases included are prioritized to accept.

Please make sure that your new code and documentation match the existing style.
We use [lintr](https://github.com/jimhester/lintr) for static code analysis (i.e., code style).

## Questions

Questions are welcomed on the [Issues page](https://github.com/kadyb/rgugik/issues).
Adding a reproducible example may make it easier for us to answer.

## Thanks for contributing!
