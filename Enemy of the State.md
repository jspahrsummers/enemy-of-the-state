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

^ Think of it like the transition from assembly to higher-level programming languages. Each new higher-level language offers more convenience, more tools for managing complexity, more safety, and so forth. They do this by offering more and more powerful abstractions.

---

# What even is
# [fit] state?

^ Now, in _this_ abstract talk, I'm going to explain why state is harmful, and offer some tools (abstractions) to minimize its impact. But, first, we need to be on the same page about what state _is_.

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

^ To use a different example, it's definitely _easy_ to stuff all of your model data into NSDictionaries instead of creating purpose-specific classes. Everyone understands dictionaries, and creating them takes less effort, but ultimately they make your code more complex and error-prone (for example, if you expect a dictionary with one kind of structure but get something else).

---

# [fit] Easy
# and
# [fit] Simple
# are not the same

_See Rich Hickey’s talk, “Simple Made Easy”_

---

# [fit] Easy
# [fit] _Familiar_ or _approachable_

---

# [fit] Simple
# [fit] Fewer concepts and concerns

---

# [fit] State is
# [fit] familiar
# (but complex)

---

![fill](sadmac.png)

^ The biggest problem with state is that it can "go bad." Any time you've restarted your computer or an app to fix an issue, you've been a victim of state.

---

# State is
# [fit] complex

^ That's a pretty heavy assertion. Before we can decide whether it's true or not, what is complexity?

---

# [fit] Complexity
# [fit] Mixing (“complecting”) concepts or concerns

^ Using this definition, state is complex because it mixes together completely unrelated components of your application. When the state of one component depends on the state of another, and so on, suddenly all of those components have gotten coupled and tied together, when they really didn't need to be.

---

# All systems have
# [fit] _essential_ complexity
# [fit]
# State also adds
# [fit] _incidental_ complexity

_See Moseley and Marks' paper, “Out of the Tar Pit”_

^ Essential complexity refers to the complexity that's inherent to the problem you're trying to solve. If you're writing an app that connects to the internet, for example, you automatically have to deal with all the complexity of networking (even if it's hidden away from you).

^ By contrast, incidental complexity is the complexity that's not actually necessary. It arises solely because of your application architecture, or design choices, or whatever else. State falls into this category, because its complexity is avoidable, as we'll see later.

---

# [fit] `var visible` → 2 states
# [fit]
# [fit] `var enabled` → 4 states
# [fit]
# [fit] `var selected` → 8 states!
# [fit]
# [fit] `var highlighted` → 16 states!!

^ In fact, state is exponentially complex! As you add each new boolean, you double the total number of states your program can be in. For more complicated data types, the growth in complexity is even more dramatic.

---

# State is just a
# [fit] glorified cache

^ For example, a variable caches a single value. You can store into the variable (the cache), invalidate it by resetting the variable to something else, and so forth.

^ Makes sense. What's the big deal?

---

> There are only two hard problems in Computer Science: **cache invalidation** and naming things.
—Phil Karlton

^ Cache invalidation is hard. Really hard. And in a GUI application, user interaction often means having to recalculate or invalidate some stored state.

---

# EXAMPLE OF INVALIDATING CACHED UI STATE

_See Andy Matuschak's post, “Mutability, aliasing, and the caches you didn’t know you had”_

---

# State is
# [fit] unpredictable

^ The unpredictability of state makes code extremely hard to reason about. When code is hard to reason about, bugs crop up, because each developer might have a different understanding of the intended behavior.

---

![fit](raceconditions.jpg)

^ We're probably all familiar with race conditions, where multiple threads try to use the same state at the same time. If anything is modifying the state at the same time, you can see inconsistency at best, or corruption at worst.

^ How do you prevent race conditions? It's very hard to prove their absence, you just have to focus on eliminating them through careful code analysis, which is time-consuming and error-prone. This is a consequence of state.

---

> [State is] spooky action at a distance
—Albert Einstein _(probably)_

^ This term of his was actually about quantum entanglement, but the parallels are astounding.

---

# State is unpredictable

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

# State is
# [fit] hard to test

---

# [fit] Tests
# [fit] verify expected outputs for certain inputs
#
# [fit] State
# [fit] is an _implicit_ input that can change unexpectedly

^ Not only is it complicated to set up a correct initial state for testing, but method calls can change it during the test, which can introduce issues with ordering and repeatability.

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

![fit](trollface.png)

^ This (slightly modified) test verifies that a view controller's NSFetchedResultsController successfully updates after a managed object is deleted from the context.

^ As you can see, it uses a lot of mocks and stubs to avoid actually manipulating a database (which is a form of state). Stateless code requires less mocking and stubbing, since the output of a method should only depend on its input!

