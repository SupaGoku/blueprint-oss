# Universal Code Style Guide

## General Principles

### Naming Conventions

#### Variables and Functions

- **Descriptive Names**: Use full words that clearly describe purpose
  - Good: `calculateTotalPrice`, `userAuthenticationToken`
  - Bad: `calcTP`, `authTok`
- **Avoid Abbreviations**: Unless universally understood (e.g., URL, API)

  - Good: `maximum`, `minimum`, `temperature`
  - Bad: `max`, `min`, `temp` (except in limited scope)

- **Boolean Names**: Should be questions or states

  - Good: `isEnabled`, `hasPermission`, `canEdit`
  - Bad: `enabled`, `permission`, `edit`

- **Collections**: Use plural names
  - Good: `users`, `items`, `products`
  - Bad: `userList`, `itemArray`, `productCollection`

#### Constants

- **Semantic Naming**: Name by meaning, not value

  - Good: `MAX_RETRY_ATTEMPTS`, `DEFAULT_TIMEOUT`
  - Bad: `FIVE`, `THIRTY_SECONDS`

- **Configuration Constants**: Group related constants
  ```
  DATABASE_HOST
  DATABASE_PORT
  DATABASE_NAME
  ```

### Code Organization

#### File Structure

- **Logical Grouping**: Related functionality in same file/module
- **Single Responsibility**: One primary purpose per file
- **Consistent Ordering**:
  1. Imports/Dependencies
  2. Constants/Configuration
  3. Type Definitions
  4. Main Implementation
  5. Helper Functions
  6. Exports

#### Function Design

- **Size Limit**: Keep functions under 50 lines ideally
- **Parameter Count**: Limit to 3-4 parameters, use objects for more
- **Single Purpose**: One function, one task
- **Pure Functions**: Prefer functions without side effects
- **Early Returns**: Exit early for error conditions

### Formatting Standards

#### Indentation

- **Consistency**: Use same style throughout project
- **Spaces vs Tabs**: Pick one and stick with it
- **Continuation Lines**: Align with opening delimiter
  ```
  longFunctionName(argument1,
                   argument2,
                   argument3)
  ```

#### Line Length

- **Maximum Width**: 80-120 characters per line
- **Breaking Long Lines**:
  - Break after operators
  - Break before closing brackets
  - Align continuation with start

#### Whitespace

- **Vertical Spacing**: Blank lines between logical sections
- **Horizontal Spacing**: Space around operators
- **Trailing Whitespace**: Remove all trailing spaces
- **End of File**: Single newline at end

### Comments and Documentation

#### Comment Types

##### Inline Comments

- **When to Use**: Only for complex or non-obvious code
- **Format**: Space after comment marker
- **Position**: Above the line being explained
  ```
  // Calculate compound interest using daily compounding
  result = principal * Math.pow(1 + rate/365, days)
  ```

##### Block Comments

- **Purpose**: Explain complex algorithms or business logic
- **Format**: Clear header and body
  ```
  /*
   * Binary search implementation
   * Time Complexity: O(log n)
   * Space Complexity: O(1)
   */
  ```

##### Documentation Comments

- **Function Documentation**:
  ```
  /**
   * Calculates the distance between two geographic points
   * @param lat1 - Latitude of first point
   * @param lon1 - Longitude of first point
   * @param lat2 - Latitude of second point
   * @param lon2 - Longitude of second point
   * @returns Distance in kilometers
   */
  ```

#### What to Comment

- **Why, not What**: Explain reasoning, not mechanics
- **Complex Business Logic**: Document domain-specific rules
- **Workarounds**: Explain temporary solutions
- **TODOs**: Mark future improvements with context
  ```
  // TODO: Optimize this query when index is added (JIRA-1234)
  ```

### Error Handling Style

#### Error Messages

- **Descriptive**: Include what went wrong and context

  - Good: "Failed to connect to database at localhost:5432"
  - Bad: "Connection error"

- **Actionable**: Suggest how to fix when possible
  - Good: "Invalid email format. Please use format: user@domain.com"
  - Bad: "Invalid input"

#### Error Propagation

- **Preserve Context**: Wrap errors with additional information
- **Consistent Format**: Use standard error structure
- **Appropriate Level**: Log at correct severity

### Control Structures

#### Conditionals

