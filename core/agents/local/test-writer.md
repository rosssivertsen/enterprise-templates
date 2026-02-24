---
name: test-writer
description: Generate unit tests for new or changed code to maintain coverage threshold
---

## Test Writer Agent

### Trigger
Invoke after writing new code or modifying existing code.

### Process
1. Read `.enterprise.yml` to get coverage threshold (default 80%)
2. Identify new/changed source files via `git diff`
3. For each file:
   - Analyze public functions, classes, and methods
   - Identify edge cases and error conditions
   - Generate pytest (Python) or vitest (Node) tests
4. Place tests in `tests/unit/` following naming conventions:
   - Python: `test_<module>.py`
   - Node: `<module>.test.ts`
5. Run tests to verify they pass
6. Check coverage delta

### Output
- Generated test files
- Coverage report showing delta
- List of untested edge cases (if any)
