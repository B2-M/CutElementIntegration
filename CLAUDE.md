# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

CutElementIntegration is a MATLAB-based benchmark framework for testing numerical integration routines over elements cut by arbitrary interfaces. It supports multiple integration libraries and provides comprehensive testing capabilities for 2D and 3D cut-cell integration problems.

**📋 To explore all test cases, use the interactive query tool: `queryExampleDetails()`**

## Project Setup

### Initial Setup
Run `StartUpCall` in MATLAB to:
- Add all required paths to MATLAB path
- Set Python execution mode to OutOfProcess
- Initialize and check accessibility of all integrators

```matlab
StartUpCall
```

### Submodules
Initialize git submodules using:
```bash
./init_submodules.sh
```
Or manually:
```bash
git submodule update --progress --init
```

## Project Structure

The project follows a clear organizational hierarchy for enhanced maintainability and discoverability:

```
CutElementIntegration/
├── runExampleTests.m              # Main test runner (root level for easy access)
├── queryExampleDetails.m          # Interactive example query tool (root level)
├── StartUpCall.m                  # Framework initialization
├── framework-classes/             # Core framework class definitions
│   ├── AbstractIntegrator.m
│   ├── Domain.m, Interface.m
│   ├── QuadratureData.m, TestCase.m
│   └── LevelSetFunctionAndGradient.m
├── codes/                         # Integration library implementations
│   ├── *Integrator.m             # Integrator classes (inherit from AbstractIntegrator)
│   └── [library-name]/           # Library-specific implementations
├── examples/                      # Example problems by category
│   ├── AreaComputation2D/
│   ├── VolumeComputation3D/
│   └── [problem-type]/           # Each contains examples + test files
├── utilities/                     # Organized utility functions
│   ├── data-management/          # File I/O, data export, log management
│   ├── error-computation/        # Error analysis functions
│   ├── examples/                 # Example-related utilities
│   │   ├── geometry-templates/   # 2D/3D geometric primitives
│   │   ├── reference-solutions/  # Reference solutions for validation
│   │   └── runtests/            # Test execution helpers
│   ├── file-utilities/          # File operations, documentation tools
│   ├── framework-unittests/     # Framework validation tests
│   │   ├── helpers/              # Test helper functions (includes exportExampleReference)
│   │   └── reference-data/       # Reference data (test configs, example registry)
│   ├── integrator-management/   # Integrator discovery, construction, validation
│   └── visualization/           # Plotting, figure output, visualization
├── publications/                 # Paper-specific examples
└── nurbs-1.4.3/                 # NURBS geometry package
```

### Design Principles
- **Clear separation of concerns**: Classes, utilities, examples, and main functions are logically separated
- **Functional organization**: Utilities grouped by purpose rather than mixed together  
- **Enhanced discoverability**: Main entry points at root level, descriptive folder names
- **Professional structure**: Follows software engineering best practices for maintainability
- **Scalability**: Easy to add new categories and functionality

## Architecture

### Core Framework Classes (`framework-classes/`)
- **AbstractIntegrator**: Base class for all integration implementations, stores quadrature points and provides common interface
- **TestCase**: Complete integration test problem with domain, interface, integrand, reference solutions, and problem dimension
- **Domain**: Background computational domain/mesh where integration occurs
- **Interface**: Cutting geometry defined via either implicit level set functions OR parametric NURBS curves/surfaces
- **QuadratureData**: Stores quadrature points, weights, and computed integral values
- **LevelSetFunctionAndGradient**: Provides level set function φ(x) and gradient ∇φ(x) for implicit geometries

### Integration Libraries
The framework integrates multiple libraries located in `codes/`:
- **Algoim**: High-order quadrature for implicitly defined domains
- **BoSSS**: Discontinuous Galerkin framework
- **Fcmlab**: Finite Cell Method library
- **QUGaR**: Quadratures for Unfitted GeometRies (parametric NURBS-based trimming via reparametrization)
- **Gridap**: Grid-based approximation in Julia
- **Mlhp**: Multi-level hp-refinement
- **Ngsxfem**: NGSolve extended finite element method
- **Nutils**: Python-based numerical toolkit
- **Quahog**: Spectral element integration
- **QuahogPE**: Spectral polynomial enrichment
- **Queso**: Quadrature for embedded solids

### Example Categories
Examples are organized in `examples/` by problem type:
- **AreaComputation2D**: 2D area integration
- **AreaComputationMoving2D**: Moving geometry area integration
- **AreaViaFluxComputation2D**: Area via flux integration
- **IntegralComputation2D/3D**: General integral computation
- **InterfaceComputation2D/3D**: Interface length/area computation
- **VolumeComputation3D**: 3D volume integration
- **VolumeViaFluxComputation3D**: Volume via flux integration

