# Outline

- What is state?
  - In-place changes (mutation)
  - State is _easy_ to understand
  - Simplicity and ease are two different things
    - Rich Hickey's Simple Made Easy
- Why is state harmful?
  - State is _complex_
  - Out of the Tar Pit
    - Accidental vs. essential complexity
  - State introduces _exponential_ complexity
    - Each new bit of state means 2x as many states that an app can be in
  - State often gives rise to ordering and inconsistency issues
    - Think about restarting a computer or app to fix an issue (you reset the state)
    - Race conditions: if two threads update a variable "simultaneously," what is its resulting
      value? One update "wins" and we don't get to do anything with the other.
    - Because of this, state makes correct concurrent programming incredibly difficult
- Minimizing state
  - Prefer immutable objects
    - Treat your model as a _value_, not changing data
    - Multiple threads can use an immutable object without worrying about race
      conditions
    - It's easy to reason about two getters in a row when the underlying object is
      immutable (it can't change between them)
    - With validation at initialization, it becomes impossible to have an object
      in an invalid state (with mutation, you can make this happen by changing
      one property inconsistently)
    - Class clusters (a la collections) can help if you still need to make
      changes sometimes
    - http://www.jonmsterling.com/posts/2012-12-27-a-pattern-for-immutability.html
  - ReactiveCocoa/FRP
    - Treats data as a stream of values over time (unlike variables, which
      contain only the latest value)
    - Because you can model time, it's possible to react to all changes, no matter
      how quickly they occur
    - Focuses on _deriving_ values through transformations, leading to more
      declarative code
  - Model-View-ViewModel?
    - Unfortunately, Cocoa relies on state for UI presentation (e.g., setting
      `UITextField.text`, presenting and dismissing `UIAlertView`s)
    - MVVM can help by isolating state within one component (the view model)
    - Instead of mutating the model, you _transform_ it, and replace the view
      model's copy with the new (immutable) version
