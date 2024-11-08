# Odin Boids 

A 140LoC implementation of the [boids algorithm](https://en.wikipedia.org/wiki/Boids), using odin and raylib. 

First non-trivial program in odin and raylib. 

# Example 



# Details 

[Odin](https://odin-lang.org/)     : odin version dev-2024-09-nightly:dd1f151
[Raylib](https://www.raylib.com/)   : vendor lib of above

Tested on MacBook Pro 13-Inch (2020 - x86) : macOS Monterey v12.7.5

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
