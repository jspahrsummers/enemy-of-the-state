# [fit] Enemy of the State
### _(Swift edition!)_

^ WHAT I'M TALKING ABOUT

---

![autoplay](nyantocat.mov)

^ First of all, let me introduce myself. My name is Justin Spahr-Summers, and I work on GitHub for Mac and GitHub for Windows.

---

# Why this talk?

- At its heart, programming is all about **abstraction**
- We all want to be using the _best possible_ abstractions for building software

^ I could talk about concrete things, like RAC or how we build native apps at GitHub. However, I want to impart abstract knowledge, so this will be a less concrete talk than you're used to.

^ Don't let your eyes glaze over, though, because programming is all about abstraction, and an understanding of theory is hugely important for solving practical, real world problems.

---

# What even is state?

- **State** refers to a program's stored values at any given time
- **Mutation** is the act of updating some state in-place

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

# State is easy

- But **easy** and **simple** are not the same
- A **simple** design minimizes concepts and concerns

_See Rich Hickey’s talk, “Simple Made Easy”_

^ State is easy because it's familiar, or approachable. We first learned how to program statefully, so it comes naturally to us, but that doesn't make it right.

---

![fill](sadmac.png)

^ The biggest problem with state is that it "go bad." Any time you've restarted your computer or an app to fix an issue, you've been a victim of state.

---

# State is complex

- **Complexity** arises from multiple concepts or concerns being interleaved
- All systems have some level of **essential** complexity
- However, state also adds **incidental** complexity

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

# [fit] Questions?