### Publications
Paper-specific examples in `publications/`:
- **Paper_CIbenchenv4libs/**: Examples from CI benchmark environment paper
- **Paper_CutElemComp/**: Cut-element comparison paper examples with specialized plotting functions

## Common Development Commands

### Running Tests
```matlab
% Run all unit tests (from project root)
runExampleTests

% Run specific test suite
runExampleTests('unitTest', {'testExampleChanges_AreaComputation2D'})

% Run convergence study for all integrators
runExampleTests('convergenceStudy')

% Run tests for specific integrator
runExampleTests('unitTest', 'all', 'off', 'Algoim')

% Update reference solutions for an integrator
updateExampleTestsResultsRef('Algoim')

% Update reference solutions from GitLab CI runner results
% (useful for synchronizing local references with CI-computed results)
updateExampleTestsResultsRefByExistingFile('Algoim', 'AreaComputation2D', 'all', results_folder)
updateExampleTestsResultsRefByExistingFile('Algoim', 'AreaComputation2D', ...
    ["example_multiple_connected_curves","example_punched_plate"], results_folder)

% Run framework validation tests
runtests('utilities/framework-unittests')
```

### Running Examples
Each example category has h-refinement runners:
```matlab
% Navigate to specific example folder
cd examples/AreaComputation2D
runAreaComputation2D_h_refinement

cd ../VolumeComputation3D  
runVolumeComputation3D_h_refinement
```

### Checking Integrator Availability
```matlab
% Get all accessible integrators
integrators = getAccessibleIntegrators(3); % 3 quad points per direction

% Get integrators for specific dimension
integrators_2d = getAccessibleIntegrators(3, 2); % 2D problems only
```

### Finding and Exploring Examples
```matlab
% Interactive query tool - show all examples
queryExampleDetails()

% Quick search
queryExampleDetails('circle')

% Filter by category
queryExampleDetails('Category', 'AreaComputation2D')

% Find specific test case
queryExampleDetails('TestCaseId', 15)

% Find all 3D examples
queryExampleDetails('Dimension', 3)

% Get results for programmatic use
circleExamples = queryExampleDetails('circle');
```

### Example Registry Maintenance
```matlab
% Update reference after adding/modifying examples
exportExampleReference()

% Build ID map for programmatic access (used internally by queryExampleDetails)
idMap = buildExampleIdMap();  % All examples
idMap2D = buildExampleIdMap(2);  % 2D only
```

**Workflow for maintaining example definitions:**
1. Add or modify test cases in example files
2. Run `exportExampleReference()` to update the reference
3. Verify changes with `queryExampleDetails()`
4. Run `runAllFrameworkTests()` - includes automated validation
5. Commit updated `utilities/framework-unittests/reference-data/example_registry.mat`

## File Patterns

### Integrator Implementation
New integrators should:
1. Inherit from `AbstractIntegrator`
2. Be placed in `codes/` folder
3. Have corresponding README in subfolder
4. Be registered in `getAccessibleIntegrators.m`

### Test Cases
- Test functions: Any `.m` file returning TestCase object (commonly prefixed `example_*` by convention)
- Test classes: `testExampleChanges_*.m` for each example category
- Reference results: Stored in `results_ref/` subfolders  
- Runner scripts: `run*_h_refinement.m` for convergence studies

### Organized Utility Functions (`utilities/`)

**Data Management (`utilities/data-management/`)**
- File I/O: `getDataFromFile.m`, `deleteFilesInResultsFolders.m`, `getLogFileNames.m`
- Data export: `write_error_to_table.m`, `write_quaddata_to_table.m`
- Log management: `set_up_log_data.m`

**Error Computation (`utilities/error-computation/`)**
- Error analysis: `compute_abs_error.m`, `compute_rel_error.m`

**Examples (`utilities/examples/`)**
- Test case helpers: `getTestCase2D.m`, `getTestCase3D.m`, `getInterfaceCase2D.m`
- Geometry templates: `utilities/examples/geometry-templates/` (2D/3D geometric primitives)
- Reference solutions: `utilities/examples/reference-solutions/`
- Test execution: `utilities/examples/runtests/` (runExampleTests helper functions)

**File Utilities (`utilities/file-utilities/`)**
- File operations: `findfile.m`, `isCurrentFolderCorrect.m`
- Documentation: `AddDefaultHeader.m`, `defaultHeader.txt`
- Date/string utilities: `getDateStrFormat.m`, `isDateStrCorrect.m`

**Framework Unit Tests (`utilities/framework-unittests/`)**
- Infrastructure validation: `FrameworkTestSuite.m`, `InfrastructureTests.m`
- Structure validation: `StructureValidationTests.m`
- Interface testing: `IntegratorInterfaceTests.m`
- Test case validation: `TestCaseValidationTests.m`
- Utility testing: `UtilityFunctionTests.m`
- Test runner with coverage: `runAllFrameworkTests.m` - runs all tests and generates coverage reports
- Helper functions: `helpers/exportTestCase2DReferences.m`, `helpers/exportTestCase3DReferences.m`

**Integrator Management (`utilities/integrator-management/`)**
- Discovery: `getAccessibleIntegrators.m`, `getAllIntegratorNames.m`
- Construction: `callIntegratorConstructor.m`, `selectIntegrator.m`
- Validation: `checkIntegratorAvailability.m`, `isCompatibleWithPlatform.m`, `isCompatibleWithProblemDim.m`
- Management: `removeIntegrator.m`

**Visualization (`utilities/visualization/`)**
- Plotting: `plot_error_h_refinement.m`, `plot_domain.m`, `plot_quad_pts.m`, `plot_mesh.m`
- Configuration: `set_2D_plot_options.m`, `set_3D_plot_options.m`
- Output: `print_figure.m`, `save_video.m`

### Refactored Testing Architecture

The testing framework has been reorganized for enhanced clarity and maintainability:

**Main Test Runner (`runExampleTests.m` - Root Level)**
- Primary entry point for example regression testing
- Backward-compatible API maintained
- Orchestrates testing pipeline through modular helper functions
- Easily accessible from project root

**Test Execution Helpers (`utilities/examples/runtests/`)**
- `runExampleTests_parseParameters.m`: Input validation and default handling
- `runExampleTests_validateTestNames.m`: Test name validation and filtering
- `runExampleTests_resolvePlotSettings.m`: Plot configuration resolution
- `runExampleTests_buildConfigurations.m`: Test suite configuration building
- `runExampleTests_getIntegratorNames.m`: Integrator name resolution and validation
- `runExampleTests_createSuite.m`: MATLAB test suite creation
- `runExampleTests_executeSuite.m`: Test execution with progress reporting
- Additional utilities: `getTestFolderNames.m`, `getTestSuiteNames.m`, `updateExampleTestsResultsRef.m`, `updateExampleTestsResultsRefByExistingFile.m`
- `updateExampleTestsResultsRefByExistingFile.m`: Updates reference solutions by copying from existing result files (useful when new references have been computed on GitLab CI runner)

**Framework Infrastructure Tests (`utilities/framework-unittests/`)**
- Comprehensive test suite for framework reliability and maintenance
- `FrameworkTestSuite.m`: Main test runner for infrastructure validation
- `InfrastructureTests.m`: Core framework function testing
- `StructureValidationTests.m`: Project structure integrity validation
- `IntegratorInterfaceTests.m`: Integrator compliance and interface testing
- `TestCaseValidationTests.m`: Validates interface and test case configurations
  - Tests 2D/3D interface definitions (static and moving geometries)
  - Validates test case configurations against reference snapshots
  - Detects unintended changes to test definitions
  - Cross-validates implicit and parametric geometry representations
  - Use `exportTestCase2DReferences()` or `exportTestCase3DReferences()` to update references
- `UtilityFunctionTests.m`: Tests core utility functions
- Test helpers: `helpers/exportTestCase2DReferences.m`, `helpers/exportTestCase3DReferences.m`

## Key Dependencies

### NURBS Package (`nurbs-1.4.3/`)
Octave NURBS package (GNU GPL license) providing parametric geometry capabilities:
- Create NURBS curves/surfaces for complex cutting interfaces
- Alternative to level set functions for geometric representation
- Includes geometric primitives (circles, cylinders), operations (knot insertion, degree elevation), and B-spline functions

### Python Integration
Many integrators require Python with specific packages. Check individual README files in `codes/*/` for requirements.

### External Libraries
- Various MEX files for performance-critical operations
- Git submodules for open-source integration libraries

## Coding Standards

### File Headers
All MATLAB files (`.m`) must start with the standardized header from `utilities/file-utilities/defaultHeader.txt`. This header provides:
- BSD 3-Clause license information
- Copyright notice (© 2025, Graz University of Technology)
- List of contributors
- Required redistribution conditions

When creating new files or modifying existing ones, ensure the header is present and up-to-date. Use `utilities/file-utilities/AddDefaultHeader.m` to add headers automatically.

## Development Notes

### Adding New Test Examples
1. Create function returning TestCase object in appropriate `examples/` subfolder
2. Add corresponding test method in `testExampleChanges_*.m` class
3. Run test coverage check: `testsuite.runTestCoverage()` to verify detection
4. Generate reference solutions: `updateExampleTestsResultsRef('IntegratorName')`

### Adding New Integrators
1. Create folder in `codes/`
2. Implement class inheriting from `AbstractIntegrator` (located in `framework-classes/`)
3. Add README with setup instructions
4. Register in `utilities/integrator-management/getAccessibleIntegrators.m`
5. Add to unit test framework in `utilities/framework-unittests/`

### Test Development
- Unit tests compare against reference solutions stored in `results_ref/`
- Tests do not validate solution quality - only consistency
- Multiple reference solutions for same test/integrator cause test failure
- Use `updateExampleTestsResultsRef()` to update references after improvements

### Platform Compatibility
Framework supports Windows and Linux. Individual integrators may have platform restrictions checked via `isCompatibleWithPlatform()`.
- function name must be the same as the file name
- keep runExamplesTests in the root, distinguish between framwork-validation (unit test for the utilities functions)  and runExampleTests (main function to investigate the examples; the tests are regression test that only check if there is a change in outputs compared to previous runs )