---

# [fit] Hey, state happens

- Preferences
- Open documents
- Documents saved to disk
- In-memory or on-disk caches
- UI appearance and content

^ Most applications require some state, and that's okay. Here are some examples of state being necessary and helpful for solving a particular problem.

---

# [fit] Minimize state
# [fit] Minimize complexity

^ So although it's not possible to eliminate all state from a Cocoa application, we can try to minimize it (and therefore minimize complexity) as much as possible.

---

# Values
# Purity
# Isolation

^ Here are three of my favorite techniques for minimizing the complexity of state. Let's go through each one in turn.

---

##  
## [fit] Values
## Purity
## Isolation

^ A value is just a piece of data, like a string, a number, a collection, or a date. Values themselves do not change, so converting mutable objects into immutable values is a great way to eliminate state.

---

# [fit] Structs
# [fit] Enums

^ These are Swift's value types, which we can use to create our _own_ values. Classes, by contrast, are reference types.

---

# [fit] Copied
# (not shared)

^ One of the key attributes of a value type is that instances are copied when assigned to variables, passed to methods, etc., unlike a reference type, where a reference to the existing instance is passed instead.

^ For example, this means that modifying a struct does not affect preexisting copies of that struct. We'll see why this is important shortly.

---

# Value types are
# [fit] immutable
# in Swift

^ Values never change. Only variables do.

---

> But I can set the properties of a struct in Swift! This guy doesn’t know what he’s talking about.
—You, the audience

^ I've said that values are immutable multiple times now, but it might be hard to see why. Let's dig into an example.

---

# [fit] “Mutating” a struct in Swift

```swift
struct Point {
	var x = 0.0
	var y = 0.0

	mutating func scale(factor: Double) {
		self.x *= factor
		self.y *= factor
	}
}
```

^ Here's a struct that I've defined for representing geometric points (we'll pretend that CGPoint doesn't already exist). It has some writable coordinates, and a mutating function that scales the point by a given factor.

---

# [fit] “Mutating” a struct in Swift

```swift
var p = Point(x: 5, y: 10)
```

^ If we use the var keyword, we can create a point…

---

# [fit] “Mutating” a struct in Swift

```swift
var p = Point(x: 5, y: 10)
p.x = 7     // p = (7, 10)
```

^ And then, seemingly, write straight to it.

---

# [fit] “Mutating” a struct in Swift

```swift
var p = Point(x: 5, y: 10)
p.x = 7     // p = (7, 10)
p.scale(2)  // p = (14, 20)
```

^ Likewise, we can call our mutating method, and it appears that the point has changed in place. But what does it mean for it to have changed "in place?"

---

# [fit] “Mutating” a struct in Swift

```swift
var p = Point(x: 5, y: 10)
let q = p
```

^ Let's change our example slightly, so that we save the Point into a read-only variable before continuing.

---

# [fit] “Mutating” a struct in Swift

```swift
var p = Point(x: 5, y: 10)
let q = p

p.scale(2)  // p = (10, 20)
            // q = (5, 10)
```

^ As we would expect with a Swift struct, 'q' retains the original value, while 'p' has been scaled.

---

# [fit] Here's the key:

^ So far, I haven't proved that value types are immutable in Swift. In fact, my examples seem to contradict that notion entirely. But here's the key…

---

# [fit] Variables mutate
# [fit] Values never change

^ In all of those examples, the _variable_ is being updated to point at a new _value_. When we scale the Point, or change its coordinates, we're really creating a NEW Point, that gets stored into the variable.

---

# [fit] “Mutating” a struct in Swift

```swift
var p = Point(x: 5, y: 10)
let q = p

p.scale(2)  // p = (10, 20)
            // q = (5, 10)
```

^ Looking at the code again, the only difference between 'p' and 'q' is the variable declaration. We've declared that the variable 'q' may never change. What this really means is that the value _stored in_ 'p' is allowed to be replaced, while the value _stored in_ 'q' is not.

---

# [fit] “Mutating” a struct in Swift

```swift
var p = Point(x: 5, y: 10)
let q = p

p.scale(2)  // p = (10, 20)
            // q = (5, 10)

q.x = 2
q.scale(2)  // Error!
```

^ Consequently, any attempts to update the value in 'q' will fail.

---

# [fit] “Mutating” functions

```swift
func pointByScaling(factor: Double) -> Point {
	return Point(self.x * factor, self.y * factor)
}

mutating func scale(factor: Double) {
	self.x *= factor
	self.y *= factor
}
```

^ To really drive this point home, let's look at how `mutating` functions are actually implemented. We'll contrast our 'scale' function with a non-mutating version, seen here at the top.

