# [fit] Enemy of the State
### _(Swift edition!)_

^ WHAT I'M TALKING ABOUT

---

![autoplay](nyantocat.mov)

^ First of all, let me introduce myself. My name is Justin Spahr-Summers, and I work on GitHub for Mac and GitHub for Windows.

---

# [fit] Programming is all about
# [fit] abstraction

^ Why this talk? I could talk about concrete things, like RAC or how we build native apps at GitHub. However, I want to impart abstract knowledge, so this will be a less concrete talk than you're used to.

^ Don't let your eyes glaze over, though, because programming is all about abstraction, and an understanding of theory is hugely important for solving practical, real world problems.

---

# [fit] We want to be using the
# [fit] best possible
# [fit] abstractions for development

^ The right abstractions can reduce complexity, increase reliability and maintainability, and give you greater confidence in the correctness of your code.

---

# What even is
# [fit] state?

---

# [fit] State
# [fit] Your stored values at any given time
# [fit]
# [fit] Mutation
# [fit] The act of updating some state in place

^ A value is unchanging, it has no concept of time. State consists of all the values you currently have.

---

# Variables are state

```swift
var x: Int

// Store a value into the variable
a = 5

// Update (mutate) the variable, by replacing the value
a = 2

// Mutate the variable again
a++
```

^ Variables are the most apparent kind of state in any program. When you want to hold on to a new value, you change the variable in-place (i.e., you mutate it).

---

# State is
# [fit] easy

^ State is easy because it's familiar, or approachable. We first learned how to program statefully, so it comes naturally to us.

---

# But
# [fit] easy
# and
# [fit] simple
# are not the same

_See Rich Hickey’s talk, “Simple Made Easy”_

^ A **simple** design minimizes concepts and concerns. Unfortunately, state makes your code more complex.

---

![fill](sadmac.png)

^ The biggest problem with state is that it "go bad." Any time you've restarted your computer or an app to fix an issue, you've been a victim of state.

---

# State is
# [fit] complex

---

# [fit] Complexity
# [fit] Mixing (“complecting”) concepts or concerns

---

# All systems have
# [fit] _essential_ complexity
# [fit]
# State also adds
# [fit] _incidental_ complexity

_See Moseley and Marks' paper, “Out of the Tar Pit”_

---

# [fit] `var visible` → 2 states
# [fit]
# [fit] `var enabled` → 4 states
# [fit]
# [fit] `var selected` → 8 states!
# [fit]
# [fit] `var highlighted` → 16 states!!

^ In fact, state is exponentially complex! As you add each new boolean, you double the total number of states your program can be in. For more complicated data types, the growth in complexity is even more dramatic.

^ GLOBAL STATE?!

---

# State is a cache

- I REALLY HATE THIS SLIDE
- User interaction often means recalculating or _invalidating_ some stored state
- Cache invalidation is really, _really_ hard to get right

_See Andy Matuschak's Quora post, “Mutability, aliasing, and the caches you didn’t know you had”_

^ This is true every time any state is aliased, or stored in more than one location. For example, if you have a text field with some content, and then also track some version of that content in your view controller, one of those is effectively a cache for the other.

---

# EXAMPLE OF CACHED STATE

---

# State is nondeterministic

- Race conditions can lead to corruption or inconsistent state
- Variables can change unpredictably from a distance

^ These make code difficult to reason about. For example, if two threads update a variable almost simultaneously, what's the result? Could you figure it out just by reading the code?

---

# State is nondeterministic

```swift
let x = self.myInt
println(x)
```

**==> 5**

```swift
let y = self.myInt
println(y)
```

**==> 10 (?!?!)**

![fit](rageface.png)

---

# State is hard to test

- Tests verify that certain inputs result in a certain output
- State is an _implicit_ input that can change unexpectedly

^ Not only is it complicated to set up a correct initial state for testing, but method calls can change it during the test, which can introduce issues with ordering and repeatability.

^ By contrast, it's much easier to test a pure algorithm, where the output is only determined by its explicit inputs.

---

# [fit] _Example:_ Testing Core Data

```objc
id managedObject = [OCMockObject mockForClass:[NSManagedObject class]];
id context = [OCMockObject
	mockForClass:[NSManagedObjectContext class]];

[[context expect] deleteObject:managedObject];
[[[context stub] andReturnValue:@YES] save:[OCMArg anyObjectRef]];

id resultsController = [OCMockObject
	mockForClass:[NSFetchedResultsController class]];

[[[resultsController stub] andReturn:context] managedObjectContext];
[[[resultsController stub] andReturn:managedObject]
	objectAtIndexPath:OCMOCK_ANY];

id viewController = partialMockForViewController();
[[[viewController stub] andReturn:resultsController]
	fetchedResultsController];

[viewController deleteObjectAtIndexPath:nil];
[context verify];
```

_from Ash Furrow’s C-41 project (sorry, Ash!)_

^ This (slightly modified) test verifies that a view controller's NSFetchedResultsController successfully updates after a managed object is deleted from the context.

^ As you can see, it uses a lot of mocks and stubs to avoid actually manipulating a database (which is a form of state). Stateless code requires less mocking and stubbing, since the output of a method should only depend on its input!

---

# [fit] Hey, state happens

- Preferences
- Open and saved documents
- In-memory or on-disk caches
- UI appearance and content

