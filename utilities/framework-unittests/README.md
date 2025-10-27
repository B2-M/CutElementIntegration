# Framework Infrastructure Test Suite

This directory contains MATLAB unit tests for the CutElementIntegration framework infrastructure, designed to maintain and validate core framework functionality independent of specific integration examples.

## Purpose

The test suite validates:
- **Framework reliability** - Core functions work correctly as project evolves
- **Structure integrity** - Project structure and organization is maintained  
- **Interface compliance** - Integrators follow AbstractIntegrator contract
- **Utility functions** - Supporting utility functions work correctly

## Test Classes

### Main Test Suite
- **`FrameworkTestSuite.m`** - Main entry point with high-level framework tests

### Specialized Test Classes  
- **`InfrastructureTests.m`** - Tests core framework functions (`getAccessibleIntegrators`, `getTestSuiteNames`, etc.)
- **`StructureValidationTests.m`** - Tests project structure integrity (codes/ directory, file patterns, inheritance)
- **`IntegratorInterfaceTests.m`** - Tests integrator interface compliance and instantiation
- **`UtilityFunctionTests.m`** - Tests utility functions used throughout the framework

### Supporting Files
- **`runAllFrameworkTests.m`** - Runs all framework tests with code coverage analysis and generates HTML reports

## Important: Run from Project Root

**All framework tests must be run from the project root directory** (the directory containing the `codes/` folder). This ensures:
- Correct relative path resolution
- Proper access to framework functions
- Consistent test behavior across all platforms

Running tests from subdirectories will fail with a clear error message.

## Usage

### Run All Framework Tests
```matlab
% IMPORTANT: Must be run from project root directory
% (The directory containing codes/, examples/, utilities/, etc.)
runtests('utilities/framework-unittests')

% Or use convenience method
FrameworkTestSuite.runAllFrameworkTests();
```

### Run Specific Test Classes
```matlab
% Infrastructure tests
runtests('utilities/framework-unittests/InfrastructureTests');

% Structure validation tests
runtests('utilities/framework-unittests/StructureValidationTests');

% Integrator interface tests
runtests('utilities/framework-unittests/IntegratorInterfaceTests');

% Utility function tests
runtests('utilities/framework-unittests/UtilityFunctionTests');
```

### Run Individual Test Methods
```matlab
% Run specific test method
runtests('utilities/framework-unittests/InfrastructureTests', 'Name', 'testGetAccessibleIntegrators*');
```

## Test Categories

### 1. Framework Functions
- `getAccessibleIntegrators()` discovery and validation
- `getTestSuiteNames()` test suite discovery
- `isCurrentFolderCorrect()` directory validation
- Refactored function availability and correctness

### 2. Structure Validation
- codes/ directory contains only `*Integrator.m` files
- All integrator files inherit from `AbstractIntegrator`
- Essential directories exist (examples/, utilities/, etc.)
- Test class naming conventions

### 3. Integrator Interface
- Integrator instantiation and accessibility
- AbstractIntegrator interface compliance  
- Dimension compatibility (2D/3D filtering)

### 4. Utility Functions
- Supporting utility function correctness
- Error handling and input validation
- Cross-platform compatibility

## Key Features

### Parameterized Testing
Tests run with multiple quadrature point values (3, 5, 7) to ensure robustness across different configurations.

### Robust Error Handling
Tests gracefully handle integrators that may not be available on all platforms or configurations.

### Enforced Project Root Execution
Tests enforce execution from the project root directory using `isCurrentFolderCorrect()`, preventing relative path issues and ensuring consistent behavior.

### Code Coverage
Use `runAllFrameworkTests()` to analyze test coverage and identify areas needing additional testing. This generates both test results and code coverage HTML reports.

## Test Philosophy

These tests focus on **framework maintainability** rather than integration accuracy:

✅ **Test the framework, not the physics** - Verify infrastructure works, not integration results  
✅ **Independent of examples** - Framework tests don't depend on specific integration problems  
✅ **Structure preservation** - Ensure project organization supports framework functionality  
✅ **Interface contracts** - Validate integrator implementations follow expected patterns  

## Continuous Integration

The test suite is designed to:
- Run quickly (focusing on framework, not heavy integration)
- Provide clear failure diagnostics
- Support automated testing in CI/CD pipelines
- Validate framework changes before deployment

This test suite ensures the CutElementIntegration framework remains reliable and well-structured as it evolves.