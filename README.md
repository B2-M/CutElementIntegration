# TABLE OF CONTENTS
1. [TABLE OF CONTENTS](#table-of-contents)
2. [CutElementIntegration](#cutelementintegration)
   1. [Description](#description)
   2. [Publications](#publications)
3. [Getting started](#getting-started)
   1. [Git](#git)
   2. [Matlab](#matlab)
   3. [Unit tests](#unit-tests)
   4. [Codes included](#codes-included)
4. [License](#license)
5. [Acknowledge](#acknowledge)

# CutElementIntegration

## Description

This repo provides benchmark test for routines that integrate over elements cut by an arbitrary interface. The interface may be defined implicitly by a level set function or parametrically by a NURBS curve.
The included codes for integrating over cut elements are either provided as a static version in a folder or as a submodule. A list of provided codes can be seen in ``release_files.txt``, with a respective ``README*.md`` file in the folder ``\codes``.
The technical details to set up the framework are shown in [Getting started](#getting-started)

# Getting started

## Git

Note for Windows users: getting the submodules may fail when the passphrase is not remembered. Try running start-ssh-agent before calling the following lines in the same terminal

```
git clone git@github.com:B2-M/CutElementIntegration.git
git submodule add https://gitlab.lrz.de/cie_sam_public/fcmlab.git  codes/fcmlab/fcmlab
```

or

```
git clone git@github.com:B2-M/CutElementIntegration.git
git submodule update --progress --init
```

Not all submodules might be available to all users due to individual restrictions. Therefore, the following command could be used alternatively which explicitly updates certain codes:
````
git.exe  submodule update --progress --init -- "codes/fcmlab/fcmlab" "codes/algoim/matlabalgoimwrapper" "codes/quahog/quahog"
````

The ``--progress`` option prints additional information regarding the updating progress.

In order to initialize all codes properly, it is recommended to run ``init_submodules.sh``. Afterwards, the intialized submodules can be updated recursively with Git.

## Matlab

Within matlab
 - navigate to the CutElementIntegration folder
 - run ``StartUpCall`` to add all mandatory paths and check the accessibility of the different integrators (provided in the ``\codes`` folder)
 ```
StartUpCall
```

See the ``\codes`` folder for adding integration tools and the ``\examples`` folder for setting up test cases.

To delete all stored results locally in the machine call

# Unit tests

To run all unit tests call:
 ```
runExampleTests
```

To run a specific test for all integrators run e.g.,
```
testsuit = testExampleChanges_AreaComputation2D;
run(testsuit,"checkForChanges_example_circle_1");
```

To run a specific test for a specific integrator run e.g.,
```
testsuit = testExampleChanges_AreaComputation2D;
testsuit.integrator_names={integrator_name};
run(testsuit,"checkForChanges_example_circle_1");
```

When you want to update the reference solutions of all tests for an integrator (e.g. because you made some improvements) call
```
updateExampleTestsResultsRef( integrator_name )
```

If two or more references for one integrator for one test are stored, the test fails.


### Structure

Every examples subfolder has a ``testExampleChanges_*.m`` class that provides 
- the ``runTestCoverage`` function that checks if all examples in the subfolder are having a test, and
- ``checkForChanges_*`` functions that make a test run of an example

The reference solutions are stored in the corresponding subfolders ``results_ref/``. Per test case and integrator there shall be only one reference solution within these folders.

The ``runExampleTests.m`` script is the main function that runs all testExampleChanges_*.m classes.

### Warning

The unit tests only compare the current run with previously obtained results. They cannot assess the **quality of the results**. This is the **responsibility of the user**.

# Codes included 

The included codes for integrating over cut elements are collected in the codes/ folder. They are either provided as a static version in a folder or as a submodule. Please check the README files in the corresponding subfolders for integrator-specific details.

# License

The test environment the 3-Clause BSD License (https://opensource.org/license/bsd-3-clause). 

Further, the test environment relies on the Octave NURBS package under the GNU General Public License.

For the licenses of the integration codes, see the license files in the corresponding subfolders.

# Acknowledgments
The work is supported by the joint DFG/FWF Collaborative Research Centre CREATOR (DFG: Project-ID 492661287/TRR 361; FWF: 10.55776/F90) at TU Darmstadt, TU Graz and JKU Linz. 