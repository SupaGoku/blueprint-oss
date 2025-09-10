# Language-Agnostic Programming Style Guide

## Universal Programming Paradigms

### Paradigm Selection Guidelines

#### Imperative Programming

**Characteristics:**

- Step-by-step instructions
- Mutable state
- Control flow statements
- Direct hardware mapping

**When to Use:**

- System programming
- Performance-critical code
- Algorithm implementation
- Low-level operations

**Style Guidelines:**

- Clear sequence of operations
- Minimize state mutations
- Group related statements
- Use meaningful variable names for state

#### Declarative Programming

**Characteristics:**

- Describe what, not how
- Immutable data
- Expression-based
- Higher abstraction

**When to Use:**

- Data transformations
- Configuration
- Query operations
- UI declarations

**Style Guidelines:**

- Chain operations logically
- Keep expressions simple
- Avoid side effects
- Use functional composition

#### Object-Oriented Programming

**Characteristics:**

- Encapsulation
- Inheritance
- Polymorphism
- Message passing

**When to Use:**

- Complex domain modeling
- GUI applications
- Large systems
- Team collaboration

**Style Guidelines:**

- Small, focused classes
- Favor composition over inheritance
- Clear interfaces
- SOLID principles

#### Functional Programming

**Characteristics:**

- First-class functions
- Immutability
- Pure functions
- Function composition

**When to Use:**

- Data processing
- Concurrent systems
- Mathematical computations
- Predictable behavior

**Style Guidelines:**

- Keep functions pure
- Small, composable functions
- Avoid side effects
- Use higher-order functions

### Type System Approaches

#### Static Typing Style

**Best Practices:**

- Explicit type declarations for public APIs
- Type inference for local variables
- Use type aliases for complex types
- Leverage type system for validation
- Create domain-specific types

**Documentation:**

```
// Function signature with clear types
function processOrder(order: Order): Result<Invoice, Error>
```

#### Dynamic Typing Style

**Best Practices:**

- Defensive programming
- Runtime type checking
- Clear naming conventions
- Comprehensive documentation

**Documentation:**

```
// Document expected types clearly
// @param {Object} order - Order object with items array
// @returns {Object} Invoice or error object
```

## Language-Neutral Patterns

### Data Structure Usage

#### Arrays/Lists

**Style Guidelines:**

- Use for ordered collections
- Prefer immutable operations
- Clear naming (plural forms)
- Consider performance implications
- Document element types

**Common Operations:**

- Mapping transformations
- Filtering predicates
- Reduction/folding
- Searching/finding
- Sorting/ordering

#### Maps/Dictionaries

**Style Guidelines:**

- Use for key-value associations
- Clear key naming conventions
- Document key constraints
- Handle missing keys gracefully
- Consider ordering requirements

**Common Patterns:**

- Configuration objects
- Caching/memoization
- Lookup tables
- Grouping operations
- Counting/frequency

#### Sets

**Style Guidelines:**

- Use for unique collections
- Set operations (union, intersection)
- Deduplication
- Mathematical sets

### Control Flow Patterns

#### Conditional Logic

**Early Return Pattern:**

```
function process(data) {
    // Guard clauses first
    if (!data) return null
    if (data.invalid) return error

    // Main logic
    return transform(data)
}
```

**Pattern Matching Style:**

```
// Use appropriate language construct
switch/case, match, cond
- Exhaustive handling
- Default cases
- Group related cases
```

#### Iteration Patterns

**Functional Style:**

- Map for transformation
- Filter for selection
- Reduce for aggregation
- Foreach for side effects

**Imperative Style:**

- For loops for index access
- While for unknown iterations
- Do-while for at-least-once
- Break/continue sparingly

### Error Handling Strategies

#### Exception/Error Style

**Best Practices:**

- Catch specific exceptions
- Clean up resources
- Log appropriately
- Re-throw when needed
- Document thrown exceptions

**Pattern:**

```
try {
    // Risky operation
    result = performOperation()
} catch (SpecificError) {
    // Handle known case
} finally {
    // Cleanup always
}
```

#### Result/Option Types

**Best Practices:**

- Explicit error handling
- Compose error-prone operations
- Railway-oriented programming
- Clear success/failure paths

**Pattern:**

```
result = operation()
    .map(transform)
    .flatMap(validate)
    .getOrElse(defaultValue)
```

### Concurrency Patterns

#### Synchronous Style

- Sequential execution
- Blocking operations
- Simple mental model
- Predictable flow
- Limited scalability

#### Asynchronous Style

**Callbacks:**

