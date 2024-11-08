# Odin Boids 

A *140 LoC* implementation of the [boids algorithm](https://en.wikipedia.org/wiki/Boids), using odin and raylib. 

First non-trivial program in odin and raylib. 

# Example 

![](https://github.com/alfiehiscox/boids/blob/main/boids.gif)

# Details 

[Odin](https://odin-lang.org/): dev-2024-09-nightly

[Raylib](https://www.raylib.com/)

Tested on MacBookPro 13-Inch (x86) : macOS Monterey v12.7.5

# Usage 

Assuming you have odin installed it's as simple as: 

```
git clone https://github.com/alfiehiscox/boids.git
odin run boids 
```

## Configuration 

There are a number of constants at the top of `main.odin`. 

You can control things like: 
- Amount of Boids
- Alignment
- Cohesion 
- Separtion 
- Velocity
- etc. 