---

# [fit] “Mutating” functions

```swift
func pointByScaling(self: Point, factor: Double) -> Point {
	return Point(self.x * factor, self.y * factor)
}

mutating func scale(self: Point, factor: Double) {
	self.x *= factor
	self.y *= factor
}
```

^ The first realization here is that `self` is actually a magic argument to every instance method. The compiler inserts `self` automatically, so you never see it, but the functions actually look kinda like this under the hood.

^ But wait, Swift arguments are read-only by default, so the mutating method here is actually invalid. It wouldn't be able to write to `self`, much less have those changes saved.

---

# [fit] “Mutating” functions

```swift
func pointByScaling(self: Point, factor: Double) -> Point {
	return Point(self.x * factor, self.y * factor)
}

mutating func scale(inout self: Point, factor: Double) {
	self.x *= factor
	self.y *= factor
}
```

^ In fact, the mutating method needs an `inout` version of `self`, and this is the key to the whole mutability model. What this function is doing then, is accepting a copy of the Point, transforming it, and then _storing_ it back to the caller.

^ Except storage is a feature of _variables_, not values. We've come full circle. The method is only "mutating" because it can write to the variable at the call site. If the variable is read-only (defined with `let`), it cannot be written to, so "mutating" methods cannot be used.

---

# [fit] Variables mutate
# [fit] Values never change

^ This is why value types are so incredibly powerful in Swift. Values won't mutate from underneath you, and you can use `let` to declare variables that don't either.

---

# [fit] So what?

^ Why does it _matter_ that values are immutable?

---

# [fit] Values are automatically
# [fit] thread-safe

^ Unlike variables, which have to be synchronized, values are automatically thread-safe. Changing a variable on one thread does not affect another thread's view of the previous _value_. This is huge—no more race conditions!

---

# [fit] Values are automatically
# [fit] predictable

^ And, unlike state, which is often nondeterministic, values are predictable and unsurprising. You can use them repeatedly and always see the same results.

---

# Values are predictable

```swift
let value = self.myData

let x = value.someInt
println(x)
```

**==> 5**

```swift
let y = value.someInt
println(y)
```

**==> still 5!**

![](successkid.jpg)

^ NOTES

---

## Values
## [fit] Purity
## Isolation

^ In addition to value types, so-called "pure" algorithms are another great way to eliminate state.

---

# [fit] Pure functions
# [fit] Same inputs always yield the same result
# [fit] Must not have _observable_ side effects

^ Note that lazily-computed properties, memory allocation, etc. can still be pure, as long as the same inputs lead to the same result—always.

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

^ Here are some examples of pure vs. impure functions from the Swift standard library. (Talk about each.)

^ Is Array.count pure? I would argue yes, because it depends only on the _input_ that is the array itself. If the array (the input) has not changed, the output (the count) will not change either.

---

# [fit] Impure functions are
# [fit] surprising

^ Reasoning about behavior becomes extremely difficult when a function does different things for different invocations.

---

> Insanity is doing the same thing over and over again but expecting **different results**.

^ It's actually pretty insane that we put up with this. Pure functions are so much simpler and sane.

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

^ As I alluded to before, it's not feasible to eliminate _all_ state from a Cocoa application. Value types and pure algorithms can get you pretty far, but there will be some remainder that "needs" to be stateful.

^ Still, when dealing with state, we can _isolate_ (or encapsulate) it to reduce its impact on the rest of the program.

---

# [fit] Objects should have
# [fit] only one
# [fit] reason to change

^ This, the Single Responsibility Principle, is a good rule of thumb. To put it another way, each object should only be in charge of _one_ piece of state. Avoid combining the responsibilities for a bunch of state into the same class.

^ As an example of violating this principle, view controllers often end up managing a lot of different responsibilities, when really those could be split out into different objects. I'll show one such example in just a bit.

---

# Isolate
# [fit] unrelated
# pieces of state

^ Again, break apart those responsibilities. Encapsulate different concepts away from each other.

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

# [fit] Stateless core,
# [fit] stateful shell

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

# [fit] Globals:
# [fit] Just Say No

![fit](DARE_logo.png)

^ I want to briefly talk about the most egregious of all state: the global variable.

---

# [fit] Globals get mixed in to
# [fit] every part
# [fit] of your program

![fit](DARE_logo.png)

^ Globals are even more dangerous than other forms of state, because they get complected (mixed in with) every other part of your program. The dependencies are all implicit, and components get more coupled together.

---

# [fit] Isolation reduces complexity
# [fit] Globals compound it

![fit](DARE_logo.png)

^ Global variables are, in fact, the exact opposite of good isolation. Instead of isolating the state, it blankets everything.

