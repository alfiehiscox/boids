package main

import "core:math"
import "core:math/linalg"
import "core:math/rand"
import rl "vendor:raylib"

WINDOW_WIDTH :: 800
WINDOW_HEIGHT :: 600

BOID_SIZE :: 10
BOID_TURN_THRESHOLD :: 100
BOID_TURN_STRENGTH :: 100

Boid :: struct {
	position: rl.Vector2,
	velocity: rl.Vector2,
	rotation: f32,
}

main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "boids")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)

	middle_x := f32(WINDOW_WIDTH / 2)
	middle_y := f32(WINDOW_HEIGHT / 2)

	boids := [10]Boid{}
	for _, i in boids {
		boids[i] = random_boid()
	}

	for !rl.WindowShouldClose() {
		delta := rl.GetFrameTime()

		for &boid in boids {
			update_boid(&boid, delta)
			check_boid_collisions(&boid)
		}

		{
			rl.BeginDrawing()
			defer rl.EndDrawing()
			rl.ClearBackground(rl.BLACK)

			rl.DrawFPS(30, 30)

			for boid in boids {
				draw_boid(boid)
			}
		}
	}
}

random_boid :: proc() -> Boid {
	return Boid {
		position = random_vec_2(0, WINDOW_WIDTH, 0, WINDOW_HEIGHT),
		velocity = random_vec_2(200, 300, 200, 300),
		rotation = rand.float32_range(0, 360),
	}
}

random_vec_2 :: proc(minx, maxx, miny, maxy: f32) -> rl.Vector2 {
	x := rand.float32_range(minx, maxx)
	y := rand.float32_range(miny, maxy)
	return {x, y}
}

draw_boid :: proc(boid: Boid) {
	rl.DrawPoly(boid.position, 3, BOID_SIZE, boid.rotation, rl.WHITE)
}

update_boid :: proc(boid: ^Boid, delta: f32) {
	boid.position.x += boid.velocity.x * delta
	boid.position.y += boid.velocity.y * delta
	boid.rotation = math.atan2(boid.velocity.y, boid.velocity.x) * (180 / math.PI)
}

check_boid_collisions :: proc(boid: ^Boid) {
	target_velocity := boid.velocity

	if boid.position.x < BOID_TURN_THRESHOLD {
		target_velocity.x += BOID_TURN_STRENGTH
	} else if boid.position.x > WINDOW_WIDTH - BOID_TURN_STRENGTH {
		target_velocity.x -= BOID_TURN_STRENGTH
	}

	if boid.position.y < BOID_TURN_THRESHOLD {
		target_velocity.y += BOID_TURN_STRENGTH
	} else if boid.position.y > WINDOW_HEIGHT - BOID_TURN_STRENGTH {
		target_velocity.y -= BOID_TURN_STRENGTH
	}

	boid.velocity = linalg.lerp(boid.velocity, target_velocity, 0.3)
}
