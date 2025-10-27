# TABLE OF CONTENTS
1. [TABLE OF CONTENTS](#table-of-contents)
2. [CutElementIntegration](#cutelementintegration)
   1. [Description](#description)
3. [Getting started](#getting-started)
   1. [Git](#git)
   2. [.zip](#zip)
   3. [Matlab](#matlab)
4. [Integrator testing](#integrator-testing)
   1. [Running regression tests](#running-regression-tests)
   2. [Updating reference solutions](#updating-reference-solutions)
   3. [Test structure](#test-structure)
5. [Framework development](#framework-development)
   1. [Framework unit tests](#framework-unit-tests)
   2. [Include an additional code](#include-an-additional-code)
6. [Codes included](#codes-included)
7. [License](#license)
8. [Acknowledgments](#acknowledgments)

# CutElementIntegration

## Description

This repo provides benchmark test for routines that integrate over elements cut by an arbitrary interface. The interface may be defined implicitly by a level set function or parametrically by a NURBS curve.
The included codes for integrating over cut elements are either provided as a static version in a folder or as a submodule. A list of provided codes can be seen in ``release_files.txt``, with a respective ``README*.md`` file in the folder ``\codes``.
The technical details to set up the framework are shown in [Getting started](#getting-started)

# Getting started

Two ways to obtain the code are distinguished in the following:
* Clone with git from github (public) or gitlab (private)
* Download .zip from github or zenodo

## Git

Note for Windows users: getting the submodules may fail when the passphrase is not remembered. Try running start-ssh-agent before calling the following lines in the same terminal.

If you have access to the public repository, clone with:

```
git clone git@github.com:B2-M/CutElementIntegration.git
```

In order to initialize all codes properly, it is recommended to run ``init_submodules.sh``. In order to execute this file, double-click on Windows or use ``run init_submodules.sh`` on Linux. Afterwards, the intialized submodules can be updated recursively with Git.

An alternative way of initialization is to use the following git command:
```
git submodule update --progress --init
```

Not all submodules might be available to all users due to individual restrictions. Therefore, the following command could be used alternatively which explicitly updates certain codes:
````
git.exe  submodule update --progress --init -- "codes/fcmlab/fcmlab" "codes/algoim/matlabalgoimwrapper" "codes/quahog/quahog"
````

The ``--progress`` option prints additional information regarding the updating progress.

## .zip

If the code is obtained as .zip, the open-source git repositories linked as submodules are not available. Please use the git version of our code if you want to use the submodules.

## Matlab

### Requirements

**Required MATLAB Toolboxes:**
- **Symbolic Math Toolbox** - Required for reference solution computation in certain test cases

These toolboxes can be installed via MATLAB's Add-On Explorer (Home > Add-Ons > Get Add-Ons).

**Note:** `StartUpCall` will check for required toolboxes and warn if any are missing.

### Setup

Within matlab
 - navigate to the CutElementIntegration folder
 - run ``StartUpCall`` to add all mandatory paths and check the accessibility of the different integrators (provided in the ``\codes`` folder)
 ```
StartUpCall
```

**Note on Integrator Availability:**
Not all integrators may be accessible on your system. `StartUpCall` will report which integrators are available based on:
- Installed dependencies (Python packages, Julia, .NET, etc.)
- Platform compatibility (some integrators are Windows or Linux-only)
- Initialized git submodules (see [Git setup](#git))
- Individual access restrictions

Having only a subset of integrators available is **normal and expected**. The framework will work with any accessible integrators. Check individual README files in `codes/[integrator]/` for specific setup requirements.

See the ``\codes`` folder for adding integration tools and the ``\examples`` folder for setting up test cases.

### Exploring Examples

To interactively explore all available test case examples, use:
```matlab
queryExampleDetails()           % Show all examples
queryExampleDetails('circle')   % Quick search
queryExampleDetails('Category', 'AreaComputation2D')  % Filter by category
```

This tool provides detailed information about each example including test case IDs, interface IDs, categories, and source code line numbers.

# Integrator testing

The framework includes regression tests that verify integrator outputs remain consistent with reference solutions.

> **Important:** These tests only compare current runs with previously obtained results. They **cannot assess the quality of the results** - quality validation is the **responsibility of the user**.

## Running regression tests

To run all example regression tests:
```matlab
runExampleTests
```

To run a specific test for all integrators:
```matlab
testsuite = testExampleChanges_AreaComputation2D;
run(testsuite,"checkForChanges_example_circle_1");
```

To run a specific test for a specific integrator:
```matlab
testsuite = testExampleChanges_AreaComputation2D;
testsuite.integrator_names={'Fcmlab'};
run(testsuite,"checkForChanges_example_circle_1");
```

## Test structure

Every examples subfolder has a ``testExampleChanges_*.m`` class that provides
- the ``runTestCoverage`` function that ensures every example in the subfolder has a corresponding test file, and
- ``checkForChanges_*`` functions that run a test execution of the given example

The reference solutions are stored in the corresponding subfolders ``results_ref/``. Per test case and integrator there shall be only one reference solution within these folders.

The ``runExampleTests.m`` script is the main function that runs all testExampleChanges_*.m classes.

## Updating reference solutions

When you want to update the reference solutions for an integrator (e.g., because you made improvements), use:

**Update all reference solutions for an integrator:**
```matlab
updateExampleTestsResultsRef('Fcmlab')
```

**Update reference solutions for a specific test suite:**
```matlab
updateExampleTestsResultsRef('Fcmlab', 'testExampleChanges_InterfaceComputation2D')
```

**Update a specific test case within a test suite:**
```matlab
updateExampleTestsResultsRef('Fcmlab', 'testExampleChanges_InterfaceComputation2D', ...
    'checkForChanges_example_circle_1')
```

**Preserve existing reference solutions (do not replace):**
```matlab
updateExampleTestsResultsRef('Fcmlab', 'testExampleChanges_InterfaceComputation2D', [], false)
```

**Parameters:**
- `integrator_name` - Name of the integrator (required)
- `testsuite_name` - Name of the test suite class (optional, default: all test suites)
- `testcase_name` - Name of specific test case method (optional, default: 'all' tests in suite)
- `bReplaceExistingResultsRef` - Replace existing reference solutions (optional, default: `true`)
  - `true`: Deletes old reference solutions and replaces with new ones
  - `false`: Keeps existing reference solutions, skips update if reference already exists

**Important:** If two or more reference solutions for one integrator for one test are stored, the test will fail.

### Platform-specific reference solutions

For integrators that produce different results on Windows and Linux (e.g., due to numerical precision differences), you can provide platform-specific reference solutions.
The test framework automatically selects the appropriate reference file based on the current platform (`ispc` for Windows, `isunix` for Linux).

This is an exception to the general rule stated in [Test structure](#test-structure) that each test case should have only one reference solution. It is implemented as follows:

**Naming Convention:**
- Windows reference: `filename_IntegratorName-Windows.csv`
- Linux reference: `filename_IntegratorName-Linux.csv`

**Requirements:**
1. Platform keywords (`-Windows` or `-Linux`) must be added **manually** by renaming the files
2. Exactly **one Windows** and **one Linux** reference file must be provided
   - Do not keep a third file without platform keyword - this will break detection




# Framework development

## Framework unit tests

To run framework infrastructure tests (validates utility functions, project structure, and test case configurations):
```matlab
runtests('utilities/framework-unittests')
```

Or use the comprehensive test runner with coverage report:
```matlab
runAllFrameworkTests
```

## Include an additional code

This section outlines the procedure to include an additional integrator:

* Add a new folder ``new_code`` in ``codes/``
* Add a git submodule if the code should be linked as git repository
* Add a Integrator class in ``codes/`` that inherits from ``AbstractIntegrator``
* Write a README in ``codes/new_code/``
* Register the Integrator with its name in ``utilities/integrator-management/getAccessibleIntegrators.m``

# Codes included

The included codes for integrating over cut elements are collected in the ``codes/`` folder. They are either provided as a static version in a folder or as a submodule. Please check the README files in the corresponding subfolders for integrator-specific details.

# License

The test environment the 3-Clause BSD License (https://opensource.org/license/bsd-3-clause). 

Further, the test environment relies on the Octave NURBS package under the GNU General Public License.

For the licenses of the integration codes, see the license files in the corresponding subfolders.

# Acknowledgments
The work is supported by the joint DFG/FWF Collaborative Research Centre CREATOR (DFG: Project-ID 492661287/TRR 361; FWF: 10.55776/F90) at TU Darmstadt, TU Graz and JKU Linz. 