---

# [fit] Singletons
# [fit] are global state

![fit](DARE_logo.png)

^ We all know this, but don't like to acknowledge it. Singletons are just glorified global variables! They suffer from all of the problems I was just talking about, we've just combined all of the problems into one magical object.

---

# [fit] Let’s just pass
# [fit] instances
# [fit] around instead

^ The solution is simple. Instead of having a singleton that any component can access at any time, create instances with the _specific_ functionality that you need, and pass those around instead.

---

# _Example:_ Singleton Networking

```swift
class APIClient {
	// Access the singleton with APIClient.sharedClient
	class var sharedClient: APIClient {
		struct Singleton {
			static let instance = APIClient()
		}

		return Singleton.instance
	}

	// Fetches the top-level list of categories
	func fetchCategories() -> [Category]
}
```

^ Let's look at an example. Here we have a typical API client class, with a singleton as you would write it in Swift.

---

# _Example:_ Singleton Networking

```swift
class MyViewController: UIViewController {
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		APIClient.sharedClient.fetchCategories()
	}
}
```

^ A view controller might use it like this. Just grab the global variable (the singleton), and do some stuff with it.

^ Let's rewrite this, but pass an instance to the view controller instead of using a singleton.

---

# _Example:_ Instance Networking

```swift
class APIClient {
	// Fetches the top-level list of categories
	func fetchCategories() -> [Category]
}
```

^ Changing the API client is easy: we'll just remove the singleton accessor, forcing consumers to instantiate the client before they can use it.

---

# _Example:_ Instance Networking

```swift
class MyViewController: UIViewController {
	let client: APIClient

	designated init(client: APIClient) {
		super.init(nibName: nil, bundle: nil)
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		client.fetchCategories()
	}
}
```

^ Now, whoever creates the view controller needs to give it the API client that it should work with.

^ This looks a little denser, but the benefits are enormous.

---

# [fit] Easily testable
# [fit] Explicit dependencies
# [fit] More flexible

^ Singletons are notoriously difficult to test, and usually involve ridiculous levels of mocking and stubbing. With the instance-based approach, we can avoid all that by creating a special API client subclass for testing, and passing that in. Bam, the view controller is no longer hitting the network.

^ In addition, the fact that the view controller depends upon the API client is now made clear. It's not left implicit. This helps readers understand the responsibilities that the VC has.

^ Finally, the API client has become more flexible. Let's say you want to support multiple logins in the future. You could now just represent that with two separate instances of the API client, one per user. With a singleton, you'd have a very hard time retrofitting that kind of functionality.

---

# Values
# Purity
# Isolation

^ Alright, whew. We've looked at how value types and pure algorithms can avoid state entirely, and how isolation can reduce the impact of state.

^ Keeping these principles in mind will help you minimize the complexity of your programs.

---

# [fit] TL;
# [fit] DR

^ If you walk away from this talk with only one thing, it should be this…

---

# [fit] Minimize state
# [fit] Minimize complexity

^ Minimize your use of state, and you'll have minimized the complexity of your program. Less complexity means more reliable, more maintainable code, and a more pleasant development experience overall.

---

# [fit] Learning More

^ Hopefully this has given you a taste of what's possible outside of the "traditional" stateful approaches to application design. The info out there far exceeds what anyone could present in an hour, so here are some additional resources.

---

# [fit] WWDC 2014
# [fit] Session 229
# [fit] “Advanced iOS Application
# [fit] Architecture and Patterns”

^ This talk, by Andy Matuschak and Colin Barrett, covers a lot of similar topics. In particular, they talk a lot about determining "where truth resides" as a strategy for reducing complexity. I highly recommend watching it.

---

# [fit] Check out ReactiveCocoa
# [fit] github.com/ReactiveCocoa/ReactiveCocoa

^ ReactiveCocoa (of which I'm an author) offers further mechanisms for minimizing state and complexity. Explaining RAC would take a presentation of its own, but the basic idea is to think of state as "changes over time" instead of in-place updates, which makes it simpler to manage changes in general.

---

# [fit] Haskell
# [fit] book.realworldhaskell.org
# [fit]
# [fit] Elm
# elm-lang.org

^ Or just try your hand at purely functional programming. Working in a language like Haskell or Elm will open your eyes to how unnecessary state really is. Even if you never use them in a real application, they'll expand your mind and teach you valuable lessons that can be applied to everyday programming.

---

# [fit] Presentation available at
# [fit] github.com/jspahrsummers/enemy-of-the-state

^ All of these slides, and my notes, are available on GitHub. The README of this repository also contains links to every paper, talk, and post that I've referenced here.

^ Thank you!