- Error-first convention
- Avoid callback hell
- Named functions
- Clear error propagation

**Promises/Futures:**

- Chain operations
- Handle rejections
- Avoid mixing styles
- Use async/await if available

**Event-Driven:**

- Clear event names
- Document event data
- Unsubscribe/cleanup
- Error event handling

### Module/Package Organization

#### Module Structure

**Standard Layout:**

```
module/
├── Public API exports
├── Internal implementation
├── Types/Interfaces
├── Constants/Configuration
├── Utilities/Helpers
```

#### Dependency Management

**Principles:**

- Minimize dependencies
- Explicit imports
- Avoid circular dependencies
- Version pinning
- Regular updates

**Import Organization:**

1. Standard library
2. Third-party libraries
3. Internal modules
4. Local imports

### Interface Design

#### API Design Principles

**Consistency:**

- Naming conventions
- Parameter ordering
- Return types
- Error handling
- Default values

**Flexibility:**

- Optional parameters
- Configuration objects
- Builder patterns
- Fluent interfaces
- Extension points

#### Method Signatures

**Guidelines:**

- Verb-based names for actions
- Noun-based for accessors
- Boolean prefixes (is, has, can)
- Consistent parameter order
- Limit parameter count

### Documentation Patterns

#### Inline Documentation

**Function Documentation:**

```
/**
 * Purpose: Brief description
 *
 * Parameters:
 *   - param1: description and constraints
 *   - param2: description and constraints
 *
 * Returns: description and type
 *
 * Throws: possible exceptions
 *
 * Example:
 *   usage example
 */
```

#### Code Examples

**Best Practices:**

- Runnable examples
- Common use cases
- Edge cases
- Error scenarios
- Performance notes

### Performance Patterns

#### Optimization Approaches

**Algorithm Level:**

- Choose appropriate algorithms
- Consider time complexity
- Consider space complexity
- Profile before optimizing
- Document complexity

**Code Level:**

- Minimize allocations
- Cache computations
- Lazy evaluation
- Batch operations
- Pool resources

### Memory Management

#### Manual Management Style

- Clear ownership
- RAII pattern
- Explicit cleanup
- Resource pools
- Reference counting

#### Garbage Collected Style

- Minimize allocations
- Reuse objects
- Clear references
- Weak references
- Profile memory usage

### Generic/Template Programming

#### Type Parameters

**Naming Conventions:**

- Single letters for simple types (T, K, V)
- Descriptive for domain types
- Constraints documentation
- Variance annotations

**Best Practices:**

- Minimal constraints
- Clear bounds
- Type inference
- Avoid overuse
- Document requirements

### Metaprogramming

#### Code Generation

**Guidelines:**

- Clear generation markers
- Version control generated code
- Regeneration instructions
- Avoid manual edits
- Document sources

#### Reflection/Introspection

**Use Cases:**

- Serialization
- Dependency injection
- Framework integration
- Dynamic dispatch

**Cautions:**

- Performance impact
- Type safety loss
- Debugging difficulty
- Security implications

## Cross-Language Interoperability

### FFI (Foreign Function Interface)

**Best Practices:**

- Clear boundaries
- Type marshaling
- Error handling
- Resource management
- Performance considerations

### Data Exchange Formats

**JSON Style:**

- Consistent naming (camelCase/snake_case)
- Flat structures when possible
- Version fields
- Schema validation

**Binary Formats:**

- Protocol documentation
- Version compatibility
- Endianness handling
- Size optimization

## Build and Deployment Patterns

### Build Configuration

**Principles:**

- Reproducible builds
- Dependency declaration
- Environment configuration
- Build optimization
- Asset management

### Package Management

**Best Practices:**

- Semantic versioning
- Lock files
- Private registries
- Security scanning
- License compliance

## Language Migration Patterns

### Polyglot Programming

**Guidelines:**

- Choose right language for task
- Clear service boundaries
- Consistent interfaces
- Shared data formats
- Documentation standards

### Code Translation

**Considerations:**

- Idiomatic target code
- Performance characteristics
- Error handling differences
- Library availability

## Conclusion

This language-agnostic style guide provides foundational patterns applicable across programming languages. While specific syntax varies, these principles guide writing clear, maintainable, and efficient code regardless of language choice. Adapt these patterns to leverage each language's strengths while maintaining consistency in overall design approach.

Key takeaways:

- Choose paradigms appropriate to problems
- Maintain consistency within projects
- Document language-specific deviations
- Focus on clarity and maintainability
- Consider cross-language collaboration

Remember: Good style transcends syntax—it's about communicating intent clearly to both computers and humans.
