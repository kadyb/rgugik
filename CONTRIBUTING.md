
# CONTRIBUTING

No matter your current skills, it’s possible to contribute to the `rgugik`.
We appreciate any contribution and collaboration.

## Bugs

If you’ve found a bug, first create a minimal reproducible example using the [reprex](https://www.tidyverse.org/help#reprex) package.
Spend some time trying to make it as minimal as possible, this will facilitate the task and speed up the entire process.
Next submit an issue on the [Issues page](https://github.com/kadyb/rgugik/issues).

## Contributions

### Fixing typos

You can fix typos, spelling mistakes, or grammatical errors in the documentation.
We use [roxygen2](https://roxygen2.r-lib.org/), so the documentation should be generated using `.R` files, not by editing the `.Rd` files directly.

### Bigger changes

If you want to make a bigger change, it's a good idea to first file an issue and make sure someone from the team agrees that it’s needed.
We don’t want you to spend a bunch of time on something that we don’t think is a good idea.

Once accepted, you can follow pull request process:

1. Fork this repo to your GitHub account.
2. Clone your version on your account down to your machine from your account, e.g,. `git clone https://github.com/kadyb/rgugik.git`.
3. Make sure to track progress upstream (i.e., on our version of `rgugik` at `kadyb/rgugik`) by doing `git remote add upstream https://github.com/kadyb/rgugik.git`. 
Before making changes make sure to pull changes in from upstream by doing either `git fetch upstream`, then merge later or `git pull upstream` to fetch and merge in one step.
4. Make your changes (make changes on a new branch).
5. If you alter package functionality at all (e.g., the code itself, not just documentation) please do write some tests to cover the new functionality.
6. Push up to your account.
7. Submit a pull request to home base at `kadyb/rgugik`.

We use [testthat](https://testthat.r-lib.org/) for unit tests. Contributions with test cases included are prioritized to accept.

Please make sure that your new code and documentation matches the existing style.
We use [lintr](https://github.com/jimhester/lintr) for static code analysis (i.a. code style).

## Questions

Questions can be asked on [Issues page](https://github.com/kadyb/rgugik/issues).
Adding a reproducible example may make it easier to answer.

## Thanks for contributing!
