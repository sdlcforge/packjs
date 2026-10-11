// TypeScript test fixture demonstrating various TS features that should be stripped during transpilation

interface User {
  name: string;
  age: number;
}

type Status = 'active' | 'inactive';

// Generic function
function identity<T>(value: T): T {
  return value;
}

// Generic arrow function: in a '.ts' file '<T>(' must not be parsed as JSX
const identityArrow = <T>(value: T): T => value;

// Function with type annotations
function greet(user: User, status: Status): string {
  return `Hello, ${user.name}! You are ${status}.`;
}

// Class with TypeScript features
class Container<T> {
  private value: T;

  constructor(value: T) {
    this.value = value;
  }

  getValue(): T {
    return this.value;
  }
}

// Test function that exercises the TypeScript features
function testTypescript(): { success: boolean; results: string[] } {
  const results: string[] = [];

  // Test type annotations
  const user: User = { name: 'Alice', age: 30 };
  results.push(greet(user, 'active'));

  // Test generics
  const num = identityArrow<number>(42);
  const str = identity<string>('hello');
  results.push(`identity number: ${num}, string: ${str}`);

  // Test class with generics
  const container = new Container<number>(100);
  results.push(`container value: ${container.getValue()}`);

  // Test type assertion
  const value = '123' as unknown as string;
  results.push(`assertion result: ${value}`);

  return { success: true, results };
}

export { testTypescript, User, Status };
