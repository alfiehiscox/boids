package main

import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:math/rand"
import rl "vendor:raylib"

WINDOW_WIDTH :: 800
WINDOW_HEIGHT :: 600

BOID_SIZE :: 10
BOID_TURN_THRESHOLD :: 100
BOID_TURN_STRENGTH :: 100
BOID_VISION_RADIUS :: 70

Boid :: struct {
	position: rl.Vector2,
	velocity: rl.Vector2,
	rotation: f32,
	color:    rl.Color,
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
	boids[0].color = rl.RED

	for !rl.WindowShouldClose() {
		delta := rl.GetFrameTime()

		for &boid, i in boids {
			update_boid(&boid, delta)
			check_boid_collisions(&boid, i, boids[:])
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
		color = rl.WHITE,
	}
}

random_vec_2 :: proc(minx, maxx, miny, maxy: f32) -> rl.Vector2 {
	x := rand.float32_range(minx, maxx)
	y := rand.float32_range(miny, maxy)
	return {x, y}
}

draw_boid :: proc(boid: Boid) {
	if boid.color == rl.RED {
		rl.DrawCircleV(boid.position, BOID_VISION_RADIUS, rl.BLUE)
	}
	rl.DrawPoly(boid.position, 3, BOID_SIZE, boid.rotation, boid.color)
}

update_boid :: proc(boid: ^Boid, delta: f32) {
	boid.position.x += boid.velocity.x * delta
	boid.position.y += boid.velocity.y * delta
	boid.rotation = math.atan2(boid.velocity.y, boid.velocity.x) * (180 / math.PI)
}

check_boid_collisions :: proc(boid: ^Boid, i: int, boids: []Boid) {
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

	for other_boid, ix in boids {
		if ix == i {continue}
		dist := rl.Vector2Distance(boid.position, other_boid.position)
		if dist < BOID_VISION_RADIUS {
			avoid := linalg.normalize(boid.position - other_boid.position) * 20
			boid.velocity += avoid
		}
	}

	boid.velocity = linalg.lerp(boid.velocity, target_velocity, 0.3)

}
