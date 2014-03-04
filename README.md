# Enemy of the State

Presentation for [CocoaConf Mini
Austin](http://cocoaconf.com/austin-2014/sessions/enemy-of-state) in April 2014.

## Outline

- What is state?
- Why is state harmful?
  - Out of the Tar Pit
  - State introduces exponential complexity
    - Each new bit of state means 2x as many states that an app can be in
  - No modeling of changes themselves ("What are all the values that this variable holds?")
  - Ordering-dependent
    - Hard to parallelize
    - Race conditions
- Minimizing state
  - Immutable objects everywhere
    - Class clusters?
    - http://www.jonmsterling.com/posts/2012-12-27-a-pattern-for-immutability.html
  - ReactiveCocoa/FRP
    - Focus on deriving values instead of updating them in-place
  - MVVM?
    - Makes it easier to use an immutable model, keeping mutation at the VM or
      view layer