- **Simple Conditions First**: Handle edge cases early
- **Avoid Deep Nesting**: Max 3 levels, refactor if deeper
- **Explicit Comparisons**: Avoid implicit boolean conversion

  ```
  // Good
  if (count > 0)

  // Avoid
  if (count)
  ```

#### Loops

- **Clear Iteration**: Make loop purpose obvious
- **Avoid Magic Numbers**: Use named constants
- **Consider Functional Alternatives**: map, filter, reduce

### Code Smells to Avoid

#### Common Anti-patterns

- **Magic Numbers**: Always use named constants

  - Bad: `if (age > 18)`
  - Good: `if (age > MINIMUM_AGE)`

- **Dead Code**: Remove immediately
- **Commented-Out Code**: Delete, version control preserves history
- **Copy-Paste Programming**: Extract common functionality
- **God Functions**: Break down large functions
- **Deeply Nested Code**: Refactor using early returns

### Refactoring Guidelines

#### When to Refactor

- **Rule of Three**: Refactor when you repeat something third time
- **Before Adding Features**: Clean up area you'll modify
- **After Finding Bug**: Improve clarity to prevent recurrence
- **During Code Review**: When reviewers struggle to understand

#### How to Refactor

- **Small Steps**: Make incremental changes
- **One Thing at a Time**: Don't mix refactoring with features
- **Commit Separately**: Keep refactoring commits isolated

### Language-Agnostic Patterns

#### Design Patterns Usage

- **Factory Pattern**: When object creation is complex
- **Singleton**: Use sparingly, consider dependency injection
- **Observer**: For event-driven architectures
- **Strategy**: When algorithms are interchangeable
- **Repository**: For data access abstraction

#### Common Idioms

- **Guard Clauses**: Return early for invalid conditions
- **Null Object Pattern**: Avoid null checks
- **Builder Pattern**: For complex object construction
- **Fluent Interface**: For configuration APIs

### Performance Considerations

#### Optimization Rules

1. **Don't Optimize Prematurely**: Profile first
2. **Optimize for Readability**: Unless performance is critical
3. **Cache Expensive Operations**: But manage cache invalidation
4. **Use Appropriate Data Structures**: Know time/space complexity
5. **Batch Operations**: Reduce round trips

### Version Control Style

#### Commit Messages

- **Format**:

  ```
  type(scope): subject

  body (optional)

  footer (optional)
  ```

- **Types**:

  - feat: New feature
  - fix: Bug fix
  - docs: Documentation changes
  - style: Formatting changes
  - refactor: Code restructuring
  - chore: Maintenance tasks

- **Subject Line**:
  - Imperative mood: "Add" not "Added"
  - No period at end
  - Under 50 characters

#### Branch Naming

- **Feature Branches**: `feature/description`
- **Bug Fixes**: `fix/description`
- **Hotfixes**: `hotfix/description`
- **Experiments**: `experiment/description`

### Accessibility Considerations

#### Code Accessibility

- **Meaningful Variable Names**: Aid screen readers
- **Logical Structure**: Sequential flow
- **Alternative Text**: For any visual elements
- **Keyboard Navigation**: Consider in implementation

### Internationalization

#### String Handling

- **Externalize Strings**: Don't hardcode user-facing text
- **Use Keys**: Reference strings by keys, not content
- **Format Considerations**: Allow for text expansion
- **Cultural Sensitivity**: Avoid assumptions about formats

### Security Considerations

#### Secure Coding

- **Input Validation**: Always validate external input
- **Output Encoding**: Escape data before display
- **Least Privilege**: Request minimum permissions
- **Secure Defaults**: Fail closed, not open
- **No Hardcoded Secrets**: Use environment variables

## Enforcement and Tools

### Automation

- **Linters**: Automatic style checking
- **Formatters**: Automatic code formatting
- **Pre-commit Hooks**: Enforce before commit
- **CI/CD Integration**: Block merges for violations

### Code Review Focus

- **Consistency**: With existing codebase
- **Readability**: Can others understand easily?
- **Maintainability**: Easy to modify later?
- **Correctness**: Does it work as intended?

## Conclusion

This style guide provides a foundation for consistent, readable code across any programming language. Adapt these principles to your specific language and team needs, but maintain consistency within your project. Remember: the goal is to make code that is easy to read, understand, and maintain for all team members.