^ Most applications require some state, and that's okay. Here are some examples of state being necessary and helpful for solving a particular problem.

---

# Values
# Purity
# Isolation

^ Although it's not possible to eliminate all state from a Cocoa application, we can try to minimize it (and therefore minimize complexity) as much as possible. Here are three techniques for doing so. Let's go through each one in turn.

---

##  
## [fit] Values
## Purity
## Isolation

---

# Values

- **Structs** and **enums** in Swift
- Values are **copied**, not shared
- Immutable*

^ NEED NOTES HERE

---

> But I can set the properties of a struct in Swift! This guy doesn’t know what he’s talking about.
—You, the audience

---

# “Mutating” a struct in Swift

1. STEPS
1. GO
1. HERE

---

# EXAMPLE OF MUTATING A STRUCT

---

# Why is this important?

- EASIER TO REASON ABOUT VARIABLES
- THREAD SAFETY
- NO UNPREDICTABLE CHANGES

---

## Values
## [fit] Purity
## Isolation

---

# Pure functions

1. Always return the same result for the same inputs
1. Must not have _observable_ side effects

^ TALK ABOUT OBSERVABLE EFFECTS (e.g. lazily computed properties, memory allocation)

---

```swift
// Pure: concatenates two input strings and
// returns the result.
func +(lhs: String, rhs: String) -> String

protocol GeneratorType {
	// Impure: advances to the next element
	// and returns it.
	mutating func next() -> Element?
}

struct Array {
	// Pure(?)
	var count: Int { get }
}
```

---

# [fit] Impure functions are
# [fit] surprising

---

# EXAMPLE OF MANAGED OBJECT VALUEFORKEY

---

# MAKING CORE DATA PURE?

---

# EXAMPLE OF MANAGED OBJECT VALUEFORKEY

---

# [fit] Pure functions are
# [fit] easily tested

---

# EXAMPLE OF TESTING MANAGED OBJECTS BEFORE

---

# EXAMPLE OF TESTING MANAGED OBJECTS AFTER

---

## Values
## Purity
## [fit] Isolation
##  

---

# Single responsibility principle

- An object or variable should have only **one** reason to change
- Each chunk of state should be isolated in its own context

^ The most effective way to simplify state without removing it is to isolate it, so it doesn't get complected with other concerns.

---

# Isolation Done Wrong™

```swift
class MyViewController: UIViewController {
	// When logging in
	var username: String?
	var password: String?

	// After logging in
	var loggedInUser: User?
}
```

^ This is an example of poor isolation. The view controller is "complecting" the concern of logging in with the concern of knowing who's logged in. As the implementation grows to manage both of these concerns, it becomes difficult to reason about them separately.

---

# Isolation Done Right™

```swift
// For logging in
class LoginViewModel {
	var username: String?
	var password: String?

	func logIn() -> UserViewModel?
}

// After logging in
class UserViewModel {
	var loggedInUser: User?
}
```

^ By splitting these two concerns out into separate objects, the respective pieces of state don't interact directly with each other, and the relationships between them become more explicit.

---

# Stateless core, stateful shell

- Keep core **domain logic** in completely immutable value types
- Add **stateful shell objects** with mutable references to the immutable data

_See Gary Bernhardt’s talk, “Boundaries”_

^ Basically, use value types and pure algorithms for as much as possible. Once you get to the point where you need some state, wrap it around the immutable stuff. Your stateful shell can transform the values and update references to them.

---

# Model-View-ViewModel

IMAGE HERE

^ Model-View-ViewModel is actually a great example of this "stateless core" design. MVVM (depicted here, on the bottom) involves replacing the omniscient controller of MVC with a less ambitious "view model" object. The view model is actually owned by the view, and behaves like an adapter of the model.

^ The view model is responsible for changing the model, which means you can make the model immutable, and the VM can just apply transformations instead of mutations.

---

# Model-View-ViewModel

```swift
struct User { … }

class UserViewModel {
	var loggedInUser: User?

	func logOut() {
		loggedInUser = nil
	}
}
```

^ Here's an example, using the UserViewModel from before. The User is the stateless core, and the UserViewModel is the stateful shell.

^ Although User is a struct, the view model can still update its `user` property by transforming the struct and keeping the new version. Any consumers that read the property before this point will still retain their version, avoiding scary action at a distance.

---

# Globals: Just Say No

- **Singletons** are global state
- Global state gets mixed in to _every_ part of the program, compromising purity
- While isolation reduces complexity, global state compounds it

---

# PASS AROUND INSTANCES INSTEAD

---

# Values
# Purity
# Isolation

---

# Learning More

- Check out ReactiveCocoa
- Play with purely functional programming languages, like Haskell and Elm

^ ReactiveCocoa (of which I'm an author) offers further mechanisms for minimizing state and complexity. Or just try your hand at pure FP/FRP. Working in a language like Haskell or Elm will open your eyes to how unnecessary state really is. Even if you never use them in a real application, they'll expand your mind and teach you valuable lessons that can be applied to everyday programming.

^ If you want a specific tutorial, I highly recommend Real World Haskell, for a very practical approach to building Real World™ applications in a pure FP language.

---

# [fit] Presentation available at
# [fit] github.com/jspahrsummers/enemy-of-the-state
